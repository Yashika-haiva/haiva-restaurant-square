import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:haivazoho/src/service/storage_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

import '../../service/agent_data_provider.dart';

class BalanceWidget extends StatefulWidget {
  const BalanceWidget({super.key});

  @override
  State<BalanceWidget> createState() => _BalanceWidgetState();
}

class _BalanceWidgetState extends State<BalanceWidget>
    with WidgetsBindingObserver {
  // String formattedBalance = "0.00";
  Timer? _timer;
  int _pollInterval = 30; // Start with 30 seconds
  final int _maxInterval = 60; // Max interval 60 seconds

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _timer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      _startPolling();
    }
  }

  void _startPolling() {
    fetchBalance(); // Fetch immediately on start
    _timer =
        Timer.periodic(Duration(seconds: _pollInterval), (_) => fetchBalance());
  }

  Future<void> fetchBalance() async {
    const apiUrl =
        'https://data.mongodb-api.com/app/application-1-vwtigax/endpoint/data/v1/action/find';
    const apiKey =
        'FFLKYFiNCgtBrUgvE7d5ShGn189QivUsM10hijV47RmekRa0v3ZEYwqSdBJzBjgr';

    final headers = {
      'Content-Type': 'application/json',
      'api-key': apiKey,
    };

    String orgId = await StorageService().getValueFromStorage("org_id");
    final body = jsonEncode({
      "dataSource": "mongodb-atlas",
      "database": "apphaivaapiplatform",
      "collection": "org_coll",
      "filter": {
        "orgId": orgId,
      }
    });

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          final gotBalance = data['documents'][0]['creditsBalance'] ?? 00.00;
          String newBalance = gotBalance.toStringAsFixed(2);
          Provider.of<AgentDataProvider>(context, listen: false)
              .updateBalance(newBalance);
          _pollInterval = 30;
        });
      }
    } else {
      _handlePollingFailure();
      if (kDebugMode) {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    }
  }

  void _handlePollingFailure() {
    // Increase interval with exponential backoff
    _pollInterval = (_pollInterval * 2).clamp(30, _maxInterval);

    _timer?.cancel(); // Cancel existing timer
    _timer =
        Timer.periodic(Duration(seconds: _pollInterval), (_) => fetchBalance());

    if (kDebugMode) {
      print("Polling failed. Retrying every $_pollInterval seconds.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AgentDataProvider>(
      builder: (context, balanceProvider, child) {
        return Text(
          "\$${balanceProvider.formattedBalance}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}
