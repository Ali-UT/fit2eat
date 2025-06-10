import 'package:fit2eat/features/auth/data/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date formatting

import 'package:fit2eat/features/scanner/data/models/scan_result.dart';
import 'package:fit2eat/features/history/data/services/firestore_service.dart';
import 'package:fit2eat/features/scanner/presentation/screens/result_screen.dart'; // To navigate to ResultScreen

class HistoryScreen extends StatefulWidget {
  static const String routeName = '/history'; // Add this line
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<ScanResult>> _scanHistoryFuture;

  @override
  void initState() {
    super.initState();
    // It's important to get services via Provider in a way that doesn't cause
    // rebuilds in initState if not necessary, or use listen:false if appropriate.
    // Here, we assume FirestoreService and AuthService are already provided higher up the widget tree.
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;

    if (currentUser != null) {
      _scanHistoryFuture = firestoreService.getScanHistory(currentUser.uid);
    } else {
      // Handle the case where there is no logged-in user
      // You might want to show a message or prevent access to this screen
      _scanHistoryFuture = Future.value([]); // Return an empty list or handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
      ),
      body: FutureBuilder<List<ScanResult>>(
        future: _scanHistoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No scan history found.'));
          }

          final scanHistory = snapshot.data!;

          return ListView.builder(
            itemCount: scanHistory.length,
            itemBuilder: (context, index) {
              final scan = scanHistory[index];
              final bool isApproved = scan.isFitToEat;
              final Color statusColor = isApproved ? Colors.green : Colors.red;
              final String statusText = isApproved ? "Approved" : "Not Approved";
              // Assuming ScanResult has a timestamp or a way to derive a date
              // For now, let's use a placeholder for date if not available
              // You should add a 'scanDate' (DateTime) field to your ScanResult model
              // and save it when a scan is performed.
              final String displayDate = scan.timestamp != null 
                ? DateFormat('yyyy-MM-dd – kk:mm').format(scan.timestamp!) 
                : 'Date N/A';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  leading: Icon(
                    isApproved ? Icons.check_circle_outline : Icons.highlight_off,
                    color: statusColor,
                    size: 30,
                  ),
                  title: Text(displayDate),
                  subtitle: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => ResultScreen(scanResult: scan),
                    //   ),
                    // );
                    Navigator.pushNamed(context, ResultScreen.routeName, arguments: scan);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}