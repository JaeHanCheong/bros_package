import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:thinkbros/device_info.dart';

class PermissionUtility {
  static Future<bool> requestBluetoothPermission() async {
    await DeviceInfoUtility.init();
    bool hasBluetoothPermission = false;

    if (Platform.isIOS) {
      hasBluetoothPermission = await Permission.bluetooth.request().isGranted;
    }

    if (Platform.isAndroid) {
      if (DeviceInfoUtility.osVersion >= 12) {
        hasBluetoothPermission =
            await Permission.bluetoothScan.request().isGranted;

        bool hasLocationPermission =
            await Permission.location.request().isGranted;

        return Future<bool>.value(
            hasBluetoothPermission && hasLocationPermission);
      } else {
        hasBluetoothPermission = await Permission.bluetooth.request().isGranted;
      }
    }

    return Future<bool>.value(hasBluetoothPermission);
  }

  static Future<bool> checkBluetoothPermission() async {
    bool hasBluetoothPermission = false;

    if (Platform.isIOS) {
      hasBluetoothPermission = await Permission.bluetooth.isGranted;
    }

    if (Platform.isAndroid) {
      hasBluetoothPermission = await Permission.bluetoothScan.isGranted;

      if (DeviceInfoUtility.osVersion >= 12) {
        bool hasLocationPermission = await Permission.location.isGranted;

        return Future<bool>.value(
            hasBluetoothPermission && hasLocationPermission);
      }
    }

    return Future<bool>.value(hasBluetoothPermission);
  }
}
