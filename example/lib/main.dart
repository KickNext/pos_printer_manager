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
      home: PrintersPage(printerManager: printerManager),
    );
  }
}
