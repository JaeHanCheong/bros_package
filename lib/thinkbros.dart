library thinkbros;

import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:thinkbros/blutooth_sheet.dart';

/// A Calculator.
StateProvider<bool> get bluetoothConditionStateProvider =>
    StateProvider<bool>((ref) => true);
StateProvider<List<ScanResult>> get scanResultsProvider =>
    StateProvider<List<ScanResult>>((ref) => []);

class Bros {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;

  static blutoothConnectSheet(
      {required WidgetRef ref, required BuildContext context}) async {
    BluetoothConnectSheet.up(ref, context);
  }
}
