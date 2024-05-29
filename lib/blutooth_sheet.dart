import 'dart:async';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thinkbros/components/connection_state_container.dart';
import 'package:thinkbros/permissions.dart';
import 'package:thinkbros/thinkbros.dart';

class BluetoothConnectSheet {
  static void up(WidgetRef ref, BuildContext context) async {
    SnackBar snackBarOut(message) {
      return SnackBar(
        content: Text(message),
      );
    }

    if (await FlutterBluePlus.isSupported == false) {
      snackBarOut('블루투스 기능을 지원하지 않는 기기 입니다.');
      return;
    }

    bool bluetoothState =
        FlutterBluePlus.adapterStateNow != BluetoothAdapterState.off;

    // 블루투스 기능 사용 가능 여부 체크
    if (!bluetoothState) {
      if (Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
      } else {
        if (context.mounted) {
          snackBarOut('블루투스 기능이 꺼져있습니다.');
        }
        return;
      }
    }

    bool hasFineBluetoothCondition = false;

    if (bluetoothState) {
      hasFineBluetoothCondition =
          await PermissionUtility.requestBluetoothPermission();
    }

    // 블루투스 권한 설정 여부 체크

    if (Platform.isAndroid) {
      if (await Permission.bluetoothScan.isPermanentlyDenied &&
          context.mounted) {
        await PermissionUtility.openBluetoothDeniedDialog(
            context: context, title: '안내');
      }
    } else {
      if (await Permission.bluetooth.isPermanentlyDenied &&
          (FlutterBluePlus.adapterStateNow ==
              BluetoothAdapterState.unauthorized) &&
          context.mounted) {
        await PermissionUtility.openBluetoothDeniedDialog(
            context: context, title: '안내');
      }
      print('@@@블루투스 아웃');
    }

    final List<String> availableServices = [
      'EY',
      'NT',
      'netum',
      'NETUM',
      'scan',
      'SCAN'
    ];
    late StreamSubscription<List<ScanResult>> subscription;

    Future<void> startSequence() async {
      await FlutterBluePlus.stopScan();
      await FlutterBluePlus.startScan(
        withKeywords: availableServices,
        continuousUpdates: true,
        continuousDivisor: Platform.isAndroid ? 8 : 1,
      );

      subscription = FlutterBluePlus.onScanResults.listen((results) {
        ref.read(scanResultsProvider.notifier).update((state) => results);
        print('스캔결과:${ref.read(scanResultsProvider)}');
      }, onError: (e) {
        debugPrint('## :: Error $e');
      });
    }

    await startSequence();

    FlutterBluePlus.cancelWhenScanComplete(subscription);

    if (context.mounted) {
      return showModalBottomSheet(
        context: context,
        enableDrag: true,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16.0),
            topLeft: Radius.circular(16.0),
          ),
        ),
        clipBehavior: Clip.hardEdge,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter bottomState) {
            return const ConnectionStateContainer();
          });
        },
      ).whenComplete(() async {
        await FlutterBluePlus.stopScan();
        await subscription.cancel();
      });
    }
  }
}
