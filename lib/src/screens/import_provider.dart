import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../service/api_service.dart';
import '../service/storage_service.dart';
import '../shared/consts.dart';
import '../shared/enum.dart';

class ImportProvider extends StatefulWidget {
  const ImportProvider({super.key});

  @override
  State<ImportProvider> createState() => _ImportProviderState();
}

class _ImportProviderState extends State<ImportProvider>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  String workspaceId = '';
  String orgId = "";
  String templateId = '';
  String category = '';
  String recentConnName = "";
  int _textIndex = 0;
  final List<String> _texts = [
    "Connecting to server...",
    "Setting up your environment. This won't take long...",
    "Almost there! Finalizing your session setup...",
    "Preparing your workspace. Thank you for your patience...",
    "Initializing your environment. We'll be ready in a moment...."
  ];

  @override
  void initState() {
    super.initState();
    getOrgAndWSIds();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _flipAnimation = Tween<double>(begin: 1, end: -1).animate(_controller);

    Timer.periodic(const Duration(seconds: 5), (timer) {
      if(mounted) {
        setState(() {
        if (_textIndex < _texts.length - 1) {
          _textIndex++;
        } else {
          timer.cancel();
        }
      });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int successfulExecutorDeployments = 0;

  getOrgAndWSIds() async {
    final response = await APIService().getOrgAndWSIds();
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final responseBody = decodedResponse;
      var workspace = responseBody['workspace'].firstWhere(
          (ws) => ws['name'] == "Agent for Restaurants - Square",
          orElse: () => null);
      if (workspace != null) {
        workspaceId = workspace['workspace_id'];
        orgId = workspace['org_id'];
        templateId = "restaurantAgentApp_square_$workspaceId";

        /// Store the workspace_id and org_id
        final storageService = StorageService();
        await storageService.createAndUpdateKeyValuePairInStorage(
            'workspace_id', workspaceId);
        await storageService.createAndUpdateKeyValuePairInStorage(
            'org_id', orgId);
        await storageService.createAndUpdateKeyValuePairInStorage(
            "template", templateId);

        checkAgent();
      } else {
        var workspace = responseBody['workspace'].firstWhere(
            (ws) => ws['name'] == "Default workspace",
            orElse: () => null);
        orgId = workspace['org_id'];

        /// Store the workspace_id and org_id
        final storageService = StorageService();
        await storageService.createAndUpdateKeyValuePairInStorage(
            'org_id', orgId);

        insertWorkSpace();
        if (kDebugMode) {
          print("Workspace not found.");
        }
      }
    }
  }

  checkAgent() async {
    final response = await APIService().checkAgent();
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final responseBody = decodedResponse;
      if (responseBody['agent'].isNotEmpty) {
        String agentId = responseBody['agent'][0]['agent_id'];
        await StorageService()
            .createAndUpdateKeyValuePairInStorage("agentId", agentId);
        final inProgress = responseBody['agent'][0]['deployment_profile']
            ['profile_info']['in_progress'];
        final isError = responseBody['agent'][0]['deployment_profile']
            ['profile_info']['is_error'];
        if (isError || inProgress) {
          goForConnection();
        } else {
          goToDashboard();
        }
      } else {
        checkProvider();
      }
    }
  }

  goToHome() {
    context.go("/${Routes.home.name}");
  }

  goToDashboard() {
    context.go("/${Routes.dashboard.name}");
  }

  insertWorkSpace() async {
    final requestBody = {
      "name": "Agent for Restaurants - Square",
      "description": "Agent description",
      "allow_multiple_agents": false
    };
    final response = await APIService().insertWorkSPace(requestBody);

    if (response.statusCode == 201) {
      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final responseBody = decodedResponse;

      workspaceId = responseBody['workspace-id'];
      templateId = "restaurantAgentApp_square_$workspaceId";

      final storageService = StorageService();
      await storageService.createAndUpdateKeyValuePairInStorage(
          'workspace_id', workspaceId);
      await storageService.createAndUpdateKeyValuePairInStorage(
          "template", templateId);
      checkProvider();
    }
  }

  getAgentTemplate(String text) async {
    List executorsToBeTransformed = [];
    final response = await APIService().getAgentTemplates();
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final List responseBody = decodedResponse;
      for (var template in responseBody) {
        String templateName = template['templateName'];
        String producer = template['serviceProvider']['producer'];
        if (templateName == "Agent for Restaurants" && producer == 'square') {
          if (text == "add") {
            var serviceProvider = template['serviceProvider'];

            /// Modify the serviceProvider
            serviceProvider['partner'] = orgId;
            serviceProvider['account'] = workspaceId;
            serviceProvider['producer'] = templateId;

            category = serviceProvider['category'];

            /// Remove the category field
            serviceProvider.remove('category');
            addProviderAPI(serviceProvider);
          } else if (text == "deploy") {
            var agentConfigs = template['agentConfigObject']['data_configs'][0]
                ['data_sources'][0]['configs'];

            for (var executor in agentConfigs) {
              executor['id'] = 0;
              executor['account_id'] = 'app-haiva';
              executor['partner'] = 'app-haiva';
              executor['service_provider'] = templateId;
              recentConnName = "${DateTime.now().millisecondsSinceEpoch}";
              final payload = {
                "action": 'deploy',
                "apiExecutor": executor,
                "deploy_api": true,
                "isAvailable": true,
                "override_api": false,
                "replaceApiExecutor": false,
                "session": 'session',
                "timestamp": recentConnName,
              };

              executorsToBeTransformed.add(payload);
            }
            await sendExecutorsInChunks(executorsToBeTransformed, 10);
          }
        }
      }
    }
  }

  sendExecutorsInChunks(List executors, int chunkSize) async {
    /// Calculate the number of chunks we need to send
    int totalExecutors = executors.length;
    int numberOfChunks = (totalExecutors / chunkSize).ceil();

    /// Send chunks in a loop
    for (int i = 0; i < numberOfChunks; i++) {
      /// Get the chunk
      int start = i * chunkSize;
      int end = (start + chunkSize) > totalExecutors
          ? totalExecutors
          : (start + chunkSize);
      List chunk = executors.sublist(start, end);
      final payloadToAPI = {
        "application": null,
        "categories": null,
        "dataMigrationPlans": null,
        "entityDeploymentPlans": null,
        "requestModel": {
          "sourceDatabaseName": null,
          "types": null,
          "databaseObjects": null,
          "transformOption": 'executoronly',
          "targetDatabaseName": null,
          "useReferentialKey": false,
          "referentialKeyOption": null,
          "cascadeOnDelete": false,
          "cascadeOnUpdate": false,
        },
        "executorModelDeploymentPlans": chunk,
      };
      await executorDeploymentAPI(payloadToAPI, numberOfChunks);
    }
  }

  executorDeploymentAPI(requestBody, numberOfChunks) async {
    final response = await APIService().executorDeployment(requestBody);

    print("exe ${response.body}");
    if (response.statusCode == 200) {
      successfulExecutorDeployments++;
      if (successfulExecutorDeployments == numberOfChunks) {
        await goForConnection();
      }
    }
  }

  addProviderAPI(providerPayload) async {
    final response = await APIService().addProvider(providerPayload);
    print("add ${response.body}");
    if (response.statusCode == 201) {
      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final upId = decodedResponse["upsertedId"];
      getProviderIDBasedOnCategory(upId);
    }
  }

  getProviderIDBasedOnCategory(upID) async {
    final response = await APIService().getProviderID(category);
    print("get ${response.body}");
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final List responseBody = decodedResponse;
      List serviceProvider = responseBody[0]["serviceProvider"];
      final id = "responseBody[0][id]";
      serviceProvider.add(upID);
      patchAPI(serviceProvider, id);
    }
  }

  patchAPI(serviceProvider, id) async {
    final requestBody = {"serviceProvider": serviceProvider};
    final response = await APIService().patchAPI(requestBody, id);
    print("pat ${response.body}");
    if (response.statusCode == 200) {
      getAgentTemplate("deploy");
    }
  }

  checkProvider() async {
    final response = await APIService().checkProvider();
    final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
    final List responseBody = decodedResponse;
    if (responseBody.isEmpty) {
      getAgentTemplate("add");
    } else if (responseBody.isNotEmpty) {
      goForConnection();
    } else {
      callSnackBar(response, "Err");
    }
  }

  callSnackBar(response, text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: const TextStyle(color: whiteColor),
        ),
        backgroundColor:
            (response.statusCode == 200 || response.statusCode == 200)
                ? successColor
                : errorColor,
      ),
    );
  }

  goForConnection() {
    context.go('/${Routes.connect.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform(
              transform: Matrix4.rotationY(_flipAnimation.value * 3.14159),
              alignment: Alignment.center,
              child: child,
            );
          },
          child: Image.asset('assets/images/haiva.png', width: 88, height: 88),
        ),
        const SizedBox(
          height: 16,
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 5000),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _texts[_textIndex],
              textAlign: TextAlign.center,
              key: ValueKey<int>(_textIndex),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    )));
  }
}
