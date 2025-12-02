/// Use Case для удаления принтера.
///
/// Удаляет принтер из списка и сохраняет изменения в репозитории.
///
/// ## Пример использования:
///
/// ```dart
/// final useCase = RemovePrinterUseCase(
///   repository: repository,
///   getPrinters: () => printersList,
///   saveConfigs: (configs) => repository.saveConfigs(configs),
/// );
///
/// final result = await useCase('printer-123');
///
/// result.when(
///   success: (_) => print('Printer removed'),
///   failure: (error) => print('Error: ${error.message}'),
/// );
/// ```
library;

import 'package:pos_printer_manager/src/core/core.dart';
import 'package:pos_printer_manager/src/domain/use_cases/use_case.dart';
import 'package:pos_printer_manager/src/models/pos_printer.dart';
import 'package:pos_printer_manager/src/models/printer_config.dart';

/// Use Case для удаления принтера.
class RemovePrinterUseCase with LoggerMixin implements UseCase<String, void> {
  /// Callback для получения текущего списка принтеров.
  final List<PosPrinter> Function() _getPrinters;

  /// Callback для удаления принтера из списка.
  final void Function(String id) _removePrinter;

  /// Callback для сохранения всех конфигураций.
  final Future<void> Function(List<PrinterConfig>) _saveConfigs;

  /// Создает Use Case для удаления принтера.
  RemovePrinterUseCase({
    required List<PosPrinter> Function() getPrinters,
    required void Function(String id) removePrinter,
    required Future<void> Function(List<PrinterConfig>) saveConfigs,
  }) : _getPrinters = getPrinters,
       _removePrinter = removePrinter,
       _saveConfigs = saveConfigs;

  @override
  String get loggerName => 'RemovePrinterUseCase';

  @override
  Future<Result<void>> call(String printerId) async {
    logger.info('Removing printer', data: {'printerId': printerId});

    // Валидация ID
    if (printerId.trim().isEmpty) {
      logger.warning('Validation failed: empty printer ID');
      return const Result.failure(
        AppError.validation('Printer ID cannot be empty'),
      );
    }

    try {
      // Проверяем существование принтера
      final printers = _getPrinters();
      final exists = printers.any((p) => p.id == printerId);

      if (!exists) {
        logger.warning('Printer not found', data: {'printerId': printerId});
        return Result.failure(
          AppError.notFound('Printer with ID $printerId not found'),
        );
      }

      // Удаляем принтер
      _removePrinter(printerId);

      // Сохраняем обновленный список
      final remainingConfigs = _getPrinters().map((p) => p.config).toList();
      await _saveConfigs(remainingConfigs);

      logger.info(
        'Printer removed successfully',
        data: {'printerId': printerId},
      );

      return const Result.success(null);
    } catch (e, st) {
      logger.error('Failed to remove printer', error: e, stackTrace: st);
      return Result.failure(AppError.fromException(e, st));
    }
  }
}
