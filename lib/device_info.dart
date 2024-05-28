// ignore_for_file: avoid_print

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceInfoUtility {
  static final TargetPlatform os = defaultTargetPlatform;
  static String? get modelName => _modelName;
  static String? get appVersion => _appVersion;
  static String? get appBuildNumber => _appBuildNumber;
  static String? get osVersionString => _osVersionString;
  static double get osVersion {
    try {
      return double.parse(_osVersionString!);
    } catch (_) {}
    return 0;
  }

  static int get sdkVersion {
    return _sdkVersion ?? 24;
  }

  static String? _modelName;
  static String? _appVersion;
  static String? _appBuildNumber;
  static String? _osVersionString;
  static int? _sdkVersion;

  static Future<void> init() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _appVersion = packageInfo.version;
      _appBuildNumber = packageInfo.buildNumber;
    } catch (e) {
      print(e.toString());
    }

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        try {
          AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
          _modelName = androidInfo.model; // ex) "SM-N986N"
          _osVersionString = androidInfo.version.release; // ex) "12"
          _sdkVersion = androidInfo.version.sdkInt;
        } catch (e) {
          print(e.toString());
        }
        break;
      case TargetPlatform.iOS:
        try {
          IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
          _modelName = iosInfo.utsname.machine; // ex) "iPhone12,1"
          _osVersionString = iosInfo.systemVersion; // ex) "15.5"
        } catch (e) {
          print(e.toString());
        }
        break;
      default:
        break;
    }
  }

  static Future<bool> isAboveAndroidApi33() async {
    bool isAbove = false;

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
        int? sdkInt = androidInfo.version.sdkInt;
        if (sdkInt > 33) {
          isAbove = true;
        }
      }
    } catch (_) {}

    return isAbove;
  }

  static bool isTabletDevice(context) {
    return MediaQuery.of(context).size.width >= 500;
  }

  static bool isSmallDevice(context) {
    return MediaQuery.of(context).size.width <= 320;
  }

  static double toMobileDeviceHorizontalPadding(context, double defaultValue) {
    double width = MediaQuery.of(context).size.width;
    double horizontalPadding = width >= 500 ? (width - 375) / 2 : defaultValue;
    return horizontalPadding;
  }

  static Future<String?> identifierForVendor() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final isoInfo = await deviceInfo.iosInfo;
    return isoInfo.identifierForVendor;
  }

  static bool shouldHybridComposition() {
    try {
      if (Platform.isAndroid) {
        if (sdkVersion >= 34) {
          return true;
        }
      }
    } catch (_) {
      return false;
    }

    return false;
  }
}
