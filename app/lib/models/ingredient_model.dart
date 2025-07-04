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

  /// Constrói o modelo a partir de um JSON vindo do Firestore ou da base local.
  /// Espera as chaves:
  /// - 'cosingRef' (String)
  /// - 'inciName' (String)
  /// - 'description' (String)
  /// - 'functions' (List<String>)
  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    // Pega o ID do COSING (doc.id) ou o campo legacy 'COSING Ref No'
    final cosing = (json['cosingRef'] ?? json['COSING Ref No']).toString();

    // Nome INCI ou fallback para INN
    final inci = (json['inciName'] as String?)?.isNotEmpty == true
        ? json['inciName'] as String
        : (json['INCI name'] as String?)?.isNotEmpty == true
            ? json['INCI name'] as String
            : (json['INN name'] as String?) ?? '';

    // Descrição ou nome químico legado
    final desc = (json['description'] as String?)
        ?? (json['Chem/IUPAC Name / Description'] as String?)
        ?? '';

    // Lista de funções (Firestore usa 'functions', base legacy usava 'Function')
    final funcs = <String>[
      ...((json['functions'] as List<dynamic>?)?.cast<String>() ?? []),
      ...((json['Function'] as List<dynamic>?)?.cast<String>() ?? []),
    ];

    return IngredientModel(
      cosingRef: cosing,
      inciName: inci,
      description: desc,
      functions: funcs,
    );
  }

  /// Converte para JSON adequado ao Firestore
  Map<String, dynamic> toJson() {
    return {
      'cosingRef': cosingRef,
      'inciName': inciName,
      'description': description,
      'functions': functions,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngredientModel && other.cosingRef == cosingRef;

  @override
  int get hashCode => cosingRef.hashCode;
}