class DrugIngredient {
  final String name;
  final String strength;

  DrugIngredient({required this.name, required this.strength});

  @override
  String toString() => '$name $strength';
}

class DrugDetails {
  final String fullName;
  final List<DrugIngredient> ingredients;
  final String dosageForm;

  DrugDetails({
    required this.fullName,
    required this.ingredients,
    required this.dosageForm,
  });

  factory DrugDetails.fromString(String rxString) {
    // Parse input string like:
    // "1 (aspirin 325 MG / dextromethorphan hydrobromide 10 MG) Oral Tablet"

    // Extract dosage form (last part)
    final dosageFormRegex = RegExp(r'(?:Oral|Topical|Injectable)\s+[A-Za-z]+$');
    final dosageFormMatch = dosageFormRegex.firstMatch(rxString);
    final dosageForm = dosageFormMatch?.group(0) ?? 'Unknown Form';

    // Extract ingredients part (between parentheses)
    final ingredientsRegex = RegExp(r'\((.*?)\)');
    final ingredientsMatch = ingredientsRegex.firstMatch(rxString);
    final ingredientsStr = ingredientsMatch?.group(1) ?? '';

    // Split ingredients by '/'
    final ingredientsList = ingredientsStr.split('/').map((s) => s.trim());

    // Parse each ingredient
    final ingredients =
        ingredientsList.map((ingredient) {
          // Split into name and strength
          final parts = ingredient.split(RegExp(r'(\d+(?:\.\d+)?)\s*MG'));
          final name = parts[0].trim();
          final strength = parts.length > 1 ? '${parts[1].trim()} MG' : '';

          return DrugIngredient(name: name, strength: strength);
        }).toList();

    return DrugDetails(
      fullName: rxString,
      ingredients: ingredients,
      dosageForm: dosageForm,
    );
  }
}
