import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:haivazoho/src/service/balance.dart';
import '../screens/side_nav_bar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../service/api_service.dart';
import '../service/get_balance.dart';
import '../service/mongoDb.dart';
import '../service/storage_service.dart';
import '../shared/consts.dart';
import '../shared/enum.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var size, height, width;
  int conversationCount = 0;
  int transcriptsCount = 0;
  bool isLoading = false;
  String formattedBalance = '';
  String imageUrl = "";
  String displayName = "";
  String description = "";
  bool isTextChat = false;
  bool isCall = false;
  bool isVoiceChat = false;

  @override
  void initState() {
    super.initState();
    getConversationAndTranscriptsCount();
  }

  getConversationAndTranscriptsCount() async {
    setState(() {
      isLoading = true;
    });

    try {
      String wsId = await StorageService().getValueFromStorage("workspace_id");
      String agentId = await StorageService().getValueFromStorage("agentId");
      final response = await APIService().getConversationCount(wsId, agentId);
      print(response.body);
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final responseBody = decodedResponse;
        setState(() {
          conversationCount = responseBody['countByWsAndAgents']
              ['Agent for Restaurants - Square']['Agent for Restaurants'];
        });
      }

      final response1 = await APIService().getTransCount(wsId, agentId);
      print(response1.body);
      if (response1.statusCode == 200) {
        final decodedResponse1 = jsonDecode(utf8.decode(response1.bodyBytes));
        final responseBody1 = decodedResponse1;
        print(response.body);
        setState(() {
          transcriptsCount = responseBody1['countByWsAndAgents']
              ['Agent for Restaurants - Square']['Agent for Restaurants'];
        });
      }
      final responseForAgent = await APIService().getAgentDetails(agentId);
      print(responseForAgent.body);
      if (responseForAgent.statusCode == 200) {
        final decodedResponseForAgent =
            jsonDecode(utf8.decode(responseForAgent.bodyBytes));
        final responseBodyForAgent = decodedResponseForAgent;
        setState(() {
          imageUrl = responseBodyForAgent['agent_configs']['image'];
          displayName = responseBodyForAgent['agent_configs']['display_name'];
          description = responseBodyForAgent['agent_configs']['description'];
          isCall = responseBodyForAgent['agent_configs']['telephony_configs']
              ['enable_call'];
          isTextChat = responseBodyForAgent['agent_configs']
              ['text_chat_configs']['enable_text_chat'];
          isVoiceChat = responseBodyForAgent['agent_configs']
              ['voice_chat_configs']['enable_voice_chat'];
        });
      }

      final responseForBalance = await APIService().getBalance();
      print(responseForBalance.body);
      if (responseForBalance.statusCode == 200) {
        final decodedResponseForBalance =
            jsonDecode(utf8.decode(responseForBalance.bodyBytes));
        final responseBodyForAgent = decodedResponseForBalance;
        setState(() {
          final balance = responseBodyForAgent['availableBalance'] ?? 0.00;
          formattedBalance = balance.toStringAsFixed(2);
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return Scaffold(
      drawer: const SideNavBar(),
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: isLoading
          ? Center(
              child: LoadingAnimationWidget.beat(
                  color: primaryLightColor, size: 100))
          :
          // RefreshIndicator(
          //         onRefresh: () async {
          //           await getConversationAndTranscriptsCount();
          //         },
          //         child:
          SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    "Agent Overview",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildAgentCard(),
                  // const SizedBox(height: 16),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 16),
                  //   child: Center(
                  //     child: ElevatedButton(
                  //         style: ElevatedButton.styleFrom(
                  //           minimumSize: const Size(double.infinity, 40),
                  //         ),
                  //         onPressed: () {
                  //           context.push('/${Routes.editProfile.name}');
                  //         },
                  //         child: const Text(
                  //           "Edit Agent",
                  //         )),
                  //   ),
                  // ),
                  const SizedBox(height: 24),
                  Text(
                    "Analytics",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildAnalyticsCards(),
                  // const SizedBox(height: 24),
                  // _buildRecentActivitySection(),
                  // CreditsBalanceWidget(),
                ],
              ),
            ),
      // ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: IconButton(
              onPressed: () async {
                String numberToCall =
                    await StorageService().getValueFromStorage("phone_number");
                _makePhoneCall(numberToCall);
                // StorageService().deleteAllValuesFromStorage();
                // print(
                //     await StorageService().getValueFromStorage("workspace_id"));
              },
              icon: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.call,
                  size: 32,
                  color: whiteColor,
                ),
              )),
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUrl = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    final Uri launchingUrl = Uri.parse(phoneUrl.toString());
    if (!await launchUrl(launchingUrl)) {
      throw Exception('Could not launch ${phoneUrl.toString()}');
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: primaryColor,
      title: const Text('Dashboard',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet,
                    color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  isLoading? "\$0.00":"\$$formattedBalance",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgentCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(imageUrl),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Smart Integration Agent",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFeatureChip(Icons.chat, "Chat", isTextChat),
                    const SizedBox(width: 8),
                    _buildFeatureChip(Icons.mic, "Voice", isVoiceChat),
                    const SizedBox(width: 8),
                    _buildFeatureChip(Icons.call, "Call", isCall),
                  ],
                ),
              ],
            ),
            Positioned(
                top: -8,
                left: width - 124,
                child: IconButton(
                    onPressed: () {
                      context.push('/${Routes.editProfile.name}');
                    },
                    icon: const Icon(
                      Icons.edit,
                      color: primaryColor,
                      size: 26,
                    ))),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label, bool enable) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: enable
            ? bubbleGreen.withOpacity(0.1)
            : primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: enable ? bubbleGreen : primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: enable ? bubbleGreen : primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            "Conversations",
            conversationCount.toString(),
            Icons.forum,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            "Transcripts",
            transcriptsCount.toString(),
            Icons.description,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Colors.blueGrey[700],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            // const SizedBox(height: 8),
            // Row(
            //   children: [
            //     Icon(
            //       Icons.trending_up,
            //       size: 16,
            //       color: Colors.green[400],
            //     ),
            //     const SizedBox(width: 4),
            //     Text(
            //       "12% this week",
            //       style: TextStyle(
            //         fontSize: 12,
            //         color: Colors.green[400],
            //         fontWeight: FontWeight.w500,
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

// Widget _buildRecentActivitySection() {
//   return Card(
//     elevation: 2,
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//     child: Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "Recent Activities",
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blueGrey[800],
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {},
//                 child: const Text("See All"),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           _buildActivityItem(
//             "New conversation started",
//             "12:35 PM",
//             Icons.chat_bubble_outline,
//             Colors.blue,
//           ),
//           const Divider(),
//           _buildActivityItem(
//             "Transcript generated",
//             "Yesterday",
//             Icons.description_outlined,
//             Colors.orange,
//           ),
//           const Divider(),
//           _buildActivityItem(
//             "Agent configuration updated",
//             "Mar 10",
//             Icons.settings_outlined,
//             Colors.purple,
//           ),
//         ],
//       ),
//     ),
//   );
// }
//
// Widget _buildActivityItem(
//     String title, String time, IconData icon, Color color) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 8.0),
//     child: Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(
//             icon,
//             size: 20,
//             color: color,
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 time,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }
}

// class DataList extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<MyData>>(
//       future: getData(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return CircularProgressIndicator();
//         } else if (snapshot.hasError) {
//           return Text('Error: ${snapshot.error}');
//         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return Text('No data found.');
//         } else {
//           final data = snapshot.data!;
//           return ListView.builder(
//             itemCount: data.length,
//             itemBuilder: (context, index) {
//               return ListTile(
//                 title: Text(data[index].name),
//                 subtitle: Text('Age: ${data[index].age}'),
//               );
//             },
//           );
//         }
//       },
//     );
//   }
// }