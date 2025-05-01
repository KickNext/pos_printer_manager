import 'package:pos_printer_manager/pos_printer_manager.dart';

class PrinterConfig {
  final String id;
  String name;
  final PrinterPOSType printerPosType;
  Map<String, dynamic> rawSettings;

  PrinterConfig({
    required this.id,
    required this.name,
    required this.printerPosType,
    required this.rawSettings,
  });

  factory PrinterConfig.fromJson(Map<String, dynamic> json) {
    final typeName = json['printerPosType'] as String?;
    if (typeName == null) {
      throw Exception('Printer type is not specified in the config');
    }
    final type = PrinterPOSType.values.byName(typeName);
    return PrinterConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      printerPosType: type,
      rawSettings: Map<String, dynamic>.from(json['rawSettings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'printerPosType': printerPosType.name,
      'rawSettings': rawSettings,
    };
  }
}
