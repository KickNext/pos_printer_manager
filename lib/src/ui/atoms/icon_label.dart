import 'package:flutter/material.dart';

/// A reusable icon with label atom component.
///
/// Displays an icon alongside a label text in horizontal layout.
/// Commonly used for displaying information fields or menu items.
///
/// Example usage:
/// ```dart
/// IconLabel(
///   icon: Icons.wifi,
///   label: 'Network Connection',
///   value: '192.168.1.100',
/// )
/// ```
class IconLabel extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// The label text.
  final String label;

  /// Optional value text displayed after the label.
  final String? value;

  /// Icon color. If null, uses theme's icon color.
  final Color? iconColor;

  /// Label text style. If null, uses default body text style.
  final TextStyle? labelStyle;

  /// Value text style. If null, uses default caption style.
  final TextStyle? valueStyle;

  /// Size of the icon.
  final double iconSize;

  /// Spacing between icon and text.
  final double spacing;

  /// Layout direction for icon and text.
  final IconLabelLayout layout;

  /// Whether the value should be displayed on a new line.
  final bool valueOnNewLine;

  /// Creates an icon label widget.
  const IconLabel({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.iconColor,
    this.labelStyle,
    this.valueStyle,
    this.iconSize = 20.0,
    this.spacing = 8.0,
    this.layout = IconLabelLayout.horizontal,
    this.valueOnNewLine = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? theme.iconTheme.color;
    final effectiveLabelStyle = labelStyle ?? theme.textTheme.bodyMedium;
    final effectiveValueStyle =
        valueStyle ??
        theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        );

    final iconWidget = Icon(icon, size: iconSize, color: effectiveIconColor);

    Widget textContent;
    if (value != null && valueOnNewLine) {
      textContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: effectiveLabelStyle),
          const SizedBox(height: 2),
          Text(value!, style: effectiveValueStyle),
        ],
      );
    } else if (value != null) {
      textContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: effectiveLabelStyle),
          Text(value!, style: effectiveValueStyle),
        ],
      );
    } else {
      textContent = Text(label, style: effectiveLabelStyle);
    }

    switch (layout) {
      case IconLabelLayout.horizontal:
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            iconWidget,
            SizedBox(width: spacing),
            Flexible(child: textContent),
          ],
        );

      case IconLabelLayout.vertical:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            iconWidget,
            SizedBox(height: spacing),
            textContent,
          ],
        );
    }
  }
}

/// Layout options for IconLabel.
enum IconLabelLayout {
  /// Icon and text arranged horizontally.
  horizontal,

  /// Icon and text arranged vertically.
  vertical,
}

/// A compact info field atom component.
///
/// Displays a label-value pair in a compact format, useful for
/// displaying printer connection parameters and settings.
///
/// Example usage:
/// ```dart
/// InfoField(
///   label: 'IP Address',
///   value: '192.168.1.100',
///   icon: Icons.network_wifi,
/// )
/// ```
class InfoField extends StatelessWidget {
  /// The field label.
  final String label;

  /// The field value. If null or empty, displays placeholder.
  final String? value;

  /// Optional icon to display.
  final IconData? icon;

  /// Placeholder text when value is null or empty.
  final String placeholder;

  /// Whether the field value can be copied to clipboard.
  final bool copyable;

  /// Callback when value is copied.
  final VoidCallback? onCopied;

  /// Creates an info field widget.
  const InfoField({
    super.key,
    required this.label,
    this.value,
    this.icon,
    this.placeholder = '-',
    this.copyable = false,
    this.onCopied,
  });

  /// Whether the field has a valid value.
  bool get _hasValue => value != null && value!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayValue = _hasValue ? value! : placeholder;
    final valueColor = _hasValue
        ? theme.textTheme.bodyMedium?.color
        : theme.colorScheme.onSurfaceVariant;

    return ListTile(
      leading: icon != null
          ? Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant)
          : null,
      title: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: Text(
        displayValue,
        style: theme.textTheme.bodyMedium?.copyWith(color: valueColor),
      ),
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: icon != null
          ? null
          : const EdgeInsets.symmetric(horizontal: 16),
      trailing: copyable && _hasValue
          ? IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () {
                // Copy functionality would be implemented here
                onCopied?.call();
              },
              tooltip: 'Copy',
              visualDensity: VisualDensity.compact,
            )
          : null,
    );
  }
}

/// A section header atom component.
///
/// Displays a styled section header with optional trailing widget.
///
/// Example usage:
/// ```dart
/// SectionHeader(
///   icon: Icons.settings,
///   title: 'Connection Settings',
///   trailing: IconButton(
///     icon: Icon(Icons.edit),
///     onPressed: () {},
///   ),
/// )
/// ```
class SectionHeader extends StatelessWidget {
  /// The header icon.
  final IconData? icon;

  /// The header title.
  final String title;

  /// Optional trailing widget.
  final Widget? trailing;

  /// Icon color. If null, uses primary color.
  final Color? iconColor;

  /// Creates a section header widget.
  const SectionHeader({
    super.key,
    this.icon,
    required this.title,
    this.trailing,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? theme.colorScheme.primary;

    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: effectiveIconColor),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
