import 'package:flutter/material.dart';

import '../square.dart';
import 'splash_screen.dart';

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

bool _showSplash = true;

class _AppEntryState extends State<AppEntry> {
  @override
  void initState() {
    super.initState();
    _startSplashScreenTimer();
  }

  void _startSplashScreenTimer() {
    Future.delayed(const Duration(milliseconds: 5000), () {
      setState(() {
        _showSplash = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showSplash ? const SplashScreen() : const Square();
  }
}
