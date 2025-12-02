/// Use Case для тестирования подключения к принтеру.
///
/// Выполняет тестовую печать для проверки работоспособности
/// принтера и его подключения.
///
/// ## Пример использования:
///
/// ```dart
/// final useCase = TestPrinterConnectionUseCase(
///   getPrinters: () => printersList,
/// );
///
/// final result = await useCase('printer-123');
///
/// result.when(
///   success: (_) => print('Connection OK'),
///   failure: (error) => print('Error: ${error.message}'),
/// );
/// ```
library;

import 'package:pos_printer_manager/src/core/core.dart';
import 'package:pos_printer_manager/src/domain/use_cases/use_case.dart';
import 'package:pos_printer_manager/src/models/pos_printer.dart';

/// Use Case для тестирования подключения к принтеру.
class TestPrinterConnectionUseCase
    with LoggerMixin
    implements UseCase<String, void> {
  /// Callback для получения текущего списка принтеров.
  final List<PosPrinter> Function() _getPrinters;

  /// Создает Use Case для тестирования подключения.
  TestPrinterConnectionUseCase({
    required List<PosPrinter> Function() getPrinters,
  }) : _getPrinters = getPrinters;

  @override
  String get loggerName => 'TestPrinterConnectionUseCase';

  @override
  Future<Result<void>> call(String printerId) async {
    final stopwatch = logger.startOperation('Test connection');

    logger.info('Testing printer connection', data: {'printerId': printerId});

    // Валидация
    if (printerId.trim().isEmpty) {
      logger.warning('Validation failed: empty printer ID');
      return const Result.failure(
        AppError.validation('Printer ID cannot be empty'),
      );
    }

    try {
      // Поиск принтера
      final printers = _getPrinters();
      final printer = printers.where((p) => p.id == printerId).firstOrNull;

      if (printer == null) {
        logger.warning('Printer not found', data: {'printerId': printerId});
        return Result.failure(
          AppError.notFound('Printer with ID $printerId not found'),
        );
      }

      // Проверка наличия параметров подключения
      if (printer.handler.settings.connectionParams == null) {
        logger.warning(
          'No connection params configured',
          data: {'printerId': printerId},
        );
        return const Result.failure(
          AppError.configuration('Printer connection is not configured'),
        );
      }

      // Выполнение тестового подключения
      await printer.testConnection();

      // Проверка результата
      if (printer.status == PrinterConnectionStatus.connected) {
        logger.endOperation('Test connection', stopwatch);
        logger.info('Connection test passed', data: {'printerId': printerId});
        return const Result.success(null);
      } else {
        final errorMessage = printer.lastError?.message ?? 'Unknown error';
        logger.warning(
          'Connection test failed',
          data: {
            'printerId': printerId,
            'status': printer.status.name,
            'error': errorMessage,
          },
        );
        return Result.failure(
          AppError.connection('Connection test failed: $errorMessage'),
        );
      }
    } catch (e, st) {
      logger.error(
        'Connection test failed with exception',
        error: e,
        stackTrace: st,
      );
      return Result.failure(
        AppError.connection(e.toString(), cause: e, stackTrace: st),
      );
    }
  }
}
