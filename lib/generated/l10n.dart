// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class PrinterManagerL10n {
  PrinterManagerL10n();

  static PrinterManagerL10n? _current;

  static PrinterManagerL10n get current {
    assert(
      _current != null,
      'No instance of PrinterManagerL10n was loaded. Try to initialize the PrinterManagerL10n delegate before accessing PrinterManagerL10n.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<PrinterManagerL10n> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = PrinterManagerL10n();
      PrinterManagerL10n._current = instance;

      return instance;
    });
  }

  static PrinterManagerL10n of(BuildContext context) {
    final instance = PrinterManagerL10n.maybeOf(context);
    assert(
      instance != null,
      'No instance of PrinterManagerL10n present in the widget tree. Did you add PrinterManagerL10n.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static PrinterManagerL10n? maybeOf(BuildContext context) {
    return Localizations.of<PrinterManagerL10n>(context, PrinterManagerL10n);
  }

  /// `Printer Details`
  String get printerDetails {
    return Intl.message(
      'Printer Details',
      name: 'printerDetails',
      desc: 'Title for printer details screen',
      args: [],
    );
  }

  /// `Rename Printer`
  String get renamePrinter {
    return Intl.message(
      'Rename Printer',
      name: 'renamePrinter',
      desc: 'Dialog title for renaming printer',
      args: [],
    );
  }

  /// `Printer Name`
  String get printerName {
    return Intl.message(
      'Printer Name',
      name: 'printerName',
      desc: 'Label for printer name input field',
      args: [],
    );
  }

  /// `Please enter a name`
  String get pleaseEnterName {
    return Intl.message(
      'Please enter a name',
      name: 'pleaseEnterName',
      desc: 'Validation error when name is empty',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: 'Save button label',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: 'Cancel button label',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: 'Close button label',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message(
      'Back',
      name: 'back',
      desc: 'Back button label',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message(
      'Next',
      name: 'next',
      desc: 'Next button label',
      args: [],
    );
  }

  /// `Create`
  String get create {
    return Intl.message(
      'Create',
      name: 'create',
      desc: 'Create button label',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: 'Confirm button label',
      args: [],
    );
  }

  /// `Remove`
  String get remove {
    return Intl.message(
      'Remove',
      name: 'remove',
      desc: 'Remove button label',
      args: [],
    );
  }

  /// `Remove Printer`
  String get removePrinter {
    return Intl.message(
      'Remove Printer',
      name: 'removePrinter',
      desc: 'Remove printer action label',
      args: [],
    );
  }

  /// `Remove Printer?`
  String get removePrinterQuestion {
    return Intl.message(
      'Remove Printer?',
      name: 'removePrinterQuestion',
      desc: 'Remove printer confirmation dialog title',
      args: [],
    );
  }

  /// `This will remove the printer and all its configuration. You can add it again later.`
  String get removePrinterConfirmation {
    return Intl.message(
      'This will remove the printer and all its configuration. You can add it again later.',
      name: 'removePrinterConfirmation',
      desc: 'Remove printer confirmation dialog message',
      args: [],
    );
  }

  /// `Disconnect`
  String get disconnect {
    return Intl.message(
      'Disconnect',
      name: 'disconnect',
      desc: 'Disconnect button label',
      args: [],
    );
  }

  /// `Disconnect Printer?`
  String get disconnectPrinterQuestion {
    return Intl.message(
      'Disconnect Printer?',
      name: 'disconnectPrinterQuestion',
      desc: 'Disconnect printer confirmation dialog title',
      args: [],
    );
  }

  /// `This will remove the current connection settings. You can reconnect later.`
  String get disconnectPrinterConfirmation {
    return Intl.message(
      'This will remove the current connection settings. You can reconnect later.',
      name: 'disconnectPrinterConfirmation',
      desc: 'Disconnect printer confirmation dialog message',
      args: [],
    );
  }

  /// `Connect`
  String get connect {
    return Intl.message(
      'Connect',
      name: 'connect',
      desc: 'Connect button label',
      args: [],
    );
  }

  /// `Change`
  String get change {
    return Intl.message(
      'Change',
      name: 'change',
      desc: 'Change button label',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message(
      'Retry',
      name: 'retry',
      desc: 'Retry button label',
      args: [],
    );
  }

  /// `Refresh`
  String get refresh {
    return Intl.message(
      'Refresh',
      name: 'refresh',
      desc: 'Refresh button label',
      args: [],
    );
  }

  /// `Test Print`
  String get testPrint {
    return Intl.message(
      'Test Print',
      name: 'testPrint',
      desc: 'Test print button label',
      args: [],
    );
  }

  /// `Printing...`
  String get printing {
    return Intl.message(
      'Printing...',
      name: 'printing',
      desc: 'Status shown while printing',
      args: [],
    );
  }

  /// `Diagnostics`
  String get diagnostics {
    return Intl.message(
      'Diagnostics',
      name: 'diagnostics',
      desc: 'Diagnostics button label',
      args: [],
    );
  }

  /// `Diagnosing...`
  String get diagnosing {
    return Intl.message(
      'Diagnosing...',
      name: 'diagnosing',
      desc: 'Status shown while running diagnostics',
      args: [],
    );
  }

  /// `Clear Error`
  String get clearError {
    return Intl.message(
      'Clear Error',
      name: 'clearError',
      desc: 'Clear error button label',
      args: [],
    );
  }

  /// `Last Test Successful`
  String get readyToPrint {
    return Intl.message(
      'Last Test Successful',
      name: 'readyToPrint',
      desc: 'Status when last printer operation was successful',
      args: [],
    );
  }

  /// `Connection Error`
  String get connectionError {
    return Intl.message(
      'Connection Error',
      name: 'connectionError',
      desc: 'Status when there is a connection error',
      args: [],
    );
  }

  /// `Not Connected`
  String get notConnected {
    return Intl.message(
      'Not Connected',
      name: 'notConnected',
      desc: 'Status when printer is not connected',
      args: [],
    );
  }

  /// `Troubleshooting Tips`
  String get troubleshootingTips {
    return Intl.message(
      'Troubleshooting Tips',
      name: 'troubleshootingTips',
      desc: 'Section header for troubleshooting tips',
      args: [],
    );
  }

  /// `Check that the printer is powered on`
  String get tipCheckPowerOn {
    return Intl.message(
      'Check that the printer is powered on',
      name: 'tipCheckPowerOn',
      desc: 'Troubleshooting tip about power',
      args: [],
    );
  }

  /// `For USB: Ensure cable is securely connected`
  String get tipUsbCable {
    return Intl.message(
      'For USB: Ensure cable is securely connected',
      name: 'tipUsbCable',
      desc: 'Troubleshooting tip about USB cable',
      args: [],
    );
  }

  /// `For Network: Verify WiFi/Ethernet connection`
  String get tipNetworkConnection {
    return Intl.message(
      'For Network: Verify WiFi/Ethernet connection',
      name: 'tipNetworkConnection',
      desc: 'Troubleshooting tip about network',
      args: [],
    );
  }

  /// `Check that paper is loaded correctly`
  String get tipCheckPaper {
    return Intl.message(
      'Check that paper is loaded correctly',
      name: 'tipCheckPaper',
      desc: 'Troubleshooting tip about paper for receipt/kitchen printers',
      args: [],
    );
  }

  /// `Ensure labels are loaded properly`
  String get tipCheckLabels {
    return Intl.message(
      'Ensure labels are loaded properly',
      name: 'tipCheckLabels',
      desc: 'Troubleshooting tip about labels for label printers',
      args: [],
    );
  }

  /// `Check network connectivity to AndroBar device`
  String get tipCheckAndroBarNetwork {
    return Intl.message(
      'Check network connectivity to AndroBar device',
      name: 'tipCheckAndroBarNetwork',
      desc: 'Troubleshooting tip for AndroBar',
      args: [],
    );
  }

  /// `Danger Zone`
  String get dangerZone {
    return Intl.message(
      'Danger Zone',
      name: 'dangerZone',
      desc: 'Section header for dangerous actions',
      args: [],
    );
  }

  /// `Removing this printer will delete all its configuration. You can add it again later, but you will need to reconfigure it.`
  String get dangerZoneDescription {
    return Intl.message(
      'Removing this printer will delete all its configuration. You can add it again later, but you will need to reconfigure it.',
      name: 'dangerZoneDescription',
      desc: 'Warning message in danger zone section',
      args: [],
    );
  }

  /// `Additional Settings`
  String get additionalSettings {
    return Intl.message(
      'Additional Settings',
      name: 'additionalSettings',
      desc: 'Section header for plugin-specific settings',
      args: [],
    );
  }

  /// `Add Printer`
  String get addPrinter {
    return Intl.message(
      'Add Printer',
      name: 'addPrinter',
      desc: 'Add printer button/dialog title',
      args: [],
    );
  }

  /// `Select printer type`
  String get selectPrinterType {
    return Intl.message(
      'Select printer type',
      name: 'selectPrinterType',
      desc: 'Step title for printer type selection',
      args: [],
    );
  }

  /// `Choose the type of printer you want to add.`
  String get selectPrinterTypeDescription {
    return Intl.message(
      'Choose the type of printer you want to add.',
      name: 'selectPrinterTypeDescription',
      desc: 'Description for printer type selection step',
      args: [],
    );
  }

  /// `Name your printer`
  String get nameYourPrinter {
    return Intl.message(
      'Name your printer',
      name: 'nameYourPrinter',
      desc: 'Step title for naming printer',
      args: [],
    );
  }

  /// `Give your printer a descriptive name to identify it easily.`
  String get nameYourPrinterDescription {
    return Intl.message(
      'Give your printer a descriptive name to identify it easily.',
      name: 'nameYourPrinterDescription',
      desc: 'Description for printer naming step',
      args: [],
    );
  }

  /// `e.g., Kitchen Display, Bar Printer`
  String get printerNameHint {
    return Intl.message(
      'e.g., Kitchen Display, Bar Printer',
      name: 'printerNameHint',
      desc: 'Hint text for printer name input',
      args: [],
    );
  }

  /// `Printer {number}`
  String printerDefaultName(int number) {
    return Intl.message(
      'Printer $number',
      name: 'printerDefaultName',
      desc: 'Default printer name with number',
      args: [number],
    );
  }

  /// `You can configure connection after creation`
  String get configureConnectionLater {
    return Intl.message(
      'You can configure connection after creation',
      name: 'configureConnectionLater',
      desc: 'Info text shown after selecting printer type',
      args: [],
    );
  }

  /// `Please select a printer type`
  String get pleaseSelectPrinterType {
    return Intl.message(
      'Please select a printer type',
      name: 'pleaseSelectPrinterType',
      desc: 'Validation error when no printer type selected',
      args: [],
    );
  }

  /// `Failed to create printer: {error}`
  String failedToCreatePrinter(String error) {
    return Intl.message(
      'Failed to create printer: $error',
      name: 'failedToCreatePrinter',
      desc: 'Error message when printer creation fails',
      args: [error],
    );
  }

  /// `Type`
  String get stepType {
    return Intl.message(
      'Type',
      name: 'stepType',
      desc: 'Wizard step label for type selection',
      args: [],
    );
  }

  /// `Name`
  String get stepName {
    return Intl.message(
      'Name',
      name: 'stepName',
      desc: 'Wizard step label for naming',
      args: [],
    );
  }

  /// `Ready to Connect`
  String get readyToConnect {
    return Intl.message(
      'Ready to Connect',
      name: 'readyToConnect',
      desc: 'Title when printer is created and ready to connect',
      args: [],
    );
  }

  /// `Your printer has been created. You can now configure the connection.`
  String get readyToConnectDescription {
    return Intl.message(
      'Your printer has been created. You can now configure the connection.',
      name: 'readyToConnectDescription',
      desc: 'Description after printer is created',
      args: [],
    );
  }

  /// `Receipt Printer`
  String get receiptPrinter {
    return Intl.message(
      'Receipt Printer',
      name: 'receiptPrinter',
      desc: 'Printer type name',
      args: [],
    );
  }

  /// `For receipts and bills`
  String get receiptPrinterDescription {
    return Intl.message(
      'For receipts and bills',
      name: 'receiptPrinterDescription',
      desc: 'Printer type description',
      args: [],
    );
  }

  /// `Kitchen Printer`
  String get kitchenPrinter {
    return Intl.message(
      'Kitchen Printer',
      name: 'kitchenPrinter',
      desc: 'Printer type name',
      args: [],
    );
  }

  /// `For kitchen orders`
  String get kitchenPrinterDescription {
    return Intl.message(
      'For kitchen orders',
      name: 'kitchenPrinterDescription',
      desc: 'Printer type description',
      args: [],
    );
  }

  /// `Label Printer`
  String get labelPrinter {
    return Intl.message(
      'Label Printer',
      name: 'labelPrinter',
      desc: 'Printer type name',
      args: [],
    );
  }

  /// `For product labels`
  String get labelPrinterDescription {
    return Intl.message(
      'For product labels',
      name: 'labelPrinterDescription',
      desc: 'Printer type description',
      args: [],
    );
  }

  /// `AndroBar`
  String get androBar {
    return Intl.message(
      'AndroBar',
      name: 'androBar',
      desc: 'Printer type name',
      args: [],
    );
  }

  /// `Bar display system`
  String get androBarDescription {
    return Intl.message(
      'Bar display system',
      name: 'androBarDescription',
      desc: 'Printer type description',
      args: [],
    );
  }

  /// `Find Printers`
  String get findPrinters {
    return Intl.message(
      'Find Printers',
      name: 'findPrinters',
      desc: 'Button to search for printers',
      args: [],
    );
  }

  /// `Searching for printers...`
  String get searchingForPrinters {
    return Intl.message(
      'Searching for printers...',
      name: 'searchingForPrinters',
      desc: 'Status while searching for printers',
      args: [],
    );
  }

  /// `Found {count} printer(s)`
  String foundPrinters(int count) {
    return Intl.message(
      'Found $count printer(s)',
      name: 'foundPrinters',
      desc: 'Status showing number of printers found',
      args: [count],
    );
  }

  /// `Scanning network and USB...`
  String get scanningNetworkAndUsb {
    return Intl.message(
      'Scanning network and USB...',
      name: 'scanningNetworkAndUsb',
      desc: 'Status while scanning for printers',
      args: [],
    );
  }

  /// `No Printers Found`
  String get noPrintersFound {
    return Intl.message(
      'No Printers Found',
      name: 'noPrintersFound',
      desc: 'Empty state title when no printers found',
      args: [],
    );
  }

  /// `Make sure your printer is powered on and connected to the same network or via USB.`
  String get noPrintersFoundDescription {
    return Intl.message(
      'Make sure your printer is powered on and connected to the same network or via USB.',
      name: 'noPrintersFoundDescription',
      desc: 'Empty state description when no printers found',
      args: [],
    );
  }

  /// `Search Again`
  String get searchAgain {
    return Intl.message(
      'Search Again',
      name: 'searchAgain',
      desc: 'Button to search for printers again',
      args: [],
    );
  }

  /// `No Printers Available`
  String get noPrintersAvailable {
    return Intl.message(
      'No Printers Available',
      name: 'noPrintersAvailable',
      desc: 'Empty state title when max printers reached',
      args: [],
    );
  }

  /// `Maximum number of printers reached.`
  String get maxPrintersReached {
    return Intl.message(
      'Maximum number of printers reached.',
      name: 'maxPrintersReached',
      desc: 'Empty state description when max printers reached',
      args: [],
    );
  }

  /// `No Printers Configured`
  String get noPrintersConfigured {
    return Intl.message(
      'No Printers Configured',
      name: 'noPrintersConfigured',
      desc: 'Empty state title when no printers configured',
      args: [],
    );
  }

  /// `Add a printer to get started.`
  String get addPrinterToStart {
    return Intl.message(
      'Add a printer to get started.',
      name: 'addPrinterToStart',
      desc: 'Empty state description when no printers configured',
      args: [],
    );
  }

  /// `No Connection`
  String get noConnection {
    return Intl.message(
      'No Connection',
      name: 'noConnection',
      desc: 'Title when no printer connection configured',
      args: [],
    );
  }

  /// `No printer is connected. Search for available printers to configure the connection.`
  String get noConnectionDescription {
    return Intl.message(
      'No printer is connected. Search for available printers to configure the connection.',
      name: 'noConnectionDescription',
      desc: 'Description when no printer connection configured',
      args: [],
    );
  }

  /// `USB Connection`
  String get usbConnection {
    return Intl.message(
      'USB Connection',
      name: 'usbConnection',
      desc: 'Connection type label for USB',
      args: [],
    );
  }

  /// `Network Connection`
  String get networkConnection {
    return Intl.message(
      'Network Connection',
      name: 'networkConnection',
      desc: 'Connection type label for Network',
      args: [],
    );
  }

  /// `USB`
  String get usb {
    return Intl.message(
      'USB',
      name: 'usb',
      desc: 'USB connection type badge label',
      args: [],
    );
  }

  /// `Network`
  String get network {
    return Intl.message(
      'Network',
      name: 'network',
      desc: 'Network connection type badge label',
      args: [],
    );
  }

  /// `Bluetooth`
  String get bluetooth {
    return Intl.message(
      'Bluetooth',
      name: 'bluetooth',
      desc: 'Bluetooth connection type badge label',
      args: [],
    );
  }

  /// `Unknown`
  String get unknown {
    return Intl.message(
      'Unknown',
      name: 'unknown',
      desc: 'Unknown connection type badge label',
      args: [],
    );
  }

  /// `Manufacturer`
  String get manufacturer {
    return Intl.message(
      'Manufacturer',
      name: 'manufacturer',
      desc: 'USB device info field',
      args: [],
    );
  }

  /// `Product Name`
  String get productName {
    return Intl.message(
      'Product Name',
      name: 'productName',
      desc: 'USB device info field',
      args: [],
    );
  }

  /// `Serial Number`
  String get serialNumber {
    return Intl.message(
      'Serial Number',
      name: 'serialNumber',
      desc: 'USB device info field',
      args: [],
    );
  }

  /// `Vendor ID`
  String get vendorId {
    return Intl.message(
      'Vendor ID',
      name: 'vendorId',
      desc: 'USB device info field',
      args: [],
    );
  }

  /// `Product ID`
  String get productId {
    return Intl.message(
      'Product ID',
      name: 'productId',
      desc: 'USB device info field',
      args: [],
    );
  }

  /// `IP Address`
  String get ipAddress {
    return Intl.message(
      'IP Address',
      name: 'ipAddress',
      desc: 'Network device info field',
      args: [],
    );
  }

  /// `Subnet Mask`
  String get subnetMask {
    return Intl.message(
      'Subnet Mask',
      name: 'subnetMask',
      desc: 'Network device info field',
      args: [],
    );
  }

  /// `Gateway`
  String get gateway {
    return Intl.message(
      'Gateway',
      name: 'gateway',
      desc: 'Network device info field',
      args: [],
    );
  }

  /// `MAC Address`
  String get macAddress {
    return Intl.message(
      'MAC Address',
      name: 'macAddress',
      desc: 'Network device info field',
      args: [],
    );
  }

  /// `DHCP`
  String get dhcp {
    return Intl.message(
      'DHCP',
      name: 'dhcp',
      desc: 'Network device info field',
      args: [],
    );
  }

  /// `Enabled`
  String get enabled {
    return Intl.message(
      'Enabled',
      name: 'enabled',
      desc: 'Status label for enabled state',
      args: [],
    );
  }

  /// `Disabled`
  String get disabled {
    return Intl.message(
      'Disabled',
      name: 'disabled',
      desc: 'Status label for disabled state',
      args: [],
    );
  }

  /// `Network Settings`
  String get networkSettings {
    return Intl.message(
      'Network Settings',
      name: 'networkSettings',
      desc: 'Network settings dialog/button title',
      args: [],
    );
  }

  /// `IP Address is required`
  String get ipAddressRequired {
    return Intl.message(
      'IP Address is required',
      name: 'ipAddressRequired',
      desc: 'Validation error for empty IP address',
      args: [],
    );
  }

  /// `192.168.1.100`
  String get ipAddressHint {
    return Intl.message(
      '192.168.1.100',
      name: 'ipAddressHint',
      desc: 'Hint text for IP address input',
      args: [],
    );
  }

  /// `255.255.255.0`
  String get subnetMaskHint {
    return Intl.message(
      '255.255.255.0',
      name: 'subnetMaskHint',
      desc: 'Hint text for subnet mask input',
      args: [],
    );
  }

  /// `192.168.1.1`
  String get gatewayHint {
    return Intl.message(
      '192.168.1.1',
      name: 'gatewayHint',
      desc: 'Hint text for gateway input',
      args: [],
    );
  }

  /// `Save Settings`
  String get saveSettings {
    return Intl.message(
      'Save Settings',
      name: 'saveSettings',
      desc: 'Save settings button label',
      args: [],
    );
  }

  /// `Network settings updated successfully`
  String get networkSettingsUpdated {
    return Intl.message(
      'Network settings updated successfully',
      name: 'networkSettingsUpdated',
      desc: 'Success message after saving network settings',
      args: [],
    );
  }

  /// `MAC address required for network configuration`
  String get macAddressRequired {
    return Intl.message(
      'MAC address required for network configuration',
      name: 'macAddressRequired',
      desc: 'Error when MAC address is missing for network config',
      args: [],
    );
  }

  /// `USB Permission`
  String get usbPermission {
    return Intl.message(
      'USB Permission',
      name: 'usbPermission',
      desc: 'USB permission section title',
      args: [],
    );
  }

  /// `Grant USB Permission`
  String get grantUsbPermission {
    return Intl.message(
      'Grant USB Permission',
      name: 'grantUsbPermission',
      desc: 'Button to request USB permission',
      args: [],
    );
  }

  /// `Requesting...`
  String get requesting {
    return Intl.message(
      'Requesting...',
      name: 'requesting',
      desc: 'Status while requesting permission',
      args: [],
    );
  }

  /// `Permission Granted`
  String get permissionGranted {
    return Intl.message(
      'Permission Granted',
      name: 'permissionGranted',
      desc: 'Status when permission is granted',
      args: [],
    );
  }

  /// `Permission Denied`
  String get permissionDenied {
    return Intl.message(
      'Permission Denied',
      name: 'permissionDenied',
      desc: 'Status when permission is denied',
      args: [],
    );
  }

  /// `Permission Required`
  String get permissionRequired {
    return Intl.message(
      'Permission Required',
      name: 'permissionRequired',
      desc: 'Status when permission is required',
      args: [],
    );
  }

  /// `No Permission Needed`
  String get noPermissionNeeded {
    return Intl.message(
      'No Permission Needed',
      name: 'noPermissionNeeded',
      desc: 'Status when no permission is needed',
      args: [],
    );
  }

  /// `USB permission granted. Printer is ready to use.`
  String get usbPermissionGrantedMessage {
    return Intl.message(
      'USB permission granted. Printer is ready to use.',
      name: 'usbPermissionGrantedMessage',
      desc: 'Message when USB permission is granted',
      args: [],
    );
  }

  /// `USB permission was denied. Please grant permission to use this printer.`
  String get usbPermissionDeniedMessage {
    return Intl.message(
      'USB permission was denied. Please grant permission to use this printer.',
      name: 'usbPermissionDeniedMessage',
      desc: 'Message when USB permission is denied',
      args: [],
    );
  }

  /// `USB permission is required to communicate with this printer.`
  String get usbPermissionRequiredMessage {
    return Intl.message(
      'USB permission is required to communicate with this printer.',
      name: 'usbPermissionRequiredMessage',
      desc: 'Message when USB permission is required',
      args: [],
    );
  }

  /// `No USB permission required for network printers.`
  String get noUsbPermissionNeededMessage {
    return Intl.message(
      'No USB permission required for network printers.',
      name: 'noUsbPermissionNeededMessage',
      desc: 'Message when no USB permission is needed',
      args: [],
    );
  }

  /// `USB permission denied`
  String get usbPermissionDeniedError {
    return Intl.message(
      'USB permission denied',
      name: 'usbPermissionDeniedError',
      desc: 'Error message when USB permission is denied',
      args: [],
    );
  }

  /// `USB permission granted`
  String get usbPermissionGrantedSuccess {
    return Intl.message(
      'USB permission granted',
      name: 'usbPermissionGrantedSuccess',
      desc: 'Success message when USB permission is granted',
      args: [],
    );
  }

  /// `USB permission granted: {deviceInfo}`
  String usbPermissionGrantedWithDevice(String deviceInfo) {
    return Intl.message(
      'USB permission granted: $deviceInfo',
      name: 'usbPermissionGrantedWithDevice',
      desc: 'Success message with device info',
      args: [deviceInfo],
    );
  }

  /// `Problems Found`
  String get diagnosticsProblemsFound {
    return Intl.message(
      'Problems Found',
      name: 'diagnosticsProblemsFound',
      desc: 'Diagnostics dialog title when problems found',
      args: [],
    );
  }

  /// `All Checks Passed`
  String get diagnosticsAllPassed {
    return Intl.message(
      'All Checks Passed',
      name: 'diagnosticsAllPassed',
      desc: 'Diagnostics dialog title when all checks pass',
      args: [],
    );
  }

  /// `Some diagnostic checks failed. Review the issues below and follow the suggestions to resolve them.`
  String get diagnosticsProblemsDescription {
    return Intl.message(
      'Some diagnostic checks failed. Review the issues below and follow the suggestions to resolve them.',
      name: 'diagnosticsProblemsDescription',
      desc: 'Description when diagnostics found problems',
      args: [],
    );
  }

  /// `All diagnostic checks passed successfully. Your printer is configured correctly.`
  String get diagnosticsSuccessDescription {
    return Intl.message(
      'All diagnostic checks passed successfully. Your printer is configured correctly.',
      name: 'diagnosticsSuccessDescription',
      desc: 'Description when all diagnostics pass',
      args: [],
    );
  }

  /// `Connection Configuration`
  String get connectionConfiguration {
    return Intl.message(
      'Connection Configuration',
      name: 'connectionConfiguration',
      desc: 'Diagnostic check title',
      args: [],
    );
  }

  /// `No connection configured. Please set up USB or Network connection first.`
  String get noConnectionConfigured {
    return Intl.message(
      'No connection configured. Please set up USB or Network connection first.',
      name: 'noConnectionConfigured',
      desc: 'Diagnostic error when no connection configured',
      args: [],
    );
  }

  /// `Use the "Find Printers" button to configure connection.`
  String get useFinderToConnect {
    return Intl.message(
      'Use the "Find Printers" button to configure connection.',
      name: 'useFinderToConnect',
      desc: 'Suggestion to use printer finder',
      args: [],
    );
  }

  /// `Connection parameters are configured ({connectionType}).`
  String connectionParamsConfigured(String connectionType) {
    return Intl.message(
      'Connection parameters are configured ($connectionType).',
      name: 'connectionParamsConfigured',
      desc: 'Diagnostic success for connection params',
      args: [connectionType],
    );
  }

  /// `USB Permission`
  String get usbPermissionCheck {
    return Intl.message(
      'USB Permission',
      name: 'usbPermissionCheck',
      desc: 'Diagnostic check title for USB permission',
      args: [],
    );
  }

  /// `USB permission granted.`
  String get usbPermissionGrantedDiag {
    return Intl.message(
      'USB permission granted.',
      name: 'usbPermissionGrantedDiag',
      desc: 'Diagnostic success for USB permission',
      args: [],
    );
  }

  /// `USB permission not granted.`
  String get usbPermissionNotGranted {
    return Intl.message(
      'USB permission not granted.',
      name: 'usbPermissionNotGranted',
      desc: 'Diagnostic error for USB permission',
      args: [],
    );
  }

  /// `Grant USB permission by clicking "Grant USB Permission" button.`
  String get grantUsbPermissionSuggestion {
    return Intl.message(
      'Grant USB permission by clicking "Grant USB Permission" button.',
      name: 'grantUsbPermissionSuggestion',
      desc: 'Suggestion to grant USB permission',
      args: [],
    );
  }

  /// `Could not check USB permission: {error}`
  String couldNotCheckUsbPermission(String error) {
    return Intl.message(
      'Could not check USB permission: $error',
      name: 'couldNotCheckUsbPermission',
      desc: 'Error checking USB permission',
      args: [error],
    );
  }

  /// `Try reconnecting the USB device.`
  String get tryReconnectingUsb {
    return Intl.message(
      'Try reconnecting the USB device.',
      name: 'tryReconnectingUsb',
      desc: 'Suggestion to reconnect USB',
      args: [],
    );
  }

  /// `Not required for network printers.`
  String get notRequiredForNetworkPrinters {
    return Intl.message(
      'Not required for network printers.',
      name: 'notRequiredForNetworkPrinters',
      desc: 'Info that USB permission not required for network',
      args: [],
    );
  }

  /// `Printer Connectivity`
  String get printerConnectivity {
    return Intl.message(
      'Printer Connectivity',
      name: 'printerConnectivity',
      desc: 'Diagnostic check title for connectivity',
      args: [],
    );
  }

  /// `Printer responded successfully to test command.`
  String get printerRespondedSuccessfully {
    return Intl.message(
      'Printer responded successfully to test command.',
      name: 'printerRespondedSuccessfully',
      desc: 'Diagnostic success for connectivity',
      args: [],
    );
  }

  /// `Printer test failed: {error}`
  String printerTestFailed(String error) {
    return Intl.message(
      'Printer test failed: $error',
      name: 'printerTestFailed',
      desc: 'Diagnostic error for connectivity',
      args: [error],
    );
  }

  /// `Grant USB permission and try again.`
  String get suggestionGrantPermission {
    return Intl.message(
      'Grant USB permission and try again.',
      name: 'suggestionGrantPermission',
      desc: 'Suggestion for permission error',
      args: [],
    );
  }

  /// `Check that the printer is powered on and connected. Try reconnecting.`
  String get suggestionCheckPowerAndConnection {
    return Intl.message(
      'Check that the printer is powered on and connected. Try reconnecting.',
      name: 'suggestionCheckPowerAndConnection',
      desc: 'Suggestion for timeout error',
      args: [],
    );
  }

  /// `Verify the printer is connected and visible to the device.`
  String get suggestionVerifyPrinterConnected {
    return Intl.message(
      'Verify the printer is connected and visible to the device.',
      name: 'suggestionVerifyPrinterConnected',
      desc: 'Suggestion for not found error',
      args: [],
    );
  }

  /// `Check network connection and printer IP address.`
  String get suggestionCheckNetworkAndIp {
    return Intl.message(
      'Check network connection and printer IP address.',
      name: 'suggestionCheckNetworkAndIp',
      desc: 'Suggestion for network error',
      args: [],
    );
  }

  /// `Load paper into the printer.`
  String get suggestionLoadPaper {
    return Intl.message(
      'Load paper into the printer.',
      name: 'suggestionLoadPaper',
      desc: 'Suggestion for paper error',
      args: [],
    );
  }

  /// `Check printer connection and configuration.`
  String get suggestionCheckConnection {
    return Intl.message(
      'Check printer connection and configuration.',
      name: 'suggestionCheckConnection',
      desc: 'Generic suggestion for errors',
      args: [],
    );
  }

  /// `Run full diagnostics and show problems if any`
  String get runDiagnosticsTooltip {
    return Intl.message(
      'Run full diagnostics and show problems if any',
      name: 'runDiagnosticsTooltip',
      desc: 'Tooltip for diagnostics button',
      args: [],
    );
  }

  /// `Some diagnostic checks failed. Review the issues below and follow the suggestions to resolve them.`
  String get diagnosticsSomeFailed {
    return Intl.message(
      'Some diagnostic checks failed. Review the issues below and follow the suggestions to resolve them.',
      name: 'diagnosticsSomeFailed',
      desc: 'Summary when some diagnostic checks failed',
      args: [],
    );
  }

  /// `All diagnostic checks passed successfully. Your printer is configured correctly.`
  String get diagnosticsAllPassedDescription {
    return Intl.message(
      'All diagnostic checks passed successfully. Your printer is configured correctly.',
      name: 'diagnosticsAllPassedDescription',
      desc: 'Summary when all diagnostic checks passed',
      args: [],
    );
  }

  /// `Use the "Find Printers" button to configure connection.`
  String get useFindPrintersButton {
    return Intl.message(
      'Use the "Find Printers" button to configure connection.',
      name: 'useFindPrintersButton',
      desc: 'Suggestion to use Find Printers button',
      args: [],
    );
  }

  /// `USB permission granted.`
  String get usbPermissionGrantedShort {
    return Intl.message(
      'USB permission granted.',
      name: 'usbPermissionGrantedShort',
      desc: 'Short message when USB permission is granted',
      args: [],
    );
  }

  /// `Configure IP, subnet mask, gateway`
  String get networkSettingsTooltip {
    return Intl.message(
      'Configure IP, subnet mask, gateway',
      name: 'networkSettingsTooltip',
      desc: 'Tooltip for network settings button',
      args: [],
    );
  }

  /// `No USB permission required for network printers.`
  String get usbPermissionNotRequiredMessage {
    return Intl.message(
      'No USB permission required for network printers.',
      name: 'usbPermissionNotRequiredMessage',
      desc: 'Message when USB permission is not required',
      args: [],
    );
  }

  /// `Grant USB permission and try again.`
  String get suggestionGrantUsbPermission {
    return Intl.message(
      'Grant USB permission and try again.',
      name: 'suggestionGrantUsbPermission',
      desc: 'Suggestion to grant USB permission',
      args: [],
    );
  }

  /// `Enable DHCP`
  String get enableDhcp {
    return Intl.message(
      'Enable DHCP',
      name: 'enableDhcp',
      desc: 'Label for DHCP toggle switch',
      args: [],
    );
  }

  /// `Automatically obtain IP address from network`
  String get enableDhcpDescription {
    return Intl.message(
      'Automatically obtain IP address from network',
      name: 'enableDhcpDescription',
      desc: 'Description for DHCP toggle explaining what it does',
      args: [],
    );
  }

  /// `Static IP Configuration`
  String get staticIpSettings {
    return Intl.message(
      'Static IP Configuration',
      name: 'staticIpSettings',
      desc: 'Section header for manual IP configuration when DHCP is disabled',
      args: [],
    );
  }

  /// `DHCP is enabled. The printer will automatically obtain network settings from your router.`
  String get dhcpEnabled {
    return Intl.message(
      'DHCP is enabled. The printer will automatically obtain network settings from your router.',
      name: 'dhcpEnabled',
      desc: 'Information message when DHCP is enabled',
      args: [],
    );
  }

  /// `MAC address is required to configure DHCP via network`
  String get dhcpRequiresMac {
    return Intl.message(
      'MAC address is required to configure DHCP via network',
      name: 'dhcpRequiresMac',
      desc: 'Error message when MAC address is missing for DHCP configuration',
      args: [],
    );
  }

  /// `Network Settings Sent`
  String get networkSettingsAppliedTitle {
    return Intl.message(
      'Network Settings Sent',
      name: 'networkSettingsAppliedTitle',
      desc: 'Dialog title when network settings were sent to printer',
      args: [],
    );
  }

  /// `Network settings have been sent to the printer. Please restart the printer for changes to take effect.`
  String get networkSettingsAppliedMessage {
    return Intl.message(
      'Network settings have been sent to the printer. Please restart the printer for changes to take effect.',
      name: 'networkSettingsAppliedMessage',
      desc:
          'Message explaining printer needs restart after network settings change',
      args: [],
    );
  }

  /// `DHCP has been enabled. After restarting, the printer will obtain a new IP address from your router.`
  String get networkSettingsDhcpAppliedMessage {
    return Intl.message(
      'DHCP has been enabled. After restarting, the printer will obtain a new IP address from your router.',
      name: 'networkSettingsDhcpAppliedMessage',
      desc: 'Message when DHCP was enabled',
      args: [],
    );
  }

  /// `Static IP ({ipAddress}) has been configured. After restarting, the printer will use this address.`
  String networkSettingsStaticIpAppliedMessage(String ipAddress) {
    return Intl.message(
      'Static IP ($ipAddress) has been configured. After restarting, the printer will use this address.',
      name: 'networkSettingsStaticIpAppliedMessage',
      desc: 'Message when static IP was configured',
      args: [ipAddress],
    );
  }

  /// `Printer Restart Required`
  String get restartPrinterRequired {
    return Intl.message(
      'Printer Restart Required',
      name: 'restartPrinterRequired',
      desc: 'Warning title about printer restart requirement',
      args: [],
    );
  }

  /// `Network settings were changed. The printer must be restarted for changes to take effect.`
  String get pendingRebootWarning {
    return Intl.message(
      'Network settings were changed. The printer must be restarted for changes to take effect.',
      name: 'pendingRebootWarning',
      desc: 'Warning message about pending printer reboot',
      args: [],
    );
  }

  /// `After restarting the printer, use "Find Printers" to reconnect with the new settings.`
  String get reconnectAfterRestart {
    return Intl.message(
      'After restarting the printer, use "Find Printers" to reconnect with the new settings.',
      name: 'reconnectAfterRestart',
      desc: 'Instructions to reconnect after printer restart',
      args: [],
    );
  }

  /// `Testing is unavailable until the printer is restarted and reconnected.`
  String get testingBlockedPendingReboot {
    return Intl.message(
      'Testing is unavailable until the printer is restarted and reconnected.',
      name: 'testingBlockedPendingReboot',
      desc: 'Message when testing is blocked due to pending reboot',
      args: [],
    );
  }

  /// `Diagnostics is unavailable until the printer is restarted and reconnected.`
  String get diagnosticsBlockedPendingReboot {
    return Intl.message(
      'Diagnostics is unavailable until the printer is restarted and reconnected.',
      name: 'diagnosticsBlockedPendingReboot',
      desc: 'Message when diagnostics is blocked due to pending reboot',
      args: [],
    );
  }

  /// `Reset Connection`
  String get resetConnectionAndReconnect {
    return Intl.message(
      'Reset Connection',
      name: 'resetConnectionAndReconnect',
      desc: 'Button to reset connection for reconnecting with new settings',
      args: [],
    );
  }

  /// `This will remove the current connection. After restarting the printer, search for it again using "Find Printers".`
  String get resetConnectionConfirmation {
    return Intl.message(
      'This will remove the current connection. After restarting the printer, search for it again using "Find Printers".',
      name: 'resetConnectionConfirmation',
      desc: 'Confirmation message for resetting connection',
      args: [],
    );
  }

  /// `1. Turn off the printer\n2. Wait 10 seconds\n3. Turn on the printer\n4. Click "Reset Connection" below\n5. Use "Find Printers" to reconnect`
  String get printerRestartInstructions {
    return Intl.message(
      '1. Turn off the printer\n2. Wait 10 seconds\n3. Turn on the printer\n4. Click "Reset Connection" below\n5. Use "Find Printers" to reconnect',
      name: 'printerRestartInstructions',
      desc: 'Step by step instructions for restarting printer',
      args: [],
    );
  }

  /// `Understood`
  String get understood {
    return Intl.message(
      'Understood',
      name: 'understood',
      desc: 'Button label for acknowledging information',
      args: [],
    );
  }

  /// `USB connection will continue to work normally.`
  String get usbConnectionStillWorks {
    return Intl.message(
      'USB connection will continue to work normally.',
      name: 'usbConnectionStillWorks',
      desc:
          'Note that USB connection is not affected by network settings change',
      args: [],
    );
  }
}

class AppLocalizationDelegate
    extends LocalizationsDelegate<PrinterManagerL10n> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
      Locale.fromSubtags(languageCode: 'es', countryCode: 'PR'),
      Locale.fromSubtags(languageCode: 'ru', countryCode: 'RU'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<PrinterManagerL10n> load(Locale locale) =>
      PrinterManagerL10n.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
