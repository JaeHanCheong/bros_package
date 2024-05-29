import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

  static Future<void> openBluetoothDeniedDialog({
    required BuildContext context,
    String title = '안내',
  }) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: Text(title),
          content: const Text('블루투스 기능을 켜지 않으면 해당 기능을 사용할 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('닫기'),
            ),
            TextButton(
              onPressed: () async {
                if (context.mounted) {
                  final resultState =
                      await PermissionUtility.checkBluetoothPermission();

                  if (resultState) {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  } else {
                    AppSettings.openAppSettings();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                }
              },
              child: const Text('설정으로'),
            ),
          ],
        );
      },
    );
  }
}
