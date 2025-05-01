import 'package:example/printer_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

class PrinterCard extends StatelessWidget {
  const PrinterCard({super.key, required this.printer});

  final PosPrinter printer;

  @override
  Widget build(BuildContext context) {
    return Card(
      
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PrinterDetailsScreen(printer: printer),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            spacing: 16,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(printer.config.name),
                  Text(printer.type.displayName),
                ],
              ),
              Icon(
                printer.isConnected ? Icons.print : Icons.print_disabled,
                color: printer.isConnected ? Colors.green : Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
