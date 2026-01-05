import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

/// Короткий алиас для доступа к локализации принтер-менеджера.
typedef _L = PrinterManagerL10n;

/// Wizard step definitions for printer setup.
enum PrinterSetupStep {
  /// Step 1: Select printer type
  selectType,

  /// Step 2: Enter printer name
  enterName,

  /// Step 3: Find and connect printer (optional)
  connect,
}

/// An organism component for guided printer setup.
///
/// Provides a step-by-step wizard for adding a new printer with
/// clear guidance and validation at each step.
///
/// Example usage:
/// ```dart
/// PrinterSetupWizard(
///   printerManager: _printerManager,
///   onComplete: (printer) {
///     Navigator.pop(context);
///     // Navigate to printer details
///   },
///   onCancel: () => Navigator.pop(context),
/// )
/// ```
class PrinterSetupWizard extends StatefulWidget {
  /// The printer manager instance.
  final PrintersManager printerManager;

  /// Callback when setup is complete.
  final ValueChanged<PosPrinter>? onComplete;

  /// Callback when setup is cancelled.
  final VoidCallback? onCancel;

  /// Creates a printer setup wizard widget.
  const PrinterSetupWizard({
    super.key,
    required this.printerManager,
    this.onComplete,
    this.onCancel,
  });

  @override
  State<PrinterSetupWizard> createState() => _PrinterSetupWizardState();
}

class _PrinterSetupWizardState extends State<PrinterSetupWizard> {
  PrinterSetupStep _currentStep = PrinterSetupStep.selectType;
  PrinterPOSType? _selectedType;
  final _nameController = TextEditingController();
  bool _isCreating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Default name will be set in didChangeDependencies when context is available
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Generate default name with localization
    if (_nameController.text.isEmpty) {
      final count = widget.printerManager.printers.length + 1;
      _nameController.text = _L.of(context).printerDefaultName(count);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Available printer types with availability check.
  /// Использует централизованную систему иконок PrinterIcons.
  List<PrinterTypeOption> _getAvailableTypes(PrinterManagerL10n l) {
    final printers = widget.printerManager.printers;

    return [
      PrinterTypeOption(
        id: PrinterPOSType.receiptPrinter.name,
        name: l.receiptPrinter,
        icon: PrinterIcons.receiptPrinter,
        description: l.receiptPrinterDescription,
        enabled:
            widget.printerManager.maxReceiptPrinters >
            printers
                .where((p) => p.type == PrinterPOSType.receiptPrinter)
                .length,
      ),
      PrinterTypeOption(
        id: PrinterPOSType.kitchenPrinter.name,
        name: l.kitchenPrinter,
        icon: PrinterIcons.kitchenPrinter,
        description: l.kitchenPrinterDescription,
        enabled:
            widget.printerManager.maxKitchenPrinters >
            printers
                .where((p) => p.type == PrinterPOSType.kitchenPrinter)
                .length,
      ),
      PrinterTypeOption(
        id: PrinterPOSType.labelPrinter.name,
        name: l.labelPrinter,
        icon: PrinterIcons.labelPrinter,
        description: l.labelPrinterDescription,
        enabled:
            widget.printerManager.maxLabelPrinters >
            printers.where((p) => p.type == PrinterPOSType.labelPrinter).length,
      ),
      PrinterTypeOption(
        id: PrinterPOSType.androBar.name,
        name: l.androBar,
        icon: PrinterIcons.androBar,
        description: l.androBarDescription,
        enabled:
            widget.printerManager.maxAndroBarPrinters >
            printers.where((p) => p.type == PrinterPOSType.androBar).length,
      ),
    ];
  }

  /// Validates current step and returns error message if invalid.
  String? _validateCurrentStep(PrinterManagerL10n l) {
    switch (_currentStep) {
      case PrinterSetupStep.selectType:
        if (_selectedType == null) {
          return l.pleaseSelectPrinterType;
        }
        break;
      case PrinterSetupStep.enterName:
        if (_nameController.text.trim().isEmpty) {
          return l.pleaseEnterName;
        }
        break;
      case PrinterSetupStep.connect:
        // Connection is optional
        break;
    }
    return null;
  }

  /// Advances to the next step or completes setup.
  Future<void> _nextStep() async {
    final l = _L.of(context);
    final error = _validateCurrentStep(l);
    if (error != null) {
      setState(() => _errorMessage = error);
      return;
    }

    setState(() => _errorMessage = null);

    switch (_currentStep) {
      case PrinterSetupStep.selectType:
        setState(() => _currentStep = PrinterSetupStep.enterName);
        break;
      case PrinterSetupStep.enterName:
        await _createPrinter();
        break;
      case PrinterSetupStep.connect:
        // Already created, just finish
        widget.onCancel?.call();
        break;
    }
  }

  /// Goes back to the previous step.
  void _previousStep() {
    setState(() {
      _errorMessage = null;
      switch (_currentStep) {
        case PrinterSetupStep.selectType:
          widget.onCancel?.call();
          break;
        case PrinterSetupStep.enterName:
          _currentStep = PrinterSetupStep.selectType;
          break;
        case PrinterSetupStep.connect:
          _currentStep = PrinterSetupStep.enterName;
          break;
      }
    });
  }

  /// Creates the printer and advances to connection step.
  Future<void> _createPrinter() async {
    if (_selectedType == null) return;
    final l = _L.of(context);

    setState(() {
      _isCreating = true;
      _errorMessage = null;
    });

    try {
      await widget.printerManager.addPosPrinter(
        _nameController.text.trim(),
        _selectedType!,
      );

      // Find the newly created printer
      final newPrinter = widget.printerManager.printers.lastOrNull;

      if (newPrinter != null) {
        widget.onComplete?.call(newPrinter);
      } else {
        widget.onCancel?.call();
      }
    } catch (e) {
      setState(() => _errorMessage = l.failedToCreatePrinter(e.toString()));
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = _L.of(context);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.addPrinter,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onCancel,
                    icon: const Icon(Icons.close),
                    tooltip: l.cancel,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Step indicator
              WizardStepperMolecule(
                steps: [l.stepType, l.stepName],
                currentStep: _currentStep.index,
              ),

              const SizedBox(height: 24),

              // Content
              Flexible(
                child: SingleChildScrollView(child: _buildStepContent(l)),
              ),

              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                InfoBanner(message: _errorMessage!, type: InfoBannerType.error),
              ],

              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ActionButton(
                    label: _currentStep == PrinterSetupStep.selectType
                        ? l.cancel
                        : l.back,
                    icon: _currentStep == PrinterSetupStep.selectType
                        ? PrinterIcons.wizardClose
                        : PrinterIcons.wizardBack,
                    onPressed: _isCreating ? null : _previousStep,
                    variant: ActionButtonVariant.tertiary,
                  ),
                  ActionButton(
                    label: _currentStep == PrinterSetupStep.enterName
                        ? l.create
                        : l.next,
                    icon: _currentStep == PrinterSetupStep.enterName
                        ? PrinterIcons.wizardComplete
                        : PrinterIcons.wizardNext,
                    onPressed: _isCreating ? null : _nextStep,
                    isLoading: _isCreating,
                    variant: ActionButtonVariant.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(PrinterManagerL10n l) {
    switch (_currentStep) {
      case PrinterSetupStep.selectType:
        return _buildTypeSelectionStep(l);
      case PrinterSetupStep.enterName:
        return _buildNameEntryStep(l);
      case PrinterSetupStep.connect:
        return _buildConnectStep(l);
    }
  }

  Widget _buildTypeSelectionStep(PrinterManagerL10n l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.selectPrinterType,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          l.selectPrinterTypeDescription,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        PrinterTypeSelectionMolecule(
          selectedType: _selectedType?.name,
          onTypeSelected: (typeId) {
            setState(() {
              _selectedType = PrinterPOSType.values.byName(typeId);
              _errorMessage = null;
            });
          },
          availableTypes: _getAvailableTypes(l),
        ),
      ],
    );
  }

  Widget _buildNameEntryStep(PrinterManagerL10n l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.nameYourPrinter, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          l.nameYourPrinterDescription,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        ValidatedInputMolecule(
          label: l.printerName,
          controller: _nameController,
          hint: l.printerNameHint,
          prefixIcon: Icons.print,
          required: true,
          maxLength: 50,
          onChanged: (_) {
            if (_errorMessage != null) {
              setState(() => _errorMessage = null);
            }
          },
          textInputAction: TextInputAction.done,
          onEditingComplete: _nextStep,
        ),
        const SizedBox(height: 16),
        // Show selected type info
        if (_selectedType != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _getIconForType(_selectedType!),
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedType!.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        l.configureConnectionLater,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildConnectStep(PrinterManagerL10n l) {
    return EmptyState(
      icon: Icons.search,
      title: l.readyToConnect,
      message: l.readyToConnectDescription,
    );
  }

  /// Возвращает иконку для типа принтера.
  /// Использует централизованную систему иконок для консистентности.
  IconData _getIconForType(PrinterPOSType type) {
    return PrinterIcons.forType(type);
  }
}
