class IngredientModel {
  final String cosingRef;
  final String inciName;
  final String description;
  final List<String> functions;

  IngredientModel({
    required this.cosingRef,
    required this.inciName,
    required this.description,
    required this.functions,
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      cosingRef: json['COSING Ref No'] as String,
      inciName: (json['INCI name'] as String).isEmpty
          ? json['INN name'] as String
          : json['INCI name'] as String,
      description: json['Chem/IUPAC Name / Description'] as String,
      functions: List<String>.from(json['Function'] ?? []),
    );
  }
}