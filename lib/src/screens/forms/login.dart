import "package:flutter/material.dart";

// import "package:flutter/services.dart";
import "package:go_router/go_router.dart";

// import "package:mobile_number/mobile_number.dart";
// import "package:mobile_number/sim_card.dart";
import "package:provider/provider.dart";

import "../../service/auth_service.dart";
import "../../service/storage_service.dart";
import "../../shared/consts.dart";
import "../../shared/enum.dart";

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // String _mobileNumber = '';
  // bool _isPermissionGranted = false;
  // List<SimCard> _simCard = <SimCard>[];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    StorageService()
        .createAndUpdateKeyValuePairInStorage('isFirstLogin', 'true');
    // MobileNumber.listenPhonePermission((isPermissionGranted) {
    //   if (isPermissionGranted) {
    //     _isPermissionGranted = isPermissionGranted;
    //     initMobileNumberState();
    //   } else {}
    // });
    //
    // initMobileNumberState();
  }

  ///getting user mobile number
  // Future<void> initMobileNumberState() async {
  //   if (!await MobileNumber.hasPhonePermission) {
  //     await MobileNumber.requestPhonePermission;
  //     return;
  //   } else {
  //     _isPermissionGranted = true;
  //   }
  //   try {
  //     _mobileNumber = (await MobileNumber.mobileNumber)!;
  //     _simCard = (await MobileNumber.getSimCards)!;
  //
  //     print("_sim : $_simCard");
  //     print("_mobile : $_mobileNumber");
  //   } on PlatformException catch (e) {
  //     debugPrint("Failed to get mobile number because of '${e.message}'");
  //   }
  //
  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;
  //
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/login.png',
              ),
              const SizedBox(height: 20),
              const Text(
                textAlign: TextAlign.center,
                'Haiva Agent for Restaurants Integrated with Square',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    await authService.login();
                    if (await authService.isAuthenticated()) {
                      goToImport();
                    }
                    // StorageService().deleteAllValuesFromStorage();
                  },
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator())
                      : const Text(
                          'Get Started',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Powered by",
              style: textStyleS12W400,
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/haiva.png', height: 40, width: 40),
                const Text(
                  "Haiva",
                  style: textStyleS20W700,
                )
              ],
            ),
            const SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }

  goToImport() {
    setState(() {
      isLoading = false;
    });
    context.go("/${Routes.import.name}");
  }
}
