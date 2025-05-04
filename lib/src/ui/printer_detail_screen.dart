import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

class PrinterDetailsScreen extends StatefulWidget {
  const PrinterDetailsScreen({super.key, required this.printer});

  final PosPrinter printer;

  @override
  State<PrinterDetailsScreen> createState() => _PrinterDetailsScreenState();
}

class _PrinterDetailsScreenState extends State<PrinterDetailsScreen> {
  @override
  void initState() {
    widget.printer.handler.manager.addListener(update);
    super.initState();
  }

  void update() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.printer.handler.manager.removeListener(update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              widget.printer.isConnected ? Icons.check : Icons.close,
              color: widget.printer.isConnected ? Colors.green : Colors.red,
            ),
            Text(widget.printer.config.name),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              unawaited(
                widget.printer.handler.manager.removePosPrinter(
                  widget.printer.id,
                ),
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 16,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                Text('Printer Type: ${widget.printer.type.displayName}'),
                Text('Printer Name: ${widget.printer.config.name}'),
                ElevatedButton(
                  onPressed: () async {
                    await widget.printer.handler.testPrint();
                  },
                  child: Text('Test Print'),
                ),
              ],
            ),
            ConnectionParameters(printer: widget.printer),
          ],
        ),
      ),
    );
  }
}
