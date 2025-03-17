import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../models/agent.dart';
import '../shared/consts.dart';

class AgentService {
  final String baseUrl = 'https://app-haiva.gateway.apiplatform.io/v1';
  final String baseUrl2 = 'https://app-haiva.gateway.apiplatform.io/v2';

  static  String? workspaceId = Constants.workspaceId;
  static  String? token = Constants.accessToken;

  Future<Agent> getAgentById(String agentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/getHaivaAgentConfig?agent-id=$agentId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      Constants.orgId = data['org_id'];
      print("orgid = ${Constants.orgId}");
      return Agent.fromJson(data);
    } else {
      print('Error status code: ${response.statusCode}');
      print('Error response body: ${response.body}');
      throw Exception('Failed to load agent with ID: $agentId');
    }
  }

  Future<List<Agent>> getAgents() async {
    final response = await http.get(
      Uri.parse('$baseUrl/getZohoAgents?workspaceId=${Constants.workspaceId}'),
      headers: {
        'Authorization': '$token',
        'Content-Type': 'application/json',
      },
    );
    print ('Agents+++++++ ${response}');
    print("workspace id ${workspaceId}");
    print("status code ${response.statusCode}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("response body+_+_+_ ${response.body}");
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['agents'] != null && data['agents'] is List) {
        final List<dynamic> agentsJson = data['agents'];

        if (agentsJson.isNotEmpty) {
          Constants.orgId = agentsJson[0]['org_id'] ?? '';
          print("org id: ${Constants.orgId}");
        }

        return agentsJson.map((json) => Agent.fromJson(json)).toList();
      } else {
        print('No agents found or invalid data structure');
        return [];
      }
    }
    else {
      print('Error status code: ${response.statusCode}');
      print('Error response body: ${response.body}');
      throw Exception('Failed to load agents');
    }
  }

  Future<String> uploadImage(File image) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://app-haiva.gateway.apiplatform.io/v1/insertAvatar'),
    )
      ..headers['Authorization'] = 'Bearer ${Constants.accessToken}' // Add the authorization header
      ..fields['workspaceId'] = Constants.workspaceId! // Add the workspaceId field
      ..files.add(
        http.MultipartFile.fromBytes(
          'avatarFile',
          await image.readAsBytes(),
          filename: image.path.split('/').last,
          contentType: MediaType.parse(lookupMimeType(image.path) ?? 'application/octet-stream'),
        ),
      );

    final response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = await response.stream.bytesToString();
      final Map<String, dynamic> data = json.decode(responseData);
      if (data['Url'] != null && data['Url'] is String) {
        print('Url: ${data['Url']}');
        return data['Url'] as String;
      } else {
        throw Exception('Invalid response format: Url is missing or not a string');
      }
    } else {
      final responseData = await response.stream.bytesToString();
      final errorMessage = json.decode(responseData)['message'] ?? 'Failed to upload image';
      throw Exception(errorMessage);
    }
  }
  Future<void> modifyZohoAgent(String agentId, String connectorName) async {
    try {
      final url = '$baseUrl/modifyZohoAgent?agentId=$agentId&connectorName=$connectorName';
      print("Calling URL: $url");
      print("AgentId: $agentId");
      print("ConnectorName: $connectorName");
      print("token : $token");
      final response = await http.patch(
          Uri.parse(url),
          headers: {
            'Authorization': '$token',
            'Content-Type': 'application/json',
          },
          body: json.encode({})
      );

      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Agent modified successfully");
      } else {
        throw HttpException('Failed to modify agent: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in modifyZohoAgent: $e');
      throw Exception('Failed to modify agent: $e');
    }
  }
  Future<String> createAgent(Agent agent, String connectorName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/deployZohoAgent?workspaceId=$workspaceId&connectorName=${connectorName}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': agent.name,
        'description': agent.description,
        'type': 'Sales',
        'image': agent.agentConfigs?.image,
        'display_name': agent.agentConfigs?.displayName,
        'colors': agent.agentConfigs?.colors ?? {},
      }),
    );


    if (response.statusCode == 200 || response.statusCode == 201) {

      final Map<String, dynamic> data = json.decode(response.body);
      return data['agentId'];
    } else {
      print('Error status code: ${response.statusCode}');
      print('Error response body: ${response.body}');
      throw Exception('Failed to create agent');
    }
  }

  // Future<void> updateAgent(Agent agent) async {
  //   final url = Uri.parse('$baseUrl/saveHaivaAgentConfig?agent-id=${agent.id}');
  //
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       'Authorization': 'Bearer $token',
  //       'Content-Type': 'application/json',
  //     },
  //     body: json.encode({
  //       // 'name': agent.name,
  //       // 'description': agent.description,
  //       // 'type': agent.type,
  //       // 'agent_id': agent.id,
  //       'agent_configs': {
  //         'image': agent.agentConfigs?.image,
  //         'display_name': agent.agentConfigs?.displayName,
  //         'is_speech2text': agent.agentConfigs?.isSpeech2text,
  //         'languages': agent.agentConfigs?.languages,
  //         'colors': agent.agentConfigs?.colors ?? {},
  //         'description': agent.agentConfigs?.description,
  //         'voice_code': agent.agentConfigs?.voice_code,
  //         'is_api': true,
  //       },
  //       // 'is_deployed': agent.isDeployed,
  //       // 'is_active': agent.isActive,
  //       // 'updated_at': DateTime.now().toUtc().toIso8601String(),
  //       //'workspace_id': agent.workspaceId,
  //       //  'org_id': agent.orgId,
  //     }),
  //   );
  //   print("response update agent body = ${response.body}");
  //   print("response update agent = ${response.statusCode}");
  //   if (response.statusCode == 200  || response.statusCode == 201) {
  //     print('Agent updated successfully');
  //   } else {
  //     // Handle error
  //     throw Exception('Failed to update agent${response.body}');
  //   }
  // }

  Future<void> deleteAgent(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/deleteHaivaAgent?agentId=$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Successfully deleted
      print('Agent deleted successfully');
    } else {
      // Handle error
      throw Exception('Failed to delete agent');
    }
  }

  Future<dynamic> getAgentDetailsById(String agentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/getHaivaAgentConfig?agent-id=$agentId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      Constants.orgId = data['org_id'];
      print("orgid = ${Constants.orgId}");
      print('33333${data}');
      return data;
    } else {
      print('Error status code: ${response.statusCode}');
      print('Error response body: ${response.body}');
      throw Exception('Failed to load agent with ID: $agentId');
    }
  }

  Future<void> updateAgentDataConfig(String agent_id, dynamic data_configs) async {
    final url = Uri.parse('$baseUrl/saveHaivaAgentConfig?agent-id=${agent_id}');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'data_configs': data_configs
      }),
    );
    print("response update agent body = ${response.body}");
    print("response update agent = ${response.statusCode}");
    if (response.statusCode == 200  || response.statusCode == 201) {
      print('Agent updated successfully');
    } else {
      // Handle error
      throw Exception('Failed to update agent${response.body}');
    }
  }

  Future<http.Response> publishAgent(String agentID) async {
    final uri = Uri.parse(
        '$baseUrl/publishAgent?agentId=$agentID');
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: '{}',
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> unPublishAgent(String agentID) async {
    final uri = Uri.parse(
        '$baseUrl/unpublishAgent?agentId=$agentID');
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: '{}',
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  Future<http.Response> featureAgent(String agentID) async {
    final uri = Uri.parse(
        '$baseUrl/featureAgent?agentId=$agentID');
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: '{}',
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> DefeatureAgent(String agentID) async {
    final uri = Uri.parse(
        '$baseUrl/deFeatureAgent?agentId=$agentID');
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: '{}',
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  Future<http.Response> deployFilesAgent(String agentId, dynamic file_configs) async {
    print('------${file_configs}');
    final response = await http.post(
      Uri.parse('$baseUrl2/deployZohoAgent?workspaceId=$workspaceId&agentId=${agentId}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      // body: json.encode( {
      //     'agent_configs': {
      //   'name': agent.name,
      //   'description': agent.description,
      //   'type': 'Sales',
      //   'image': agent.agentConfigs?.image,
      //   'display_name': agent.agentConfigs?.displayName,
      //   'colors': agent.agentConfigs?.colors ?? {},
      // },
      //   'file_configs': file_configs,
      // }),
      body: json.encode(file_configs),
    );


    if (response.statusCode == 200 || response.statusCode == 201) {
      print('------${response.body}');
      final Map<String, dynamic> data = json.decode(response.body);
      return response;
    } else {
      print('Error status code: ${response.statusCode}');
      print('Error response body: ${response.body}');
      throw Exception('Failed to create agent');
    }
  }

}
