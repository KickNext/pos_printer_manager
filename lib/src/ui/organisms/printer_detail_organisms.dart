import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

/// Короткий алиас для доступа к локализации принтер-менеджера.
typedef _L = PrinterManagerL10n;

/// Organism component for displaying printer information header with quick actions.
///
/// Объединяет информацию о принтере, статус и быстрые действия в одной карточке.
/// Включает:
/// - Информацию о принтере (имя, тип, иконка)
/// - Текущий статус подключения
/// - Быстрые действия (тестовая печать, повторить попытку)
/// - Советы по устранению неполадок (при наличии ошибок)
///
/// Example usage:
/// ```dart
/// PrinterHeaderOrganism(
///   printer: myPrinter,
///   onRename: () => _showRenameDialog(),
/// )
/// ```
class PrinterHeaderOrganism extends StatefulWidget {
  /// The printer to display information for.
  final PosPrinter printer;

  /// Callback when rename is requested.
  final VoidCallback? onRename;

  /// Creates a printer header organism widget.
  const PrinterHeaderOrganism({
    super.key,
    required this.printer,
    this.onRename,
  });

  @override
  State<PrinterHeaderOrganism> createState() => _PrinterHeaderOrganismState();
}

class _PrinterHeaderOrganismState extends State<PrinterHeaderOrganism> {
  /// Whether test print is in progress.
  bool _isTestPrinting = false;

  /// Whether diagnostics is in progress.
  bool _isRunningDiagnostics = false;

  /// Last error message from printing.
  String? _lastError;

  /// Проверяет, можно ли выполнить тестовую печать.
  bool get _canTestPrint =>
      widget.printer.handler.settings.connectionParams != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = widget.printer.config;
    final l = _L.of(context);

    // Determine current status from PrinterConnectionStatus
    final (statusType, statusText) = _getStatusInfo(
      widget.printer.status,
      l: l,
    );
    final hasError = widget.printer.lastError != null || _lastError != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ============================================================
            // HEADER: Иконка типа принтера, название и тип
            // ============================================================
            Row(
              children: [
                // Иконка типа принтера в стильном контейнере
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    PrinterIcons.forType(config.printerPosType),
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Название и тип принтера
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Бейдж типа принтера (без иконки, только текст)
                      PrinterTypeBadge(printerType: config.printerPosType),
                    ],
                  ),
                ),

                // Кнопка переименования
                if (widget.onRename != null)
                  IconButton(
                    icon: const Icon(PrinterIcons.rename),
                    onPressed: widget.onRename,
                    tooltip: _L.of(context).renamePrinter,
                  ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 20),

            // ============================================================
            // STATUS & QUICK ACTIONS: Статус подключения и быстрые действия
            // ============================================================
            Row(
              children: [
                // Status indicator
                StatusIndicator(
                  status: statusType,
                  size: StatusIndicatorSize.large,
                ),
                const SizedBox(width: 12),

                // Status text and error message
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_lastError != null ||
                          widget.printer.lastError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _lastError ??
                                widget.printer.lastError?.message ??
                                '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Quick action buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Test Print button
                if (_canTestPrint)
                  Builder(
                    builder: (context) {
                      final l = _L.of(context);
                      return ActionButton(
                        label: _isTestPrinting ? l.printing : l.testPrint,
                        icon: PrinterIcons.testPrint,
                        onPressed: _isTestPrinting ? null : _handleTestPrint,
                        isLoading: _isTestPrinting,
                        variant: ActionButtonVariant.primary,
                        size: ActionButtonSize.small,
                      );
                    },
                  ),

                // Diagnostics button - проводит полную диагностику и показывает проблемы
                Builder(
                  builder: (context) {
                    final l = _L.of(context);
                    return ActionButton(
                      label: _isRunningDiagnostics
                          ? l.diagnosing
                          : l.diagnostics,
                      icon: PrinterIcons.sectionDiagnostics,
                      onPressed: _isRunningDiagnostics
                          ? null
                          : _runDiagnosticsAndShowDialog,
                      isLoading: _isRunningDiagnostics,
                      variant: ActionButtonVariant.secondary,
                      size: ActionButtonSize.small,
                      tooltip: l.runDiagnosticsTooltip,
                    );
                  },
                ),

                // Retry button (only shown on error)
                if (hasError)
                  ActionButton(
                    label: _L.of(context).clearError,
                    icon: PrinterIcons.refresh,
                    onPressed: _isTestPrinting ? null : _clearError,
                    variant: ActionButtonVariant.tertiary,
                    size: ActionButtonSize.small,
                  ),
              ],
            ),

            // ============================================================
            // TROUBLESHOOTING TIPS: Советы по устранению неполадок
            // ============================================================
            if (hasError) ...[
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 16),
              _TroubleshootingSection(printerType: config.printerPosType),
            ],
          ],
        ),
      ),
    );
  }

  /// Gets the status type and text for the current connection status.
  (StatusType, String) _getStatusInfo(
    PrinterConnectionStatus status, {
    required PrinterManagerL10n l,
  }) {
    switch (status) {
      case PrinterConnectionStatus.connected:
        return (StatusType.success, l.readyToPrint);
      case PrinterConnectionStatus.error:
        return (StatusType.error, l.connectionError);
      case PrinterConnectionStatus.unknown:
        return (StatusType.inactive, l.notConnected);
    }
  }

  /// Handles test print action.
  Future<void> _handleTestPrint() async {
    setState(() {
      _isTestPrinting = true;
      _lastError = null;
    });

    try {
      await widget.printer.testConnection();
    } catch (e) {
      setState(() {
        _lastError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isTestPrinting = false;
        });
      }
    }
  }

  /// Clears the last error message.
  void _clearError() {
    widget.printer.clearError();
    setState(() {
      _lastError = null;
    });
  }

  /// Запускает полную диагностику принтера и показывает результаты в диалоге.
  ///
  /// Проверяет:
  /// - Наличие параметров подключения
  /// - USB права (для USB-принтеров)
  /// - Тестовое соединение с принтером
  Future<void> _runDiagnosticsAndShowDialog() async {
    setState(() {
      _isRunningDiagnostics = true;
    });

    final l = _L.of(context);
    final diagnostics = <_DiagnosticResult>[];
    bool hasProblems = false;

    try {
      // === Проверка 1: Параметры подключения ===
      final connectionParams = widget.printer.handler.settings.connectionParams;
      if (connectionParams == null) {
        diagnostics.add(
          _DiagnosticResult(
            title: l.connectionConfiguration,
            status: _DiagnosticStatus.error,
            description: l.noConnectionConfigured,
            suggestion: l.useFindPrintersButton,
          ),
        );
        hasProblems = true;
      } else {
        diagnostics.add(
          _DiagnosticResult(
            title: l.connectionConfiguration,
            status: _DiagnosticStatus.success,
            description: l.connectionParamsConfigured(
              connectionParams.connectionType.name,
            ),
          ),
        );

        // === Проверка 2: USB права (только для USB) ===
        if (connectionParams.connectionType == PosPrinterConnectionType.usb) {
          try {
            final permissionResult = await widget.printer.checkUsbPermission();
            if (permissionResult.granted) {
              diagnostics.add(
                _DiagnosticResult(
                  title: l.usbPermissionCheck,
                  status: _DiagnosticStatus.success,
                  description: l.usbPermissionGrantedShort,
                ),
              );
            } else {
              diagnostics.add(
                _DiagnosticResult(
                  title: l.usbPermissionCheck,
                  status: _DiagnosticStatus.error,
                  description:
                      permissionResult.errorMessage ??
                      l.usbPermissionNotGranted,
                  suggestion: l.grantUsbPermissionSuggestion,
                ),
              );
              hasProblems = true;
            }
          } catch (e) {
            diagnostics.add(
              _DiagnosticResult(
                title: l.usbPermissionCheck,
                status: _DiagnosticStatus.warning,
                description: l.couldNotCheckUsbPermission(e.toString()),
                suggestion: l.tryReconnectingUsb,
              ),
            );
            hasProblems = true;
          }
        } else {
          diagnostics.add(
            _DiagnosticResult(
              title: l.usbPermissionCheck,
              status: _DiagnosticStatus.notApplicable,
              description: l.notRequiredForNetworkPrinters,
            ),
          );
        }

        // === Проверка 3: Тестовое соединение ===
        try {
          await widget.printer.testConnection();
          diagnostics.add(
            _DiagnosticResult(
              title: l.printerConnectivity,
              status: _DiagnosticStatus.success,
              description: l.printerRespondedSuccessfully,
            ),
          );
        } catch (e) {
          diagnostics.add(
            _DiagnosticResult(
              title: l.printerConnectivity,
              status: _DiagnosticStatus.error,
              description: l.printerTestFailed(e.toString()),
              suggestion: _getSuggestionForError(e.toString(), l),
            ),
          );
          hasProblems = true;
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRunningDiagnostics = false;
        });
      }
    }

    // Показываем диалог с результатами
    if (mounted) {
      await showDialog(
        context: context,
        builder: (dialogContext) => _DiagnosticsResultDialog(
          diagnostics: diagnostics,
          hasProblems: hasProblems,
          printerName: widget.printer.config.name,
        ),
      );
    }
  }

  /// Возвращает рекомендацию по исправлению ошибки на основе текста ошибки.
  String _getSuggestionForError(String error, PrinterManagerL10n l) {
    final lowerError = error.toLowerCase();

    if (lowerError.contains('permission') || lowerError.contains('access')) {
      return l.suggestionGrantUsbPermission;
    }
    if (lowerError.contains('timeout') || lowerError.contains('timed out')) {
      return l.suggestionCheckPowerAndConnection;
    }
    if (lowerError.contains('not found') ||
        lowerError.contains('device not available')) {
      return l.suggestionVerifyPrinterConnected;
    }
    if (lowerError.contains('network') ||
        lowerError.contains('socket') ||
        lowerError.contains('connection refused')) {
      return l.suggestionCheckNetworkAndIp;
    }
    if (lowerError.contains('paper') || lowerError.contains('out of paper')) {
      return l.suggestionLoadPaper;
    }

    return l.suggestionCheckConnection;
  }
}

/// Секция с советами по устранению неполадок.
///
/// Показывает контекстные советы в зависимости от типа принтера.
class _TroubleshootingSection extends StatelessWidget {
  final PrinterPOSType printerType;

  const _TroubleshootingSection({required this.printerType});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = _L.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              PrinterIcons.statusInfo,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              l.troubleshootingTips,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._getTipsForPrinterType(
          l,
        ).map((tip) => _TroubleshootingTip(icon: tip.$1, text: tip.$2)),
      ],
    );
  }

  /// Возвращает советы в зависимости от типа принтера.
  List<(IconData, String)> _getTipsForPrinterType(PrinterManagerL10n l) {
    final baseTips = <(IconData, String)>[
      (Icons.power_settings_new_rounded, l.tipCheckPowerOn),
      (PrinterIcons.connectionUsb, l.tipUsbCable),
      (PrinterIcons.connectionNetwork, l.tipNetworkConnection),
    ];

    switch (printerType) {
      case PrinterPOSType.receiptPrinter:
      case PrinterPOSType.kitchenPrinter:
        return [...baseTips, (Icons.receipt_rounded, l.tipCheckPaper)];
      case PrinterPOSType.labelPrinter:
        return [...baseTips, (Icons.inventory_2_rounded, l.tipCheckLabels)];
      case PrinterPOSType.androBar:
        return [...baseTips, (Icons.wifi_rounded, l.tipCheckAndroBarNetwork)];
    }
  }
}

/// Отдельный совет по устранению неполадок.
class _TroubleshootingTip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TroubleshootingTip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Organism component for danger zone actions.
///
/// Displays destructive actions like removing a printer with
/// clear warnings and confirmation.
///
/// Example usage:
/// ```dart
/// DangerZoneCard(
///   onRemove: () => _confirmRemovePrinter(),
/// )
/// ```
class DangerZoneCard extends StatelessWidget {
  /// Callback when remove action is confirmed.
  final VoidCallback onRemove;

  /// Creates a danger zone card widget.
  const DangerZoneCard({super.key, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = _L.of(context);

    return Card(
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  PrinterIcons.sectionDanger,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  l.dangerZone,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              l.dangerZoneDescription,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 16),

            // Remove button
            SizedBox(
              width: double.infinity,
              child: ActionButton(
                label: l.removePrinter,
                icon: PrinterIcons.remove,
                onPressed: onRemove,
                variant: ActionButtonVariant.destructive,
                expanded: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// DIAGNOSTICS CLASSES
// ============================================================================

/// Статус результата диагностики.
enum _DiagnosticStatus {
  /// Проверка прошла успешно.
  success,

  /// Обнаружено предупреждение.
  warning,

  /// Обнаружена ошибка.
  error,

  /// Проверка не применима к данному принтеру.
  notApplicable,
}

/// Результат одной диагностической проверки.
class _DiagnosticResult {
  /// Название проверки.
  final String title;

  /// Статус результата.
  final _DiagnosticStatus status;

  /// Описание результата.
  final String description;

  /// Рекомендация по исправлению (если есть проблема).
  final String? suggestion;

  const _DiagnosticResult({
    required this.title,
    required this.status,
    required this.description,
    this.suggestion,
  });
}

/// Диалог с результатами диагностики принтера.
///
/// Показывает список выполненных проверок с их статусами
/// и рекомендациями по исправлению проблем.
class _DiagnosticsResultDialog extends StatelessWidget {
  /// Список результатов диагностики.
  final List<_DiagnosticResult> diagnostics;

  /// Есть ли обнаруженные проблемы.
  final bool hasProblems;

  /// Имя принтера для заголовка.
  final String printerName;

  const _DiagnosticsResultDialog({
    required this.diagnostics,
    required this.hasProblems,
    required this.printerName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = _L.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            hasProblems
                ? PrinterIcons.statusWarning
                : PrinterIcons.statusSuccess,
            color: hasProblems
                ? theme.colorScheme.error
                : const Color(0xFF4CAF50),
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasProblems
                      ? l.diagnosticsProblemsFound
                      : l.diagnosticsAllPassed,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  printerName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Краткое резюме
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasProblems
                    ? theme.colorScheme.errorContainer.withValues(alpha: 0.3)
                    : const Color(0xFF4CAF50).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                hasProblems
                    ? l.diagnosticsSomeFailed
                    : l.diagnosticsAllPassedDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: hasProblems
                      ? theme.colorScheme.error
                      : const Color(0xFF2E7D32),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Список результатов проверок
            ...diagnostics.map(
              (diagnostic) => _DiagnosticResultItem(diagnostic: diagnostic),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.close),
        ),
      ],
    );
  }
}

/// Элемент списка результатов диагностики.
class _DiagnosticResultItem extends StatelessWidget {
  final _DiagnosticResult diagnostic;

  const _DiagnosticResultItem({required this.diagnostic});

  IconData get _icon {
    switch (diagnostic.status) {
      case _DiagnosticStatus.success:
        return PrinterIcons.statusSuccess;
      case _DiagnosticStatus.warning:
        return PrinterIcons.statusWarning;
      case _DiagnosticStatus.error:
        return PrinterIcons.statusError;
      case _DiagnosticStatus.notApplicable:
        return Icons.remove_circle_outline_rounded;
    }
  }

  Color _getColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (diagnostic.status) {
      case _DiagnosticStatus.success:
        return const Color(0xFF4CAF50);
      case _DiagnosticStatus.warning:
        return const Color(0xFFFF9800);
      case _DiagnosticStatus.error:
        return theme.colorScheme.error;
      case _DiagnosticStatus.notApplicable:
        return theme.colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getColor(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status icon
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  diagnostic.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),

                // Description
                Text(
                  diagnostic.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                // Suggestion (if any)
                if (diagnostic.suggestion != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 14,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            diagnostic.suggestion!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
