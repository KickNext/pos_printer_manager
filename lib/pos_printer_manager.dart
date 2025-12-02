/// Библиотека управления POS-принтерами для Flutter.
///
/// Предоставляет комплексное решение для работы с различными типами
/// POS-принтеров: чековые, кухонные, этикеточные и AndroBar.
///
/// ## Основные возможности:
///
/// - **Управление принтерами** — добавление, настройка, удаление
/// - **Поиск устройств** — автоматическое обнаружение принтеров в сети
/// - **Печать** — поддержка разных типов заданий (чеки, этикетки, кухонные талоны)
/// - **UI компоненты** — готовые виджеты для управления принтерами
///
/// ## Быстрый старт:
///
/// ```dart
/// import 'package:pos_printer_manager/pos_printer_manager.dart';
///
/// // Инициализация менеджера
/// final manager = PrinterManager(
///   repository: SharedPrefsPrinterConfigRepository(),
/// );
/// await manager.init();
///
/// // Добавление принтера
/// final result = await manager.addPrinter(
///   AddPrinterParams(
///     name: 'Kitchen Printer',
///     type: PrinterType.kitchen,
///     address: '192.168.1.100',
///     port: 9100,
///   ),
/// );
///
/// // Обработка результата
/// result.fold(
///   onSuccess: (printer) => print('Принтер добавлен: ${printer.id}'),
///   onFailure: (error) => print('Ошибка: ${error.message}'),
/// );
/// ```
///
/// ## Архитектура:
///
/// Библиотека построена на принципах Clean Architecture:
///
/// - **Core** — базовые утилиты (Result, Logger, IdGenerator)
/// - **Domain** — Use Cases (AddPrinter, UpdatePrinter, DeletePrinter)
/// - **Models** — модели данных (PrinterConfig, PosPrinter)
/// - **Plugins** — плагины для разных типов принтеров
/// - **Repository** — абстракция хранения данных
/// - **UI** — Flutter виджеты (Atomic Design)
///
/// ## Паттерн Result:
///
/// Все асинхронные операции возвращают `Result<T>` для явной обработки ошибок:
///
/// ```dart
/// final result = await manager.updatePrinter(params);
///
/// // Через fold
/// result.fold(
///   onSuccess: (printer) => handleSuccess(printer),
///   onFailure: (error) => handleError(error),
/// );
///
/// // Или через свойства
/// if (result.isSuccess) {
///   final printer = result.value;
/// } else {
///   final error = result.error;
/// }
/// ```
///
/// ## Типы принтеров:
///
/// - [PrinterType.receipt] — чековые принтеры для POS-систем
/// - [PrinterType.kitchen] — кухонные принтеры для ресторанов
/// - [PrinterType.label] — этикеточные принтеры (TSPL, ZPL)
/// - [PrinterType.androBar] — принтеры для баров (AndroBar)
///
/// См. также:
/// - [PrinterManager] — основной класс для управления принтерами
/// - [PrintersFinder] — поиск принтеров в сети
/// - [PrinterPluginRegistry] — реестр плагинов принтеров
library;

// Core utilities
export 'src/core/core.dart';

// Domain layer - Use Cases
export 'src/domain/domain.dart';

// Core manager and models
export 'src/manager.dart';
export 'src/models/label_printer_language.dart';
export 'src/models/pos_printer.dart';
export 'src/models/printer_config.dart';

// Plugins
export 'src/plugins/andro_bar_printer/andro_bar_printer_plugin.dart';
export 'src/plugins/category_for_printer.dart';
export 'src/plugins/kitchen_printer/kitchen_printer_plugin.dart';
export 'src/plugins/label_printer/label_printer_plugin.dart';
export 'src/plugins/label_printer/label_builder.dart';
export 'src/plugins/printer_connection_params_extension.dart';
export 'src/plugins/printer_settings.dart';
export 'src/plugins/printer_type.dart';
export 'src/plugins/receipt_printer/receipt_printer_plugin.dart';

// Discovery and protocol
export 'src/printers_finder.dart';
export 'src/protocol/handler.dart';
export 'src/protocol/print_job.dart';

// Registry and repository
export 'src/registry/registry.dart';
export 'src/repository/repository.dart';
export 'src/repository/shared_prefs_repo.dart';

// UI Components - Atomic Design
export 'src/ui/atoms/atoms.dart';
export 'src/ui/molecules/molecules.dart';
export 'src/ui/organisms/organisms.dart';

// UI Pages and Screens
export 'src/ui/printers_page.dart';
export 'src/ui/printer_detail_screen.dart';

// Dependencies
export 'package:pos_printers/pos_printers.dart';
// test
