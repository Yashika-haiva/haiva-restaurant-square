import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:haivazoho/src/shared/consts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../shared/enum.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _loading = false;
  String _paymentStatus = '';
 String sKey = "sk_test_51R4FnBANZM907lrWGhvuLgiaT6ZpkV3Mot7n4nXIlEFGkLTfYWLgHF0uoj5AOQwO67DcvObRXO5Ug6FJhFe3YdAf00vBN6HFBh";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _handleCardPayment,
                child:
                    const Text('Pay with Card', style: TextStyle(fontSize: 16)),
              ),
            const SizedBox(height: 20),
            Text(
              _paymentStatus,
              style: TextStyle(
                fontSize: 16,
                color: _paymentStatus.contains('Error')
                    ? Colors.red
                    : (_paymentStatus.contains('completed')
                        ? Colors.green
                        : Colors.black),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCardPayment() async {
    try {
      setState(() {
        _loading = true;
        _paymentStatus = '';
      });

      /// Step 1: Create payment intent on the server
      final paymentIntentResult = await _createPaymentIntent();
      final clientSecret = paymentIntentResult['client_secret'];

      /// Step 2: Confirm the payment with the card details
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Haiva',
          style: ThemeMode.light,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: primaryColor,
            ),
            shapes: PaymentSheetShape(
              borderRadius: 12.0,
              borderWidth: 1.0,
            ),
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      setState(() {
        _paymentStatus = 'Payment completed successfully!';
      });

      context.go("/${Routes.paymentSuccess.name}");
    } catch (e) {
      setState(() {
        _paymentStatus = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _createPaymentIntent() async {
    /// This should be a call to your backend where you create a PaymentIntent

    /// API call to backend
    final response = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_intents'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        "Authorization":
            "Bearer $sKey"
      },
      body: {
        'amount': "1099", // $10.99 in cents
        'currency': 'usd',
        'payment_method_types[]': 'card',
      },
    );

    print("ResponStrp ${response.body}");
    ///need to return clint_secret in response_body
    return jsonDecode(response.body);
  }
}
