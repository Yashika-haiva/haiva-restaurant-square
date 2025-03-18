import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../service/api_service.dart';
import '../service/storage_service.dart';
import '../shared/consts.dart';
import '../shared/enum.dart';

class ReDeployAgent extends StatefulWidget {
  final dynamic agentData;
  final dynamic agentId;

  const ReDeployAgent({super.key, this.agentData, this.agentId});

  @override
  State<ReDeployAgent> createState() => _ReDeployAgentState();
}

class _ReDeployAgentState extends State<ReDeployAgent> {
  reDeployAgent() async {
    String name = await StorageService().getValueFromStorage("display_name") ??
        widget.agentData['agent_configs']['display_name'];
    String description =
        await StorageService().getValueFromStorage("description") ??
            widget.agentData['agent_configs']['description'];
    String imageUrl =
        await StorageService().getValueFromStorage("image") ??
            widget.agentData['agent_configs']['image'];
    widget.agentData['agent_configs']['display_name'] = name;
    widget.agentData['agent_configs']['description'] = description;
    widget.agentData['agent_configs']['image'] = imageUrl;
    String wsId = await StorageService().getValueFromStorage("workspace_id");
    String agentId = widget.agentId;
    final response =
        await APIService().reDeployAgent(widget.agentData, wsId, agentId);
    print('redeployAgent ${response.body}');
    print('redeployAgent ${response.statusCode}');
    if (response.statusCode == 200) {
      bool isSidThere = widget.agentData['agent_configs']['telephony_configs']
              ['account_sid'] ==
          '';
      bool isATokenThere = widget.agentData['agent_configs']
              ['telephony_configs']['auth_token'] ==
          '';
      print(
          widget.agentData['agent_configs']['telephony_configs']['auth_token']);
      if (isSidThere && isATokenThere) {
        linkPhoneNumberOnRedeploy(agentId);
        callSnackBar(response, "Deployment started!");
      } else {
        assignTelephonyOnRedeploy(agentId);
      }
    } else {
      callSnackBar(response, "Deployment aborted!");
      context.pop();
    }
  }

  linkPhoneNumberOnRedeploy(String agentId) async {
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
        assignTelephonyOnRedeploy(agentId);
      } else {
        startDeployStatusCheckOnRedeploy(agentId);
      }
    }
  }

  void startDeployStatusCheckOnRedeploy(String agentId) {
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

  assignTelephonyOnRedeploy(String agentId) async {
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
      startDeployStatusCheckOnRedeploy(agentId);
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
    super.initState();
    reDeployAgent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: LoadingAnimationWidget.beat(color: greenColor, size: 50)));
  }
}
