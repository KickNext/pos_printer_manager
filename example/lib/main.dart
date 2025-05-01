import 'package:example/create_printer_dialog.dart';
import 'package:example/printer_card.dart';
import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Создание и инициализация менеджера
  final manager = PrintersManager();
  await manager.init();

  runApp(MyApp(printerManager: manager));
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
      home: MyHomePage(
        title: 'Printer Manager example test',
        printerManager: printerManager,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final PrintersManager printerManager;
  const MyHomePage({
    super.key,
    required this.title,
    required this.printerManager,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    widget.printerManager.addListener(update);
    super.initState();
  }

  void update() {
    setState(() {});
  }

  Future<void> onAddPrinter() async {
    await showDialog(
      context: context,
      builder:
          (context) =>
              CreatePrinterDialog(printerManager: widget.printerManager),
    );
    setState(() {});
  }

  @override
  void dispose() {
    widget.printerManager.removeListener(update);
    super.dispose();
  }

  Future<void> rundomPrint() async {
    final indexes = List.generate(
      widget.printerManager.printers.length,
      (index) => index,
    );
    indexes.shuffle();
    for (var i = 0; i < indexes.length; i++) {
      final printer = widget.printerManager.printers[indexes[i]];
      await printer.handler.testPrint();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              rundomPrint();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              onAddPrinter();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children:
              widget.printerManager.printers
                  .map((p) => PrinterCard(printer: p))
                  .toList(),
        ),
      ),
    );
  }
}
