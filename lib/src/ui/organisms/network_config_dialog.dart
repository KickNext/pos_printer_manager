import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

/// Короткий алиас для доступа к локализации принтер-менеджера.
typedef _L = PrinterManagerL10n;

/// Диалог для настройки сетевых параметров принтера.
///
/// Позволяет переключать между режимами:
/// - **DHCP** — автоматическое получение IP-адреса от роутера
/// - **Статический IP** — ручной ввод IP, маски подсети и шлюза
///
/// Логика работы:
/// - Если принтер подключён по USB, настройки отправляются через setNetSettings
/// - Если принтер сетевой, настройки отправляются через UDP broadcast
///   (требуется MAC-адрес)
class NetworkConfigDialog extends StatefulWidget {
  /// Принтер для настройки.
  final PosPrinter printer;

  /// Текущие параметры подключения принтера.
  final PrinterConnectionParamsDTO currentParams;

  /// Менеджер принтеров для отправки команд.
  final PrintersManager printerManager;

  /// Callback при успешном сохранении настроек.
  final VoidCallback? onConfigured;

  /// Создаёт диалог настройки сети.
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
  /// Ключ формы для валидации.
  final _formKey = GlobalKey<FormState>();

  /// Контроллер поля IP-адреса.
  late TextEditingController _ipController;

  /// Контроллер поля маски подсети.
  late TextEditingController _maskController;

  /// Контроллер поля шлюза.
  late TextEditingController _gatewayController;

  /// Флаг сохранения настроек (показывает индикатор загрузки).
  bool _isSaving = false;

  /// Сообщение об ошибке при сохранении.
  String? _errorMessage;

  /// Флаг включения DHCP (автоматическое получение IP).
  late bool _isDhcpEnabled;

  @override
  void initState() {
    super.initState();
    final net = widget.currentParams.networkParams;

    // Инициализируем состояние DHCP из текущих настроек принтера
    _isDhcpEnabled = net?.dhcp ?? false;

    // Инициализируем контроллеры текстовых полей
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

  /// Сохраняет сетевые настройки на принтер.
  ///
  /// При включённом DHCP отправляет команду на включение автоматического
  /// получения IP. При выключенном — отправляет статические настройки.
  ///
  /// После успешной отправки:
  /// 1. Устанавливает состояние ожидания перезагрузки на принтере
  /// 2. Показывает информационный диалог с инструкциями
  /// 3. Закрывает диалог настроек
  Future<void> _saveSettings() async {
    // Валидация формы нужна только при статическом IP
    if (!_isDhcpEnabled && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final l = _L.of(context);

    try {
      // Формируем параметры сети в зависимости от режима
      final netSettings = NetworkParams(
        // При DHCP IP-адрес может быть пустым или текущим
        // (принтер получит новый от роутера)
        ipAddress: _isDhcpEnabled
            ? (widget.currentParams.networkParams?.ipAddress ?? '0.0.0.0')
            : _ipController.text.trim(),
        mask: _isDhcpEnabled ? '0.0.0.0' : _maskController.text.trim(),
        gateway: _isDhcpEnabled ? '0.0.0.0' : _gatewayController.text.trim(),
        macAddress: widget.currentParams.networkParams?.macAddress,
        dhcp: _isDhcpEnabled,
      );

      // Определяем способ отправки настроек в зависимости от типа подключения
      final configuredVia = widget.currentParams.connectionType;

      if (configuredVia == PosPrinterConnectionType.usb) {
        // USB-принтер: отправляем настройки напрямую
        await widget.printerManager.setNetSettings(
          widget.currentParams,
          netSettings,
        );
      } else {
        // Сетевой принтер: нужен MAC-адрес для UDP broadcast
        final mac = widget.currentParams.networkParams?.macAddress;
        if (mac != null) {
          await widget.printerManager.configureNetViaUDP(mac, netSettings);
        } else {
          // Для настройки через сеть обязательно нужен MAC-адрес
          throw Exception(l.dhcpRequiresMac);
        }
      }

      if (mounted) {
        // Устанавливаем состояние ожидания перезагрузки на принтере
        widget.printer.setNetworkSettingsPending(
          newSettings: netSettings,
          configuredVia: configuredVia,
        );

        // Закрываем текущий диалог
        Navigator.of(context).pop();

        // Показываем информационный диалог о необходимости перезагрузки
        await _showRebootRequiredDialog(
          context: context,
          isDhcp: _isDhcpEnabled,
          newIpAddress: _isDhcpEnabled ? null : _ipController.text.trim(),
          configuredViaUsb: configuredVia == PosPrinterConnectionType.usb,
        );

        // Уведомляем родительский виджет об изменениях
        widget.onConfigured?.call();
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  /// Показывает диалог с информацией о необходимости перезагрузки принтера.
  Future<void> _showRebootRequiredDialog({
    required BuildContext context,
    required bool isDhcp,
    String? newIpAddress,
    required bool configuredViaUsb,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _NetworkSettingsAppliedDialog(
        isDhcp: isDhcp,
        newIpAddress: newIpAddress,
        configuredViaUsb: configuredViaUsb,
      ),
    );
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
                // === Заголовок диалога ===
                SectionHeader(
                  icon: Icons.settings_ethernet,
                  title: l.networkSettings,
                ),
                const SizedBox(height: 24),

                // === Сообщение об ошибке (если есть) ===
                if (_errorMessage != null) ...[
                  InfoBanner(
                    message: _errorMessage!,
                    type: InfoBannerType.error,
                  ),
                  const SizedBox(height: 16),
                ],

                // === Переключатель DHCP ===
                _DhcpToggleSection(
                  isDhcpEnabled: _isDhcpEnabled,
                  onChanged: (value) {
                    setState(() => _isDhcpEnabled = value);
                  },
                ),
                const SizedBox(height: 20),

                // === Поля статического IP (показываем только при выключенном DHCP) ===
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: _isDhcpEnabled
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  // Показываем поля ввода при статическом IP
                  firstChild: _StaticIpFieldsSection(
                    ipController: _ipController,
                    maskController: _maskController,
                    gatewayController: _gatewayController,
                  ),
                  // Показываем информационное сообщение при DHCP
                  secondChild: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: InfoBanner(
                      message: l.dhcpEnabled,
                      type: InfoBannerType.info,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // === Кнопки действий ===
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

/// Секция переключателя DHCP.
///
/// Отображает переключатель с заголовком и описанием.
class _DhcpToggleSection extends StatelessWidget {
  /// Текущее состояние DHCP.
  final bool isDhcpEnabled;

  /// Callback при изменении состояния.
  final ValueChanged<bool> onChanged;

  const _DhcpToggleSection({
    required this.isDhcpEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = _L.of(context);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDhcpEnabled
              ? theme.colorScheme.primary.withValues(alpha: 0.5)
              : theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          l.enableDhcp,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          l.enableDhcpDescription,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        value: isDhcpEnabled,
        onChanged: onChanged,
      ),
    );
  }
}

/// Секция полей ввода статического IP.
///
/// Содержит поля для IP-адреса, маски подсети и шлюза.
class _StaticIpFieldsSection extends StatelessWidget {
  /// Контроллер IP-адреса.
  final TextEditingController ipController;

  /// Контроллер маски подсети.
  final TextEditingController maskController;

  /// Контроллер шлюза.
  final TextEditingController gatewayController;

  const _StaticIpFieldsSection({
    required this.ipController,
    required this.maskController,
    required this.gatewayController,
  });

  @override
  Widget build(BuildContext context) {
    final l = _L.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок секции
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            l.staticIpSettings,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),

        // Поле IP-адреса
        ValidatedInputMolecule(
          label: l.ipAddress,
          controller: ipController,
          hint: '192.168.1.100',
          required: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l.ipAddressRequired;
            }
            // Базовая валидация IP-адреса
            final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
            if (!ipRegex.hasMatch(value)) {
              return l.ipAddressRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Поле маски подсети
        ValidatedInputMolecule(
          label: l.subnetMask,
          controller: maskController,
          hint: '255.255.255.0',
          required: true,
        ),
        const SizedBox(height: 16),

        // Поле шлюза
        ValidatedInputMolecule(
          label: l.gateway,
          controller: gatewayController,
          hint: '192.168.1.1',
        ),
      ],
    );
  }
}

/// Диалог, информирующий пользователя о необходимости перезагрузки принтера.
///
/// Показывается после успешной отправки сетевых настроек на принтер.
/// Объясняет:
/// - Что настройки были отправлены
/// - Что принтер нужно перезагрузить
/// - Что после перезагрузки нужно переподключить принтер
/// - Что USB-подключение продолжит работать (если применимо)
class _NetworkSettingsAppliedDialog extends StatelessWidget {
  /// Были ли включены настройки DHCP.
  final bool isDhcp;

  /// Новый IP-адрес (null если DHCP).
  final String? newIpAddress;

  /// Были ли настройки отправлены через USB.
  final bool configuredViaUsb;

  const _NetworkSettingsAppliedDialog({
    required this.isDhcp,
    this.newIpAddress,
    required this.configuredViaUsb,
  });

  @override
  Widget build(BuildContext context) {
    final l = _L.of(context);
    final theme = Theme.of(context);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // === Заголовок с иконкой ===
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.restart_alt_rounded,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      l.networkSettingsAppliedTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // === Основное сообщение ===
              InfoBanner(
                message: isDhcp
                    ? l.networkSettingsDhcpAppliedMessage
                    : l.networkSettingsStaticIpAppliedMessage(
                        newIpAddress ?? '',
                      ),
                type: InfoBannerType.warning,
              ),
              const SizedBox(height: 16),

              // === Инструкции по перезагрузке ===
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.restartPrinterRequired,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l.printerRestartInstructions,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              // === Примечание о USB (если настройки отправлены через USB) ===
              if (configuredViaUsb) ...[
                const SizedBox(height: 16),
                InfoBanner(
                  message: l.usbConnectionStillWorks,
                  type: InfoBannerType.info,
                ),
              ],

              const SizedBox(height: 24),

              // === Кнопка подтверждения ===
              ActionButton(
                label: l.understood,
                onPressed: () => Navigator.of(context).pop(),
                variant: ActionButtonVariant.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
