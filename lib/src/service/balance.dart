// import 'package:flutter/material.dart';
//
// import 'mongoDb.dart';
//
// class CreditsBalanceWidget extends StatefulWidget {
//   final String? orgId;
//
//   const CreditsBalanceWidget({Key? key, this.orgId}) : super(key: key);
//
//   @override
//   _CreditsBalanceWidgetState createState() => _CreditsBalanceWidgetState();
// }
//
// class _CreditsBalanceWidgetState extends State<CreditsBalanceWidget> {
//   late CreditsBalanceService _balanceService;
//   bool _isLoading = true;
//   String? _errorMessage;
//
//   @override
//   void initState() {
//     super.initState();
//     _balanceService = CreditsBalanceService();
//     _initBalanceService();
//   }
//
//   Future<void> _initBalanceService() async {
//     try {
//       await _balanceService.login();
//       await _balanceService.watchCreditsBalance(widget.orgId);
//
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     } catch (error) {
//       if (mounted) {
//         setState(() {
//           _errorMessage = error.toString();
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _balanceService.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Center(child: CircularProgressIndicator());
//     }
//
//     if (_errorMessage != null) {
//       return Center(
//         child: Text('Error: $_errorMessage', style: TextStyle(color: Colors.red)),
//       );
//     }
//
//     return StreamBuilder<double?>(
//       stream: _balanceService.creditsBalance,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
//           return Center(child: CircularProgressIndicator());
//         }
//
//         final balance = snapshot.data ?? 0.0;
//
//         return Card(
//           child: Padding(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text('Credits Balance', style: TextStyle(fontSize: 16)),
//                 SizedBox(height: 8),
//                 Text(
//                   '${balance.toStringAsFixed(2)}',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: balance > 0 ? Colors.green : Colors.red,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }