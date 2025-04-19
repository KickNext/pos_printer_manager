import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Регистрация плагинов принтеров
  registerReceiptPrinter();
  registerKitchenPrinter();
  registerLabelPrinter();

  // Создание и инициализация менеджера
  final manager = PrinterManager();

  runApp(MyApp(printerManager: manager));
}

class MyApp extends StatelessWidget {
  final PrinterManager printerManager;
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
        title: 'Printer Manager Demo',
        printerManager: printerManager,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final PrinterManager printerManager;
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Placeholder(),
    );
  }
}
