import 'fileconfig.dart';

class Agent {
  final String? id;
  final String? name;
  final String? description;
  final String? type;
  final bool? isActive;
  final bool? isDeployed;
  final AgentConfigs? agentConfigs;

  Agent({
    required this.id,
    this.name,
    this.description,
    this.type,
    this.isActive,
    this.isDeployed,
    required this.agentConfigs,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['agent_id'] ?? '',
      // Provide default value if null
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      isActive: json['is_active'],
      isDeployed: json['is_deployed'],
      agentConfigs: json['agent_configs'] != null
          ? AgentConfigs.fromJson(json['agent_configs'])
          : AgentConfigs(
              displayName: '',
              description: '',
              isSpeech2text: true,
              languages: [],
              customQuestions: [],
              colors: {},
            ), // Provide default `AgentConfigs` if null
    );
  }

  Agent copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    bool? isActive,
    bool? isDeployed,
    AgentConfigs? agentConfigs,
  }) {
    return Agent(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      isDeployed: isDeployed ?? this.isDeployed,
      agentConfigs: agentConfigs ?? this.agentConfigs,
    );
  }
}

class AgentConfigs {
  final String? displayName;
  final String? description;
  final String? image;
  final FileConfig? fileConfig; // Optional fileConfig
  final List<dynamic>? customQuestions; // Custom questions field
  final bool? isSpeech2text; // Speech-to-text field
  final List<String>? languages; // Languages field
  final Map<String, dynamic>? colors; // Colors field

  AgentConfigs({
    this.displayName,
    this.description,
    this.image,
    this.fileConfig, // Optional fileConfig
    this.customQuestions,
    this.isSpeech2text,
    this.languages,
    this.colors,
  });

  factory AgentConfigs.fromJson(Map<String, dynamic> json) {
    return AgentConfigs(
      displayName: json['display_name'] ?? '',
      // Default to empty string if null
      description: json['description'] ?? '',
      image: json['image'],
      // Nullable field
      fileConfig: json.containsKey('file_config')
          ? FileConfig.fromJson(json['file_config'])
          : null,
      customQuestions: json['custom_questions'] != null
          ? List<dynamic>.from(json['custom_questions'])
          : [],
      // Default to empty list if not present
      isSpeech2text: json['is_speech2text'] ?? false,
      languages:
          json['languages'] != null ? List<String>.from(json['languages']) : [],
      // Default to empty list if not present
      colors: json['colors'] != null
          ? Map<String, dynamic>.from(json['colors'])
          : {}, // Default to empty map if not present
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'display_name': displayName,
      'description': description,
      'image': image,
      'custom_questions': customQuestions,
      'is_speech2text': isSpeech2text,
      'languages': languages,
      'colors': colors,
    };
    if (fileConfig != null) {
      data['file_config'] = fileConfig!.toJson();
    }
    return data;
  }

  AgentConfigs copyWith({
    String? displayName,
    String? description,
    String? image,
    FileConfig? fileConfig,
    List<dynamic>? customQuestions,
    bool? isSpeech2text,
    List<String>? languages,
    Map<String, dynamic>? colors, // Correct type here
  }) {
    return AgentConfigs(
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      image: image ?? this.image,
      fileConfig: fileConfig ?? this.fileConfig,
      customQuestions: customQuestions ?? this.customQuestions,
      isSpeech2text: isSpeech2text ?? this.isSpeech2text,
      languages: languages ?? this.languages,
      colors: colors ?? this.colors,
    );
  }
}
