import 'package:flutter/material.dart';
import 'package:fit2eat/features/scanner/data/models/scan_result.dart'; // Adjust import path as needed
import 'package:fit2eat/features/home/presentation/screens/home_screen.dart'; // Import HomeScreen

class ResultScreen extends StatelessWidget {
  static const String routeName = '/results'; // Add this line
  final ScanResult? scanResult; // Make scanResult nullable if route can be called without it initially

  const ResultScreen({super.key, this.scanResult});

  @override
  Widget build(BuildContext context) {
    // Handle case where scanResult might be null if navigated directly via route name without arguments
    // or if it's an initial route placeholder.
    if (scanResult == null) {
      // Attempt to get arguments if not passed directly (e.g. from named route)
      final args = ModalRoute.of(context)?.settings.arguments as ScanResult?;
      if (args == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: const Center(child: Text('No scan result found.')),
        );
      }
      // If args are found, use them. This is a common pattern for named routes.
      // Note: This specific assignment inside build is not ideal for state management
      // but works for displaying data passed via arguments for a StatelessWidget.
      // For more complex scenarios, consider state management solutions.
      return _buildResultView(context, args);
    }

    return _buildResultView(context, scanResult!);
  }

  Widget _buildResultView(BuildContext context, ScanResult currentScanResult) { // Extracted view logic
    final bool isApproved = currentScanResult.isFitToEat;
    final Color statusColor = isApproved ? Colors.green : Colors.red;
    final String statusText = isApproved ? "Approved" : "Not Approved";
    final IconData statusIcon = isApproved ? Icons.check_circle_outline : Icons.highlight_off;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Result'),
        backgroundColor: statusColor,
        leading: IconButton( // Add back button to navigate to HomeScreen
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Status Section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: statusColor, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(statusIcon, color: statusColor, size: 40.0),
                  const SizedBox(width: 16.0),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Harmful Ingredients Section
            if (currentScanResult.harmfulIngredients.isNotEmpty)
              Card(
                elevation: 2,
                child: ExpansionTile(
                  leading: Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
                  title: Text(
                    'Harmful Ingredients (${currentScanResult.harmfulIngredients.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: currentScanResult.harmfulIngredients.map((ingredient) {
                    return ListTile(
                      title: Text(ingredient.name),
                      subtitle: Text(ingredient.reason ?? 'No description available.'), // Assuming HarmfulIngredient has a description
                    );
                  }).toList(),
                ),
              ),
            if (currentScanResult.harmfulIngredients.isNotEmpty) const SizedBox(height: 16.0),

            // Warnings Section
            if (currentScanResult.warnings.isNotEmpty)
              Card(
                elevation: 2,
                child: ExpansionTile(
                  leading: Icon(Icons.info_outline_rounded, color: Colors.blue[700]),
                  title: Text(
                    'Warnings (${currentScanResult.warnings.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: currentScanResult.warnings.map((warning) {
                    return ListTile(
                      title: Text(warning),
                    );
                  }).toList(),
                ),
              ),
            if (currentScanResult.warnings.isEmpty && currentScanResult.harmfulIngredients.isEmpty && isApproved)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Column(
                    children: [
                      Icon(Icons.sentiment_very_satisfied, size: 60, color: Colors.green[700]),
                      const SizedBox(height: 8),
                      const Text(
                        'Looks good! No harmful ingredients or warnings found.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}