// lib/models/ingredient_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

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

  /// Constrói o modelo a partir de um DocumentSnapshot do Firestore,
  /// garantindo que cosingRef seja sempre o doc.id.
  factory IngredientModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    // INCI name com fallback
    final inci = (data['inciName'] as String?)?.isNotEmpty == true
        ? data['inciName'] as String
        : (data['INCI name'] as String?)?.isNotEmpty == true
            ? data['INCI name'] as String
            : (data['INN name'] as String?) ?? '';

    // descrição com fallback
    final desc = (data['description'] as String?)
        ?? (data['Chem/IUPAC Name / Description'] as String?)
        ?? '';

    // funções (Firestore vs. legado)
    final funcs = <String>[
      ...((data['functions'] as List<dynamic>?)?.cast<String>() ?? []),
      ...((data['Function'] as List<dynamic>?)?.cast<String>() ?? []),
    ];

    return IngredientModel(
      cosingRef: doc.id,
      inciName: inci,
      description: desc,
      functions: funcs,
    );
  }

  /// Constrói o modelo a partir de um JSON genérico,
  /// usado para dados legados ou mocks.
  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    final cosing = (json['cosingRef'] ?? json['COSING Ref No']).toString();

    final inci = (json['inciName'] as String?)?.isNotEmpty == true
        ? json['inciName'] as String
        : (json['INCI name'] as String?)?.isNotEmpty == true
            ? json['INCI name'] as String
            : (json['INN name'] as String?) ?? '';

    final desc = (json['description'] as String?)
        ?? (json['Chem/IUPAC Name / Description'] as String?)
        ?? '';

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

  Map<String, dynamic> toJson() => {
        'cosingRef': cosingRef,
        'inciName': inciName,
        'description': description,
        'functions': functions,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngredientModel && other.cosingRef == cosingRef;

  @override
  int get hashCode => cosingRef.hashCode;
}