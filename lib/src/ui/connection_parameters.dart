import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

class ConnectionParameters extends StatefulWidget {
  const ConnectionParameters({super.key, required this.printer});

  final PosPrinter printer;

  @override
  State<ConnectionParameters> createState() => _ConnectionParametersState();
}

class _ConnectionParametersState extends State<ConnectionParameters> {
  PrinterConnectionParamsDTO? get _params =>
      widget.printer.handler.settings.connectionParams;

  Future<void> _connectPrinter() async {
    await showDialog(
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

  Future<void> _updateDhcp(bool value) async {
    final params = _params;
    if (params == null || params.connectionType != PosPrinterConnectionType.network) return;
    final net = params.networkParams;
    if (net == null) return;

    final updated = PrinterConnectionParamsDTO(
      id: params.id,
      connectionType: params.connectionType,
      usbParams: null,
      networkParams: NetworkParams(
        ipAddress: net.ipAddress,
        mask: net.mask,
        gateway: net.gateway,
        macAddress: net.macAddress,
        dhcp: value,
      ),
    );

    await widget.printer.handler.settings.updateConnectionParams(updated);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child:
            _params == null
                ? ElevatedButton.icon(
                  onPressed: _connectPrinter,
                  icon: const Icon(Icons.usb),
                  label: const Text('Connect Printer'),
                )
                : _buildConnectionParameters(_params!),
      ),
    );
  }

  Widget _buildConnectionParameters(PrinterConnectionParamsDTO params) {
    switch (params.connectionType) {
      case PosPrinterConnectionType.usb:
        final usb = params.usbParams;
        return _ConnectionCard(
          icon: Icons.usb,
          title: 'USB Connection',
          fields: [
            _Field(Icons.business, 'Manufacturer', usb?.manufacturer),
            _Field(Icons.label, 'Product Name', usb?.productName),
            _Field(
              Icons.confirmation_number,
              'Serial Number',
              usb?.serialNumber,
            ),
            _Field(Icons.numbers, 'Vendor ID', usb?.vendorId.toString()),
            _Field(Icons.numbers, 'Product ID', usb?.productId.toString()),
          ],
          onEdit: _connectPrinter,
          onRemove: _disconnectPrinter,
        );
      case PosPrinterConnectionType.network:
        final net = params.networkParams;
        return _ConnectionCard(
          icon: Icons.wifi,
          title: 'Network Connection',
          fields: [
            _Field(Icons.network_wifi, 'IP Address', net?.ipAddress),
            _Field(Icons.router, 'Subnet Mask', net?.mask),
            _Field(Icons.dns, 'Gateway', net?.gateway),
            _Field(Icons.link, 'MAC Address', net?.macAddress),
            SwitchListTile(
              title: const Text('DHCP'),
              secondary: const Icon(Icons.settings_ethernet),
              value: net?.dhcp ?? false,
              onChanged: (v) => _updateDhcp(v),
              subtitle: Text((net?.dhcp ?? false) ? 'Enabled' : 'Disabled'),
              dense: true,
            ),
          ],
          onEdit: _connectPrinter,
          onRemove: _disconnectPrinter,
        );
    }
  }
}

class _ConnectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> fields;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _ConnectionCard({
    required this.icon,
    required this.title,
    required this.fields,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: Icon(icon), title: Text(title), dense: true),
            const Divider(),
            ...fields,
            OverflowBar(
              alignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text('Change'),
                ),
                TextButton.icon(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete),
                  label: const Text('Remove'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;

  const _Field(this.icon, this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value ?? '-'),
      visualDensity: VisualDensity.compact,
    );
  }

  // конец файла
}
