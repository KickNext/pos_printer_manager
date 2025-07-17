import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Создание и инициализация менеджера
  final manager = PrintersManager();
  await manager.init(categoriesFuture: categoriesFuture());

  runApp(MyApp(printerManager: manager));
}

Future<List<CategoryForPrinter>> categoriesFuture() async {
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
      home: Scaffold(
        appBar: AppBar(title: const Text('Printers Manager Demo')),
        body: PrintersPage(printerManager: printerManager),
      ),
    );
  }
}
