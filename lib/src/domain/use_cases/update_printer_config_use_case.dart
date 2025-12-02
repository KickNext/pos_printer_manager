/// Use Case для обновления конфигурации принтера.
///
/// Позволяет изменить имя и настройки принтера.
///
/// ## Пример использования:
///
/// ```dart
/// final useCase = UpdatePrinterConfigUseCase(
///   getPrinters: () => printersList,
///   saveConfigs: (configs) => repository.saveConfigs(configs),
/// );
///
/// final result = await useCase(UpdatePrinterParams(
///   printerId: 'printer-123',
///   name: 'New Printer Name',
/// ));
///
/// result.when(
///   success: (config) => print('Updated: ${config.name}'),
///   failure: (error) => print('Error: ${error.message}'),
/// );
/// ```
library;

import 'package:pos_printer_manager/src/core/core.dart';
import 'package:pos_printer_manager/src/domain/use_cases/use_case.dart';
import 'package:pos_printer_manager/src/models/pos_printer.dart';
import 'package:pos_printer_manager/src/models/printer_config.dart';

/// Параметры для обновления конфигурации принтера.
class UpdatePrinterParams {
  /// ID принтера для обновления.
  final String printerId;

  /// Новое имя принтера (если требуется изменить).
  final String? name;

  /// Новые настройки (если требуется изменить).
  final Map<String, dynamic>? settings;

  /// Создает параметры для обновления принтера.
  const UpdatePrinterParams({
    required this.printerId,
    this.name,
    this.settings,
  });
}

/// Use Case для обновления конфигурации принтера.
class UpdatePrinterConfigUseCase
    with LoggerMixin
    implements UseCase<UpdatePrinterParams, PrinterConfig> {
  /// Callback для получения текущего списка принтеров.
  final List<PosPrinter> Function() _getPrinters;

  /// Callback для сохранения всех конфигураций.
  final Future<void> Function(List<PrinterConfig>) _saveConfigs;

  /// Создает Use Case для обновления конфигурации принтера.
  UpdatePrinterConfigUseCase({
    required List<PosPrinter> Function() getPrinters,
    required Future<void> Function(List<PrinterConfig>) saveConfigs,
  }) : _getPrinters = getPrinters,
       _saveConfigs = saveConfigs;

  @override
  String get loggerName => 'UpdatePrinterConfigUseCase';

  @override
  Future<Result<PrinterConfig>> call(UpdatePrinterParams params) async {
    logger.info(
      'Updating printer config',
      data: {
        'printerId': params.printerId,
        'hasName': params.name != null,
        'hasSettings': params.settings != null,
      },
    );

    // Валидация
    if (params.printerId.trim().isEmpty) {
      logger.warning('Validation failed: empty printer ID');
      return const Result.failure(
        AppError.validation('Printer ID cannot be empty'),
      );
    }

    if (params.name != null && params.name!.trim().isEmpty) {
      logger.warning('Validation failed: empty name');
      return const Result.failure(
        AppError.validation('Printer name cannot be empty'),
      );
    }

    // Проверка что есть что обновлять
    if (params.name == null && params.settings == null) {
      logger.warning('Validation failed: nothing to update');
      return const Result.failure(AppError.validation('Nothing to update'));
    }

    try {
      // Поиск принтера
      final printers = _getPrinters();
      final printer = printers
          .where((p) => p.id == params.printerId)
          .firstOrNull;

      if (printer == null) {
        logger.warning(
          'Printer not found',
          data: {'printerId': params.printerId},
        );
        return Result.failure(
          AppError.notFound('Printer with ID ${params.printerId} not found'),
        );
      }

      // Создаём новую immutable конфигурацию с обновлёнными полями
      var newConfig = printer.config;

      // Обновление имени
      if (params.name != null) {
        newConfig = newConfig.copyWith(name: params.name!.trim());
      }

      // Обновление настроек
      if (params.settings != null) {
        newConfig = newConfig.copyWith(
          rawSettings: Map<String, dynamic>.unmodifiable(
            Map<String, dynamic>.from(params.settings!),
          ),
        );
      }

      // Применяем новую конфигурацию к принтеру
      printer.updateConfig(newConfig);

      // Сохранение
      final allConfigs = printers.map((p) => p.config).toList();
      await _saveConfigs(allConfigs);

      logger.info(
        'Printer config updated',
        data: {'printerId': params.printerId, 'name': printer.config.name},
      );

      return Result.success(printer.config);
    } catch (e, st) {
      logger.error('Failed to update printer config', error: e, stackTrace: st);
      return Result.failure(AppError.fromException(e, st));
    }
  }
}
