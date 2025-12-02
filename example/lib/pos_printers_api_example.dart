import 'dart:developer' as developer;
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

/// Логгер для примера API принтеров.
///
/// Использует [developer.log] для вывода сообщений, что является
/// рекомендуемым подходом вместо [print] в production коде.
class _ExampleLogger {
  /// Название логгера для фильтрации в DevTools
  static const String _loggerName = 'PosPrintersApiExample';

  /// Логирует информационное сообщение
  static void info(String message) {
    developer.log(message, name: _loggerName, level: 800);
  }

  /// Логирует сообщение об ошибке
  static void error(String message, [Object? error]) {
    developer.log(message, name: _loggerName, level: 1000, error: error);
  }
}

/// Пример полного использования API pos_printer_manager
/// Демонстрирует все возможности плагина согласно README
class PosPrintersApiExample {
  late final PrintersManager manager;

  /// Инициализация менеджера
  Future<void> initialize() async {
    manager = PrintersManager();
    await manager.init(getCategoriesFunction: _getCategoriesFunction);
  }

  /// Функция для получения категорий принтеров
  Future<List<CategoryForPrinter>> _getCategoriesFunction({
    required List<CategoryForPrinter> currentCategories,
  }) async {
    return [
      CategoryForPrinter(
        id: '1',
        displayName: 'Горячие блюда',
        color: Colors.red,
      ),
      CategoryForPrinter(
        id: '2',
        displayName: 'Холодные блюда',
        color: Colors.blue,
      ),
      CategoryForPrinter(id: '3', displayName: 'Напитки', color: Colors.green),
    ];
  }

  // === PRINTER DISCOVERY ===

  /// Поиск принтеров с фильтрацией
  Future<void> discoverPrinters() async {
    // Поиск всех принтеров
    final allPrintersStream = manager.findPrinters(filter: null);
    allPrintersStream.listen((printer) {
      _ExampleLogger.info(
        'Найден принтер: ${printer.id} (${printer.connectionType})',
      );
    });

    // Поиск только USB принтеров
    final filter = PrinterDiscoveryFilter(
      connectionTypes: [DiscoveryConnectionType.usb],
    );
    final filteredStream = manager.findPrinters(filter: filter);
    filteredStream.listen((printer) {
      _ExampleLogger.info('Найден USB принтер: ${printer.id}');
    });

    // Ожидание завершения поиска
    await manager.awaitDiscoveryComplete();
    _ExampleLogger.info('Поиск принтеров завершен');
  }

  /// Мониторинг событий подключения/отключения
  void monitorConnectionEvents() {
    manager.connectionEvents.listen((event) {
      switch (event.type) {
        case PrinterConnectionEventType.attached:
          _ExampleLogger.info('Принтер подключен: ${event.printer?.id}');
          break;
        case PrinterConnectionEventType.detached:
          _ExampleLogger.info('Принтер отключен: ${event.printer?.id}');
          break;
      }
    });
  }

  // === PRINTER STATUS ===

  /// Получение статуса принтера
  Future<void> checkPrinterStatus(PrinterConnectionParamsDTO printer) async {
    // Общий статус
    final status = await manager.getPrinterStatus(printer);
    if (status.success) {
      _ExampleLogger.info('Статус принтера: ${status.status}');
    } else {
      _ExampleLogger.error('Ошибка получения статуса: ${status.errorMessage}');
    }

    // Серийный номер
    final snResult = await manager.getPrinterSN(printer);
    if (snResult.success) {
      _ExampleLogger.info('Серийный номер: ${snResult.value}');
    }

    // ZPL статус (только для ZPL принтеров)
    try {
      final zplStatus = await manager.getZPLPrinterStatus(printer);
      if (zplStatus.success) {
        _ExampleLogger.info('ZPL статус код: ${zplStatus.code}');
      }
    } catch (e) {
      _ExampleLogger.error('Принтер не поддерживает ZPL', e);
    }
  }

  // === ESC/POS PRINTING ===

  /// Печать HTML чека
  Future<void> printReceiptHTML(PrinterConnectionParamsDTO printer) async {
    const html = '''
      <html>
      <body style="font-family: monospace; text-align: center;">
        <h2>КАССОВЫЙ ЧЕК</h2>
        <hr>
        <table width="100%">
          <tr><td>Кофе</td><td align="right">150 руб.</td></tr>
          <tr><td>Сэндвич</td><td align="right">300 руб.</td></tr>
          <tr><td>Сок</td><td align="right">80 руб.</td></tr>
        </table>
        <hr>
        <p><b>Итого: 530 руб.</b></p>
        <p>Спасибо за покупку!</p>
      </body>
      </html>
    ''';

    try {
      await manager.printEscHTML(printer, html, PaperSize.mm80.value);
      _ExampleLogger.info('HTML чек напечатан успешно');
    } catch (e) {
      _ExampleLogger.error('Ошибка печати HTML чека', e);
    }
  }

  /// Печать сырых ESC/POS команд
  Future<void> printRawESC(PrinterConnectionParamsDTO printer) async {
    final commands = <int>[
      0x1B, 0x40, // Инициализация
      0x1B, 0x61, 0x01, // Выравнивание по центру
      ...utf8.encode('ТЕСТОВАЯ ПЕЧАТЬ'),
      0x0A, 0x0A, // Перевод строки
      0x1B, 0x61, 0x00, // Выравнивание слева
      ...utf8.encode('Строка 1'),
      0x0A,
      ...utf8.encode('Строка 2'),
      0x0A, 0x0A, 0x0A,
      0x1D, 0x56, 0x42, 0x00, // Отрезка бумаги
    ];

    try {
      await manager.printEscRawData(
        printer,
        Uint8List.fromList(commands),
        PaperSize.mm80.value,
      );
      _ExampleLogger.info('Сырые ESC/POS команды напечатаны');
    } catch (e) {
      _ExampleLogger.error('Ошибка печати сырых команд', e);
    }
  }

  // === ZPL LABEL PRINTING ===

  /// Печать HTML этикетки (ZPL)
  Future<void> printLabelHTML(PrinterConnectionParamsDTO printer) async {
    const html = '''
      <html>
      <body style="font-family: Arial; padding: 10px;">
        <div style="border: 2px solid black; padding: 20px;">
          <h1>ЭТИКЕТКА ДОСТАВКИ</h1>
          <p><b>Кому:</b> Иванов И.И.</p>
          <p><b>Адрес:</b> ул. Пушкина, д. 10</p>
          <p><b>Город:</b> Москва, 123456</p>
          <div style="margin-top: 20px; font-size: 24px;">
            <b>Трек-номер: ABC123456789</b>
          </div>
        </div>
      </body>
      </html>
    ''';

    try {
      await manager.printZplHtml(printer, html, PaperSize.mm80.value);
      _ExampleLogger.info('HTML этикетка напечатана (ZPL)');
    } catch (e) {
      _ExampleLogger.error('Ошибка печати HTML этикетки', e);
    }
  }

  /// Печать сырых ZPL команд
  Future<void> printRawZPL(PrinterConnectionParamsDTO printer) async {
    const zplCommands = '''
      ^XA
      ^CFD,30
      ^FO50,50^FDТестовая этикетка^FS
      ^FO50,100^FDДата: 11.09.2025^FS
      ^FO50,150^FDНомер: 12345^FS
      ^XZ
    ''';

    try {
      await manager.printZplRawData(
        printer,
        Uint8List.fromList(utf8.encode(zplCommands)),
        PaperSize.mm80.value,
      );
      _ExampleLogger.info('Сырые ZPL команды напечатаны');
    } catch (e) {
      _ExampleLogger.error('Ошибка печати ZPL команд', e);
    }
  }

  // === TSPL LABEL PRINTING ===

  /// Печать HTML этикетки (TSPL)
  Future<void> printTsplLabelHTML(PrinterConnectionParamsDTO printer) async {
    const html = '''
      <html>
      <head>
        <style>
          body { font-family: Arial; padding: 10px; }
          h1 { font-size: 24px; text-align: center; }
        </style>
      </head>
      <body>
        <h1>Этикетка товара</h1>
        <p><b>Артикул:</b> 12345</p>
        <p><b>Название:</b> Тестовый товар</p>
        <p><b>Цена:</b> 1999.00 руб</p>
      </body>
      </html>
    ''';

    try {
      await manager.printTsplHtml(printer, html, PaperSize.mm58.value);
      _ExampleLogger.info('HTML этикетка напечатана (TSPL)');
    } catch (e) {
      _ExampleLogger.error('Ошибка печати TSPL HTML этикетки', e);
    }
  }

  /// Печать сырых TSPL команд
  Future<void> printRawTSPL(PrinterConnectionParamsDTO printer) async {
    const tsplCommands = '''
SIZE 57 mm, 32 mm
GAP 2 mm, 0 mm
DIRECTION 1
CLS
BLOCK 30,30,370,90,"3",0,0,1,0,"Тестовая этикетка"
TEXT 30,192,"2",0,1,1,"Артикул: 12345"
TEXT 30,236,"2",0,1,1,"Цена: 1999 руб"
PRINT 1
    ''';

    try {
      await manager.printTsplRawData(
        printer,
        Uint8List.fromList(utf8.encode(tsplCommands)),
        673, // 57mm width at 300 DPI (with DIRECTION 1, height becomes width)
      );
      _ExampleLogger.info('Сырые TSPL команды напечатаны');
    } catch (e) {
      _ExampleLogger.error('Ошибка печати TSPL команд', e);
    }
  }

  /// Получить статус TSPL принтера
  Future<void> getTsplPrinterStatus(PrinterConnectionParamsDTO printer) async {
    try {
      final status = await manager.getTSPLPrinterStatus(printer);
      if (status.success) {
        _ExampleLogger.info('TSPL статус код: ${status.code}');
        // Расшифровка кодов статуса:
        // 0x00 - Нормальный
        // 0x01 - Головка открыта
        // 0x04 - Нет бумаги
        // 0x08 - Нет ленты
      } else {
        _ExampleLogger.error(
          'Ошибка получения статуса: ${status.errorMessage}',
        );
      }
    } catch (e) {
      _ExampleLogger.error('Принтер не поддерживает TSPL', e);
    }
  }

  // === CASH DRAWER ===

  /// Открытие денежного ящика
  Future<void> openCashDrawer(PrinterConnectionParamsDTO printer) async {
    try {
      await manager.openCashBox(printer);
      _ExampleLogger.info('Денежный ящик открыт');
    } catch (e) {
      _ExampleLogger.error('Ошибка открытия денежного ящика', e);
    }
  }

  // === NETWORK CONFIGURATION ===

  /// Конфигурация сети через USB
  Future<void> configureNetworkViaUSB(
    PrinterConnectionParamsDTO usbPrinter,
  ) async {
    final networkParams = NetworkParams(
      ipAddress: '192.168.1.100',
      mask: '255.255.255.0',
      gateway: '192.168.1.1',
      dhcp: false,
      macAddress: null, // Автоматически определится
    );

    try {
      await manager.setNetSettings(usbPrinter, networkParams);
      _ExampleLogger.info('Сетевые настройки применены через USB');
    } catch (e) {
      _ExampleLogger.error('Ошибка конфигурации сети', e);
    }
  }

  /// Конфигурация сети через UDP
  Future<void> configureNetworkViaUDP() async {
    const macAddress = 'AA:BB:CC:DD:EE:FF';
    final networkParams = NetworkParams(
      ipAddress: '192.168.1.200',
      mask: '255.255.255.0',
      gateway: '192.168.1.1',
      dhcp: false,
      macAddress: macAddress,
    );

    try {
      await manager.configureNetViaUDP(macAddress, networkParams);
      _ExampleLogger.info('Сетевые настройки применены через UDP');
    } catch (e) {
      _ExampleLogger.error('Ошибка UDP конфигурации', e);
    }
  }

  // === STRESS TESTING ===

  /// Стресс-тест с несколькими принтерами
  Future<void> stressTestPrinting(
    List<PrinterConnectionParamsDTO> printers,
  ) async {
    final futures = <Future<void>>[];

    // Отправляем 10 заданий печати одновременно
    for (int i = 0; i < 10; i++) {
      final html =
          '<html><body><h1>Чек #$i</h1><p>Время: ${DateTime.now()}</p></body></html>';
      final printer = printers[i % printers.length];

      futures.add(manager.printEscHTML(printer, html, PaperSize.mm80.value));
    }

    try {
      await Future.wait(futures);
      _ExampleLogger.info('Все задания печати выполнены успешно');
    } catch (e) {
      _ExampleLogger.error('Ошибка в стресс-тесте', e);
    }
  }

  // === COMPLETE EXAMPLE ===

  /// Полный пример использования
  Future<void> completeExample() async {
    await initialize();

    // Мониторинг событий
    monitorConnectionEvents();

    // Поиск принтеров
    _ExampleLogger.info('=== Поиск принтеров ===');
    await discoverPrinters();

    // Используем первый найденный принтер
    final discoveryStream = manager.findPrinters(filter: null);
    PrinterConnectionParamsDTO? printer;

    await for (final foundPrinter in discoveryStream) {
      printer = foundPrinter;
      break; // Берем первый найденный
    }

    if (printer == null) {
      _ExampleLogger.info('Принтеры не найдены');
      return;
    }

    _ExampleLogger.info('=== Проверка статуса ===');
    await checkPrinterStatus(printer);

    _ExampleLogger.info('=== Печать чека ===');
    await printReceiptHTML(printer);

    _ExampleLogger.info('=== Печать сырых команд ===');
    await printRawESC(printer);

    _ExampleLogger.info('=== Открытие денежного ящика ===');
    await openCashDrawer(printer);

    // Примечание: для ZPL принтеров можно использовать методы printLabelHTML и printRawZPL
    // Раскомментируйте, если ваш принтер поддерживает ZPL
    // _ExampleLogger.info('=== Печать этикетки ===');
    // await printLabelHTML(printer);
    // await printRawZPL(printer);

    _ExampleLogger.info('=== Пример завершен ===');
  }

  /// Освобождение ресурсов
  void dispose() {
    manager.dispose();
  }
}

// Пример использования в Flutter приложении
class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  ExampleAppState createState() => ExampleAppState();
}

/// Состояние для примера приложения POS принтеров.
///
/// Демонстрирует инициализацию и использование API принтеров.
class ExampleAppState extends State<ExampleApp> {
  final _example = PosPrintersApiExample();

  @override
  void initState() {
    super.initState();
    _runExample();
  }

  Future<void> _runExample() async {
    try {
      await _example.completeExample();
    } catch (e) {
      _ExampleLogger.error('Ошибка в примере', e);
    }
  }

  @override
  void dispose() {
    _example.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('POS Printers API Example')),
        body: Center(child: Text('Проверьте логи для результатов API вызовов')),
      ),
    );
  }
}
