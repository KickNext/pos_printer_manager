import 'package:flutter/material.dart';
import 'package:pos_printer_manager/src/ui/atoms/atoms.dart';

/// A molecule component for wizard step indication.
///
/// Displays the current step in a multi-step process with
/// visual progress indicator.
///
/// Example usage:
/// ```dart
/// WizardStepperMolecule(
///   steps: ['Select Type', 'Name', 'Connect'],
///   currentStep: 1,
/// )
/// ```
class WizardStepperMolecule extends StatelessWidget {
  /// List of step labels.
  final List<String> steps;

  /// Current active step index (0-based).
  final int currentStep;

  /// Creates a wizard stepper molecule widget.
  const WizardStepperMolecule({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        // Odd indices are connectors
        if (index.isOdd) {
          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex < currentStep;
          return Expanded(
            child: Container(
              height: 2,
              color: isCompleted
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
            ),
          );
        }

        // Even indices are step circles
        final stepIndex = index ~/ 2;
        final isActive = stepIndex == currentStep;
        final isCompleted = stepIndex < currentStep;

        return _StepCircle(
          label: steps[stepIndex],
          stepNumber: stepIndex + 1,
          isActive: isActive,
          isCompleted: isCompleted,
        );
      }),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final String label;
  final int stepNumber;
  final bool isActive;
  final bool isCompleted;

  const _StepCircle({
    required this.label,
    required this.stepNumber,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onPrimaryColor = theme.colorScheme.onPrimary;
    final outlineColor = theme.colorScheme.outline;
    final surfaceColor = theme.colorScheme.surface;

    Color backgroundColor;
    Color foregroundColor;

    if (isCompleted) {
      backgroundColor = primaryColor;
      foregroundColor = onPrimaryColor;
    } else if (isActive) {
      backgroundColor = primaryColor;
      foregroundColor = onPrimaryColor;
    } else {
      backgroundColor = surfaceColor;
      foregroundColor = outlineColor;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: isActive || isCompleted
                ? null
                : Border.all(color: outlineColor, width: 2),
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, size: 18, color: foregroundColor)
                : Text(
                    '$stepNumber',
                    style: TextStyle(
                      color: foregroundColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isActive ? primaryColor : outlineColor,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// A molecule component for printer type selection.
///
/// Displays printer type options in a grid with icons and descriptions.
///
/// Example usage:
/// ```dart
/// PrinterTypeSelectionMolecule(
///   selectedType: _selectedType,
///   onTypeSelected: (type) => setState(() => _selectedType = type),
///   availableTypes: [
///     PrinterTypeOption(id: 'receipt', name: 'Receipt', icon: Icons.receipt),
///   ],
/// )
/// ```
class PrinterTypeSelectionMolecule extends StatelessWidget {
  /// Currently selected type ID.
  final String? selectedType;

  /// Callback when type is selected.
  final ValueChanged<String> onTypeSelected;

  /// Available printer type options.
  final List<PrinterTypeOption> availableTypes;

  /// Creates a printer type selection molecule widget.
  const PrinterTypeSelectionMolecule({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    required this.availableTypes,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: availableTypes.map((option) {
        final isSelected = option.id == selectedType;
        return _PrinterTypeChip(
          option: option,
          isSelected: isSelected,
          onTap: option.enabled ? () => onTypeSelected(option.id) : null,
        );
      }).toList(),
    );
  }
}

class _PrinterTypeChip extends StatelessWidget {
  final PrinterTypeOption option;
  final bool isSelected;
  final VoidCallback? onTap;

  const _PrinterTypeChip({
    required this.option,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = option.enabled;

    final backgroundColor = isSelected
        ? theme.colorScheme.primary
        : isEnabled
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);

    final foregroundColor = isSelected
        ? theme.colorScheme.onPrimary
        : isEnabled
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface.withValues(alpha: 0.38);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(option.icon, size: 20, color: foregroundColor),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    option.name,
                    style: TextStyle(
                      color: foregroundColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  if (option.description != null)
                    Text(
                      option.description!,
                      style: TextStyle(
                        color: foregroundColor.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
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

/// Option data for printer type selection.
class PrinterTypeOption {
  /// Unique identifier for this type.
  final String id;

  /// Display name.
  final String name;

  /// Icon to display.
  final IconData icon;

  /// Optional description.
  final String? description;

  /// Whether this option is enabled/selectable.
  final bool enabled;

  /// Creates a printer type option.
  const PrinterTypeOption({
    required this.id,
    required this.name,
    required this.icon,
    this.description,
    this.enabled = true,
  });
}

/// A molecule component for confirmation dialog content.
///
/// Provides consistent layout for confirmation dialogs with
/// icon, title, message, and actions.
///
/// Example usage:
/// ```dart
/// ConfirmationDialogMolecule(
///   icon: Icons.delete,
///   iconColor: Colors.red,
///   title: 'Remove Printer?',
///   message: 'This action cannot be undone.',
///   confirmLabel: 'Remove',
///   onConfirm: () => _removePrinter(),
///   onCancel: () => Navigator.pop(context),
/// )
/// ```
class ConfirmationDialogMolecule extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// Icon color.
  final Color? iconColor;

  /// Dialog title.
  final String title;

  /// Dialog message.
  final String message;

  /// Confirm button label.
  final String confirmLabel;

  /// Cancel button label.
  final String cancelLabel;

  /// Callback when confirmed.
  final VoidCallback onConfirm;

  /// Callback when cancelled.
  final VoidCallback onCancel;

  /// Whether confirm action is destructive.
  final bool isDestructive;

  /// Whether action is in progress.
  final bool isLoading;

  /// Creates a confirmation dialog molecule widget.
  const ConfirmationDialogMolecule({
    super.key,
    required this.icon,
    this.iconColor,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    required this.onConfirm,
    required this.onCancel,
    this.isDestructive = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor =
        iconColor ??
        (isDestructive ? theme.colorScheme.error : theme.colorScheme.primary);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icon and title
        Row(
          children: [
            Icon(icon, size: 28, color: effectiveIconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Message
        Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 24),

        // Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ActionButton(
              label: cancelLabel,
              onPressed: isLoading ? null : onCancel,
              variant: ActionButtonVariant.tertiary,
            ),
            const SizedBox(width: 8),
            ActionButton(
              label: confirmLabel,
              onPressed: isLoading ? null : onConfirm,
              isLoading: isLoading,
              variant: isDestructive
                  ? ActionButtonVariant.destructive
                  : ActionButtonVariant.primary,
            ),
          ],
        ),
      ],
    );
  }
}

/// A molecule component for input with validation.
///
/// Combines text field with validation message display.
///
/// Example usage:
/// ```dart
/// ValidatedInputMolecule(
///   label: 'Printer Name',
///   controller: _nameController,
///   validator: (value) => value?.isEmpty == true ? 'Name required' : null,
/// )
/// ```
class ValidatedInputMolecule extends StatelessWidget {
  /// Input label.
  final String label;

  /// Text controller.
  final TextEditingController controller;

  /// Validation function.
  final String? Function(String?)? validator;

  /// Input hint text.
  final String? hint;

  /// Whether field is required.
  final bool required;

  /// Input prefix icon.
  final IconData? prefixIcon;

  /// Callback when value changes.
  final ValueChanged<String>? onChanged;

  /// Callback when editing is complete.
  final VoidCallback? onEditingComplete;

  /// Text input action.
  final TextInputAction? textInputAction;

  /// Whether input is enabled.
  final bool enabled;

  /// Maximum input length.
  final int? maxLength;

  /// Creates a validated input molecule widget.
  const ValidatedInputMolecule({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.hint,
    this.required = false,
    this.prefixIcon,
    this.onChanged,
    this.onEditingComplete,
    this.textInputAction,
    this.enabled = true,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      textInputAction: textInputAction,
      enabled: enabled,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: const OutlineInputBorder(),
        counterText: '', // Hide counter when maxLength is set
      ),
    );
  }
}
