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
      cosingRef: json['cosingRef'] ?? '',
      inciName: json['inciName'] ?? '',
      description: json['description'] ?? '',
      functions: List<String>.from(json['functions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cosingRef': cosingRef,
      'inciName': inciName,
      'description': description,
      'functions': functions,
    };
  }
}