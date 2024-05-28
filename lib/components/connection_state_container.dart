import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:thinkbros/components/connected_device_tile.dart';
import 'package:thinkbros/components/sheet_scan_result_tile.dart';
import 'package:thinkbros/thinkbros.dart';
import 'package:thinkbros/utils/extra.dart';

// ignore: must_be_immutable
class ConnectionStateContainer extends HookConsumerWidget {
  const ConnectionStateContainer({super.key});

  Future<void> onConnectPressed(
      BluetoothDevice device, BuildContext context) async {
    context.loaderOverlay.show();

    try {
      await device.connectAndUpdateStream();
      if (context.mounted) {
        context.loaderOverlay.hide();

        GsSnackbarScaffoldFlutter.show(
            message: '스캐너가 연결 되었습니다.', center: true, context: context);
      }
    } catch (e) {
      debugPrint('@@ [ERROR] Bluetooth connect tried :$e');
      if (context.mounted) {
        context.loaderOverlay.hide();

        GsSnackbarScaffoldFlutter.show(
          message: '정상적으로 처리되지 않았습니다. 다시 시도하여 주세요.',
          center: true,
          context: context,
        );
      }
    }
  }

  Future<void> onDisconnectPressed(
      BluetoothDevice device, BuildContext context) async {
    context.loaderOverlay.show();

    await device.disconnectAndUpdateStream(device);

    try {
      if (context.mounted) {
        context.loaderOverlay.hide();

        GsSnackbarScaffoldFlutter.show(
            message: '스캐너가 해제 되었습니다.', center: true, context: context);
      }
    } catch (e) {
      debugPrint('@@ [ERROR] Bluetooth disconnect tried :$e');
      if (context.mounted) {
        context.loaderOverlay.hide();

        GsSnackbarScaffoldFlutter.show(
          message: '정상적으로 처리되지 않았습니다. 다시 시도하여 주세요.',
          center: true,
          context: context,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(scanResultsProvider);
    final c = FlutterBluePlus.connectedDevices;
    print('@@@@@@connectionstatecontainer:결과$s connected:$c');

    List<Widget> buildConnectedDeviceTiles(BuildContext context) {
      return c
          .map(
            (d) => ConnectedDeviceTile(
              connectedDevice: d,
              onConnect: () => onConnectPressed(d, context),
              onDisconnect: () => onDisconnectPressed(d, context),
            ),
          )
          .toList();
    }

    List<Widget> buildScanResultTiles(BuildContext context) {
      print('@@@@buildScanResultTiles:$s');
      return s
          .where((r) {
            for (var connected in c) {
              if (connected.remoteId == r.device.remoteId) {
                return false;
              }
            }

            return true;
          })
          .map(
            (ScanResult r) => SheetScanResultTile(
              scannedDevice: r,
              onConnect: () => onConnectPressed(r.device, context),
              onDisconnect: () => onDisconnectPressed(r.device, context),
            ),
          )
          .toList()
          .reversed
          .toList();
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      width: double.infinity,
      child: LoaderOverlay(
        useDefaultLoading: false,
        overlayColor: Colors.black12.withAlpha(180),
        overlayOpacity: 0.6,
        overlayWidget: const Center(
          child: SpinKitPianoWave(
            color: Colors.blue,
            size: 36.0,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 5.0,
                    width: 48.0,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(25.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32.0),
                const Text(
                  '블루투스 페어링..',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 4.0,
                ),
                Expanded(
                  child: SizedBox(
                    child: ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        ...buildConnectedDeviceTiles(context),
                        ...buildScanResultTiles(context),
                        const SizedBox(height: 16.0),
                        const SizedBox(
                          height: 32,
                          width: 32,
                          child: FittedBox(
                              child: CircularProgressIndicator(
                            color: Colors.black12,
                            strokeWidth: 1.0,
                          )),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GsSnackbarScaffoldFlutter {
  static void show({
    required BuildContext context,
    required String message,
    int duration = 1000,
    bool center = false,
    Color backgroundColor = Colors.blueAccent,
  }) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: center
            ? Center(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              )
            : Text(
                message,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
        backgroundColor: backgroundColor.withAlpha(180),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: Duration(milliseconds: duration),
        margin: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        behavior: SnackBarBehavior.floating,
      ));
  }
}
