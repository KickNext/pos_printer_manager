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
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 360),
      child:
          connectionParams == null
              ? ElevatedButton.icon(
                onPressed: _connectPrinter,
                icon: Icon(Icons.usb),
                label: Text('Connect Printer'),
              )
              : _buildConnectionParameters(),
    );
  }

  Widget _buildConnectionParameters() {
    if (connectionParams == null) {
      return const Text('No connection parameters available');
    }
    final params = connectionParams!;
    switch (params.connectionType) {
      case PosPrinterConnectionType.usb:
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(leading: Icon(Icons.usb), title: Text('USB Connection')),
              Divider(),
              ListTile(
                leading: Icon(Icons.business),
                title: Text('Manufacturer'),
                subtitle: Text(params.usbParams?.manufacturer ?? '-'),
              ),
              ListTile(
                leading: Icon(Icons.label),
                title: Text('Product Name'),
                subtitle: Text(params.usbParams?.productName ?? '-'),
              ),
              ListTile(
                leading: Icon(Icons.confirmation_number),
                title: Text('Serial Number'),
                subtitle: Text(params.usbParams?.serialNumber ?? '-'),
              ),
              ListTile(
                leading: Icon(Icons.numbers),
                title: Text('Vendor ID'),
                subtitle: Text('${params.usbParams?.vendorId ?? '-'}'),
              ),
              ListTile(
                leading: Icon(Icons.numbers),
                title: Text('Product ID'),
                subtitle: Text('${params.usbParams?.productId ?? '-'}'),
              ),
              OverflowBar(
                alignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: _connectPrinter,
                    icon: Icon(Icons.edit),
                    label: Text('Change'),
                  ),
                  TextButton.icon(
                    onPressed: _disconnectPrinter,
                    icon: Icon(Icons.delete),
                    label: Text('Remove'),
                  ),
                ],
              ),
            ],
          ),
        );

      case PosPrinterConnectionType.network:
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.wifi),
                title: Text('Network Connection'),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.network_wifi),
                title: Text('IP Address'),
                subtitle: Text(params.networkParams?.ipAddress ?? '-'),
              ),
              ListTile(
                leading: Icon(Icons.router),
                title: Text('Subnet Mask'),
                subtitle: Text(params.networkParams?.mask ?? '-'),
              ),
              ListTile(
                leading: Icon(Icons.dns),
                title: Text('Gateway'),
                subtitle: Text(params.networkParams?.gateway ?? '-'),
              ),
              ListTile(
                leading: Icon(Icons.link),
                title: Text('MAC Address'),
                subtitle: Text(params.networkParams?.macAddress ?? '-'),
              ),
              ListTile(
                leading: Icon(Icons.settings_ethernet),
                title: Text('DHCP'),
                subtitle: Text(
                  params.networkParams?.dhcp == null
                      ? '-'
                      : (params.networkParams!.dhcp! ? 'Enabled' : 'Disabled'),
                ),
              ),
              OverflowBar(
                alignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: _connectPrinter,
                    icon: Icon(Icons.edit),
                    label: Text('Change'),
                  ),
                  TextButton.icon(
                    onPressed: _disconnectPrinter,
                    icon: Icon(Icons.delete),
                    label: Text('Remove'),
                  ),
                ],
              ),
            ],
          ),
        );
    }
  }
}
