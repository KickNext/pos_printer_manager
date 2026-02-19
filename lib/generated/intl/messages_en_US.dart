// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en_US locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en_US';

  static String m0(connectionType) =>
      "Connection parameters are configured (${connectionType}).";

  static String m1(error) => "Could not check USB permission: ${error}";

  static String m2(error) => "Failed to create printer: ${error}";

  static String m3(count) => "Found ${count} printer(s)";

  static String m4(ipAddress) =>
      "Static IP (${ipAddress}) has been configured. After restarting, the printer will use this address.";

  static String m5(number) => "Printer ${number}";

  static String m6(error) => "Printer test failed: ${error}";

  static String m7(deviceInfo) => "USB permission granted: ${deviceInfo}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "addPrinter": MessageLookupByLibrary.simpleMessage("Add Printer"),
    "addPrinterToStart": MessageLookupByLibrary.simpleMessage(
      "Add a printer to get started.",
    ),
    "additionalSettings": MessageLookupByLibrary.simpleMessage(
      "Additional Settings",
    ),
    "androBar": MessageLookupByLibrary.simpleMessage("AndroBar"),
    "androBarDescription": MessageLookupByLibrary.simpleMessage(
      "Bar display system",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Back"),
    "bluetooth": MessageLookupByLibrary.simpleMessage("Bluetooth"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "change": MessageLookupByLibrary.simpleMessage("Change"),
    "clearError": MessageLookupByLibrary.simpleMessage("Clear Error"),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "configureConnectionLater": MessageLookupByLibrary.simpleMessage(
      "You can configure connection after creation",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "connect": MessageLookupByLibrary.simpleMessage("Connect"),
    "connectionConfiguration": MessageLookupByLibrary.simpleMessage(
      "Connection Configuration",
    ),
    "connectionError": MessageLookupByLibrary.simpleMessage("Connection Error"),
    "connectionParamsConfigured": m0,
    "couldNotCheckUsbPermission": m1,
    "create": MessageLookupByLibrary.simpleMessage("Create"),
    "dangerZone": MessageLookupByLibrary.simpleMessage("Danger Zone"),
    "dangerZoneDescription": MessageLookupByLibrary.simpleMessage(
      "Removing this printer will delete all its configuration. You can add it again later, but you will need to reconfigure it.",
    ),
    "dhcp": MessageLookupByLibrary.simpleMessage("DHCP"),
    "dhcpEnabled": MessageLookupByLibrary.simpleMessage(
      "DHCP is enabled. The printer will automatically obtain network settings from your router.",
    ),
    "dhcpRequiresMac": MessageLookupByLibrary.simpleMessage(
      "MAC address is required to configure DHCP via network",
    ),
    "diagnosing": MessageLookupByLibrary.simpleMessage("Diagnosing..."),
    "diagnostics": MessageLookupByLibrary.simpleMessage("Diagnostics"),
    "diagnosticsAllPassed": MessageLookupByLibrary.simpleMessage(
      "All Checks Passed",
    ),
    "diagnosticsAllPassedDescription": MessageLookupByLibrary.simpleMessage(
      "All diagnostic checks passed successfully. Your printer is configured correctly.",
    ),
    "diagnosticsBlockedPendingReboot": MessageLookupByLibrary.simpleMessage(
      "Diagnostics is unavailable until the printer is restarted and reconnected.",
    ),
    "diagnosticsProblemsDescription": MessageLookupByLibrary.simpleMessage(
      "Some diagnostic checks failed. Review the issues below and follow the suggestions to resolve them.",
    ),
    "diagnosticsProblemsFound": MessageLookupByLibrary.simpleMessage(
      "Problems Found",
    ),
    "diagnosticsSomeFailed": MessageLookupByLibrary.simpleMessage(
      "Some diagnostic checks failed. Review the issues below and follow the suggestions to resolve them.",
    ),
    "diagnosticsSuccessDescription": MessageLookupByLibrary.simpleMessage(
      "All diagnostic checks passed successfully. Your printer is configured correctly.",
    ),
    "disabled": MessageLookupByLibrary.simpleMessage("Disabled"),
    "disconnect": MessageLookupByLibrary.simpleMessage("Disconnect"),
    "disconnectPrinterConfirmation": MessageLookupByLibrary.simpleMessage(
      "This will remove the current connection settings. You can reconnect later.",
    ),
    "disconnectPrinterQuestion": MessageLookupByLibrary.simpleMessage(
      "Disconnect Printer?",
    ),
    "enableDhcp": MessageLookupByLibrary.simpleMessage("Enable DHCP"),
    "enableDhcpDescription": MessageLookupByLibrary.simpleMessage(
      "Automatically obtain IP address from network",
    ),
    "enabled": MessageLookupByLibrary.simpleMessage("Enabled"),
    "failedToCreatePrinter": m2,
    "findPrinters": MessageLookupByLibrary.simpleMessage("Find Printers"),
    "foundPrinters": m3,
    "gateway": MessageLookupByLibrary.simpleMessage("Gateway"),
    "gatewayHint": MessageLookupByLibrary.simpleMessage("192.168.1.1"),
    "grantUsbPermission": MessageLookupByLibrary.simpleMessage(
      "Grant USB Permission",
    ),
    "grantUsbPermissionSuggestion": MessageLookupByLibrary.simpleMessage(
      "Grant USB permission by clicking \"Grant USB Permission\" button.",
    ),
    "ipAddress": MessageLookupByLibrary.simpleMessage("IP Address"),
    "ipAddressHint": MessageLookupByLibrary.simpleMessage("192.168.1.100"),
    "ipAddressRequired": MessageLookupByLibrary.simpleMessage(
      "IP Address is required",
    ),
    "kitchenPrinter": MessageLookupByLibrary.simpleMessage("Kitchen Printer"),
    "kitchenPrinterDescription": MessageLookupByLibrary.simpleMessage(
      "For kitchen orders",
    ),
    "labelPrinter": MessageLookupByLibrary.simpleMessage("Label Printer"),
    "labelPrinterDescription": MessageLookupByLibrary.simpleMessage(
      "For product labels",
    ),
    "macAddress": MessageLookupByLibrary.simpleMessage("MAC Address"),
    "macAddressRequired": MessageLookupByLibrary.simpleMessage(
      "MAC address required for network configuration",
    ),
    "manufacturer": MessageLookupByLibrary.simpleMessage("Manufacturer"),
    "maxPrintersReached": MessageLookupByLibrary.simpleMessage(
      "Maximum number of printers reached.",
    ),
    "nameYourPrinter": MessageLookupByLibrary.simpleMessage(
      "Name your printer",
    ),
    "nameYourPrinterDescription": MessageLookupByLibrary.simpleMessage(
      "Give your printer a descriptive name to identify it easily.",
    ),
    "network": MessageLookupByLibrary.simpleMessage("Network"),
    "networkConnection": MessageLookupByLibrary.simpleMessage(
      "Network Connection",
    ),
    "networkSettings": MessageLookupByLibrary.simpleMessage("Network Settings"),
    "networkSettingsAppliedMessage": MessageLookupByLibrary.simpleMessage(
      "Network settings have been sent to the printer. Please restart the printer for changes to take effect.",
    ),
    "networkSettingsAppliedTitle": MessageLookupByLibrary.simpleMessage(
      "Network Settings Sent",
    ),
    "networkSettingsDhcpAppliedMessage": MessageLookupByLibrary.simpleMessage(
      "DHCP has been enabled. After restarting, the printer will obtain a new IP address from your router.",
    ),
    "networkSettingsStaticIpAppliedMessage": m4,
    "networkSettingsTooltip": MessageLookupByLibrary.simpleMessage(
      "Configure IP, subnet mask, gateway",
    ),
    "networkSettingsUpdated": MessageLookupByLibrary.simpleMessage(
      "Network settings updated successfully",
    ),
    "next": MessageLookupByLibrary.simpleMessage("Next"),
    "noConnection": MessageLookupByLibrary.simpleMessage("No Connection"),
    "noConnectionConfigured": MessageLookupByLibrary.simpleMessage(
      "No connection configured. Please set up USB or Network connection first.",
    ),
    "noConnectionDescription": MessageLookupByLibrary.simpleMessage(
      "No printer is connected. Search for available printers to configure the connection.",
    ),
    "noPermissionNeeded": MessageLookupByLibrary.simpleMessage(
      "No Permission Needed",
    ),
    "noPrintersAvailable": MessageLookupByLibrary.simpleMessage(
      "No Printers Available",
    ),
    "noPrintersConfigured": MessageLookupByLibrary.simpleMessage(
      "No Printers Configured",
    ),
    "noPrintersFound": MessageLookupByLibrary.simpleMessage(
      "No Printers Found",
    ),
    "noPrintersFoundDescription": MessageLookupByLibrary.simpleMessage(
      "Make sure your printer is powered on and connected to the same network or via USB.",
    ),
    "noUsbPermissionNeededMessage": MessageLookupByLibrary.simpleMessage(
      "No USB permission required for network printers.",
    ),
    "notConnected": MessageLookupByLibrary.simpleMessage("Not Connected"),
    "notRequiredForNetworkPrinters": MessageLookupByLibrary.simpleMessage(
      "Not required for network printers.",
    ),
    "pendingRebootWarning": MessageLookupByLibrary.simpleMessage(
      "Network settings were changed. The printer must be restarted for changes to take effect.",
    ),
    "permissionDenied": MessageLookupByLibrary.simpleMessage(
      "Permission Denied",
    ),
    "permissionGranted": MessageLookupByLibrary.simpleMessage(
      "Permission Granted",
    ),
    "permissionRequired": MessageLookupByLibrary.simpleMessage(
      "Permission Required",
    ),
    "pleaseEnterName": MessageLookupByLibrary.simpleMessage(
      "Please enter a name",
    ),
    "pleaseSelectPrinterType": MessageLookupByLibrary.simpleMessage(
      "Please select a printer type",
    ),
    "printerConnectivity": MessageLookupByLibrary.simpleMessage(
      "Printer Connectivity",
    ),
    "printerDefaultName": m5,
    "printerDetails": MessageLookupByLibrary.simpleMessage("Printer Details"),
    "printerName": MessageLookupByLibrary.simpleMessage("Printer Name"),
    "printerNameHint": MessageLookupByLibrary.simpleMessage(
      "e.g., Kitchen Display, Bar Printer",
    ),
    "printerRespondedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Printer responded successfully to test command.",
    ),
    "printerRestartInstructions": MessageLookupByLibrary.simpleMessage(
      "1. Turn off the printer\n2. Wait 10 seconds\n3. Turn on the printer\n4. Click \"Reset Connection\" below\n5. Use \"Find Printers\" to reconnect",
    ),
    "printerTestFailed": m6,
    "printing": MessageLookupByLibrary.simpleMessage("Printing..."),
    "productId": MessageLookupByLibrary.simpleMessage("Product ID"),
    "productName": MessageLookupByLibrary.simpleMessage("Product Name"),
    "readyToConnect": MessageLookupByLibrary.simpleMessage("Ready to Connect"),
    "readyToConnectDescription": MessageLookupByLibrary.simpleMessage(
      "Your printer has been created. You can now configure the connection.",
    ),
    "readyToPrint": MessageLookupByLibrary.simpleMessage(
      "Last Test Successful",
    ),
    "receiptPrinter": MessageLookupByLibrary.simpleMessage("Receipt Printer"),
    "receiptPrinterDescription": MessageLookupByLibrary.simpleMessage(
      "For receipts and bills",
    ),
    "reconnectAfterRestart": MessageLookupByLibrary.simpleMessage(
      "After restarting the printer, use \"Find Printers\" to reconnect with the new settings.",
    ),
    "refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
    "remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "removePrinter": MessageLookupByLibrary.simpleMessage("Remove Printer"),
    "removePrinterConfirmation": MessageLookupByLibrary.simpleMessage(
      "This will remove the printer and all its configuration. You can add it again later.",
    ),
    "removePrinterQuestion": MessageLookupByLibrary.simpleMessage(
      "Remove Printer?",
    ),
    "renamePrinter": MessageLookupByLibrary.simpleMessage("Rename Printer"),
    "requesting": MessageLookupByLibrary.simpleMessage("Requesting..."),
    "resetConnectionAndReconnect": MessageLookupByLibrary.simpleMessage(
      "Reset Connection",
    ),
    "resetConnectionConfirmation": MessageLookupByLibrary.simpleMessage(
      "This will remove the current connection. After restarting the printer, search for it again using \"Find Printers\".",
    ),
    "restartPrinterRequired": MessageLookupByLibrary.simpleMessage(
      "Printer Restart Required",
    ),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "runDiagnosticsTooltip": MessageLookupByLibrary.simpleMessage(
      "Run full diagnostics and show problems if any",
    ),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveSettings": MessageLookupByLibrary.simpleMessage("Save Settings"),
    "scanningNetworkAndUsb": MessageLookupByLibrary.simpleMessage(
      "Scanning network and USB...",
    ),
    "searchAgain": MessageLookupByLibrary.simpleMessage("Search Again"),
    "searchingForPrinters": MessageLookupByLibrary.simpleMessage(
      "Searching for printers...",
    ),
    "selectPrinterType": MessageLookupByLibrary.simpleMessage(
      "Select printer type",
    ),
    "selectPrinterTypeDescription": MessageLookupByLibrary.simpleMessage(
      "Choose the type of printer you want to add.",
    ),
    "serialNumber": MessageLookupByLibrary.simpleMessage("Serial Number"),
    "staticIpSettings": MessageLookupByLibrary.simpleMessage(
      "Static IP Configuration",
    ),
    "stepName": MessageLookupByLibrary.simpleMessage("Name"),
    "stepType": MessageLookupByLibrary.simpleMessage("Type"),
    "subnetMask": MessageLookupByLibrary.simpleMessage("Subnet Mask"),
    "subnetMaskHint": MessageLookupByLibrary.simpleMessage("255.255.255.0"),
    "suggestionCheckConnection": MessageLookupByLibrary.simpleMessage(
      "Check printer connection and configuration.",
    ),
    "suggestionCheckNetworkAndIp": MessageLookupByLibrary.simpleMessage(
      "Check network connection and printer IP address.",
    ),
    "suggestionCheckPowerAndConnection": MessageLookupByLibrary.simpleMessage(
      "Check that the printer is powered on and connected. Try reconnecting.",
    ),
    "suggestionGrantPermission": MessageLookupByLibrary.simpleMessage(
      "Grant USB permission and try again.",
    ),
    "suggestionGrantUsbPermission": MessageLookupByLibrary.simpleMessage(
      "Grant USB permission and try again.",
    ),
    "suggestionLoadPaper": MessageLookupByLibrary.simpleMessage(
      "Load paper into the printer.",
    ),
    "suggestionVerifyPrinterConnected": MessageLookupByLibrary.simpleMessage(
      "Verify the printer is connected and visible to the device.",
    ),
    "testPrint": MessageLookupByLibrary.simpleMessage("Test Print"),
    "testingBlockedPendingReboot": MessageLookupByLibrary.simpleMessage(
      "Testing is unavailable until the printer is restarted and reconnected.",
    ),
    "tipCheckAndroBarNetwork": MessageLookupByLibrary.simpleMessage(
      "Check network connectivity to AndroBar device",
    ),
    "tipCheckLabels": MessageLookupByLibrary.simpleMessage(
      "Ensure labels are loaded properly",
    ),
    "tipCheckPaper": MessageLookupByLibrary.simpleMessage(
      "Check that paper is loaded correctly",
    ),
    "tipCheckPowerOn": MessageLookupByLibrary.simpleMessage(
      "Check that the printer is powered on",
    ),
    "tipNetworkConnection": MessageLookupByLibrary.simpleMessage(
      "For Network: Verify WiFi/Ethernet connection",
    ),
    "tipUsbCable": MessageLookupByLibrary.simpleMessage(
      "For USB: Ensure cable is securely connected",
    ),
    "troubleshootingTips": MessageLookupByLibrary.simpleMessage(
      "Troubleshooting Tips",
    ),
    "tryReconnectingUsb": MessageLookupByLibrary.simpleMessage(
      "Try reconnecting the USB device.",
    ),
    "understood": MessageLookupByLibrary.simpleMessage("Understood"),
    "unknown": MessageLookupByLibrary.simpleMessage("Unknown"),
    "upsideDownMode": MessageLookupByLibrary.simpleMessage("Upside Down"),
    "upsideDownModeDescription": MessageLookupByLibrary.simpleMessage(
      "Print in 180° rotated mode",
    ),
    "usb": MessageLookupByLibrary.simpleMessage("USB"),
    "usbConnection": MessageLookupByLibrary.simpleMessage("USB Connection"),
    "usbConnectionStillWorks": MessageLookupByLibrary.simpleMessage(
      "USB connection will continue to work normally.",
    ),
    "usbPermission": MessageLookupByLibrary.simpleMessage("USB Permission"),
    "usbPermissionCheck": MessageLookupByLibrary.simpleMessage(
      "USB Permission",
    ),
    "usbPermissionDeniedError": MessageLookupByLibrary.simpleMessage(
      "USB permission denied",
    ),
    "usbPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "USB permission was denied. Please grant permission to use this printer.",
    ),
    "usbPermissionGrantedDiag": MessageLookupByLibrary.simpleMessage(
      "USB permission granted.",
    ),
    "usbPermissionGrantedMessage": MessageLookupByLibrary.simpleMessage(
      "USB permission granted. Printer is ready to use.",
    ),
    "usbPermissionGrantedShort": MessageLookupByLibrary.simpleMessage(
      "USB permission granted.",
    ),
    "usbPermissionGrantedSuccess": MessageLookupByLibrary.simpleMessage(
      "USB permission granted",
    ),
    "usbPermissionGrantedWithDevice": m7,
    "usbPermissionNotGranted": MessageLookupByLibrary.simpleMessage(
      "USB permission not granted.",
    ),
    "usbPermissionNotRequiredMessage": MessageLookupByLibrary.simpleMessage(
      "No USB permission required for network printers.",
    ),
    "usbPermissionRequiredMessage": MessageLookupByLibrary.simpleMessage(
      "USB permission is required to communicate with this printer.",
    ),
    "useFindPrintersButton": MessageLookupByLibrary.simpleMessage(
      "Use the \"Find Printers\" button to configure connection.",
    ),
    "useFinderToConnect": MessageLookupByLibrary.simpleMessage(
      "Use the \"Find Printers\" button to configure connection.",
    ),
    "vendorId": MessageLookupByLibrary.simpleMessage("Vendor ID"),
  };
}
