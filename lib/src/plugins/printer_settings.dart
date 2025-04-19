import 'package:flutter/cupertino.dart';
import 'package:pos_printers/pos_printers.dart';

abstract class PrinterSettings {
  final PrinterConnectionParams connectionParams;

  PrinterSettings({required this.connectionParams});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'connectionParams': connectionParams.encode(),
    };
    map.addAll(extraSettingsToJson);
    return map;
  }

  @protected
  Map<String, dynamic> get extraSettingsToJson;

  /// Декодирование настроек через переданный фабричный метод.
  /// Creator получает параметры подключения и полный JSON для разбора дополнительных полей.
  static T fromJson<T extends PrinterSettings>(
    Map<String, dynamic> json,
    T Function(PrinterConnectionParams params, Map<String, dynamic> json)
    creator,
  ) {
    final cp = PrinterConnectionParams.decode(json['connectionParams']);
    return creator(cp, json);
  }
}
