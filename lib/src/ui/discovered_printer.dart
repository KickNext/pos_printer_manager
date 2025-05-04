import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

class DiscoveredPrinter extends StatelessWidget {
  const DiscoveredPrinter({
    super.key,
    required this.discoveredPrinter,
    required this.onConnect,
  });

  final PrinterConnectionParamsDTO discoveredPrinter;
  final VoidCallback onConnect;

  IconData _getIconForConnectionType(PosPrinterConnectionType? type) {
    switch (type) {
      case PosPrinterConnectionType.usb:
        return Icons.usb;
      case PosPrinterConnectionType.network:
        return Icons.wifi;
      default:
        return Icons.device_unknown; // Default icon
    }
  }

  String _getPrinterSubtitle(PrinterConnectionParamsDTO printer) {
    final params = printer;
    final typeName = params.connectionType.name.toUpperCase();
    String details = '';
    switch (params.connectionType) {
      case PosPrinterConnectionType.usb:
        details =
            'VID: ${params.usbParams?.vendorId}, PID: ${params.usbParams?.productId}';
        if (params.usbParams?.serialNumber != null) {
          details += '\nSN: ${params.usbParams?.serialNumber}';
        }
        break;
      case PosPrinterConnectionType.network:
        details = 'IP: ${params.networkParams?.ipAddress}';
        if (params.networkParams?.macAddress != null) {
          details += '\nMAC: ${params.networkParams?.macAddress}';
        }
        break;
    }
    return '$typeName\n$details';
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getIconForConnectionType(
      discoveredPrinter.connectionType,
    );
    final title = discoveredPrinter.displayName;
    final subtitle = _getPrinterSubtitle(discoveredPrinter);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          onConnect();
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              Icon(
                icon,
                size: 40.0,
                color: Theme.of(context).colorScheme.primary,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textTheme.titleMedium),
                  const SizedBox(height: 4.0),
                  Text(subtitle, style: textTheme.bodySmall),
                ],
              ),
              const SizedBox(width: 4.0),
            ],
          ),
        ),
      ),
    );
  }
}
