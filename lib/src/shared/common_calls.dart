// import 'dart:convert';
//
// import '../service/api_service.dart';
//
// getAgentTemplate() async {
//   final response = await APIService().getAgentTemplates();
//   print("getAgent${response.body}");
//   if (response.statusCode == 200) {
//     final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
//     final List responseBody = decodedResponse;
//     for (var template in responseBody) {
//       String templateName = template['templateName'];
//       String producer = template['serviceProvider']['producer'];
//       if (templateName == "Agent for Restaurants" && producer == 'square') {
//         var serviceProvider = template['serviceProvider'];
//
//         /// Modify the serviceProvider
//         serviceProvider['partner'] = "org-m0kjudb0-mrrcx";
//         serviceProvider['account'] = "ws-m0kjudb0-bqqas6qy";
//         serviceProvider['producer'] = "restaurantAgentApp_square_ws-m0kjudb0-bqqas6qy";
//
//         /// Remove the category field
//         serviceProvider.remove('category');
//         addProviderAPI(serviceProvider);
//       }
//     }
//   }
// }