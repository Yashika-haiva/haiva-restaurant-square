import 'dart:convert';
import 'dart:io';


import '../service/storage_service.dart';
import 'package:http/http.dart' as http;

class APIService {
  Map<String, String> headersWithoutAuth() => {
        'Content-Type': 'application/json',
      };

  Future<Map<String, String>> headersWithAuthForConnection() async => {
        'Content-Type': 'application/json',
        'Authorization': await StorageService().token ?? "",
        'Apikey': 'H7pxIwTlky5F1KQ4RMlgTRTfktmqMOnX',
        'pkey': '3fd4326bc440f8f83fe9055a0d97dfde',
      };

  Future<Map<String, String>> headersWithAuthForCheckConnection() async => {
        'Content-Type': 'application/json',
        'Authorization': await StorageService().token ?? "",
        'Apikey': '6aRV9kJkeD6tiCqtMMINA0ycDOLlSeE5',
        'pkey': '3fd99a6cdda045e23fb310d0ba17f868',
      };

  Future<Map<String, String>> headersWithAuth() async => {
        'Content-Type': 'application/json',
        'Authorization': await StorageService().token ?? "",
      };

  Future<Map<String, String>> headersWithAuthImage() async => {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': await StorageService().token ?? "",
  };


  Future<http.Response> getOrgAndWSIds() async => await http.get(
        Uri.parse(
          "https://app-haiva.gateway.apiplatform.io/v1/getAllWorkspacesByOrg",
        ),
        headers: await headersWithAuthForConnection(),
      );

  Future<http.Response> getConversationCount(wsId, agentId) async =>
      await http.get(
        Uri.parse(
          "https://app-haiva.gateway.apiplatform.io/v1/getConversationCounts?workspaceId=$wsId&agentId=$agentId",
        ),
        headers: await headersWithAuthForConnection(),
      );

  Future<http.Response> getTransCount(wsId, agentId) async => await http.get(
        Uri.parse(
          "https://app-haiva.gateway.apiplatform.io/v1/getTranscriptCounts?workspaceId=$wsId&agentId=$agentId",
        ),
        headers: await headersWithAuthForConnection(),
      );

  Future<http.Response> executorDeployment(requestBody) async =>
      await http.post(
        Uri.parse(
          "https://services.apiplatform.io/v1/admin/app-haiva/app-haiva/createfromdeploymentplan",
        ),
        headers: await headersWithAuthForCheckConnection(),
        body: jsonEncode(requestBody),
      );

  Future<http.Response> addProvider(requestBody) async => await http.post(
        Uri.parse(
          "https://services.apiplatform.io/v1/data/services/services/apiproducers",
        ),
        headers: await headersWithAuthForCheckConnection(),
        body: jsonEncode(requestBody),
      );

  Future<http.Response> getAgentDetails(agentId) async => await http.get(
        Uri.parse(
          "https://app-haiva.gateway.apiplatform.io/v1/getHaivaAgentConfig?agent-id=$agentId",
        ),
      );

  Future<http.Response> getBalance() async => await http.get(
      Uri.parse(
        "https://app-haiva.gateway.apiplatform.io/v1/getAvailableBalance",
      ),
      headers: await headersWithAuth());

  Future<http.Response> patchAPI(requestBody) async => await http.patch(
        Uri.parse(
          "https://services.apiplatform.io/v1/data/services/services/producerCategories/5",
        ),
        headers: await headersWithAuthForCheckConnection(),
        body: jsonEncode(requestBody),
      );

  Future<http.Response> getProviderID(category) async => await http.get(
        Uri.parse(
          "https://services.apiplatform.io/v1/data/services/services/producerCategories?name=$category&dbref=false",
        ),
        headers: await headersWithAuthForCheckConnection(),
      );

  Future<http.Response> onDeployInitial() async {
    String template = await StorageService().getValueFromStorage("template");
    return await http.get(
      Uri.parse(
        "https://services.apiplatform.io/v1/api/app-haiva/app-haiva/producer/executors?producer=$template",
      ),
      headers: await headersWithAuthForConnection(),
    );
  }

  Future<http.Response> getConnection() async => await http.get(
        Uri.parse(
          "https://app-haiva.gateway.apiplatform.io/v1/providerAuthAttributes?providerName=square&authModel.authType=OAuth%202.0",
        ),
        headers: await headersWithAuthForConnection(),
      );

  Future<http.Response> checkSquareConnection() async {
    String template = await StorageService().getValueFromStorage("template");
    String wsId = await StorageService().getValueFromStorage("workspace_id");
    return await http.get(
      Uri.parse(
        "https://app-haiva.gateway.apiplatform.io/v1/getAllApiConnectorInfo?workspaceId=$wsId&producer=$template",
      ),
      headers: await headersWithAuthForConnection(),
    );
  }

  Future<http.Response> insertWorkSPace(requestBody) async => await http.post(
        Uri.parse(
          "https://app-haiva.gateway.apiplatform.io/v1/insertWorkspaceInfo",
        ),
        headers: await headersWithAuthForConnection(),
        body: jsonEncode(requestBody),
      );

  Future<http.Response> checkAgent() async {
    String wsId = await StorageService().getValueFromStorage("workspace_id");
    return await http.get(
      Uri.parse(
        "https://app-haiva.gateway.apiplatform.io/v1/getAllHaivaAgentsByWs?workspace-id=$wsId",
      ),
      headers: await headersWithAuthForConnection(),
    );
  }

  Future<http.Response> getAvailableHaivaNumbers() async {
    String wsId = await StorageService().getValueFromStorage("workspace_id");
    return await http.get(
      Uri.parse(
        "https://app-haiva.gateway.apiplatform.io/v1/getPhoneNumbers?workspaceId=$wsId",
      ),
      headers: await headersWithAuth(),
    );
  }

  Future<http.Response> checkCredits() async => await http.get(
        Uri.parse(
          "https://app-haiva.gateway.apiplatform.io/v1/checkoutCredits?item=number",
        ),
        headers: await headersWithAuth(),
      );

  Future<http.Response> getAgentTemplates() async => await http.get(
        Uri.parse(
            "https://app-haiva.gateway.apiplatform.io/v1/getAgentTemplates"),
        headers: await headersWithAuth(),
      );

  Future<http.Response> getDeployStatus(agentId) async => await http.get(
        Uri.parse(
            "https://app-haiva.gateway.apiplatform.io/v1/getHaivaAgentConfig?agent-id=$agentId"),
        headers: await headersWithAuth(),
      );

  Future<http.Response> addCredits(String amount) async => await http.post(
        Uri.parse(
          "https://services.haiva.ai/v2/billing/create-checkout-session?credits=$amount",
        ),
        headers: await headersWithAuth(),
      );

  Future<http.Response> insertAvatar(String workspaceId, File imageFile) async {
    var uri = Uri.parse("https://app-haiva.gateway.apiplatform.io/v1/insertAvatar");

    // Create a multipart request
    var request = http.MultipartRequest('POST', uri);

    // Add authorization header
    request.headers['Authorization'] = await StorageService().token ?? "";

    // Add the text field
    request.fields['workspaceId'] = workspaceId;

    // Add the file
    var stream = http.ByteStream(imageFile.openRead());
    var length = await imageFile.length();
    var multipartFile = http.MultipartFile(
        'avatarFile',
        stream,
        length,
        filename: imageFile.path.split('/').last
    );
    request.files.add(multipartFile);

    // Send the request
    var response = await request.send();

    // Convert to Response object
    return http.Response.fromStream(response);
  }

  Future<http.Response> deployAgent(requestBody, wsId) async => await http.post(
        Uri.parse(
          "https://app-haiva.gateway.apiplatform.io/v1/deployTemplateAgent?workspaceId=$wsId",
        ),
        headers: await headersWithAuth(),
        body: jsonEncode(requestBody),
      );

  Future<http.Response> reDeployAgent(requestBody, wsId, agentId) async =>
      await http.post(
        Uri.parse(
          "https://app-haiva.gateway.apiplatform.io/v1/deployHaivaAgent?workspaceId=$wsId&agentId=$agentId",
        ),
        headers: await headersWithAuthForConnection(),
        body: jsonEncode(requestBody),
      );

  Future<http.Response> linkNumberToAgent(requestBody) async =>
      await http.patch(
        Uri.parse(
          "https://app-haiva.gateway.apiplatform.io/v1/patchPhoneNumbers",
        ),
        headers: await headersWithAuth(),
        body: jsonEncode(requestBody),
      );

  Future<http.Response> assignTelephony(requestBody, bool enable) async =>
      await http.post(
        Uri.parse(
          enable
              ? "https://services.haiva.ai/v2/telephony/assign-webhook"
              : "https://services.haiva.ai/v1/telephony/assign-webhook",
        ),
        headers: await headersWithAuth(),
        body: jsonEncode(requestBody),
      );

  Future<http.Response> buyHaivaNumbers(requestBody) async {
    String wsId = await StorageService().getValueFromStorage("workspace_id");
    return await http.post(
      Uri.parse(
        "https://services.haiva.ai/v1/telephony/buy-phone-number?workspaceId=$wsId",
      ),
      headers: await headersWithAuth(),
      body: jsonEncode(requestBody),
    );
  }

  Future<http.Response> checkTwilioConnection(
    String authToken,
    String sid,
  ) async =>
      http.get(
        Uri.parse(
          "https://services-stage.haiva.ai/v1/telephony/verify-account?provider=twilio&auth_token=$authToken&account_sid=$sid",
        ),
        headers: headersWithoutAuth(),
      );

  Future<http.Response> getTwilioNumbers(
    String authToken,
    String sid,
  ) async =>
      http.get(
        Uri.parse(
          "https://services-stage.haiva.ai/v1/telephony/phone-numbers?provider=twilio&auth_token=$authToken&account_sid=$sid",
        ),
        headers: headersWithoutAuth(),
      );

  Future<http.Response> getOrSearchAvailableNumbersToBuy(
    String provider,
    String country,
    String searchTerm,
  ) async =>
      http.get(
        Uri.parse(
          "https://services.haiva.ai/v1/telephony/search-available-numbers?provider=$provider&country=$country&search_term=$searchTerm",
        ),
        headers: await headersWithAuthForConnection(),
      );

  Future<http.Response> getVoices(bool callLanguages) async => http.get(
        Uri.parse(
          callLanguages
              ? "https://services-stage.haiva.ai/v1/speech/voices"
              : "https://services-stage.haiva.ai/v1/speech/voices?filter=multilingual",
        ),
        headers: await headersWithAuthForConnection(),
      );

  Future<http.Response> checkProvider() async {
    String template = await StorageService().getValueFromStorage("template");
    return http.get(
      Uri.parse(
        "https://services.apiplatform.io/v1/data/services/services/apiproducers?producer=$template",
      ),
      headers: await headersWithAuthForCheckConnection(),
    );
  }

  Future<http.Response> convertTextToVoice(requestBody) async => http.post(
        Uri.parse("https://services-stage.haiva.ai/v1/speech/text-to-speech"),
        headers: headersWithoutAuth(),
        body: jsonEncode(requestBody),
      );
}
