import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../service/api_service.dart';
import '../service/storage_service.dart';
import '../shared/consts.dart';
import '../shared/enum.dart';

class VoiceOptions extends StatefulWidget {
  final dynamic agentData;

  const VoiceOptions({super.key, required this.agentData});

  @override
  State<VoiceOptions> createState() => _VoiceOptionsState();
}

class _VoiceOptionsState extends State<VoiceOptions> {
  String? selectedVoice;
  String selectedFilter = 'Both';
  List<String> selectedLanguages = [];
  List<Map<String, dynamic>> voices = [];
  List<Map<String, dynamic>> voices1 = [];
  final List<String> languages = ['English', 'Spanish', 'French', 'German'];
  final Map<String, bool> languageSelections = {
    'English': false,
    'Spanish': false,
    'French': false,
    'German': false,
  };
  bool _isLoading = false;
  late AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;

  TextEditingController welcomeMessageController = TextEditingController();
  String formattedBalance = '';

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    welcomeMessageController.text = "Hello, how can I assist you today?";
    getVoicesAndBalance();
  }

  getVoicesAndBalance() async {
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
          };
        }).toList();
        if (voices.isNotEmpty) {
          var emmaVoice = voices.firstWhere((voice) => voice['name'] == "Emma",
              orElse: () => voices[0]);
          selectedVoice = emmaVoice['code'];
          String text = emmaVoice['playback_text'];
          callApiForVoice(selectedVoice, text);
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
          };
        }).toList();

        for (var voice in voices1) {
          if (!languages.contains(voice['language'])) {
            languages.add(voice['language']);
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
      _isLoading = true;
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
          _isLoading = false;
        });
      });
    } else {
      setState(() {
        isPlaying = false;
        _isLoading = false;
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
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title:
            const Text('Voice Options', style: TextStyle(color: Colors.white)),
        elevation: 10,
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                              widget.agentData['agent_configs']['voice_configs']
                                  ['code'] = newVoiceCode;
                              for (var voice in voices) {
                                if (voice['code'] == newVoiceCode) {
                                  widget.agentData['agent_configs']
                                          ['voice_configs']['gender'] =
                                      voice['gender'];
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
                          items: voices
                              .map<DropdownMenuItem<String>>((voice) {
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
                        icon: const Icon(Icons.filter_alt_outlined),
                        onPressed: () {
                          showMenu<String>(
                            context: context,
                            position:
                                const RelativeRect.fromLTRB(300, 100, 300, 300),
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
                            if (filteredVoices.isNotEmpty) {
                              selectedVoice = filteredVoices[0]['code'];
                              String text = filteredVoices[0]['playback_text'];
                              callApiForVoice(selectedVoice, text);
                            }
                            setState(() {
                              this.selectedFilter = selectedFilter ?? 'Both';
                              if (!filteredVoices.any(
                                (voice) => voice['code'] == selectedVoice,
                              )) {
                                selectedVoice = null;
                              }
                            });
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: PopupMenuButton<int>(
                          constraints: BoxConstraints(
                              maxHeight: 200, maxWidth: size.width - 48),
                          onSelected: (int index) {
                            setState(() {
                              String selectedLanguage = languages[index];
                              if (selectedLanguages.contains(
                                selectedLanguage,
                              )) {
                                selectedLanguages.remove(selectedLanguage);
                              } else {
                                selectedLanguages.add(selectedLanguage);
                              }
                            });
                          },
                          itemBuilder: (BuildContext context) {
                            return List.generate(languages.length, (index) {
                              return PopupMenuItem<int>(
                                value: index,
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: selectedLanguages.contains(
                                        languages[index],
                                      ),
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            selectedLanguages.add(
                                              languages[index],
                                            );
                                          } else {
                                            selectedLanguages.remove(
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
                                      languages[index],
                                      overflow: TextOverflow.ellipsis,
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
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedLanguages.isEmpty
                                      ? 'Select Languages'
                                      : selectedLanguages.join(', '),
                                ),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Welcome Message:"),
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
                        borderSide: const BorderSide(color: secondaryColor),
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
                        isPlaying
                            ? const Icon(Icons.volume_off_outlined,
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
              onPressed: () async {
                checkAgent();
                // print(await StorageService().getValueFromStorage("template"));
                // print(await StorageService().getValueFromStorage("workspace_id"));
                // print(await StorageService().token);
              },
              child: const Text("Deploy Agent")),
        ),
      ),
    );
  }

  checkAgent() async {
    final response = await APIService().checkAgent();
    print("responceofWs ${response.body}");
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final responseBody = decodedResponse;
      String agentId = responseBody['agent'][0]['agent_id'];
      context.push('/${Routes.reDeploAgent.name}',
          extra: {'agentData': widget.agentData, 'agentId': agentId});
    } else {
      deployInitial();
    }
  }

  deployInitial() async {
    final response = await APIService().onDeployInitial();
    if (response.statusCode == 200) {
      print(widget.agentData);
      print(await StorageService().getValueFromStorage("phone_number"));
      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final List responseBody = decodedResponse;
      context.push('/${Routes.deployAgent.name}',
          extra: {'agentData': widget.agentData, 'deployData': responseBody});
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
          icon: _isLoading
              ? const Icon(Icons.volume_off_outlined)
              : const Icon(Icons.volume_up),
          onPressed: () async {
            if (voice['code'] != null) {
              try {
                await callApiForVoice(voice['code'], voice['playback_text']);
              } catch (e) {
                setState(() {
                  _isLoading = false;
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
