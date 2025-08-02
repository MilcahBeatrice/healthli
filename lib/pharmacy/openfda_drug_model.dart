class OpenFdaDrug {
  final String brandName;
  final String genericName;
  final String dosageForm;
  final List<ActiveIngredient> activeIngredients;
  final String route;
  final String labelerName;

  OpenFdaDrug({
    required this.brandName,
    required this.genericName,
    required this.dosageForm,
    required this.activeIngredients,
    required this.route,
    required this.labelerName,
  });

  factory OpenFdaDrug.fromJson(Map<String, dynamic> json) {
    final ingredients =
        (json['active_ingredients'] as List?)
            ?.map((e) => ActiveIngredient.fromJson(e))
            .toList() ??
        [];
    // route can be a String or a List
    String route = '';
    if (json['route'] is String) {
      route = json['route'];
    } else if (json['route'] is List && (json['route'] as List).isNotEmpty) {
      route = (json['route'] as List).join(', ');
    }
    return OpenFdaDrug(
      brandName: json['brand_name'] ?? '',
      genericName: json['generic_name'] ?? '',
      dosageForm: json['dosage_form'] ?? '',
      activeIngredients: ingredients,
      route: route,
      labelerName: json['labeler_name'] ?? '',
    );
  }
}

class ActiveIngredient {
  final String name;
  final String strength;

  ActiveIngredient({required this.name, required this.strength});

  factory ActiveIngredient.fromJson(Map<String, dynamic> json) {
    return ActiveIngredient(
      name: json['name'] ?? '',
      strength: json['strength'] ?? '',
    );
  }
}
