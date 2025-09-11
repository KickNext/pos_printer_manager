import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';
import 'package:pos_printer_manager/src/ui/widgets/card_header.dart';

class ConnectionParameters extends StatefulWidget {
  const ConnectionParameters({
    super.key,
    required this.printer,
    required this.printerManager,
  });

  final PosPrinter printer;
  final PrintersManager printerManager;

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

  Future<void> _configureNetwork() async {
    final params = _params;
    if (params == null) return;

    await showDialog(
      context: context,
      builder:
          (_) => NetworkConfigDialog(
            printer: widget.printer,
            currentParams: params,
            printerManager: widget.printerManager,
            onConfigured: () {
              setState(() {});
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child:
            _params == null
                ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 12)),
                  const CardHeader(
                    leading: Icon(Icons.wifi_off, size: 20),
                    title: 'No printer connected',
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      onPressed: _connectPrinter,
                      icon: const Icon(Icons.search_rounded),
                      label: const Text('Find and connect'),
                    ),
                  ),
                ],
                )
                : _buildConnectionParameters(_params!),
      ),
    );
  }

  Widget _buildConnectionParameters(PrinterConnectionParamsDTO params) {
    switch (params.connectionType) {
      case PosPrinterConnectionType.usb:
        final usb = params.usbParams;
        final vId = usb?.vendorId;
        final pId = usb?.productId;
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
            _Field(Icons.numbers, 'Vendor ID', vId?.toString()),
            _Field(Icons.numbers, 'Product ID', pId?.toString()),
          ],
          onEdit: _connectPrinter,
          onRemove: _disconnectPrinter,
          onConfigureNetwork: _configureNetwork,
          showNetworkConfig: true,
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
            _Field(
              Icons.settings_ethernet,
              'DHCP',
              (net?.dhcp ?? false) ? 'Enabled' : 'Disabled',
            ),
          ],
          onEdit: _connectPrinter,
          onRemove: _disconnectPrinter,
          onConfigureNetwork: _configureNetwork,
          showNetworkConfig: true,
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
  final VoidCallback onConfigureNetwork;
  final bool showNetworkConfig;

  const _ConnectionCard({
    required this.icon,
    required this.title,
    required this.fields,
    required this.onEdit,
    required this.onRemove,
    required this.onConfigureNetwork,
    required this.showNetworkConfig,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(padding: EdgeInsets.symmetric(horizontal: 12)),
          CardHeader(
            leading: Icon(icon, size: 20),
            title: title,
          ),
          const Divider(),
          ...fields.map(
            (w) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: w,
            ),
          ),
          const SizedBox(height: 4),
          OverflowBar(
            overflowAlignment: OverflowBarAlignment.end,
            alignment: MainAxisAlignment.end,
            spacing: 8,
            children: [
              if (showNetworkConfig)
                Tooltip(
                  message: 'Change IP, subnet mask, gateway, and DHCP',
                  child: OutlinedButton.icon(
                    onPressed: onConfigureNetwork,
                    icon: const Icon(Icons.settings_ethernet),
                    label: const Text('Network Settings'),
                  ),
                ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit),
                label: const Text('Change'),
              ),
              TextButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red[700],
                ),
              ),
            ],
          ),
        ],
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
    final hasValue = (value != null && value!.trim().isNotEmpty);
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(hasValue ? value! : '-'),
      visualDensity: VisualDensity.compact,
    );
  }
}

class NetworkConfigDialog extends StatefulWidget {
  final PosPrinter printer;
  final PrinterConnectionParamsDTO currentParams;
  final VoidCallback onConfigured;
  final PrintersManager printerManager;

  const NetworkConfigDialog({
    super.key,
    required this.printer,
    required this.currentParams,
    required this.onConfigured,
    required this.printerManager,
  });

  @override
  State<NetworkConfigDialog> createState() => _NetworkConfigDialogState();
}

class _NetworkConfigDialogState extends State<NetworkConfigDialog> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _ipController = TextEditingController();
  final _maskController = TextEditingController();
  final _gatewayController = TextEditingController();
  final _macController = TextEditingController();
  final _ipFocusNode = FocusNode();
  final _maskFocusNode = FocusNode();
  final _gatewayFocusNode = FocusNode();
  bool _dhcpEnabled = false;
  bool _isConfiguring = false;
  bool _needsReboot = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    final net = widget.currentParams.networkParams;
    if (net != null) {
      _ipController.text = net.ipAddress;
      _maskController.text = net.mask ?? '255.255.255.0';
      _gatewayController.text = net.gateway ?? '192.168.1.1';
      _macController.text = net.macAddress ?? '';
      _dhcpEnabled = net.dhcp ?? false;
    } else {
      // Default network settings
      _ipController.text = '192.168.1.100';
      _maskController.text = '255.255.255.0';
      _gatewayController.text = '192.168.1.1';
      _dhcpEnabled = false;

      // For USB connection, MAC is not available initially
      if (widget.currentParams.connectionType == PosPrinterConnectionType.usb) {
        _macController.text = '';
      }
    }
  }

  Future<void> _applyNetworkSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isConfiguring = true;
    });

    try {
      final networkParams = NetworkParams(
        ipAddress: _ipController.text.trim(),
        mask: _maskController.text.trim(),
        gateway: _gatewayController.text.trim(),
        macAddress:
            _macController.text.trim().isEmpty
                ? null
                : _macController.text.trim(),
        dhcp: _dhcpEnabled,
      );

      // Apply network settings based on connection type
      if (widget.currentParams.connectionType == PosPrinterConnectionType.usb) {
        await widget.printer.handler.manager.setNetSettings(
          widget.currentParams,
          networkParams,
        );
      } else {
        // Network printer - use UDP configuration with existing MAC
        final macAddress = widget.currentParams.networkParams?.macAddress;
        if (macAddress == null || macAddress.isEmpty) {
          throw Exception(
            'MAC address not found in current connection parameters',
          );
        }
        await widget.printer.handler.manager.configureNetViaUDP(
          macAddress,
          networkParams,
        );
      }

      // Clear current connection as it will change
      await widget.printer.handler.settings.updateConnectionParams(null);

      setState(() {
        _needsReboot = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to configure network: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isConfiguring = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_needsReboot) {
      return _buildRebootDialog();
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final availableHeight = screenHeight - keyboardHeight;

    return AlertDialog(
      title: const Text('Network Configuration'),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0.0),
      content: SizedBox(
        width: 400,
        height: (availableHeight * 0.8).clamp(
          300.0,
          600.0,
        ), // Adaptive height with constraints
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'DHCP — automatic IP address assignment. Disable DHCP to manually set IP, subnet mask, and gateway. Printer reboot is required to apply settings.',
                        ),
                      ),
                    ],
                  ),
                ),
                SwitchListTile(
                  title: const Text('Enable DHCP'),
                  subtitle: const Text('Automatic IP configuration'),
                  value: _dhcpEnabled,
                  onChanged: (value) {
                    setState(() {
                      _dhcpEnabled = value;
                    });
                  },
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child:
                      _dhcpEnabled
                          ? const SizedBox.shrink()
                          : Column(
                            key: const ValueKey('manual_ip'),
                            children: [
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Manual IP',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _ipController,
                                focusNode: _ipFocusNode,
                                decoration: const InputDecoration(
                                  labelText: 'IP Address',
                                  hintText: '192.168.1.100',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (!_dhcpEnabled &&
                                      (value == null || value.trim().isEmpty)) {
                                    return 'IP address is required';
                                  }
                                  return null;
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]'),
                                  ),
                                ],
                                autofocus: true,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(_maskFocusNode);
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _maskController,
                                focusNode: _maskFocusNode,
                                decoration: const InputDecoration(
                                  labelText: 'Subnet Mask',
                                  hintText: '255.255.255.0',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (!_dhcpEnabled &&
                                      (value == null || value.trim().isEmpty)) {
                                    return 'Subnet mask is required';
                                  }
                                  return null;
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]'),
                                  ),
                                ],
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(_gatewayFocusNode);
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _gatewayController,
                                focusNode: _gatewayFocusNode,
                                decoration: const InputDecoration(
                                  labelText: 'Gateway',
                                  hintText: '192.168.1.1',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (!_dhcpEnabled &&
                                      (value == null || value.trim().isEmpty)) {
                                    return 'Gateway is required';
                                  }
                                  return null;
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]'),
                                  ),
                                ],
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted:
                                    (_) => _applyNetworkSettings(),
                              ),
                            ],
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isConfiguring ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isConfiguring ? null : _applyNetworkSettings,
          child:
              _isConfiguring
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildRebootDialog() {
    return AlertDialog(
      title: const Text('Network Configuration Applied'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Network settings have been sent to the printer.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text('To complete the configuration:'),
          SizedBox(height: 8),
          Text('1. Turn OFF the printer'),
          Text('2. Wait 10 seconds'),
          Text('3. Turn ON the printer'),
          SizedBox(height: 16),
          Text(
            'The printer will apply the new network settings after reboot.',
            style: TextStyle(color: Colors.orange),
          ),
        ],
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: () {
            widget.onConfigured();
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.search),
          label: const Text('Complete Setup'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _ipController.dispose();
    _maskController.dispose();
    _gatewayController.dispose();
    _macController.dispose();
    _ipFocusNode.dispose();
    _maskFocusNode.dispose();
    _gatewayFocusNode.dispose();
    super.dispose();
  }
}
