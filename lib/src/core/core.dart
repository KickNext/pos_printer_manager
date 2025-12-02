/// Основные компоненты ядра приложения.
///
/// Этот модуль экспортирует базовые компоненты, используемые
/// во всем приложении:
///
/// - [Result] - типобезопасная обработка ошибок
/// - [PrinterLogger] - централизованное логирование
/// - [PrinterException] - типизированные исключения
/// - [IdGenerator] - генерация уникальных идентификаторов
///
/// ## Использование Result:
///
/// ```dart
/// import 'package:pos_printer_manager/src/core/core.dart';
///
/// Future<Result<PrinterConfig>> getPrinter(String id) async {
///   try {
///     final config = await repository.findById(id);
///     if (config == null) {
///       return Result.failure(AppError.notFound('Printer not found'));
///     }
///     return Result.success(config);
///   } catch (e, st) {
///     return Result.failure(AppError.fromException(e, st));
///   }
/// }
/// ```
///
/// ## Использование Logger:
///
/// ```dart
/// import 'package:pos_printer_manager/src/core/core.dart';
///
/// class MyService with LoggerMixin {
///   @override
///   String get loggerName => 'MyService';
///
///   void process() {
///     logger.info('Processing started');
///   }
/// }
/// ```
///
/// ## Генерация ID:
///
/// ```dart
/// import 'package:pos_printer_manager/src/core/core.dart';
///
/// final printerId = IdGenerator.generate();
/// // 'f47ac10b-58cc-4372-a567-0e02b2c3d479'
/// ```
///
/// ## Обработка исключений:
///
/// ```dart
/// try {
///   final handler = PrinterPluginRegistry.buildHandler(config);
/// } on PluginNotRegisteredException catch (e) {
///   print('Plugin not found: ${e.printerType}');
/// } on PrinterException catch (e) {
///   print('Error: ${e.message}');
/// }
/// ```
library;

export 'exceptions.dart';
export 'id_generator.dart';
export 'logger.dart';
export 'result.dart';
