// import 'dart:io';
//
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/foundation.dart';
//
// Future<void> getDeviceInfo() async {
//   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//   if (Platform.isAndroid) {
//     AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//     if (kDebugMode) {
//       print('Running on ${androidInfo.model}');
//     }
//   } else if (Platform.isIOS) {
//     IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
//     if (kDebugMode) {
//       print('Running on ${iosInfo.utsname.machine}');
//     }
//   }
// }
