import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Создание и инициализация менеджера
  final manager = PrintersManager();
  await manager.init(getCategoriesFunction: categoriesFuture);

  runApp(MyApp(printerManager: manager));
}

Future<List<CategoryForPrinter>> categoriesFuture({
  required List<CategoryForPrinter> currentCategories,
}) async {
  return [
    CategoryForPrinter(id: '1', displayName: 'Category 1', color: Colors.red),
    CategoryForPrinter(id: '2', displayName: 'Category 2', color: Colors.green),
    CategoryForPrinter(id: '3', displayName: 'Category 3', color: Colors.blue),
  ];
}

class MyApp extends StatelessWidget {
  final PrintersManager printerManager;
  const MyApp({super.key, required this.printerManager});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Printer Manager Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MainScreen(printerManager: printerManager),
    );
  }
}

class MainScreen extends StatefulWidget {
  final PrintersManager printerManager;
  const MainScreen({super.key, required this.printerManager});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isDiscovering = false;
  List<PrinterConnectionParamsDTO> _discoveredPrinters = [];

  @override
  void initState() {
    super.initState();
    _setupConnectionListener();
  }

  void _setupConnectionListener() {
    widget.printerManager.connectionEvents.listen((event) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              event.type == PrinterConnectionEventType.attached
                  ? 'Принтер подключен: ${event.printer?.id}'
                  : 'Принтер отключен: ${event.printer?.id}',
            ),
          ),
        );
      }
    });
  }

  Future<void> _discoverPrinters() async {
    setState(() {
      _isDiscovering = true;
      _discoveredPrinters.clear();
    });

    try {
      final stream = widget.printerManager.findPrinters(filter: null);
      await for (final printer in stream) {
        setState(() {
          _discoveredPrinters.add(printer);
        });
      }
      await widget.printerManager.awaitDiscoveryComplete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка поиска: $e')));
      }
    } finally {
      setState(() {
        _isDiscovering = false;
      });
    }
  }

  Future<void> _testPrinter(PrinterConnectionParamsDTO printer) async {
    try {
      // Проверяем статус
      final status = await widget.printerManager.getPrinterStatus(printer);
      if (!status.success) {
        throw Exception('Принтер недоступен: ${status.errorMessage}');
      }

      // Определяем язык принтера
      final language = await widget.printerManager.checkPrinterLanguage(
        printer,
      );

      // Печатаем тестовую страницу
      final testHtml = '''
        <html>
        <body style="font-family: monospace; text-align: center;">
          <h2>ТЕСТОВАЯ ПЕЧАТЬ</h2>
          <hr>
          <p>Дата: ${DateTime.now()}</p>
          <p>Принтер: {{id}}</p>
          <hr>
          <p>Тест успешно пройден!</p>
        </body>
        </html>
      ''';

      final htmlWithId = testHtml.replaceAll('{{id}}', printer.id);

      if (language.printerLanguage == PrinterLanguage.esc) {
        await widget.printerManager.printEscHTML(
          printer,
          htmlWithId,
          PaperSize.mm80.value,
        );
      } else if (language.printerLanguage == PrinterLanguage.zpl) {
        await widget.printerManager.printZplHtml(
          printer,
          htmlWithId,
          PaperSize.mm80.value,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Тестовая печать отправлена!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка печати: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Printer Manager Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Управление принтерами (высокоуровневый API)
          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Управление принтерами',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  PrintersPage(printerManager: widget.printerManager),
                ],
              ),
            ),
          ),

          // Поиск принтеров (низкоуровневый API)
          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Поиск принтеров',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isDiscovering ? null : _discoverPrinters,
                        icon:
                            _isDiscovering
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.search),
                        label: Text(_isDiscovering ? 'Поиск...' : 'Найти'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_discoveredPrinters.isEmpty && !_isDiscovering)
                    const Text('Нажмите "Найти" для поиска принтеров')
                  else
                    ...(_discoveredPrinters.map(
                      (printer) => Card(
                        child: ListTile(
                          leading: Icon(
                            printer.connectionType ==
                                    PosPrinterConnectionType.usb
                                ? Icons.usb
                                : Icons.network_wifi,
                          ),
                          title: Text(printer.id),
                          subtitle: Text('${printer.connectionType}'),
                          trailing: ElevatedButton(
                            onPressed: () => _testPrinter(printer),
                            child: const Text('Тест'),
                          ),
                        ),
                      ),
                    )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
