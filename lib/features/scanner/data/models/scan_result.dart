class HarmfulIngredient {
  final String name;
  final String reason;

  HarmfulIngredient({
    required this.name,
    required this.reason,
  });

  factory HarmfulIngredient.fromJson(Map<String, dynamic> json) {
    return HarmfulIngredient(
      name: json['name'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'reason': reason,
    };
  }
}

class ScanResult {
  final bool isFitToEat;
  final List<HarmfulIngredient> harmfulIngredients;
  final List<String> warnings;
  final String? originalQuery; // Optional: to store what was scanned
  final DateTime? timestamp; // Optional: for history

  ScanResult({
    required this.isFitToEat,
    this.harmfulIngredients = const [],
    this.warnings = const [],
    this.originalQuery,
    this.timestamp,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    var harmfulIngredientsList = json['harmfulIngredients'] as List?;
    List<HarmfulIngredient> harmfulIngredients = harmfulIngredientsList != null
        ? harmfulIngredientsList.map((i) => HarmfulIngredient.fromJson(i as Map<String, dynamic>)).toList()
        : [];

    var warningsList = json['warnings'] as List?;
    List<String> warnings = warningsList != null 
        ? warningsList.map((w) => w.toString()).toList() 
        : [];

    return ScanResult(
      isFitToEat: json['isFitToEat'] as bool? ?? false,
      harmfulIngredients: harmfulIngredients,
      warnings: warnings,
      originalQuery: json['originalQuery'] as String?,
      timestamp: json['timestamp'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isFitToEat': isFitToEat,
      'harmfulIngredients': harmfulIngredients.map((i) => i.toJson()).toList(),
      'warnings': warnings,
      'originalQuery': originalQuery,
      'timestamp': timestamp?.millisecondsSinceEpoch,
    };
  }
}