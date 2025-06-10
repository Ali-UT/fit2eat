import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit2eat/features/scanner/data/models/scan_result.dart'; // Adjust path if necessary

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Saves a ScanResult to a user's specific collection in Firestore.
  Future<void> saveScanResult(String userId, ScanResult scanResult) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty.');
    }
    try {
      // Ensure timestamp is set before saving, if not already
      final ScanResult resultToSave = ScanResult(
        isFitToEat: scanResult.isFitToEat,
        harmfulIngredients: scanResult.harmfulIngredients,
        warnings: scanResult.warnings,
        originalQuery: scanResult.originalQuery,
        timestamp: scanResult.timestamp ?? DateTime.now(), // Set current time if null
      );

      await _db
          .collection('users')
          .doc(userId)
          .collection('scanHistory')
          .add(resultToSave.toJson());
    } catch (e) {
      // Log error or handle it as per your app's error handling strategy
      print('Error saving scan result to Firestore: $e');
      throw Exception('Failed to save scan result.');
    }
  }

  // Fetches all past scan results for a given user, ordered by timestamp.
  Future<List<ScanResult>> getScanHistory(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty.');
    }
    try {
      final QuerySnapshot snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('scanHistory')
          .orderBy('timestamp', descending: true) // Order by most recent
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          return ScanResult.fromJson(data);
        }
        // This case should ideally not happen if data is always present
        // Or handle it by logging an error and skipping the item
        throw Exception('Found a document with null data in scanHistory for user $userId');
      }).toList();
    } catch (e) {
      // Log error or handle it
      print('Error fetching scan history from Firestore: $e');
      throw Exception('Failed to fetch scan history.');
    }
  }

  // Optional: Method to delete a specific scan result
  Future<void> deleteScanResult(String userId, String scanId) async {
    if (userId.isEmpty || scanId.isEmpty) {
      throw ArgumentError('User ID and Scan ID cannot be empty.');
    }
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('scanHistory')
          .doc(scanId)
          .delete();
    } catch (e) {
      print('Error deleting scan result from Firestore: $e');
      throw Exception('Failed to delete scan result.');
    }
  }
}