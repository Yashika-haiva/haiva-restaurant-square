import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'src/screens/app_entry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey =
      'pk_test_51R4FnBANZM907lrWaqeDL1d6qfCLzdDczqtLoYo9W4k9WHo0Iz5vAVYN9ujenO4W7aeAK7Qupu3K2ZZI3qdbbMLM00GYxBi5qp';
  await Stripe.instance.applySettings();

  runApp(const AppEntry());
}
