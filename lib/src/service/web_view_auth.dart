import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../service/storage_service.dart';
import '../shared/consts.dart';

// class AuthService {
//   final FlutterAppAuth _appAuth = FlutterAppAuth();
//   final String _clientId =
//       '3h3dhjghsivy3x3hegju3gijcj3ocr784grcHszP4KtyGnnZdARBXs';
//   final String _domain = 'https://haiva.authent.works';
//   final String _issuer = 'https://haiva.authent.works/auth';
//   final String _redirectUri = 'com.haiva.auth:/callback';
//   final String _authorizationEndpoint =
//       'https://haiva.authent.works/auth/authorize';
//   final String _tokenEndpoint = 'https://haiva.authent.works/auth/token';
//   final String logoutUrl = 'https://haiva.authent.works/auth/logout';
//
//   Future<bool> login(BuildContext context) async {
//     try {
//       await _clearTokens();
//
//       print('$_authorizationEndpoint?client_id=$_clientId&redirect_uri=$_redirectUri&response_type=code&scope=openid email profile');
//       // Use WebView for authentication
//       String? authCode = await _authenticateUsingWebView(context);
//       if (authCode == null) return false;
//
//       // Exchange the authorization code for tokens
//       final AuthorizationTokenResponse? result =
//           await _appAuth.authorizeAndExchangeCode(
//         AuthorizationTokenRequest(
//           _clientId,
//           _redirectUri,
//           issuer: _issuer,
//           scopes: ['openid', 'email', 'profile'],
//           promptValues: ['login'],
//           allowInsecureConnections: false,
//           // Ensure HTTPS is used
//           preferEphemeralSession: true,
//           // Avoids cookies interfering
//           serviceConfiguration: AuthorizationServiceConfiguration(
//             authorizationEndpoint: '$_issuer/authorize',
//             tokenEndpoint: '$_issuer/token',
//           ),
//         ),
//       );
//
//       if (result != null && result.accessToken != null) {
//         await StorageService().createAndUpdateKeyValuePairInStorage(
//             'access_token', result.accessToken);
//         Constants.accessToken = result.accessToken;
//         await StorageService()
//             .createAndUpdateKeyValuePairInStorage('id_token', result.idToken);
//         await StorageService().createAndUpdateKeyValuePairInStorage(
//             'refresh_token', result.refreshToken);
//         return true;
//       } else {
//         await _clearTokens();
//         return false;
//       }
//     } catch (e) {
//       print('Login failed: $e');
//       await _clearTokens();
//       return false;
//     }
//   }
//
//   Future<String?> _authenticateUsingWebView(BuildContext context) async {
//     return await Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => AuthWebView(
//             url:
//                 '$_authorizationEndpoint?client_id=$_clientId&redirect_uri=$_redirectUri&response_type=code&scope=openid email profile'),
//       ),
//     );
//   }
//
//   Future<void> _clearTokens() async {
//     await StorageService().deleteValueFromStorage('access_token');
//     await StorageService().deleteValueFromStorage('id_token');
//     await StorageService().deleteValueFromStorage('refresh_token');
//     Constants.accessToken = null;
//   }
//
//   Future<bool> logout() async {
//     try {
//       final accessToken =
//           await StorageService().getValueFromStorage('access_token');
//       if (accessToken != null) {
//         final Uri logoutUri = Uri.parse(logoutUrl);
//         if (await canLaunchUrl(logoutUri)) {
//           await launchUrl(logoutUri, mode: LaunchMode.inAppBrowserView);
//         }
//       }
//       await _clearTokens();
//       return true;
//     } catch (e) {
//       print('Error during logout: $e');
//       return false;
//     }
//   }
// }
//
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
//           if (request.url.startsWith('com.haiva.auth:/callback')) {
//             Uri uri = Uri.parse(request.url);
//             String? authCode = uri.queryParameters['code'];
//             if (authCode != null) {
//               Future.delayed(const Duration(milliseconds: 5000), () {
//                 Navigator.pop(context, authCode);
//                 return NavigationDecision.prevent;
//               });
//             }
//           }
//           return NavigationDecision.navigate;
//         },
//       ))
//       ..loadRequest(Uri.parse(widget.url));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//         body: Center(
//       child: CircularProgressIndicator(
//         color: primaryColor,
//       ),
//     ));
//   }
// }


import 'package:flutter_appauth/flutter_appauth.dart';
import '../service/storage_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';

import '../shared/consts.dart';

class AuthService {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final WebviewCookieManager _cookieManager = WebviewCookieManager();

  final String _clientId =
      '3h3dhjghsivy3x3hegju3gijcj3ocr784grcHszP4KtyGnnZdARBXs';
  final String _domain = 'https://haiva.authent.works';
  final String _issuer = 'https://haiva.authent.works/auth';
  final String _redirectUri = 'com.haiva.auth:/callback';
  final String logoutUrl = 'https://haiva.authent.works/auth/logout';

  Future<bool> login() async {
    try {
      await _clearTokens();

      final AuthorizationTokenResponse? result =
      await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _clientId,
          _redirectUri,
          issuer: _issuer,
          scopes: ['openid', 'email', 'profile'],
        ),
      );

      if (result != null && result.accessToken != null) {
        /// Store tokens securely
        await StorageService().createAndUpdateKeyValuePairInStorage(
            'access_token', result.accessToken);
        Constants.accessToken = result.accessToken;
        await StorageService()
            .createAndUpdateKeyValuePairInStorage('id_token', result.idToken);
        await StorageService().createAndUpdateKeyValuePairInStorage(
            'refresh_token', result.refreshToken);
        return true;
      } else {
        // Login was cancelled or failed
        await _clearTokens();
        return false;
      }
    } catch (e) {
      print('Login failed: $e');
      await _clearTokens();
      return false;
    }
  }

  Future<void> _clearTokens() async {
    await StorageService().deleteValueFromStorage('access_token');
    await StorageService().deleteValueFromStorage('id_token');
    await StorageService().deleteValueFromStorage('refresh_token');
    Constants.accessToken = null;
    Constants.workspaceId = null;
    Constants.orgId = null;
  }

  Future<bool> logout() async {
    try {
      final accessToken =
      await StorageService().getValueFromStorage('access_token');
      if (accessToken != null) {
        final Uri logoutUri = Uri.parse(logoutUrl);
        if (await canLaunchUrl(logoutUri)) {
          await launchUrl(logoutUri, mode: LaunchMode.inAppBrowserView);
        }
      }
      await _clearTokens();
      await _cookieManager.removeCookie(_domain);
      return true;
    } catch (e) {
      print('Error during logout: $e');
      return false;
    }
  }

  Future<bool> isAuthenticated() async {
    final accessToken =
    await StorageService().getValueFromStorage('access_token');
    Constants.accessToken = accessToken;
    return accessToken != null;
  }
}
