import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../shared/consts.dart';

class VoiceViewScreen extends StatefulWidget {
  final String agentId;

  const VoiceViewScreen({super.key, required this.agentId});

  @override
  State<VoiceViewScreen> createState() => _VoiceViewScreenState();
}

class _VoiceViewScreenState extends State<VoiceViewScreen> {
  late InAppWebViewController _webViewController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    print(widget.agentId);
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.microphone.request();

    if (status.isGranted) {
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required for voice chat')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: const Text(
          'Voice Chat',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: Uri.parse('https://agent.haiva.ai/#/voice/${widget.agentId}'),
            ),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                javaScriptEnabled: true,
                useOnLoadResource: true,
                mediaPlaybackRequiresUserGesture: false,
                clearCache: true,
              ),
              android: AndroidInAppWebViewOptions(
                useHybridComposition: true,
                mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
              ),
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() {
                isLoading = true;
              });
            },
            onLoadStop: (controller, url) async {
              setState(() {
                isLoading = false;
              });
            },
            onLoadError: (controller, url, code, message) {
              setState(() {
                isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to load page: $message')),
              );
            },
            androidOnPermissionRequest: (controller, origin, resources) async {
              return PermissionRequestResponse(
                resources: resources,
                action: PermissionRequestResponseAction.GRANT,
              );
            },
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: primaryColor),
            ),
        ],
      ),
    );
  }
}
