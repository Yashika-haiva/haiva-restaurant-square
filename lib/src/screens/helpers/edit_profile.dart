import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../service/api_service.dart';
import '../../service/storage_service.dart';
import '../../shared/consts.dart';
import '../../shared/enum.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({
    super.key,
  });

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  bool isLoading = false;
  String formattedBalance = '';
  String imageUrl = "";
  String displayName = "";
  String description = "";

  @override
  void initState() {
    super.initState();
    inItData();
  }

  inItData() async {
    setState(() {
      isLoading = true;
    });

    String agentId = await StorageService().getValueFromStorage("agentId");

    final responseForAgent = await APIService().getAgentDetails(agentId);
    if (responseForAgent.statusCode == 200) {
      final decodedResponseForAgent =
          jsonDecode(utf8.decode(responseForAgent.bodyBytes));
      final responseBodyForAgent = decodedResponseForAgent;
      setState(() {
        imageUrl = responseBodyForAgent['agent_configs']['image'];
        displayName = responseBodyForAgent['agent_configs']['display_name'];
        description = responseBodyForAgent['agent_configs']['description'];
        _nameController = TextEditingController(text: displayName);
        _descriptionController = TextEditingController(text: description);
      });
    }

    final responseForBalance = await APIService().getBalance();
    if (responseForBalance.statusCode == 200) {
      final decodedResponseForBalance =
          jsonDecode(utf8.decode(responseForBalance.bodyBytes));
      final responseBodyForAgent = decodedResponseForBalance;
      setState(() {
        final balance = responseBodyForAgent['availableBalance'] ?? 0.00;
        formattedBalance = balance.toStringAsFixed(2);
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: primaryColor,
      title: const Text('Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      actions: [
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
                  "\$$formattedBalance",
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

  upload(img) async {
    String wsId = await StorageService().getValueFromStorage("workspace_id");
    final response = await APIService().insertAvatar(wsId, img);
    print("responceofWs ${response.body}");
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final responseBody = decodedResponse;
      setState(() {
        imageUrl = responseBody['Url'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: isLoading
          ? Center(
              child: LoadingAnimationWidget.beat(
                  color: primaryLightColor, size: 100))
          : RefreshIndicator(
              onRefresh: () async {
                await inItData();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Customize your agent's identity with an avatar, display name, and description. Personalize its appearance with language, voice, and a custom welcome message",
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(imageUrl),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () async {
                                  final ImagePicker picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(
                                      source: ImageSource.gallery);

                                  if (image != null) {
                                    File imageFile = File(image.path);
                                    upload(imageFile);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Display Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: primaryColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: primaryColor,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: primaryColor,
                            width: 2,
                          ),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: primaryColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: primaryColor,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: primaryColor,
                            width: 2,
                          ),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.record_voice_over),
                      title: const Text('Voice / Telephony'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        StorageService().createAndUpdateKeyValuePairInStorage(
                            "display_name", _nameController.value.text);
                        StorageService().createAndUpdateKeyValuePairInStorage(
                            "description", _descriptionController.value.text);
                        StorageService().createAndUpdateKeyValuePairInStorage(
                            "image", imageUrl);
                        context.push("/${Routes.home.name}");
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
