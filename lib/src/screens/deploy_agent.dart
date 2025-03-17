import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../service/api_service.dart';
import '../service/storage_service.dart';
import '../shared/consts.dart';
import '../shared/enum.dart';

class DeployAgent extends StatefulWidget {
  final dynamic agentData;
  final dynamic deployData;

  const DeployAgent({super.key, this.agentData, this.deployData});

  @override
  State<DeployAgent> createState() => _DeployAgentState();
}

class _DeployAgentState extends State<DeployAgent> {
  deployAgent() async {
    String recentConnName =
        await StorageService().getValueFromStorage("recentConnName");
    String orgID = await StorageService().getValueFromStorage("org_id");
    String wsId = await StorageService().getValueFromStorage("workspace_id");

    ///"Agent for Restaurants" is from import provider.dart where we check templateName
    widget.agentData['name'] = 'Agent for Restaurants';
    widget.agentData['agent_configs']['display_name'] = 'Agent for Restaurants';
    final parsedData = widget.deployData[0];
    final allExecutors = [];
    for (var category in parsedData['categories']) {
      allExecutors.addAll(category['executors']);
    }
    print(allExecutors.length);
    // widget.deployData[0]['categories'][0]['executors'];
    final modifiedAuthModel = {
      'authType': 'connector',
      'authAttributes': {
        'type': 'oauth_2_0',
        'name': recentConnName,
        'producer': "restaurantAgentApp_square_$wsId",
      },
    };
    final configs =
        widget.agentData['data_configs'][0]['data_sources'][0]['configs'];
    for (var config in configs) {
      if (config['is_data_provider'] ?? false) {
        final matchingExecutor = allExecutors.firstWhere(
          (executor) =>
              executor['executor_name'] == config['executor_name'] &&
              executor['executor_method_type'] ==
                  config['executor_method_type'] &&
              executor['executor_version'] == config['executor_version'],
          orElse: () => null, // If no match found, return null
        );
        if (matchingExecutor != null) {
          matchingExecutor['is_data_provider'] = true;
          if (kDebugMode) {
            print("matching $matchingExecutor");
          }
        }
      }
    }

    for (var config in allExecutors) {
      config["authModel"] = modifiedAuthModel;
      config["connectorName"] = recentConnName;
      config["account_id"] = wsId;
      config["partner"] = orgID;
    }

    for (var config in widget.agentData['data_configs']) {
      config['category'] = 'Untitled';
      for (var dataSource in config['data_sources']) {
        dataSource['configs'] = allExecutors;
      }
    }

    final response = await APIService().deployAgent(widget.agentData, wsId);
    print('deployAgent ${response.body}');
    print('deployAgent ${response.statusCode}');
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final responseBody = decodedResponse;
      String agentId = responseBody['agentId'];
      bool isSidThere = widget.agentData['agent_configs']['telephony_configs']
              ['account_sid'] ==
          '';
      bool isATokenThere = widget.agentData['agent_configs']
              ['telephony_configs']['auth_token'] ==
          '';
      print(
          widget.agentData['agent_configs']['telephony_configs']['auth_token']);
      if (isSidThere && isATokenThere) {
        linkPhoneNumber(agentId);
        callSnackBar(response, "Deployment started!");
      } else {
        assignTelephony(agentId);
      }
    } else {
      callSnackBar(response, "Deployment aborted!");
      context.pop();
    }
  }

  linkPhoneNumber(String agentId) async {
    final requestBody = {
      "agentId": agentId,
      "isLinked": true,
      "phoneNumber": widget.agentData['agent_configs']['telephony_configs']
          ['phone_number']
    };
    print(requestBody);
    final response = await APIService().linkNumberToAgent(requestBody);
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      bool isPhone = widget.agentData['agent_configs']['telephony_configs']
              ['phone_number'] !=
          null;
      bool isSid = widget.agentData['agent_configs']['telephony_configs']
                  ['account_sid'] !=
              null &&
          widget.agentData['agent_configs']['telephony_configs']
                  ['account_sid'] !=
              '';
      bool isAToken = widget.agentData['agent_configs']['telephony_configs']
                  ['auth_token'] !=
              null &&
          widget.agentData['agent_configs']['telephony_configs']
                  ['auth_token'] !=
              '';
      print('oay $isAToken $isSid $isPhone');
      if (isAToken && isSid && isPhone) {
        assignTelephony(agentId);
      } else {
        startDeployStatusCheck(agentId);
      }
    }
  }

  void startDeployStatusCheck(String agentId) {
    Timer? timer;
    void checkDeployStatus() async {
      final response = await APIService().getDeployStatus(agentId);
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final responseBody = decodedResponse;
        final inProgress =
            responseBody['deployment_profile']['profile_info']['in_progress'];
        final isError =
            responseBody['deployment_profile']['profile_info']['is_error'];
        if (!isError && !inProgress) {
          timer?.cancel();
          await StorageService()
              .createAndUpdateKeyValuePairInStorage("agentId", agentId);
          goToDashBoard();
        } else if (isError) {
          timer?.cancel();
          callSnackBar(response, "Deployment aborted!");
          context.pop();
        } else if (inProgress) {
          timer = Timer.periodic(const Duration(seconds: 5), (timer) {
            checkDeployStatus();
          });
        }
      }
    }

    checkDeployStatus();
  }

  goToDashBoard() {
    context.go("/${Routes.dashboard.name}");
  }

  assignTelephony(String agentId) async {
    bool isActiveListen = widget.agentData['agent_configs']['telephony_configs']
            ['enable_active_listening'] ==
        true;

    final requestBody = {
      "number": widget.agentData['agent_configs']['telephony_configs']
          ['phone_number'],
      "sid": widget.agentData['agent_configs']['telephony_configs']
          ['account_sid'],
      "token": widget.agentData['agent_configs']['telephony_configs']
          ['auth_token'],
    };

    print(requestBody);
    final response =
        await APIService().assignTelephony(requestBody, isActiveListen);
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      startDeployStatusCheck(agentId);
    }
  }

  callSnackBar(response, text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(
            '$text',
            style: TextStyle(color: whiteColor),
          ),
        ),
        backgroundColor:
            (response.statusCode == 201 || response.statusCode == 200) &&
                    text != "Deployment aborted!"
                ? successColor
                : errorColor,
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    deployAgent();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: LoadingAnimationWidget.beat(color: primaryColor, size: 50)));
  }
}
