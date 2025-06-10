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

      // Get a callable reference to the cloud function
      final callable = _functions.httpsCallable('analyzeIngredients');

      // Call the function with the base64 image data
      final HttpsCallableResult result = await callable.call<Map<String, dynamic>>(
        {'image': base64Image, 'user': user.uid},
      );

      // The result.data is already a Map<String, dynamic>,
      // so we can directly pass it to our model's fromJson factory.
      if (result.data == null) {
        throw Exception('Cloud function returned null data');
      }
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