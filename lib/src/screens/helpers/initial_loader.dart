import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../service/storage_service.dart';
import '../../shared/consts.dart';
import '../../shared/enum.dart';

class InitialLoader extends StatefulWidget {
  const InitialLoader({super.key});

  @override
  State<InitialLoader> createState() => _InitialLoaderState();
}

class _InitialLoaderState extends State<InitialLoader> {
  @override
  void initState() {
    super.initState();
    goToInitialPage();
  }

  Future<String> isFirstLogin() async {
    String isLogin =
        await StorageService().getValueFromStorage('isFirstLogin') ?? "false";
    return isLogin == "false"
        ? '/${Routes.requestPermissions.name}'
        : '/${Routes.login.name}';
  }

  void goToInitialPage() async {
    final initialRoute = await isFirstLogin();
    Future.delayed(const Duration(seconds: 2), () {
      context.go(initialRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LoadingAnimationWidget.fourRotatingDots(
            color: primaryColor, size: 100),
      ),
    );
  }
}
