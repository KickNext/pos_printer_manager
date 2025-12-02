import 'package:flutter/material.dart';

/// Style variants for action buttons.
///
/// Determines the visual appearance and emphasis of the button.
enum ActionButtonVariant {
  /// Primary action - most prominent
  primary,

  /// Secondary action - less prominent
  secondary,

  /// Tertiary action - minimal styling (text button)
  tertiary,

  /// Destructive action - red/danger styling
  destructive,
}

/// Size options for action buttons.
enum ActionButtonSize {
  /// Compact button with smaller padding
  small,

  /// Standard button size
  medium,

  /// Large button with more padding
  large,
}

/// A reusable action button atom component.
///
/// Provides consistent button styling across the application with
/// support for icons, loading states, and various style variants.
///
/// Example usage:
/// ```dart
/// ActionButton(
///   label: 'Test Print',
///   icon: Icons.print,
///   onPressed: () => _handleTestPrint(),
///   variant: ActionButtonVariant.primary,
/// )
/// ```
class ActionButton extends StatelessWidget {
  /// Button label text.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Callback when button is pressed. If null, button is disabled.
  final VoidCallback? onPressed;

  /// Visual style variant.
  final ActionButtonVariant variant;

  /// Button size.
  final ActionButtonSize size;

  /// Whether button is in loading state.
  final bool isLoading;

  /// Optional loading label to show instead of regular label.
  final String? loadingLabel;

  /// Optional tooltip text.
  final String? tooltip;

  /// Whether button should expand to fill available width.
  final bool expanded;

  /// Creates an action button widget.
  const ActionButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = ActionButtonVariant.primary,
    this.size = ActionButtonSize.medium,
    this.isLoading = false,
    this.loadingLabel,
    this.tooltip,
    this.expanded = false,
  });

  /// Gets padding based on button size.
  EdgeInsetsGeometry get _padding {
    switch (size) {
      case ActionButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case ActionButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case ActionButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
    }
  }

  /// Gets text style based on button size.
  double get _fontSize {
    switch (size) {
      case ActionButtonSize.small:
        return 12.0;
      case ActionButtonSize.medium:
        return 14.0;
      case ActionButtonSize.large:
        return 16.0;
    }
  }

  /// Gets icon size based on button size.
  double get _iconSize {
    switch (size) {
      case ActionButtonSize.small:
        return 16.0;
      case ActionButtonSize.medium:
        return 18.0;
      case ActionButtonSize.large:
        return 20.0;
    }
  }

  /// Gets loader size based on button size.
  double get _loaderSize {
    switch (size) {
      case ActionButtonSize.small:
        return 14.0;
      case ActionButtonSize.medium:
        return 16.0;
      case ActionButtonSize.large:
        return 18.0;
    }
  }

  /// Builds the loading indicator widget.
  Widget _buildLoader(Color color) {
    return SizedBox(
      width: _loaderSize,
      height: _loaderSize,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  /// Builds the button content (icon + label).
  Widget _buildContent(BuildContext context, Color? foregroundColor) {
    final displayLabel = isLoading ? (loadingLabel ?? label) : label;
    final textStyle = TextStyle(fontSize: _fontSize);

    Widget content;
    if (icon != null || isLoading) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            _buildLoader(
              foregroundColor ?? Theme.of(context).colorScheme.primary,
            )
          else if (icon != null)
            Icon(icon, size: _iconSize),
          const SizedBox(width: 8),
          Text(displayLabel, style: textStyle),
        ],
      );
    } else {
      content = Text(displayLabel, style: textStyle);
    }

    return content;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine if button should be disabled
    final effectiveOnPressed = isLoading ? null : onPressed;

    Widget button;

    switch (variant) {
      case ActionButtonVariant.primary:
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            padding: _padding,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          child: _buildContent(context, colorScheme.onPrimary),
        );
        break;

      case ActionButtonVariant.secondary:
        button = OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(padding: _padding),
          child: _buildContent(context, colorScheme.primary),
        );
        break;

      case ActionButtonVariant.tertiary:
        button = TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(padding: _padding),
          child: _buildContent(context, colorScheme.primary),
        );
        break;

      case ActionButtonVariant.destructive:
        button = OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            padding: _padding,
            foregroundColor: colorScheme.error,
            side: BorderSide(color: colorScheme.error),
          ),
          child: _buildContent(context, colorScheme.error),
        );
        break;
    }

    // Wrap with expanded if needed
    if (expanded) {
      button = SizedBox(width: double.infinity, child: button);
    }

    // Wrap with tooltip if provided
    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}

/// Convenience factory constructors for common button types.
extension ActionButtonFactories on ActionButton {
  /// Creates a test print button.
  static ActionButton testPrint({
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return ActionButton(
      label: isLoading ? 'Printing…' : 'Test Print',
      icon: Icons.print,
      onPressed: onPressed,
      isLoading: isLoading,
      variant: ActionButtonVariant.primary,
    );
  }

  /// Creates a connect button.
  static ActionButton connect({
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return ActionButton(
      label: isLoading ? 'Connecting…' : 'Connect',
      icon: Icons.link,
      onPressed: onPressed,
      isLoading: isLoading,
      variant: ActionButtonVariant.primary,
    );
  }

  /// Creates a search/find button.
  static ActionButton search({
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return ActionButton(
      label: isLoading ? 'Searching…' : 'Find Printers',
      icon: Icons.search,
      onPressed: onPressed,
      isLoading: isLoading,
      variant: ActionButtonVariant.primary,
    );
  }

  /// Creates a remove/delete button.
  static ActionButton remove({
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return ActionButton(
      label: 'Remove',
      icon: Icons.delete_outline,
      onPressed: onPressed,
      isLoading: isLoading,
      variant: ActionButtonVariant.destructive,
    );
  }

  /// Creates a grant permission button.
  static ActionButton grantPermission({
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return ActionButton(
      label: isLoading ? 'Requesting…' : 'Grant Permission',
      icon: Icons.lock_open,
      onPressed: onPressed,
      isLoading: isLoading,
      variant: ActionButtonVariant.primary,
    );
  }
}
