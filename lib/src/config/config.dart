class PrinterConfig {
  final String id;
  final String name;
  final String settingsType;
  final Map<String, dynamic> rawSettings;

  PrinterConfig({
    required this.id,
    required this.name,
    required this.settingsType,
    required this.rawSettings,
  });

  factory PrinterConfig.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final name = json['name'] as String;
    final typeName = json['settingsType'] as String;
    final raw = Map<String, dynamic>.from(json['settings'] as Map);
    return PrinterConfig(
      id: id,
      name: name,
      settingsType: typeName,
      rawSettings: raw,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'settingsType': settingsType,
    'settings': rawSettings,
  };
}
