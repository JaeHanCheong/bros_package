import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class SheetScanResultTile extends StatefulWidget {
  const SheetScanResultTile({
    super.key,
    required this.scannedDevice,
    this.onConnect,
    this.onDisconnect,
  });

  final ScanResult scannedDevice;
  final Function? onConnect;
  final Function? onDisconnect;

  @override
  State<SheetScanResultTile> createState() => _SheetScanResultTileState();
}

class _SheetScanResultTileState extends State<SheetScanResultTile> {
  Widget _buildTitle(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.scannedDevice.device.platformName,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          Platform.isAndroid
              ? '(${widget.scannedDevice.device.remoteId.toString()})'
              : '(${widget.scannedDevice.device.remoteId.toString().substring(0, 8)})',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black38,
          ),
        )
      ],
    );
  }

  bool isConnected = false;
  bool toggleState = false;

  Widget _buildConnectToggle(BuildContext context) {
    isConnected = widget.scannedDevice.device.isConnected;
    toggleState = isConnected;

    return Row(
      children: [
        isConnected
            ? const Text(
                '연결',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              )
            : const Text(
                '해제',
                style: TextStyle(
                  color: Colors.black38,
                  fontWeight: FontWeight.w400,
                ),
              ),
        const SizedBox(width: 8.0),
        CupertinoSwitch(
          value: toggleState,
          activeColor: Colors.blue,
          onChanged: (bool value) async {
            isConnected
                ? await widget.onDisconnect!()
                : await widget.onConnect!();

            setState(() {
              toggleState = value;
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.scannedDevice.advertisementData.connectable &&
          widget.scannedDevice.device.platformName.isNotEmpty,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 1.0,
              color: Colors.grey.withAlpha(100),
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildTitle(context),
            _buildConnectToggle(context),
          ],
        ),
      ),
    );
  }
}
