// Реализация репозитория через SharedPreferences
import 'dart:convert';

import 'package:pos_printer_manager/src/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'repository.dart';

class SharedPrefsPrinterConfigRepository implements PrinterConfigRepository {
  static const _storageKey = 'pos_printer_configs';
  final _prefs = SharedPreferencesAsync();

  @override
  Future<List<PrinterConfig>> loadConfigs() async {
    final data = await _prefs.getString(_storageKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List<dynamic>;
    return list
        .map((e) => PrinterConfig.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveConfigs(List<PrinterConfig> configs) async {
    final data = configs.map((c) => c.toJson()).toList();
    await _prefs.setString(_storageKey, jsonEncode(data));
  }
}
