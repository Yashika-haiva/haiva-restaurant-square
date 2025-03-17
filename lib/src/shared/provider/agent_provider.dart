// providers/agent_provider.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/agent.dart';
import '../../service/agent_service.dart';


class AgentProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Map<String, String> languageCodes = {
  //   'English (India)': 'en-IN',
  //   'Tamil':'ta-IN',
  //   'Telugu':'te-IN',
  //   'Kannada':'kn-IN',
  //   'Malayalam':'ml-IN',
  //   'UK English': 'en-GB',
  //   'US English': 'en-US',
  //   'Italian': 'it-IT',
  //   'Swedish': 'sv-SE',
  //   'French Canadian': 'fr-CA',
  //   'Malay': 'ms-MY',
  //   'German': 'de-DE',
  //   'Hebrew': 'he-IL',
  //   'Australian English': 'en-AU',
  //   'Indonesian': 'id-ID',
  //   'French': 'fr-FR',
  //   'Bulgarian': 'bg-BG',
  //   'Finnish': 'fi-FI',
  //   'Spanish (Spain)': 'es-ES',
  //   'Spanish (Mexico)': 'es-MX',
  //   'Portuguese (Brazil)': 'pt-BR',
  //   'Dutch (Belgium)': 'nl-BE',
  //   'Japanese': 'ja-JP',
  //   'Romanian': 'ro-RO',
  //   'Mandarin Chinese (China)': 'zh-CN',
  //   'Vietnamese': 'vi-VN',
  //   'Arabic': 'ar-001',
  //   'Mandarin Chinese (Taiwan)': 'zh-TW',
  //   'Greek': 'el-GR',
  //   'Russian': 'ru-RU',
  //   'English (Ireland)': 'en-IE',
  //   'Catalan': 'ca-ES',
  //   'Portuguese (Portugal)': 'pt-PT',
  //   'Thai': 'th-TH',
  //   'Croatian': 'hr-HR',
  //   'Slovak': 'sk-SK',
  //   'Hindi': 'hi-IN',
  //   'Ukrainian': 'uk-UA',
  //   'Cantonese (Hong Kong)': 'zh-HK',
  //   'Polish': 'pl-PL',
  //   'Czech': 'cs-CZ',
  //   'Hungarian': 'hu-HU',
  //   'Turkish': 'tr-TR',
  //   'Korean': 'ko-KR',
  //   'Danish': 'da-DK',
  //   'Norwegian': 'nb-NO',
  //   'English (South Africa)': 'en-ZA',
  //   'Spanish (US)': 'es-US',
  //
  // };
  Map<String, String> languageCodes = {
    // 'English': 'en-IN',
    'Tamil':'ta-IN',
    'Telugu':'te-IN',
    'Kannada':'kn-IN',
    'Malayalam':'ml-IN',
    // 'UK English': 'en-GB',
    // 'US English': 'en-US',
    // 'Italian': 'it-IT',
    // 'Swedish': 'sv-SE',
    // 'French Canadian': 'fr-CA',
    // 'Malay': 'ms-MY',
    'German': 'de-DE',
    // 'Hebrew': 'he-IL',
    // 'Australian English': 'en-AU',
    // 'Indonesian': 'id-ID',
    'French': 'fr-FR',
    // 'Bulgarian': 'bg-BG',
    // 'Finnish': 'fi-FI',
    // 'Spanish (Spain)': 'es-ES',
    // 'Spanish (Mexico)': 'es-MX',
    // 'Portuguese (Brazil)': 'pt-BR',
    // 'Dutch (Belgium)': 'nl-BE',
    'Japanese': 'ja-JP',
    // 'Romanian': 'ro-RO',
    'Chinese': 'zh-CN',
    // 'Vietnamese': 'vi-VN',
    // 'Arabic': 'ar-001',
    // 'Mandarin Chinese (Taiwan)': 'zh-TW',
    // 'Greek': 'el-GR',
    // 'Russian': 'ru-RU',
    // 'English (Ireland)': 'en-IE',
    // 'Catalan': 'ca-ES',
    // 'Portuguese (Portugal)': 'pt-PT',
    // 'Thai': 'th-TH',
    // 'Croatian': 'hr-HR',
    // 'Slovak': 'sk-SK',
    'Hindi': 'hi-IN',
    // 'Ukrainian': 'uk-UA',
    // 'Cantonese (Hong Kong)': 'zh-HK',
    // 'Polish': 'pl-PL',
    // 'Czech': 'cs-CZ',
    // 'Hungarian': 'hu-HU',
    // 'Turkish': 'tr-TR',
    // 'Korean': 'ko-KR',
    // 'Danish': 'da-DK',
    // 'Norwegian': 'nb-NO',
    // 'English (South Africa)': 'en-ZA',
    'Spanish (US)': 'es-US',

  };
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  List<String> _selectedLanguages = [];
  List<String> get selectedLanguages => _selectedLanguages;

  bool _speechToTextEnabled = true;
  String _voice_code = 'de-DE-FlorianMultilingualNeural';
  bool get speechToTextEnabled => _speechToTextEnabled;
  // New properties for AgentConfig
  String _name = 'HAIVA';
  String _description = 'ABOUT HAIVA AGENT';
  String _displayName = 'HAIVA';
  String _image = 'https://console.haiva.ai/assets/images/haiva.png';
  Map<String, dynamic> _colors = {
    'primary': '#19427D',
    'secondary': '#FFFFFF',
    'accent': '#000000',
  };

  String get name =>_name;
  String get description => _description;
  String get displayName => _displayName;
  String get image => _image;
  String get voice_code => _voice_code;
  Map<String, dynamic> get colors => _colors;
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  final AgentService _agentService =  AgentService();

  List<Agent> _agents = [];

  List<Agent> get agents => _agents;

  Future<Agent> getAgentById(String agentId) async {
    try {
      final agent = await _agentService.getAgentById(agentId);
      print("agent in settings ${agent.name}");
      return agent;
    } catch (e) {
      print('Error fetching agent: $e');
      rethrow;
    }
  }
  Future<void> fetchAgents(String s) async {
    _agents = await _agentService.getAgents();
    print("agents fetch from provider---${_agents}");
    notifyListeners();
  }

  Future<String> createAgent(Agent agent ,String connectorName) async {
    String agentId = await _agentService.createAgent(agent , connectorName);
    agent = agent.copyWith(id: agentId);

    _agents.add(agent);
    notifyListeners();
    return agentId;

  }

  // Future<void> updateAgent(Agent agent) async {
  //   await _agentService.updateAgent(agent);
  //   int index = _agents.indexWhere((a) => a.id == agent.id);
  //   if (index != -1) {
  //     _agents[index] = agent;
  //     notifyListeners();
  //   }
  // }
  Map<String, dynamic> _tempAgentData = {};



  Future<void> deleteAgent(String id) async {
    await _agentService.deleteAgent(id);
    _agents.removeWhere((agent) => agent.id == id);
    notifyListeners();
  }

  List<Agent> searchAgents(String query) {
    return _agents.where((agent) =>
    agent.name?.toLowerCase().contains(query.toLowerCase())??false).toList();
  }


  void toggleLanguageSelection(String language) {
    if (_selectedLanguages.contains(language)) {
      _selectedLanguages.remove(language);
    } else {
      _selectedLanguages.add(language);
    }
    notifyListeners();
  }

  void updateVoiceCode(code) {
    _voice_code = code;
  }

  void toggleSpeechToText(bool value) {
    _speechToTextEnabled = value;
    notifyListeners();
  }
  List<String> getSelectedLanguageCodes() {
    return _selectedLanguages.map((lang) => languageCodes[lang]!).toList();
  }

  //
  // List<String> getSelectedLanguageCodes() {
  //   print("Selected languages: $_selectedLanguages");
  //   print("Language codes: $languageCodes");
  //   print("Language codes for selected languages: ${_selectedLanguages.map((lang) => languageCodes[lang]!).toList()}");
  //   return _selectedLanguages.map((lang) => languageCodes[lang]!).toList();
  // }

  // New methods for AgentConfig
  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void setDisplayName(String value) {
    _displayName = value;
    notifyListeners();
  }

  void setImage(String value) {
    _image = value;
    notifyListeners();
  }

  void setColors(Map<String, String> value) {
    _colors = value;
    notifyListeners();
  }
  // void updateAgentConfig(AgentConfigs config) {
  //   _name = config.displayName ?? _name;
  //   _description = config.description ?? _description;
  //   _displayName = config.displayName ?? _displayName;
  //   _image = config.image ?? _image;
  //   _colors = config.colors ?? _colors;
  //   _selectedLanguages = config.languages?.map((code) => languageCodes.entries.firstWhere((entry) => entry.value == code, orElse: () => MapEntry(code, code)).key).toList() ?? _selectedLanguages;
  //   _speechToTextEnabled = config.isSpeech2text ?? _speechToTextEnabled;
  //   _voice_code = config.voice_code ?? _voice_code;
  //   notifyListeners();
  // }

  String getAllAgentIdsAsString() {
    return _agents
        .map((agent) => agent.id)
        .where((id) => id != null)
        .cast<String>()
        .join(',');
  }

}