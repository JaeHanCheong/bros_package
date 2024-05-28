// ignore_for_file: depend_on_referenced_packages

import 'package:collection/collection.dart';

import 'utils.dart';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

final Map<DeviceIdentifier, StreamControllerReemit<bool>> _cglobal = {};
final Map<DeviceIdentifier, StreamControllerReemit<bool>> _dglobal = {};

/// connect & disconnect + update stream
extension Extra on BluetoothDevice {
  // convenience
  StreamControllerReemit<bool> get _cstream {
    _cglobal[remoteId] ??= StreamControllerReemit(initialValue: false);
    return _cglobal[remoteId]!;
  }

  // convenience
  StreamControllerReemit<bool> get _dstream {
    _dglobal[remoteId] ??= StreamControllerReemit(initialValue: false);
    return _dglobal[remoteId]!;
  }

  // get stream
  Stream<bool> get isConnecting {
    return _cstream.stream;
  }

  // get stream
  Stream<bool> get isDisconnecting {
    return _dstream.stream;
  }

  Future onSubscribePressed(BluetoothCharacteristic c) async {
    try {
      await c.setNotifyValue(c.isNotifying == false);
    } catch (e) {
      debugPrint('@@ READ ERR :: $e');
    }
  }

  // connect & update stream
  Future<void> connectAndUpdateStream() async {
    _cstream.add(true);
    try {
      await connect(mtu: null, timeout: const Duration(seconds: 15));

      final services = await discoverServices();

      final relevantService = services.firstWhereOrNull(
        (service) => ['feea', 'fff0'].contains(service.serviceUuid.toString()),
      );

      if (relevantService != null) {
        final characteristic = relevantService.characteristics.firstWhereOrNull(
            (characteristic) => characteristic.properties.notify);

        if (characteristic != null) {
          final descriptor = characteristic.descriptors.firstWhereOrNull(
              (descriptor) => descriptor.descriptorUuid.toString() == '2902');

          if (descriptor != null) {
            await onSubscribePressed(characteristic);
            return;
          }
        }
      }
    } finally {
      _cstream.add(false);
    }
  }

  // disconnect & update stream
  Future<void> disconnectAndUpdateStream(BluetoothDevice device,
      {bool queue = true}) async {
    _dstream.add(true);

    try {
      await disconnect(queue: queue);
    } catch (e) {
      debugPrint('@@ READ ERR :: $e');
    } finally {
      _dstream.add(false);
    }
  }
}
