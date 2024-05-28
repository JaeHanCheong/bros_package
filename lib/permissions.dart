class BrosPermission {
  Future<bool> requestBluetoothPermission() async {
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
}
