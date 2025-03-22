import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../shared/consts.dart';
import '../shared/enum.dart';

class PaymentSuccessPage extends StatefulWidget {
  const PaymentSuccessPage({super.key});

  @override
  State<PaymentSuccessPage> createState() => PaymentSuccessPageState();
}

class PaymentSuccessPageState extends State<PaymentSuccessPage> {
  @override
  void initState() {
    super.initState();
    navigateToNextScreen();
  }

  void navigateToNextScreen() {
    Future.delayed(const Duration(milliseconds: 1500),
        () => context.go('/${Routes.home.name}'));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Credits added successfully",
                  style: textStyleS23W400.copyWith(color: blackColor)),
              SizedBox(
                height: 200,
                width: 200,
                child: Image.asset(
                  "assets/gif/payment_success.gif",
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
