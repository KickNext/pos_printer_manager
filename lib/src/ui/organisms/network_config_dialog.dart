import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

/// Короткий алиас для доступа к локализации принтер-менеджера.
typedef _L = PrinterManagerL10n;

/// A dialog for configuring network settings of a printer.
class NetworkConfigDialog extends StatefulWidget {
  /// The printer to configure.
  final PosPrinter printer;

  /// Current connection parameters.
  final PrinterConnectionParamsDTO currentParams;

  /// The printer manager.
  final PrintersManager printerManager;

  /// Callback when configuration is successful.
  final VoidCallback? onConfigured;

  /// Creates a network config dialog.
  const NetworkConfigDialog({
    super.key,
    required this.printer,
    required this.currentParams,
    required this.printerManager,
    this.onConfigured,
  });

  @override
  State<NetworkConfigDialog> createState() => _NetworkConfigDialogState();
}

class _NetworkConfigDialogState extends State<NetworkConfigDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _ipController;
  late TextEditingController _maskController;
  late TextEditingController _gatewayController;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final net = widget.currentParams.networkParams;
    _ipController = TextEditingController(text: net?.ipAddress ?? '');
    _maskController = TextEditingController(text: net?.mask ?? '255.255.255.0');
    _gatewayController = TextEditingController(text: net?.gateway ?? '');
  }

  @override
  void dispose() {
    _ipController.dispose();
    _maskController.dispose();
    _gatewayController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final l = _L.of(context);

    try {
      final netSettings = NetworkParams(
        ipAddress: _ipController.text.trim(),
        mask: _maskController.text.trim(),
        gateway: _gatewayController.text.trim(),
        macAddress: widget.currentParams.networkParams?.macAddress,
        dhcp: false, // Usually static when manually configuring
      );

      // If connected via USB, use setNetSettings
      if (widget.currentParams.connectionType == PosPrinterConnectionType.usb) {
        await widget.printerManager.setNetSettings(
          widget.currentParams,
          netSettings,
        );
      } else {
        // If configuring via network (UDP broadcast), we need MAC address
        final mac = widget.currentParams.networkParams?.macAddress;
        if (mac != null) {
          await widget.printerManager.configureNetViaUDP(mac, netSettings);
        } else {
          throw Exception(l.macAddressRequired);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.networkSettingsUpdated),
            backgroundColor: Colors.green,
          ),
        );
        widget.onConfigured?.call();
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = _L.of(context);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(
                  icon: Icons.settings_ethernet,
                  title: l.networkSettings,
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null) ...[
                  InfoBanner(
                    message: _errorMessage!,
                    type: InfoBannerType.error,
                  ),
                  const SizedBox(height: 16),
                ],
                ValidatedInputMolecule(
                  label: l.ipAddress,
                  controller: _ipController,
                  hint: '192.168.1.100',
                  required: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l.ipAddressRequired;
                    }
                    // Basic IP validation could be added here
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ValidatedInputMolecule(
                  label: l.subnetMask,
                  controller: _maskController,
                  hint: '255.255.255.0',
                  required: true,
                ),
                const SizedBox(height: 16),
                ValidatedInputMolecule(
                  label: l.gateway,
                  controller: _gatewayController,
                  hint: '192.168.1.1',
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ActionButton(
                      label: l.cancel,
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.of(context).pop(),
                      variant: ActionButtonVariant.tertiary,
                    ),
                    const SizedBox(width: 8),
                    ActionButton(
                      label: l.saveSettings,
                      onPressed: _isSaving ? null : _saveSettings,
                      isLoading: _isSaving,
                      variant: ActionButtonVariant.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
