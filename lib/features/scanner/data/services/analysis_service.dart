import 'package:cloud_functions/cloud_functions.dart';
import '../models/scan_result.dart'; // Your data model
import 'package:firebase_auth/firebase_auth.dart';

class AnalysisService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<ScanResult> analyzeIngredients(String base64Image) async {
    try {
      // Ensure we have a valid auth token
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to use this feature');
      }

      // 1. Log the incoming string to check if it's empty or null.
    print('--- Preparing to call function ---');
    if (base64Image.isEmpty) {
      print('ERROR: The base64Image string is EMPTY.');
      throw Exception('Image string is empty, cannot call function.');
    }
    // This will print a small part of the string to confirm it has content.
    print('Image string received, length: ${base64Image.length}');
    print('Image string starts with: ${base64Image.substring(0, 30)}...');

      // Get a callable reference to the cloud function
      final callable = _functions.httpsCallable('analyzeIngredients');

      // Call the function with the base64 image data
      final HttpsCallableResult result = await callable.call<Map<String, dynamic>>(
        {'image': base64Image},
      );

      // The result.data is already a Map<String, dynamic>,
      // so we can directly pass it to our model's fromJson factory.
      if (result.data == null) {
        throw Exception('Cloud function returned null data');
      }
      print('--- Received data from function ---');
      print(result);
      return ScanResult.fromJson(result.data as Map<String, dynamic>);

    } on FirebaseFunctionsException catch (e) {
      // Handle specific Firebase Functions errors
      print('Firebase Functions Error: ${e.code} - ${e.message}');
      // You might want to throw a more user-friendly error or a specific exception type
      throw Exception('Failed to get analysis from server: ${e.message}');
    } catch (e) {
      // Handle general errors
      print('An unexpected error occurred: $e');
      throw Exception('An unexpected error occurred while analyzing ingredients.');
    }
  }
}