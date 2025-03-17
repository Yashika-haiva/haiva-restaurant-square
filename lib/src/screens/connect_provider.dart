import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../service/api_service.dart';
import '../service/storage_service.dart';
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
    // TODO: implement initState
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
      // Check the connection when the app comes back to foreground
      checkConnection();
    }
  }

  checkConnection() async {
    final response = await APIService().checkSquareConnection();
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final responseBody = decodedResponse;
      if (responseBody.isNotEmpty) {
        print("body $responseBody");
        if (responseBody[0]['name'] != null) {
          goToHome();
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

  @override
  Widget build(BuildContext context) {
    checkConnection();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 24),
              Center(
                child: Image.asset(
                  height: 150,
                  'assets/images/square-logo.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
              SizedBox(height: 24),
              const Text(
                textAlign: TextAlign.center,
                'Powering 4 million businesses globally. Ready for yours.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 24),
              Visibility(
                visible: !_isFieldsVisible,
                child: Column(
                  children: [
                    const Text(
                      'Connect directly with your account (Recommended)',
                      style: TextStyle(
                        fontSize: 14,
                        color: secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          getConnection();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Text(
                          'Connect to Square',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: _isFieldsVisible,
                child: Column(
                  children: [
                    const Text(
                      'Connect using your client ID and secret (Advanced)',
                      style: TextStyle(
                        fontSize: 14,
                        color: secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Client ID'),
                    TextField(
                      onChanged: (text) {
                        checkFieldsFilled();
                      },
                      controller: clintIdController,
                      decoration: InputDecoration(
                        hintStyle: const TextStyle(
                          color: hintTextColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: primaryColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: primaryColor,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Client Secret'),
                    TextField(
                      onChanged: (text) {
                        checkFieldsFilled();
                      },
                      controller: clintSecretController,
                      decoration: InputDecoration(
                        hintStyle: const TextStyle(
                          color: hintTextColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: primaryColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: primaryColor,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: areAllFieldsFilled
                          ? () {
                        getConnectionUsingClintCred();
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.link, color: whiteColor),
                          SizedBox(width: 8),
                          Text('Connect using Client Credentials'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isFieldsVisible = !_isFieldsVisible;
                    });
                  },
                  child: Text(
                    !_isFieldsVisible ? "Clint Credentials" : "Quick Connect",
                    style: textStyleS16W600.copyWith(
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  goToHome() {
    StorageService()
        .createAndUpdateKeyValuePairInStorage("connect_token", "connected");
    context.push('/${Routes.home.name}');
  }

  getConnection() async {
    final response = await APIService().getConnection();
    if (response.statusCode == 200) {
      print("Connection ${response.body}");
      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final responseBody = decodedResponse[0]['authAttributes'];
      String orgID = await StorageService().getValueFromStorage("org_id");
      String wsID = await StorageService().getValueFromStorage("workspace_id");
      String connectionID = "${DateTime
          .now()
          .millisecondsSinceEpoch}";

      ///time3,4
      String connectionId = "square_connection_$connectionID";
      await StorageService()
          .createAndUpdateKeyValuePairInStorage("recentConnName", connectionId);
      String template = await StorageService().getValueFromStorage("template");

      ///restaurantAgentApp_square_ws
      print("connection $connectionId");
      print("template $template");
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
      final String baseUrl = 'https://console.haiva.ai/oauth/callback';
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
      print("Connection ${response.body}");
      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final responseBody = decodedResponse[0]['authAttributes'];
      String orgID = await StorageService().getValueFromStorage("org_id");
      String wsID = await StorageService().getValueFromStorage("workspace_id");
      String connectionID = "${DateTime
          .now()
          .millisecondsSinceEpoch}";

      ///time3,4
      String connectionId = "square_connection_$connectionID";
      await StorageService()
          .createAndUpdateKeyValuePairInStorage("recentConnName", connectionId);
      String template = await StorageService().getValueFromStorage("template");

      ///restaurantAgentApp_square_ws
      print("connection $connectionId");
      print("template $template");
      String url =
          "https://services.haiva.ai/v1/apiconnectors/$orgID/$wsID/$template/authrequest?pkey=3fe0995209f5abcd3fe237286f32afa5"
          "&redirect_uri=https://console.haiva.ai/oauth/callback&status=false"
          "&${responseBody[0]['authAttributes'][0]['name']}=${responseBody[0]['authAttributes'][0]['value']}"
          "&${responseBody[0]['authAttributes'][1]['name']}=${responseBody[0]['authAttributes'][1]['value']}"
          "&${responseBody[0]['authAttributes'][2]['name']}=${responseBody[0]['authAttributes'][2]['value']}"
          "&${responseBody[0]['authAttributes'][3]['name']}=${clintIdController
          .value.text}"
          "&${responseBody[0]['authAttributes'][4]['name']}=${clintSecretController
          .value.text}"
          "&${responseBody[0]['authAttributes'][5]['name']}=${responseBody[0]['authAttributes'][5]['value']}"
          "&name=$connectionId&authType=OAuth 2.0";
      final String baseUrl = 'https://console.haiva.ai/oauth/callback';
      final String encodedRedirectUrl = Uri.encodeComponent(url);
      final String consoleUrl =
          '$baseUrl?org_id=$orgID&workspace_id=$wsID&connector_name=$connectionId&provider=$template&redirect_url=$encodedRedirectUrl';

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
          style: TextStyle(color: whiteColor),
        ),
        backgroundColor: errorColor,
      ),
    );
  }
}
