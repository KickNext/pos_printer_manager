/// Реализация [PrinterConfigRepository] на основе SharedPreferences.
///
/// Использует JSON-сериализацию для хранения конфигураций принтеров
/// в SharedPreferences. Подходит для небольшого количества принтеров
/// (до нескольких десятков).
///
/// ## Формат хранения:
///
/// Конфигурации сохраняются как JSON-массив в ключе `pos_printer_configs`:
/// ```json
/// [
///   {
///     "id": "printer-1",
///     "name": "Receipt Printer",
///     "printerPosType": "receiptPrinter",
///     "rawSettings": {...}
///   }
/// ]
/// ```
///
/// ## Пример использования:
///
/// ```dart
/// final repository = SharedPrefsPrinterConfigRepository();
///
/// // Загрузка всех конфигураций
/// final configs = await repository.loadConfigs();
///
/// // Добавление нового принтера
/// await repository.upsert(PrinterConfig(
///   id: 'printer-1',
///   name: 'Kitchen Printer',
///   printerPosType: PrinterPOSType.kitchenPrinter,
///   rawSettings: {},
/// ));
/// ```
library;

import 'dart:convert';

import 'package:pos_printer_manager/src/core/logger.dart';
import 'package:pos_printer_manager/src/models/printer_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'repository.dart';

/// Реализация репозитория на основе SharedPreferences.
///
/// Предоставляет персистентное хранение конфигураций принтеров
/// с использованием асинхронного API SharedPreferences.
class SharedPrefsPrinterConfigRepository
    with LoggerMixin
    implements PrinterConfigRepository {
  /// Ключ для хранения данных в SharedPreferences.
  static const _storageKey = 'pos_printer_configs';

  /// Асинхронный интерфейс SharedPreferences.
  final _prefs = SharedPreferencesAsync();

  @override
  String get loggerName => 'PrinterConfigRepository';

  @override
  Future<List<PrinterConfig>> loadConfigs() async {
    logger.debug('Loading printer configs');

    try {
      final data = await _prefs.getString(_storageKey);
      if (data == null || data.isEmpty) {
        logger.debug('No stored configs found');
        return [];
      }

      final list = jsonDecode(data) as List<dynamic>;
      final configs = <PrinterConfig>[];

      for (final item in list) {
        try {
          configs.add(PrinterConfig.fromJson(item as Map<String, dynamic>));
        } catch (e, st) {
          // Пропускаем некорректные конфигурации, но логируем ошибку
          logger.warning(
            'Failed to parse printer config',
            error: e,
            stackTrace: st,
            data: {'item': item.toString()},
          );
        }
      }

      logger.info('Loaded printer configs', data: {'count': configs.length});
      return configs;
    } catch (e, st) {
      logger.error('Failed to load configs', error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<void> saveConfigs(List<PrinterConfig> configs) async {
    logger.debug('Saving printer configs', data: {'count': configs.length});

    try {
      final data = configs.map((c) => c.toJson()).toList();
      await _prefs.setString(_storageKey, jsonEncode(data));
      logger.info('Saved printer configs', data: {'count': configs.length});
    } catch (e, st) {
      logger.error('Failed to save configs', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<PrinterConfig?> findById(String id) async {
    if (id.trim().isEmpty) {
      logger.warning('findById called with empty ID');
      return null;
    }

    final configs = await loadConfigs();
    final config = configs.where((c) => c.id == id).firstOrNull;

    if (config == null) {
      logger.debug('Printer not found', data: {'id': id});
    }

    return config;
  }

  @override
  Future<void> upsert(PrinterConfig config) async {
    logger.debug(
      'Upserting printer config',
      data: {'id': config.id, 'name': config.name},
    );

    final configs = await loadConfigs();
    final index = configs.indexWhere((c) => c.id == config.id);

    if (index >= 0) {
      // Обновляем существующую конфигурацию
      configs[index] = config;
      logger.debug('Updated existing config', data: {'id': config.id});
    } else {
      // Добавляем новую конфигурацию
      configs.add(config);
      logger.debug('Added new config', data: {'id': config.id});
    }

    await saveConfigs(configs);
  }

  @override
  Future<bool> deleteById(String id) async {
    if (id.trim().isEmpty) {
      logger.warning('deleteById called with empty ID');
      return false;
    }

    logger.debug('Deleting printer config', data: {'id': id});

    final configs = await loadConfigs();
    final initialLength = configs.length;
    configs.removeWhere((c) => c.id == id);

    if (configs.length == initialLength) {
      logger.debug('Printer not found for deletion', data: {'id': id});
      return false;
    }

    await saveConfigs(configs);
    logger.info('Deleted printer config', data: {'id': id});
    return true;
  }

  @override
  Future<bool> exists(String id) async {
    if (id.trim().isEmpty) return false;

    final configs = await loadConfigs();
    return configs.any((c) => c.id == id);
  }

  @override
  Future<int> count() async {
    final configs = await loadConfigs();
    return configs.length;
  }

  @override
  Future<void> clear() async {
    logger.warning('Clearing all printer configs');
    await _prefs.remove(_storageKey);
    logger.info('All printer configs cleared');
  }
}
