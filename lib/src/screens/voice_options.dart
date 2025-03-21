import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../service/agent_data_provider.dart';
import '../service/api_service.dart';
import '../service/storage_service.dart';
import '../shared/consts.dart';
import '../shared/enum.dart';
import 'helpers/get_balance.dart';

class VoiceOptions extends StatefulWidget {
  final dynamic agentData;

  const VoiceOptions({super.key, required this.agentData});

  @override
  State<VoiceOptions> createState() => _VoiceOptionsState();
}

class _VoiceOptionsState extends State<VoiceOptions> {
  String? selectedVoice;
  String selectedFilter = 'Both';
  List<Map<String, dynamic>> selectedLanguages = [
    {"language": "English (US)", "locale": "en-US"}
  ];
  List<Map<String, dynamic>> voices = [];
  List<Map<String, dynamic>> voices1 = [];
  final List<Map<String, dynamic>> languages = [];
  List<String> selectedLocales = ["en-US"];

  // final Map<String, bool> languageSelections = {
  //   'English': false,
  //   'Spanish': false,
  //   'French': false,
  //   'German': false,
  // };
  bool _isVoiceLoading = false;
  late AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isButtonLoading = false;
  bool isPageLoadingForDeploy = false;
  late List deployData = [];
  bool isSaveEnable = false;
  bool isLoading = false;

  TextEditingController welcomeMessageController = TextEditingController();

  // String formattedBalance = "\$0.00";

  @override
  void initState() {
    super.initState();
    initData();
  }

  String? getWelcomeMessage(Map<String, dynamic> jsonData) {
    List<dynamic> flow = jsonData["agent_flow"]["flow"];

    for (var item in flow) {
      if (item["type"] == "haiva.welcomemessage") {
        return item["data"]["textInput"];
      }
    }
    return null;
  }

  void updateWelcomeMessage(Map<String, dynamic> jsonData, String newMessage) {
    List<dynamic> flow = jsonData["agent_flow"]["flow"];

    for (var item in flow) {
      if (item["type"] == "haiva.welcomemessage") {
        item["data"]["textInput"] = newMessage;
        break; // Stop after updating the first occurrence
      }
    }
  }

  initData() async {
    setState(() {
      isLoading = true;
    });
    checkAgentSave();
    _audioPlayer = AudioPlayer();
    await getVoicesAndBalance();
    setState(() {
      isLoading = false;
    });
  }

  getVoicesAndBalance() async {
    // final responseForBalance = await APIService().getBalance();
    // if (responseForBalance.statusCode == 200) {
    //   final decodedResponseForBalance =
    //       jsonDecode(utf8.decode(responseForBalance.bodyBytes));
    //   final responseBodyForAgent = decodedResponseForBalance;
    //   setState(() {
    //     final balance = responseBodyForAgent['availableBalance'] ?? 0.00;
    //     formattedBalance = balance.toStringAsFixed(2);
    //   });
    // }

    voices = [];
    final response = await APIService().getVoices(false);
    if (response.statusCode == 200) {
      dynamic responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      List<dynamic> voicesFromApi = responseBody;
      print("Languages $voicesFromApi");
      setState(() {
        voices = voicesFromApi.map<Map<String, dynamic>>((voice) {
          return {
            'name': voice['name'],
            'code': voice['code'],
            'language': voice['language'],
            'gender': voice['gender'],
            'playback_text': voice['playback_text'],
            'locale': voice['locale']
          };
        }).toList();
        if (voices.isNotEmpty) {
          // // if(widget.agentData['agent_configs']['voice_configs']!= null){
          // // } else{
          // // en-US-EmmaMultilingualNeural
          //   var emmaVoice = voices.firstWhere((voice) => voice['name'] == "Emma",
          //       orElse: () => voices[0]);
          //   print(emmaVoice['code']);
          //   selectedVoice = emmaVoice['code'];
          //   String text = emmaVoice['playback_text'];
          //   callApiForVoice(selectedVoice, text);
          // // }
          print(widget.agentData);
          selectedVoice =
              widget.agentData['agent_configs']['voice_configs']['code'];
          // String text = emmaVoice['playback_text'];
          String? welcomeMessage = getWelcomeMessage(widget.agentData);
          callApiForVoice(selectedVoice, welcomeMessage!);
        }
      });
    } else {
      throw Exception('Failed to load voices');
    }

    voices1 = [];

    ///For Languages
    final response1 = await APIService().getVoices(true);
    if (response1.statusCode == 200) {
      dynamic responseBody = jsonDecode(utf8.decode(response1.bodyBytes));
      List<dynamic> voicesFromApi = responseBody;
      print("Languages $voicesFromApi");
      setState(() {
        voices1 = voicesFromApi.map<Map<String, dynamic>>((voice) {
          return {
            'name': voice['name'],
            'code': voice['code'],
            'language': voice['language'],
            'gender': voice['gender'],
            'playback_text': voice['playback_text'],
            'locale': voice['locale']
          };
        }).toList();

        // for (var voice in voices1) {
        //   if (!languages.contains(voice['language'])) {
        //     languages.add(voice['language']);
        //   }
        // }

        var languagesAndLocals =
            voicesFromApi.map<Map<String, dynamic>>((voice) {
          return {
            'language': voice['language'],
            'locale': voice['locale'],
          };
        }).toList();

        for (var entry in languagesAndLocals) {
          var language = entry['language'];
          var locale = entry['locale'];

          // If you want to add unique language-local pairs to a list:
          if (!languages.contains({'language': language, 'locale': locale})) {
            languages.add({'language': language, 'locale': locale});
          }
        }

        if (voices1.isNotEmpty) {
          // selectedVoice = voices1[0]['code'];
          // String text = voices1[0]['playback_text'];
          // callApiForVoice(selectedVoice, text);
        }
      });
    } else {
      throw Exception('Failed to load voices');
    }
  }

  Future<void> callApiForVoice(dynamic voiceLabel, String text) async {
    setState(() {
      isPlaying = true;
      _isVoiceLoading = true;
    });
    const language = 'en-US';
    final requestBody = {
      "language": language,
      "text": text,
      "voice": voiceLabel,
    };

    final response = await APIService().convertTextToVoice(requestBody);
    if (response.statusCode == 200) {
      Uint8List audioBytes = response.bodyBytes;
      await _audioPlayer.play(BytesSource(audioBytes));
      _audioPlayer.onPlayerComplete.listen((event) {
        setState(() {
          isPlaying = false;
          _isVoiceLoading = false;
        });
      });
    } else {
      setState(() {
        isPlaying = false;
        _isVoiceLoading = false;
      });
      throw Exception('Failed to convert text to speech');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    List<Map<String, dynamic>> filteredVoices = voices.where((voice) {
      if (selectedFilter == 'Male') {
        return voice['gender'] == 'Male';
      } else if (selectedFilter == 'Female') {
        return voice['gender'] == 'Female';
      } else {
        return true;
      }
    }).toList();
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text('Voice Options',
                style: TextStyle(color: Colors.white)),
            elevation: 10,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.account_balance_wallet,
                          color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      BalanceWidget(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: isLoading
              ? Center(
                  child: LoadingAnimationWidget.beat(
                      color: primaryLightColor, size: 100))
              : AbsorbPointer(
                  absorbing: isPageLoadingForDeploy,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Voice:',
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButton<String>(
                                        dropdownColor: whiteColor,
                                        isExpanded: true,
                                        menuMaxHeight: 184,
                                        value: selectedVoice,
                                        hint: const Text('Select a Voice'),
                                        onChanged: (String? newVoiceCode) {
                                          setState(() {
                                            widget.agentData['agent_configs']
                                                    ['voice_configs']['code'] =
                                                newVoiceCode;
                                            for (var voice in filteredVoices) {
                                              if (voice['code'] ==
                                                  newVoiceCode) {
                                                widget.agentData[
                                                                'agent_configs']
                                                            ['voice_configs']
                                                        ['gender'] =
                                                    voice['gender'];
                                                if (voice['gender'] == 'Male') {
                                                  String maleImage =
                                                      'https://s3.amazonaws.com/haiva.apiplatform.io/haiva-assets/voice-avatar-male.png';
                                                  widget.agentData[
                                                          'agent_configs']
                                                      ['image'] = maleImage;
                                                  Provider.of<AgentDataProvider>(
                                                          context,
                                                          listen: false)
                                                      .updateImageUrl(
                                                          maleImage);
                                                  StorageService()
                                                      .createAndUpdateKeyValuePairInStorage(
                                                          "image", maleImage);
                                                } else {
                                                  String femaleImage =
                                                      'https://s3.amazonaws.com/haiva.apiplatform.io/haiva-assets/voice-avatar-female.png';
                                                  widget.agentData[
                                                          'agent_configs']
                                                      ['image'] = femaleImage;
                                                  Provider.of<AgentDataProvider>(
                                                          context,
                                                          listen: false)
                                                      .updateImageUrl(
                                                          femaleImage);
                                                  StorageService()
                                                      .createAndUpdateKeyValuePairInStorage(
                                                          "image", femaleImage);
                                                }
                                                print(widget.agentData[
                                                    'agent_configs']['image']);
                                              }
                                            }
                                            selectedVoice = newVoiceCode;
                                          });
                                          if (newVoiceCode != null) {
                                            callApiForVoice(
                                              newVoiceCode,
                                              'Hi I am your selected Voice Assistant',
                                            );
                                          }
                                        },
                                        items: filteredVoices
                                            .map<DropdownMenuItem<String>>(
                                                (voice) {
                                              return DropdownMenuItem<String>(
                                                value: voice['code'],
                                                child: dropDownItem(voice),
                                              );
                                            })
                                            .toSet()
                                            .toList(),
                                      ),
                                    ),
                                    IconButton(
                                      icon:
                                          const Icon(Icons.filter_alt_outlined),
                                      onPressed: () {
                                        // showMenu<String>(
                                        //   context: context,
                                        //   position: const RelativeRect.fromLTRB(
                                        //       300, 100, 300, 300),
                                        //   items: [
                                        //     const PopupMenuItem<String>(
                                        //       value: 'Male',
                                        //       child: Text('Male'),
                                        //     ),
                                        //     const PopupMenuItem<String>(
                                        //       value: 'Female',
                                        //       child: Text('Female'),
                                        //     ),
                                        //     const PopupMenuItem<String>(
                                        //       value: 'Both',
                                        //       child: Text('Both'),
                                        //     ),
                                        //   ],
                                        // ).then((selectedFilter) {
                                        //   if (filteredVoices.isNotEmpty) {
                                        //     selectedVoice =
                                        //         filteredVoices[0]['code'];
                                        //     String text = filteredVoices[0]
                                        //         ['playback_text'];
                                        //     callApiForVoice(
                                        //         selectedVoice, text);
                                        //   }
                                        //   setState(() {
                                        //     this.selectedFilter =
                                        //         selectedFilter ?? 'Both';
                                        //     if (!filteredVoices.any(
                                        //       (voice) =>
                                        //           voice['code'] ==
                                        //           selectedVoice,
                                        //     )) {
                                        //       selectedVoice = null;
                                        //     }
                                        //   });
                                        // });
                                        showMenu<String>(
                                          context: context,
                                          position: const RelativeRect.fromLTRB(
                                              300, 100, 300, 300),
                                          items: [
                                            const PopupMenuItem<String>(
                                              value: 'Male',
                                              child: Text('Male'),
                                            ),
                                            const PopupMenuItem<String>(
                                              value: 'Female',
                                              child: Text('Female'),
                                            ),
                                            const PopupMenuItem<String>(
                                              value: 'Both',
                                              child: Text('Both'),
                                            ),
                                          ],
                                        ).then((selectedFilter) {
                                          if (selectedFilter != null) {
                                            setState(() {
                                              this.selectedFilter =
                                                  selectedFilter;

                                              // Create filtered voices list based on new filter
                                              List<Map<String, dynamic>>
                                                  newFilteredVoices =
                                                  voices.where((voice) {
                                                if (selectedFilter == 'Male') {
                                                  return voice['gender'] ==
                                                      'Male';
                                                } else if (selectedFilter ==
                                                    'Female') {
                                                  return voice['gender'] ==
                                                      'Female';
                                                } else {
                                                  return true;
                                                }
                                              }).toList();

                                              // Check if current selectedVoice is still valid with the new filter
                                              bool isCurrentVoiceValid =
                                                  newFilteredVoices.any(
                                                (voice) =>
                                                    voice['code'] ==
                                                    selectedVoice,
                                              );

                                              // If current voice is no longer valid with the new filter, select the first voice from filtered list
                                              if (!isCurrentVoiceValid &&
                                                  newFilteredVoices
                                                      .isNotEmpty) {
                                                selectedVoice =
                                                    newFilteredVoices[0]
                                                        ['code'];
                                                // Update UI and agent data with the new voice
                                                for (var voice in voices) {
                                                  if (voice['code'] ==
                                                      selectedVoice) {
                                                    widget.agentData[
                                                                'agent_configs']
                                                            ['voice_configs'][
                                                        'code'] = selectedVoice;
                                                    widget.agentData[
                                                                'agent_configs']
                                                            ['voice_configs'][
                                                        'gender'] = voice['gender'];

                                                    // Update image based on gender
                                                    String imageUrl = voice[
                                                                'gender'] ==
                                                            'Male'
                                                        ? 'https://s3.amazonaws.com/haiva.apiplatform.io/haiva-assets/voice-avatar-male.png'
                                                        : 'https://s3.amazonaws.com/haiva.apiplatform.io/haiva-assets/voice-avatar-female.png';

                                                    widget.agentData[
                                                            'agent_configs']
                                                        ['image'] = imageUrl;
                                                    Provider.of<AgentDataProvider>(
                                                            context,
                                                            listen: false)
                                                        .updateImageUrl(
                                                            imageUrl);
                                                    StorageService()
                                                        .createAndUpdateKeyValuePairInStorage(
                                                            "image", imageUrl);
                                                    break;
                                                  }
                                                }

                                                // Test the new voice
                                                if (selectedVoice != null) {
                                                  String playbackText =
                                                      'Hi I am your selected Voice Assistant';
                                                  for (var voice
                                                      in newFilteredVoices) {
                                                    if (voice['code'] ==
                                                            selectedVoice &&
                                                        voice['playback_text'] !=
                                                            null) {
                                                      playbackText = voice[
                                                          'playback_text'];
                                                      break;
                                                    }
                                                  }
                                                  callApiForVoice(selectedVoice,
                                                      playbackText);
                                                }
                                              }
                                            });
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Languages:',
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: PopupMenuButton<int>(
                                        constraints: BoxConstraints(
                                            maxHeight: 200,
                                            maxWidth: size.width - 48),
                                        onSelected: (int index) {
                                          setState(() {
                                            Map<String, dynamic>
                                                selectedLanguage =
                                                languages[index];

                                            if (selectedLanguages.contains(
                                              selectedLanguage,
                                            )) {
                                              selectedLanguages
                                                  .remove(selectedLanguage);
                                            } else {
                                              selectedLanguages
                                                  .add(selectedLanguage);
                                            }
                                          });
                                        },
                                        itemBuilder: (BuildContext context) {
                                          return List.generate(languages.length,
                                              (index) {
                                            return PopupMenuItem<int>(
                                              value: index,
                                              child: Row(
                                                children: [
                                                  Checkbox(
                                                    value: selectedLanguages
                                                        .contains(
                                                      languages[index],
                                                    ),
                                                    onChanged: (bool? value) {
                                                      setState(() {
                                                        if (value == true) {
                                                          selectedLanguages.add(
                                                            languages[index],
                                                          );
                                                        } else {
                                                          selectedLanguages
                                                              .remove(
                                                            languages[index],
                                                          );
                                                        }
                                                      });
                                                    },
                                                    checkColor: whiteColor,
                                                    activeColor: primaryColor,
                                                  ),
                                                  Expanded(
                                                      child: Text(
                                                    languages[index]
                                                        ['language'],
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  )),
                                                ],
                                              ),
                                            );
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.black),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: SingleChildScrollView(
                                            reverse: true,
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      selectedLanguages.isEmpty
                                                          ? 'Select Languages'
                                                          : selectedLanguages
                                                              .map((lang) => lang[
                                                                  "language"])
                                                              .join(', '),
                                                    ),
                                                  ],
                                                ),
                                                const Icon(
                                                    Icons.arrow_drop_down),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Text("Welcome Message:"),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: welcomeMessageController,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintStyle: const TextStyle(
                                      color: hintTextColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: const BorderSide(
                                          color: secondaryColor),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: const BorderSide(
                                        color: secondaryColor,
                                        width: 2,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: const BorderSide(
                                        color: secondaryColor,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    minimumSize:
                                        const Size(double.infinity, 40),
                                  ),
                                  onPressed: () {
                                    callApiForVoice(
                                      selectedVoice,
                                      welcomeMessageController.text,
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("Test"),
                                      const SizedBox(width: 8),
                                      !isPlaying
                                          ? const Icon(
                                              Icons.volume_off_outlined,
                                              color: whiteColor)
                                          : const Icon(Icons.volume_up_outlined,
                                              color: whiteColor),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  onPressed: () async {
                    if (isSaveEnable) {
                      updateWelcomeMessage(
                          widget.agentData, welcomeMessageController.text);
                      List<String> languageList = selectedLanguages
                          .map((lang) => lang["locale"] as String)
                          .toList();
                      widget.agentData['agent_configs']['languages'] =
                          languageList;
                      saveAgent();
                    } else {
                      updateWelcomeMessage(
                          widget.agentData, welcomeMessageController.text);
                      List<String> languageList = selectedLanguages
                          .map((lang) => lang["locale"] as String)
                          .toList();
                      widget.agentData['agent_configs']['languages'] =
                          languageList;
                      checkAgent();
                      print(widget.agentData['agent_configs']['image']);
                      // print(await StorageService().getValueFromStorage("template"));
                      // print(await StorageService().getValueFromStorage("workspace_id"));
                      // print(await StorageService().token);
                    }
                  },
                  child: isButtonLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator())
                      : isSaveEnable
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Save'),
                                SizedBox(width: 8),
                                Icon(Icons.save_outlined, color: whiteColor),
                              ],
                            )
                          : isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator())
                              : const Text("Deploy Agent")),
            ),
          ),
        ),
        if (isPageLoadingForDeploy)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              ),
            ),
          ),
      ],
    );
  }

  saveAgent() async {
    setState(() {
      isButtonLoading = true;
    });
    String agentId = await StorageService().getValueFromStorage("agentId");
    final responseForAgent =
        await APIService().saveAgent(widget.agentData, agentId);
    if (responseForAgent.statusCode == 200) {
      final decodedResponseForAgent =
          jsonDecode(utf8.decode(responseForAgent.bodyBytes));
      final responseBodyForAgent = decodedResponseForAgent;
      print(responseBodyForAgent);
      String newImage = widget.agentData['agent_configs']['image'];
      Provider.of<AgentDataProvider>(context, listen: false)
          .updateImageUrl(newImage);
      goToDashBoard();
    } else {
      print(responseForAgent.body);
    }
    setState(() {
      isButtonLoading = false;
    });
  }

  checkAgentSave() async {
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
          // getAgentTemplate();
          welcomeMessageController.text =
              "Welcome! How can I assist you with your dining experience?";
        } else {
          setState(() {
            isSaveEnable = true;
          });
          String? welcomeMessage = getWelcomeMessage(widget.agentData);
          welcomeMessageController.text = welcomeMessage!;
          // getAgentData(agentId);
        }
      } else {
        welcomeMessageController.text =
            "Welcome! How can I assist you with your dining experience?";
        // checkProvider();
      }
    }
  }

  checkAgent() async {
    setState(() {
      isButtonLoading = true;
    });
    final response = await APIService().checkAgent();
    print("responceofWs ${response.body}");
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final responseBody = decodedResponse;
      print(responseBody['agent']);
      print(responseBody['agent'].isNotEmpty);
      if (responseBody['agent'].isNotEmpty) {
        String agentId = responseBody['agent'][0]['agent_id'];
        reDeployAgent(agentId);
        // context.push('/${Routes.reDeploAgent.name}',
        //     extra: {'agentData': widget.agentData, 'agentId': agentId});
      } else {
        deployInitial();
      }
    } else {
      deployInitial();
    }

    setState(() {
      isButtonLoading = false;
    });
  }

  deployInitial() async {
    setState(() {
      isPageLoadingForDeploy = true;
    });
    final response = await APIService().onDeployInitial();
    if (response.statusCode == 200) {
      print(widget.agentData);
      print(await StorageService().getValueFromStorage("phone_number"));
      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final List responseBody = decodedResponse;
      deployData = responseBody;
      deployAgent();
      // context.push('/${Routes.deployAgent.name}',
      //     extra: {'agentData': widget.agentData, 'deployData': responseBody});
    } else {
      callSnackBar(response, "Deployment aborted!");
      setState(() {
        isPageLoadingForDeploy = false;
      });
    }
  }

  deployAgent() async {
    String recentConnName =
        await StorageService().getValueFromStorage("recentConnName");
    String orgID = await StorageService().getValueFromStorage("org_id");
    String wsId = await StorageService().getValueFromStorage("workspace_id");

    ///"Agent for Restaurants" is from import provider.dart where we check templateName
    widget.agentData['name'] = 'Agent for Restaurants';
    widget.agentData['agent_configs']['display_name'] = 'Agent for Restaurants';
    final parsedData = deployData[0];
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
      setState(() {
        isPageLoadingForDeploy = false;
      });
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
    } else {
      callSnackBar(response, "Deployment aborted!");
      setState(() {
        isPageLoadingForDeploy = false;
      });
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
        final inProgress = responseBody['deployment_profile']['profile_info']
                ['in_progress'] ??
            false;
        final isError = responseBody['deployment_profile']['profile_info']
                ['is_error'] ??
            false;
        if (!isError && !inProgress) {
          timer?.cancel();
          await StorageService()
              .createAndUpdateKeyValuePairInStorage("agentId", agentId);
          goToDashBoard();
        } else if (isError) {
          timer?.cancel();
          callSnackBar(response, "Deployment aborted!");
          setState(() {
            isPageLoadingForDeploy = false;
          });
        } else if (inProgress) {
          timer = Timer.periodic(const Duration(seconds: 5), (timer) {
            checkDeployStatus();
          });
        }
      } else {
        callSnackBar(response, "Deployment aborted!");
        setState(() {
          isPageLoadingForDeploy = false;
        });
      }
    }

    checkDeployStatus();
  }

  goToDashBoard() {
    setState(() {
      isPageLoadingForDeploy = false;
    });
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
    } else {
      callSnackBar(response, "Deployment aborted!");
      setState(() {
        isPageLoadingForDeploy = false;
      });
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

  reDeployAgent(agentId) async {
    setState(() {
      isPageLoadingForDeploy = true;
    });
    String name = await StorageService().getValueFromStorage("display_name") ??
        widget.agentData['agent_configs']['display_name'];
    String description =
        await StorageService().getValueFromStorage("description") ??
            widget.agentData['agent_configs']['description'];
    print(widget.agentData['agent_configs']['image']);
    String imageUrl = await StorageService().getValueFromStorage("image") ??
        widget.agentData['agent_configs']['image'];
    print(imageUrl);
    widget.agentData['agent_configs']['display_name'] = name;
    widget.agentData['agent_configs']['description'] = description;
    widget.agentData['agent_configs']['image'] = imageUrl;
    print(widget.agentData['agent_configs']['image']);
    String wsId = await StorageService().getValueFromStorage("workspace_id");
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
      setState(() {
        isPageLoadingForDeploy = false;
      });
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
    } else {
      callSnackBar(response, "Deployment aborted!");
      setState(() {
        isPageLoadingForDeploy = false;
      });
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
        print(
            responseBody['deployment_profile']['profile_info']['in_progress']);
        print(responseBody['deployment_profile']['profile_info']['is_error']);
        final inProgress = responseBody['deployment_profile']['profile_info']
                ['in_progress'] ??
            false;
        final isError = responseBody['deployment_profile']['profile_info']
                ['is_error'] ??
            false;
        if (!isError && !inProgress) {
          timer?.cancel();
          await StorageService()
              .createAndUpdateKeyValuePairInStorage("agentId", agentId);
          goToDashBoard();
        } else if (isError) {
          timer?.cancel();
          callSnackBar(response, "Deployment aborted!");
          setState(() {
            isPageLoadingForDeploy = false;
          });
        } else if (inProgress) {
          timer = Timer.periodic(const Duration(seconds: 5), (timer) {
            checkDeployStatus();
          });
        }
      } else {
        callSnackBar(response, "Deployment aborted!");
        setState(() {
          isPageLoadingForDeploy = false;
        });
      }
    }

    checkDeployStatus();
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
    } else {
      callSnackBar(response, "Deployment aborted!");
      setState(() {
        isPageLoadingForDeploy = false;
      });
    }
  }

  Widget dropDownItem(dynamic voice) {
    return Row(
      children: [
        CircleAvatar(
            radius: 16,
            backgroundColor: voice['gender'] == "Male"
                ? primaryColor
                : inputFieldErrorBorderColor,
            backgroundImage: NetworkImage(voice['gender'] == "Male"
                ? "https://s3.amazonaws.com/haiva.apiplatform.io/haiva-assets/voice-avatar-male.png"
                : "https://s3.amazonaws.com/haiva.apiplatform.io/haiva-assets/voice-avatar-female.png")),
        const SizedBox(width: 8),
        Text(voice['name']),
        IconButton(
          icon: !_isVoiceLoading
              ? const Icon(Icons.volume_off_outlined)
              : const Icon(Icons.volume_up),
          onPressed: () async {
            if (voice['code'] != null) {
              try {
                await callApiForVoice(voice['code'], voice['playback_text']);
              } catch (e) {
                setState(() {
                  _isVoiceLoading = false;
                });
                if (kDebugMode) {
                  print("Error playing audio: $e");
                }
              }
            }
          },
        ),
      ],
    );
  }
}
