// models/file_config.dart
class FileConfig {
  final String type;
  final List<FileDetail> files;
  final String vectorType;
  final String category;
  final String dbConnectionName;
  final List<String> dbTableNames;
  final String dbType;

  FileConfig({
    required this.type,
    required this.files,
    required this.vectorType,
    required this.category,
    required this.dbConnectionName,
    required this.dbTableNames,
    required this.dbType,
  });

  factory FileConfig.fromJson(Map<String, dynamic> json) {
    return FileConfig(
      type: json['type'],
      files: (json['files'] as List<dynamic>)
          .map((fileJson) => FileDetail.fromJson(fileJson))
          .toList(),
      vectorType: json['vector_type'],
      category: json['category'],
      dbConnectionName: json['db_connection_name'],
      dbTableNames: List<String>.from(json['db_table_names']),
      dbType: json['db_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'files': files.map((file) => file.toJson()).toList(),
      'vector_type': vectorType,
      'category': category,
      'db_connection_name': dbConnectionName,
      'db_table_names': dbTableNames,
      'db_type': dbType,
    };
  }
}

class FileDetail {
  final String name;
  final String path;
  final String lastModified;
  final String size;
  final String type;

  FileDetail({
    required this.name,
    required this.path,
    required this.lastModified,
    required this.size,
    required this.type,
  });

  factory FileDetail.fromJson(Map<String, dynamic> json) {
    return FileDetail(
      name: json['name'],
      path: json['path'],
      lastModified: json['last_modified'],
      size: json['size'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'last_modified': lastModified,
      'size': size,
      'type': type,
    };
  }
}
