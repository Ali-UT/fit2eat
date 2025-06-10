import 'dart:convert'; // For base64Encode
import 'package:fit2eat/features/auth/data/services/auth_service.dart'; // Import AuthService
import 'package:fit2eat/features/history/data/services/firestore_service.dart'; // Import FirestoreService
import 'package:fit2eat/features/scanner/data/models/scan_result.dart'; // Import ScanResult
import 'package:fit2eat/features/scanner/data/services/analysis_service.dart'; // Import AnalysisService
import 'package:flutter/material.dart'; // For ChangeNotifier
import 'package:image_picker/image_picker.dart';

class ScannerViewModel extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  final AnalysisService _analysisService; // Add AnalysisService
  final FirestoreService _firestoreService; // Add FirestoreService
  final AuthService _authService; // Add AuthService

  XFile? _pickedImageXFile;
  String? _base64Image;
  bool _isLoading = false;
  String? _errorMessage;
  ScanResult? _scanResult; // To hold the latest scan result

  // Updated constructor
  ScannerViewModel({
    required AnalysisService analysisService,
    required FirestoreService firestoreService,
    required AuthService authService,
  })  : _analysisService = analysisService,
        _firestoreService = firestoreService,
        _authService = authService;

  XFile? get pickedImage => _pickedImageXFile;
  String? get base64Image => _base64Image;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ScanResult? get scanResult => _scanResult; // Getter for scan result

  // pickImage method remains largely the same, but we might not need to set _base64Image here
  // if pickImageAndAnalyze is the primary way to get a result.
  Future<void> pickImage(ImageSource source) async {
    _isLoading = true;
    _pickedImageXFile = null;
    // _base64Image = null; // Base64 conversion will happen in pickImageAndAnalyze
    _errorMessage = null;
    _scanResult = null;
    notifyListeners();

    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        _pickedImageXFile = image;
        // Optionally, still convert to base64 here if you need to display it or for other purposes
        // final bytes = await image.readAsBytes();
        // _base64Image = base64Encode(bytes);
      } else {
        _errorMessage = 'No image selected.';
      }
    } catch (e) {
      _errorMessage = 'Failed to pick image: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // New method to handle picking, analyzing, and saving
  Future<ScanResult?> pickImageAndAnalyze(ImageSource source) async {
    _isLoading = true;
    _pickedImageXFile = null;
    _base64Image = null;
    _errorMessage = null;
    _scanResult = null;
    notifyListeners();

    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) {
        _errorMessage = 'No image selected.';
        _isLoading = false;
        notifyListeners();
        return null;
      }
      _pickedImageXFile = image;

      final bytes = await image.readAsBytes();
      _base64Image = base64Encode(bytes);
      notifyListeners(); // Update UI to show picked image/base64 if needed

      // Call AnalysisService
      _scanResult = await _analysisService.analyzeIngredients(_base64Image!);

      // Save to Firestore if user is logged in and result is valid
      final currentUser = _authService.currentUser;
      if (currentUser != null && _scanResult != null) {
        await _firestoreService.saveScanResult(currentUser.uid, _scanResult!);
      }

      return _scanResult;
    } catch (e) {
      _errorMessage = 'Analysis failed: ${e.toString()}';
      return null; // Return null on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelection() {
    _pickedImageXFile = null;
    _base64Image = null;
    _errorMessage = null;
    _scanResult = null; // Also clear scan result
    notifyListeners();
  }
}