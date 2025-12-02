import 'package:flutter/cupertino.dart';
import 'package:pos_printer_manager/src/plugins/printer_connection_params_extension.dart';
import 'package:pos_printers/pos_printers.dart';

abstract class PrinterSettings {
  PrinterConnectionParamsDTO? _connectionParams;
  final Future<void> Function() onSettingsChanged;

  PrinterConnectionParamsDTO? get connectionParams => _connectionParams;

  PrinterSettings({
    required PrinterConnectionParamsDTO? initConnectionParams,
    required this.onSettingsChanged,
  }) {
    _connectionParams = initConnectionParams;
  }

  PrinterDiscoveryFilter get discoveryFilter;

  IconData get icon;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'connectionParams': connectionParams?.toJson(),
    };
    map.addAll(extraSettingsToJson);
    return map;
  }

  Future<void> updateConnectionParams(
    PrinterConnectionParamsDTO? newConnectionParams,
  ) async {
    _connectionParams = newConnectionParams;
    await onSettingsChanged();
  }

  @protected
  Map<String, dynamic> get extraSettingsToJson;

  static T fromJson<T extends PrinterSettings>(
    Map<String, dynamic> json,
    T Function(PrinterConnectionParamsDTO? params, Map<String, dynamic> json)
    creator,
  ) {
    PrinterConnectionParamsDTO? pcp;
    final pcpJson = json['connectionParams'] as Map<String, dynamic>?;
    if (pcpJson != null) {
      pcp = PrinterConnectionParamsExtension.fromJson(json['connectionParams']);
    }
    return creator(pcp, json);
  }
}
