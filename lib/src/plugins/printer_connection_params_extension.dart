import 'package:pos_printers/pos_printers.dart';

/// Расширение для JSON-сериализации PrinterConnectionParams
extension PrinterConnectionParamsExtension on PrinterConnectionParamsDTO {
  Map<String, dynamic> toJson() => {
    'id': id,
    'connectionType': connectionType.index,
    'usbParams': usbParams?.toJson(),
    'networkParams': networkParams?.toJson(),
  };

  static PrinterConnectionParamsDTO fromJson(Map<String, dynamic> json) {
    return PrinterConnectionParamsDTO(
      id: json['id'] as String,
      connectionType:
          PosPrinterConnectionType.values[json['connectionType'] as int],
      usbParams:
          json['usbParams'] != null
              ? UsbParamsJson.fromJson(
                json['usbParams'] as Map<String, dynamic>,
              )
              : null,
      networkParams:
          json['networkParams'] != null
              ? NetworkParamsJson.fromJson(
                json['networkParams'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  String get displayName {
    switch (connectionType) {
      case PosPrinterConnectionType.usb:
        StringBuffer sb = StringBuffer();
        if (usbParams?.manufacturer != null) {
          sb.write(usbParams?.manufacturer);
          sb.write(' ');
        }
        if (usbParams?.productName != null) {
          sb.write(usbParams?.productName);
        }
        if (sb.isEmpty) {
          return '${usbParams?.vendorId}:${usbParams?.productId}';
        }
        return sb.toString();
      case PosPrinterConnectionType.network:
        return '${networkParams?.ipAddress}';
    }
  }
}

/// Вложенное расширение для USB-параметров
extension UsbParamsJson on UsbParams {
  Map<String, dynamic> toJson() => {
    'vendorId': vendorId,
    'productId': productId,
    'usbSerialNumber': serialNumber,
    'manufacturer': manufacturer,
    'productName': productName,
  };

  static UsbParams fromJson(Map<String, dynamic> json) {
    return UsbParams(
      vendorId: json['vendorId'] as int,
      productId: json['productId'] as int,
      serialNumber: json['usbSerialNumber'] as String?,
      manufacturer: json['manufacturer'] as String?,
      productName: json['productName'] as String?,
    );
  }
}

/// Вложенное расширение для сетевых параметров
extension NetworkParamsJson on NetworkParams {
  Map<String, dynamic> toJson() => {
    'ipAddress': ipAddress,
    'mask': mask,
    'gateway': gateway,
    'macAddress': macAddress,
    'dhcp': dhcp,
  };

  static NetworkParams fromJson(Map<String, dynamic> json) {
    return NetworkParams(
      ipAddress: json['ipAddress'] as String,
      mask: json['mask'] as String?,
      gateway: json['gateway'] as String?,
      macAddress: json['macAddress'] as String?,
      dhcp: json['dhcp'] as bool?,
    );
  }
}
