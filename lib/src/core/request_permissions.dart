import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../shared/consts.dart';
import '../shared/enum.dart';

part 'if_denied.dart';

class RequestPermissions extends StatefulWidget {
  const RequestPermissions({super.key});

  @override
  State<RequestPermissions> createState() => _RequestPermissionsState();
}

class _RequestPermissionsState extends State<RequestPermissions> {
  void _showIfDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const IfDenied();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Image.asset(
              'assets/images/permissions.png',
              fit: BoxFit.cover,
              height: 300,
            ),
            const Text(
              'Enable permissions',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 26,
                color: blackColor, // Use your color here
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'We ask to allow the required permissions for the functionality of application',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: blackColor, // Use your color here
                ),
              ),
            ),
            const SizedBox(height: 16),
            // buildPermissionRow('Location'),
            buildPermissionRow('Contacts'),
            buildPermissionRow('Camera'),
            // buildPermissionRow('Notifications'),
            // buildPermissionRow('SMS'),
            buildPermissionRow('Microphone'),
            const SizedBox(height: 32),
            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    minimumSize: const Size.fromHeight(56.0),
                  ),
                  onPressed: () async {
                    // Request permissions here
                    Map<Permission, PermissionStatus> status = await [
                      // Permission.location,
                      Permission.phone,
                      Permission.camera,
                      // Permission.notification,
                      // Permission.sms,
                      Permission.microphone
                    ].request();

                    /// Check if any permission is denied
                    if (status.containsValue(PermissionStatus.denied)) {
                      print("not all :$status");
                      _showIfDeniedDialog();
                    }
                    context.go('/${Routes.login.name}');
                  },
                  child: const Text(
                    "Allow",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget buildPermissionRow(String permissionName) {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0, top: 16),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor, // Customize your icon color
            ),
          ),
          const SizedBox(width: 8),
          Text(
            permissionName,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 18,
              color: blackColor,
            ),
          ),
        ],
      ),
    );
  }
}
