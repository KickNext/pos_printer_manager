import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

class PrinterCard extends StatelessWidget {
  const PrinterCard({super.key, required this.printer, required this.onTap});

  final PosPrinter printer;

  final void Function(PosPrinter) onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => onTap(printer),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            spacing: 16,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    printer.handler.settings.icon,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Icon(
                    printer.isConnected
                        ? Icons.link_rounded
                        : Icons.link_off_rounded,
                    color: printer.isConnected ? Colors.green : Colors.red,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    printer.config.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    printer.type.displayName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    printer.handler.settings.connectionParams?.displayName ??
                        'No connection parameters available',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
