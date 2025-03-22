import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../shared/consts.dart';

class ChatViewScreen extends StatefulWidget {
  final String agentId;

  const ChatViewScreen({super.key, required this.agentId});

  @override
  State<ChatViewScreen> createState() => _ChatViewScreenState();
}

class _ChatViewScreenState extends State<ChatViewScreen> {
  late final WebViewController _controller;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
            print('Page loading started: $url');
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
            print('Page finished loading: $url');
          },
          onWebResourceError: (error) {
            print('Error loading page: $error');
          },
        ),
      )
      ..loadRequest(
        Uri.parse('https://agent.haiva.ai/#/chat/${widget.agentId}'),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: primaryColor,
          title: const Text('Text Chat',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
        ),
        body: isLoading
            ? const Center(
              child: CircularProgressIndicator(
                  color: primaryColor,
                ),
            )
            : WebViewWidget(
                controller: _controller,
              ));
  }
}
