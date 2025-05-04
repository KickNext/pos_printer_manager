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
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 800),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return Padding(
                  padding:
                      isWide
                          ? const EdgeInsets.only(
                            top: 16,
                            left: 16,
                            right: 16,
                            bottom: 16,
                          )
                          : const EdgeInsets.all(16),
                  child:
                      isWide
                          ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Card(
                                  margin: const EdgeInsets.only(
                                    right: 16,
                                    bottom: 16,
                                  ),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        leading: Icon(
                                          widget.printer.isConnected
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          color:
                                              widget.printer.isConnected
                                                  ? Colors.green
                                                  : Colors.red,
                                        ),
                                        title: Text(widget.printer.config.name),
                                        subtitle: Text(
                                          'Type: ${widget.printer.type.displayName}',
                                        ),
                                      ),
                                      ButtonBar(
                                        alignment: MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: () async {
                                              await widget.printer.handler
                                                  .testPrint();
                                            },
                                            icon: Icon(Icons.print),
                                            label: Text('Test Print'),
                                          ),
                                          TextButton.icon(
                                            onPressed: () {
                                              unawaited(
                                                widget.printer.handler.manager
                                                    .removePosPrinter(
                                                      widget.printer.id,
                                                    ),
                                              );
                                              Navigator.of(context).pop();
                                            },
                                            icon: Icon(Icons.delete),
                                            label: Text('Remove Printer'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ConnectionParameters(
                                  printer: widget.printer,
                                ),
                              ),
                            ],
                          )
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: Icon(
                                        widget.printer.isConnected
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color:
                                            widget.printer.isConnected
                                                ? Colors.green
                                                : Colors.red,
                                      ),
                                      title: Text(widget.printer.config.name),
                                      subtitle: Text(
                                        'Type: ${widget.printer.type.displayName}',
                                      ),
                                    ),
                                    ButtonBar(
                                      alignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            await widget.printer.handler
                                                .testPrint();
                                          },
                                          icon: Icon(Icons.print),
                                          label: Text('Test Print'),
                                        ),
                                        TextButton.icon(
                                          onPressed: () {
                                            unawaited(
                                              widget.printer.handler.manager
                                                  .removePosPrinter(
                                                    widget.printer.id,
                                                  ),
                                            );
                                            Navigator.of(context).pop();
                                          },
                                          icon: Icon(Icons.delete),
                                          label: Text('Remove Printer'),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              ConnectionParameters(printer: widget.printer),
                            ],
                          ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
