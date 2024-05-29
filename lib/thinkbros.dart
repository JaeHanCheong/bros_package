library thinkbros;

import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:thinkbros/blutooth_sheet.dart';

/// A Calculator.
StateProvider<bool> bluetoothConditionStateProvider =
    StateProvider<bool>((ref) => true);
StateProvider<List<ScanResult>> scanResultsProvider =
    StateProvider<List<ScanResult>>((ref) => []);
late final StreamSubscription subscription;
final onCharacteristicReceivedProvider =
    Provider<Stream<OnCharacteristicReceivedEvent>>((ref) {
  return FlutterBluePlus.events.onCharacteristicReceived;
});
final barcodeResultProvider =
    StateProvider<String>((ref) => '블루투스 연결 후 바코드를 스캔해주세요');

class Bros {
  static final barcodeResultProvider =
      StateProvider<String>((ref) => '블루투스 연결 후 바코드를 스캔해주세요');

  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;

  static blutoothConnectSheet(
      {required WidgetRef ref, required BuildContext context}) async {
    BluetoothConnectSheet.up(ref, context);
  }

  static initScanner({required WidgetRef ref}) {
    subscription =
        ref.read(onCharacteristicReceivedProvider).listen((sequence) async {
      String decodedString = String.fromCharCodes(sequence.value);
      decodedString = decodedString.replaceAll('\r', '');
      ref.read(barcodeResultProvider.notifier).state = decodedString;
      if (decodedString.isNotEmpty) {
        // 10분 미사용 시 해제를 위한 dateTime 기입
        String remoteId = sequence.device.remoteId.toString();
        // final convertedRemoteId =
        Platform.isAndroid
            ? remoteId.replaceAll(':', '')
            : remoteId.replaceAll('-', '');
        if (decodedString.length == 18) {
          // 뒤 5자리중 1로 시작하면 일자(2)+월(2), 2로 시작하면 시간(2) + 일자(2)
          var additionalCode = decodedString.substring(13);

          if (additionalCode.startsWith("1") ||
              additionalCode.startsWith("2")) {
            decodedString = decodedString.substring(0, 13);
          }
        }

        // ref
        //     .read(historyListProvider.notifier)
        //     .addHistoryList(barcode: decodedString, ref: ref);
      }
    });
  }
}
