import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

class ConnectionParameters extends StatefulWidget {
  const ConnectionParameters({super.key, required this.printer});

  final PosPrinter printer;

  @override
  State<ConnectionParameters> createState() => _ConnectionParametersState();
}

class _ConnectionParametersState extends State<ConnectionParameters> {
  PrinterConnectionParamsDTO? get connectionParams {
    if (widget.printer.handler.settings.connectionParams == null) {
      return null;
    }
    return widget.printer.handler.settings.connectionParams;
  }

  Future<void> _connectPrinter() async {
    showDialog(
      context: context,
      builder: (_) => FindPrintersDialog(printer: widget.printer),
    );
    setState(() {});
  }

  Future<void> _disconnectPrinter() async {
    await widget.printer.handler.settings.updateConnectionParams(null);
    widget.printer.updateStatus(false);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return connectionParams == null
        ? ElevatedButton(
          onPressed: () {
            _connectPrinter();
          },
          child: Text('Connect printer'),
        )
        : _buildConnectionParameters();
  }

  Widget _buildConnectionParameters() {
    if (connectionParams == null) {
      return const Text('No connection parameters available');
    }
    final params = connectionParams!;
    switch (connectionParams!.connectionType) {
      case PosPrinterConnectionType.usb:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('USB Connection'),
                Text(
                  '${params.usbParams?.manufacturer} ${params.usbParams?.productName}',
                ),
                Text('Serial Number: ${params.usbParams?.serialNumber}'),
                Text('Vendor ID: ${params.usbParams?.vendorId}'),
                Text('Product ID: ${params.usbParams?.productId}'),
                ElevatedButton(
                  onPressed: () {
                    _connectPrinter();
                  },
                  child: Text('Change connection'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _disconnectPrinter();
                  },
                  child: Text('Remove connection'),
                ),
              ],
            ),
          ),
        );
      case PosPrinterConnectionType.network:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Network Connection'),
                Text('IP Address: ${params.networkParams!.ipAddress}'),
                Text('Mask: ${params.networkParams?.mask ?? 'Unknown'}'),
                Text('Geteway: ${params.networkParams?.gateway ?? 'Unknown'}'),
                Text(
                  'Mac Address: ${params.networkParams?.macAddress ?? 'Unknown'}',
                ),
                Text(
                  'DHCP: ${params.networkParams?.dhcp == null
                      ? 'Unknown'
                      : params.networkParams!.dhcp!
                      ? 'Enabled'
                      : 'Disabled'}',
                ),
                ElevatedButton(
                  onPressed: () {
                    _connectPrinter();
                  },
                  child: Text('Change connection'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _disconnectPrinter();
                  },
                  child: Text('Remove connection'),
                ),
              ],
            ),
          ),
        );
    }
  }
}
