import 'dart:convert';
import 'dart:io'; // Keep for Image.file on non-web
import 'dart:typed_data'; // Import for Uint8List
import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // XFile is here
import 'package:provider/provider.dart';
import 'package:fit2eat/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:fit2eat/features/scanner/presentation/viewmodels/scanner_viewmodel.dart';
import 'package:fit2eat/features/history/presentation/screens/history_screen.dart'; // Import HistoryScreen
import 'package:fit2eat/features/scanner/presentation/screens/result_screen.dart'; // Import ResultScreen
import 'package:fit2eat/features/scanner/data/models/scan_result.dart'; // Import ScanResult

class HomeScreen extends StatelessWidget {
  static const String routeName = '/home'; // Add this line
  const HomeScreen({super.key});

  Future<void> _showImageSourceDialog(BuildContext context, ScannerViewModel scannerViewModel) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text('Camera'),
                  onTap: () async { // Make onTap async
                    Navigator.of(dialogContext).pop(); // Pop dialog first
                    final scanResult = await scannerViewModel.pickImageAndAnalyze(ImageSource.camera);
                    if (scanResult != null && context.mounted) {
                       Navigator.pushNamed(context, ResultScreen.routeName, arguments: scanResult);
                    }
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text('Gallery'),
                  onTap: () async { // Make onTap async
                    Navigator.of(dialogContext).pop(); // Pop dialog first
                    final scanResult = await scannerViewModel.pickImageAndAnalyze(ImageSource.gallery);
                    if (scanResult != null && context.mounted) {
                      Navigator.pushNamed(context, ResultScreen.routeName, arguments: scanResult);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final scannerViewModel = Provider.of<ScannerViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fit2Eat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, HistoryScreen.routeName); // Navigate to HistoryScreen
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authViewModel.signOut();
              // Navigation is handled by the Wrapper
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (!scannerViewModel.isLoading && scannerViewModel.pickedImage == null)
              const Text('Welcome! Scan your ingredients to get started.'),
            const SizedBox(height: 20),
            if (scannerViewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  scannerViewModel.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            if (scannerViewModel.isLoading)
              const CircularProgressIndicator(),
            if (scannerViewModel.pickedImage != null) // This now refers to XFile?
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: kIsWeb
                      ? FutureBuilder<Uint8List>(
                          future: scannerViewModel.pickedImage!.readAsBytes(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                              return Image.memory(snapshot.data!);
                            } else if (snapshot.error != null) {
                              return Text('Error loading image for web: ${snapshot.error}');
                            }
                            return const CircularProgressIndicator();
                          },
                        )
                      : Image.file(File(scannerViewModel.pickedImage!.path)),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showImageSourceDialog(context, scannerViewModel),
        tooltip: 'Scan Ingredients',
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}