import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../service/api_service.dart';
import '../service/storage_service.dart';
import '../service/web_view_auth.dart';
import '../shared/consts.dart';
import '../shared/enum.dart';

class ConnectProvider extends StatefulWidget {
  const ConnectProvider({super.key});

  @override
  State<ConnectProvider> createState() => _ConnectProviderState();
}

class _ConnectProviderState extends State<ConnectProvider>
    with WidgetsBindingObserver {
  bool _isFieldsVisible = false;
  bool areAllFieldsFilled = false;
  final TextEditingController clintIdController = TextEditingController();
  final TextEditingController clintSecretController = TextEditingController();

  void checkFieldsFilled() {
    if (clintIdController.text.isNotEmpty &&
        clintSecretController.text.isNotEmpty) {
      setState(() {
        areAllFieldsFilled = true;
      });
    } else {
      setState(() {
        areAllFieldsFilled = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    checkConnection();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkConnection();
    }
  }

  checkConnection() async {
    final response = await APIService().checkSquareConnection();
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final responseBody = decodedResponse;
      if (responseBody.isNotEmpty) {
        var lastObject = responseBody.last;
        if (lastObject['name'] != null) {
          print("Data ${response.body}");
          print(responseBody[0]['name']);
          bool hasAccessToken = lastObject['credentials']
              .any((cred) => cred['key'] == 'access_token');
          if (hasAccessToken) {
            await StorageService().createAndUpdateKeyValuePairInStorage(
                "recentConnName", lastObject['name']);
            goToHome();
          }
        }
      }
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri launchingUrl = Uri.parse(url);
    if (!await launchUrl(launchingUrl, mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        surfaceTintColor: whiteColor,
        backgroundColor: whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 26,
              color: loginBlackColor),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
              fontWeight: FontWeight.w500, fontSize: 18, color: hintTextColor),
        ),
        actions: [
          Center(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                onPressed: () async {
                  await AuthService().logout();
                  await StorageService().deleteStorageLogout();
                  // StorageService().deleteAllValuesFromStorage();
                  // StorageService()
                  //     .createAndUpdateKeyValuePairInStorage('isFirstLogin', 'true');
                  context.go('/');
                },
                child: const Text(
                  'Yes',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: whiteColor),
                ),
              ),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'No',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: loginBlackColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    checkConnection();
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                _showLogoutConfirmationDialog();
              },
              icon: const Icon(Icons.logout_outlined))
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/square-logo.png',
                      height: 96,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  // const SizedBox(height: 16),
                  // const Text(
                  //   'Powering 4 million businesses globally. Ready for yours.',
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(
                  //     fontSize: 16,
                  //     fontWeight: FontWeight.w600,
                  //     color: Colors.black87,
                  //     letterSpacing: 0.3,
                  //   ),
                  // ),
                  const SizedBox(height: 16),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: _isFieldsVisible
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: _buildQuickConnectOption(),
                    secondChild: _buildAdvancedConnectOption(),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "or",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isFieldsVisible = !_isFieldsVisible;
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isFieldsVisible ? Icons.arrow_back : Icons.settings,
                          size: 16,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isFieldsVisible
                              ? "Quick Connect"
                              : "Connect with Clint-Id/Secret",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickConnectOption() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Connect directly with your account',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Recommended for most of the users',
            style: TextStyle(
              fontSize: 12,
              color: secondaryColor,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              getConnection();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bolt, size: 16),
                SizedBox(width: 4),
                Text(
                  'Sign-in to Square',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedConnectOption() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Connect using your client credentials',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'For advanced users',
            style: TextStyle(
              fontSize: 12,
              color: secondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Client ID',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: (text) {
              checkFieldsFilled();
            },
            controller: clintIdController,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Enter your client ID',
              hintStyle: const TextStyle(
                color: hintTextColor,
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: primaryColor,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Client Secret',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: (text) {
              checkFieldsFilled();
            },
            controller: clintSecretController,
            obscureText: true,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Enter your client secret',
              hintStyle: const TextStyle(
                color: hintTextColor,
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: primaryColor,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: areAllFieldsFilled
                ? () {
                    getConnectionUsingClintCred();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              disabledBackgroundColor: Colors.grey.shade300,
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.grey.shade500,
              minimumSize: const Size.fromHeight(40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.vpn_key, size: 16),
                SizedBox(width: 4),
                Text(
                  'Connect using Credentials',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  goToHome() {
    StorageService()
        .createAndUpdateKeyValuePairInStorage("connect_token", "connected");
    if (mounted) context.go('/${Routes.home.name}');
  }

  getConnection() async {
    final response = await APIService().getConnection();
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final responseBody = decodedResponse[0]['authAttributes'];
      String orgID = await StorageService().getValueFromStorage("org_id");
      print(orgID);
      String wsID = await StorageService().getValueFromStorage("workspace_id");
      String connectionID = "${DateTime.now().millisecondsSinceEpoch}";

      ///time
      String connectionId = "square_connection_$connectionID";
      await StorageService()
          .createAndUpdateKeyValuePairInStorage("recentConnName", connectionId);
      String template = await StorageService().getValueFromStorage("template");

      String url =
          "https://services.haiva.ai/v1/apiconnectors/$orgID/$wsID/$template/authrequest?pkey=3fe0995209f5abcd3fe237286f32afa5"
          "&redirect_uri=https://console.haiva.ai/oauth/callback&status=false"
          "&${responseBody[0]['authAttributes'][0]['name']}=${responseBody[0]['authAttributes'][0]['value']}"
          "&${responseBody[0]['authAttributes'][1]['name']}=${responseBody[0]['authAttributes'][1]['value']}"
          "&${responseBody[0]['authAttributes'][2]['name']}=${responseBody[0]['authAttributes'][2]['value']}"
          "&${responseBody[0]['authAttributes'][3]['name']}=${responseBody[0]['authAttributes'][3]['value']}"
          "&${responseBody[0]['authAttributes'][4]['name']}=${responseBody[0]['authAttributes'][4]['value']}"
          "&${responseBody[0]['authAttributes'][5]['name']}=${responseBody[0]['authAttributes'][5]['value']}"
          "&name=$connectionId&authType=OAuth 2.0";
      const String baseUrl = 'https://console.haiva.ai/oauth/callback';
      final String encodedRedirectUrl = Uri.encodeComponent(url);
      final String consoleUrl =
          '$baseUrl?org_id=$orgID&workspace_id=$wsID&connector_name=$connectionId&provider=$template&redirect_url=$encodedRedirectUrl';

      _launchURL(consoleUrl);
    } else {
      callSnackBar(response);
    }
  }

  getConnectionUsingClintCred() async {
    final response = await APIService().getConnection();
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final responseBody = decodedResponse[0]['authAttributes'];
      String orgID = await StorageService().getValueFromStorage("org_id");
      String wsID = await StorageService().getValueFromStorage("workspace_id");
      String connectionID = "${DateTime.now().millisecondsSinceEpoch}";

      ///time
      String connectionId = "square_connection_$connectionID";
      await StorageService()
          .createAndUpdateKeyValuePairInStorage("recentConnName", connectionId);
      String template = await StorageService().getValueFromStorage("template");

      String url =
          "https://services.haiva.ai/v1/apiconnectors/$orgID/$wsID/$template/authrequest?pkey=3fe0995209f5abcd3fe237286f32afa5"
          "&redirect_uri=https://console.haiva.ai/oauth/callback&status=false"
          "&${responseBody[0]['authAttributes'][0]['name']}=${responseBody[0]['authAttributes'][0]['value']}"
          "&${responseBody[0]['authAttributes'][1]['name']}=${responseBody[0]['authAttributes'][1]['value']}"
          "&${responseBody[0]['authAttributes'][2]['name']}=${responseBody[0]['authAttributes'][2]['value']}"
          "&${responseBody[0]['authAttributes'][3]['name']}=${clintIdController.value.text}"
          "&${responseBody[0]['authAttributes'][4]['name']}=${clintSecretController.value.text}"
          "&${responseBody[0]['authAttributes'][5]['name']}=${responseBody[0]['authAttributes'][5]['value']}"
          "&name=$connectionId&authType=OAuth 2.0";
      const String baseUrl = 'https://console.haiva.ai/oauth/callback';
      final String encodedRedirectUrl = Uri.encodeComponent(url);
      final String consoleUrl =
          '$baseUrl?org_id=$orgID&workspace_id=$wsID&connector_name=$connectionId&provider=$template&redirect_url=$encodedRedirectUrl';

      // Navigator.of(context).push(
      //   MaterialPageRoute(
      //     builder: (context) => AuthWebView(url: consoleUrl),
      //   ),
      // );
      _launchURL(consoleUrl);
    } else {
      callSnackBar(response);
    }
  }

  callSnackBar(response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Could not Connect  Status: ${response.statusCode}',
          style: const TextStyle(color: whiteColor),
        ),
        backgroundColor: errorColor,
      ),
    );
  }
}

// class AuthWebView extends StatefulWidget {
//   final String url;
//
//   const AuthWebView({required this.url, Key? key}) : super(key: key);
//
//   @override
//   State<AuthWebView> createState() => _AuthWebViewState();
// }
//
// class _AuthWebViewState extends State<AuthWebView> {
//   late final WebViewController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(NavigationDelegate(
//         onNavigationRequest: (NavigationRequest request) {
//           print("req ${request.url}");
//           Uri uri = Uri.parse(request.url);
//           print("yrii ${uri}");
//           // if (request.url.startsWith('com.haiva.auth:/callback')) {
//           //   Uri uri = Uri.parse(request.url);
//           //   String? authCode = uri.queryParameters['code'];
//           //   if (authCode != null) {
//           //     Future.delayed(const Duration(milliseconds: 5000), () {
//           //       Navigator.pop(context, authCode);
//           //       return NavigationDecision.prevent;
//           //     });
//           //   }
//           // }
//           return NavigationDecision.navigate;
//         },
//       ))
//       ..loadRequest(Uri.parse(widget.url));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: WebViewWidget(
//       controller: _controller,
//     ));
//   }
// }
