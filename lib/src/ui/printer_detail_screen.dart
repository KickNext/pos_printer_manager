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
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => _showRenameDialog(context),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.printer.config.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.edit, size: 18, color: Colors.grey),
                  ],
                ),
              ),
            ),
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              PrinterInfoCard(printer: widget.printer),
              // PrinterActions(printer: widget.printer),
              PluginWidgetsWrap(printer: widget.printer),
              ConnectionParameters(printer: widget.printer),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showRenameDialog(BuildContext context) async {
    final controller = TextEditingController(text: widget.printer.config.name);
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Rename printer'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'New name'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed:
                    () => Navigator.of(context).pop(controller.text.trim()),
                child: const Text('Save'),
              ),
            ],
          ),
    );
    if (result != null &&
        result.isNotEmpty &&
        result != widget.printer.config.name) {
      // TODO: implement printer name change via manager/repository
      setState(() {
        // Temporary: only local, not persistent
        widget.printer.config.name = result;
      });
    }
  }
}

class PrinterInfoCard extends StatelessWidget {
  final PosPrinter printer;
  const PrinterInfoCard({super.key, required this.printer});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Card(
        child: ListTile(
          leading: Icon(
            printer.isConnected ? Icons.check_circle : Icons.cancel,
            color: printer.isConnected ? Colors.green : Colors.red,
          ),
          title: Text(printer.config.name),
          subtitle: Text('Type: ${printer.type.displayName}'),
        ),
      ),
    );
  }
}

class PrinterActions extends StatelessWidget {
  final PosPrinter printer;
  const PrinterActions({super.key, required this.printer});

  @override
  Widget build(BuildContext context) {
    return OverflowBar(
      alignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            await printer.handler.testPrint();
          },
          icon: const Icon(Icons.print),
          label: const Text('Test print'),
        ),
        TextButton.icon(
          onPressed: () {
            unawaited(printer.handler.manager.removePosPrinter(printer.id));
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.delete),
          label: const Text('Remove printer'),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
        ),
      ],
    );
  }
}

class PluginWidgetsWrap extends StatelessWidget {
  final PosPrinter printer;
  const PluginWidgetsWrap({super.key, required this.printer});

  @override
  Widget build(BuildContext context) {
    final pluginWidgets = printer.handler.settings.customWidgets;
    if (pluginWidgets.isEmpty) {
      return const SizedBox();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(spacing: 12, runSpacing: 12, children: pluginWidgets),
      ),
    );
  }
}
