import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

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
      print('Найден принтер: ${printer.id} (${printer.connectionType})');
    });

    // Поиск только USB принтеров
    final filter = PrinterDiscoveryFilter(
      connectionTypes: [DiscoveryConnectionType.usb],
    );
    final filteredStream = manager.findPrinters(filter: filter);
    filteredStream.listen((printer) {
      print('Найден USB принтер: ${printer.id}');
    });

    // Ожидание завершения поиска
    await manager.awaitDiscoveryComplete();
    print('Поиск принтеров завершен');
  }

  /// Мониторинг событий подключения/отключения
  void monitorConnectionEvents() {
    manager.connectionEvents.listen((event) {
      switch (event.type) {
        case PrinterConnectionEventType.attached:
          print('Принтер подключен: ${event.printer?.id}');
          break;
        case PrinterConnectionEventType.detached:
          print('Принтер отключен: ${event.printer?.id}');
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
      print('Статус принтера: ${status.status}');
    } else {
      print('Ошибка получения статуса: ${status.errorMessage}');
    }

    // Серийный номер
    final snResult = await manager.getPrinterSN(printer);
    if (snResult.success) {
      print('Серийный номер: ${snResult.value}');
    }

    // ZPL статус (только для ZPL принтеров)
    try {
      final zplStatus = await manager.getZPLPrinterStatus(printer);
      if (zplStatus.success) {
        print('ZPL статус код: ${zplStatus.code}');
      }
    } catch (e) {
      print('Принтер не поддерживает ZPL: $e');
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
      print('HTML чек напечатан успешно');
    } catch (e) {
      print('Ошибка печати HTML чека: $e');
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
      print('Сырые ESC/POS команды напечатаны');
    } catch (e) {
      print('Ошибка печати сырых команд: $e');
    }
  }

  // === ZPL LABEL PRINTING ===

  /// Печать HTML этикетки
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
      print('HTML этикетка напечатана');
    } catch (e) {
      print('Ошибка печати HTML этикетки: $e');
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
      print('Сырые ZPL команды напечатаны');
    } catch (e) {
      print('Ошибка печати ZPL команд: $e');
    }
  }

  // === CASH DRAWER ===

  /// Открытие денежного ящика
  Future<void> openCashDrawer(PrinterConnectionParamsDTO printer) async {
    try {
      await manager.openCashBox(printer);
      print('Денежный ящик открыт');
    } catch (e) {
      print('Ошибка открытия денежного ящика: $e');
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
      print('Сетевые настройки применены через USB');
    } catch (e) {
      print('Ошибка конфигурации сети: $e');
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
      print('Сетевые настройки применены через UDP');
    } catch (e) {
      print('Ошибка UDP конфигурации: $e');
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
      print('Все задания печати выполнены успешно');
    } catch (e) {
      print('Ошибка в стресс-тесте: $e');
    }
  }

  // === COMPLETE EXAMPLE ===

  /// Полный пример использования
  Future<void> completeExample() async {
    await initialize();

    // Мониторинг событий
    monitorConnectionEvents();

    // Поиск принтеров
    print('=== Поиск принтеров ===');
    await discoverPrinters();

    // Используем первый найденный принтер
    final discoveryStream = manager.findPrinters(filter: null);
    PrinterConnectionParamsDTO? printer;

    await for (final foundPrinter in discoveryStream) {
      printer = foundPrinter;
      break; // Берем первый найденный
    }

    if (printer == null) {
      print('Принтеры не найдены');
      return;
    }

    print('=== Проверка статуса ===');
    await checkPrinterStatus(printer);

    print('=== Печать чека ===');
    await printReceiptHTML(printer);

    print('=== Печать сырых команд ===');
    await printRawESC(printer);

    print('=== Открытие денежного ящика ===');
    await openCashDrawer(printer);

    // Примечание: для ZPL принтеров можно использовать методы printLabelHTML и printRawZPL
    // Раскомментируйте, если ваш принтер поддерживает ZPL
    // print('=== Печать этикетки ===');
    // await printLabelHTML(printer);
    // await printRawZPL(printer);

    print('=== Пример завершен ===');
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
  _ExampleAppState createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
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
      print('Ошибка в примере: $e');
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
