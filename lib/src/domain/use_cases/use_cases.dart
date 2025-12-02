/// Экспорт всех Use Cases для работы с принтерами.
///
/// Use Cases инкапсулируют бизнес-логику приложения и обеспечивают
/// чистое разделение между слоями приложения.
///
/// ## Основные Use Cases:
///
/// ### Управление принтерами
/// - [AddPrinterUseCase] - добавление нового принтера
/// - [RemovePrinterUseCase] - удаление принтера
/// - [GetPrinterUseCase] - получение принтера по ID
/// - [UpdatePrinterConfigUseCase] - обновление конфигурации
///
/// ### Печать
/// - [PrintUseCase] - выполнение печати
///
/// ### Диагностика
/// - [TestPrinterConnectionUseCase] - тестирование подключения
///
/// ## Пример использования:
///
/// ```dart
/// import 'package:pos_printer_manager/src/domain/use_cases/use_cases.dart';
///
/// // Создание Use Cases с зависимостями
/// final addPrinterUseCase = AddPrinterUseCase(
///   repository: repository,
///   printerFactory: factory,
///   saveConfigs: manager.saveConfigs,
///   getPrinters: () => manager.printers,
/// );
///
/// // Использование
/// final result = await addPrinterUseCase(AddPrinterParams(
///   name: 'Kitchen Printer',
///   type: PrinterPOSType.kitchenPrinter,
/// ));
///
/// result.when(
///   success: (printer) => print('Created'),
///   failure: (error) => print('Error: ${error.message}'),
/// );
/// ```
library;

export 'use_case.dart';
export 'add_printer_use_case.dart';
export 'get_printer_use_case.dart';
export 'print_use_case.dart';
export 'remove_printer_use_case.dart';
export 'test_printer_connection_use_case.dart';
export 'update_printer_config_use_case.dart';
