import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


Future<void> uploadIngredientsToFirestore({
  required void Function(int done, int total)? onProgress,
}) async {
  final raw = await rootBundle.loadString(
    'assets/data/cosing_dados_pt-br.json',
  );
  final data = json.decode(raw);
  final list =
      (data is List)
          ? data
          : (data is Map)
          ? data.values.toList()
          : <dynamic>[];

  final total = list.length;
  const batchSize = 500;
  final col = FirebaseFirestore.instance.collection('ingredients');
S
  for (var offset = 0; offset < total; offset += batchSize) {
    final end = min(offset + batchSize, total);
    final batch = FirebaseFirestore.instance.batch();

    for (var i = offset; i < end; i++) {
      final e = list[i] as Map<String, dynamic>;
      final docRef = col.doc();
      batch.set(docRef, {
        'cosingRef': e['COSING Ref No'] as String,
        'inciName':
            ((e['INCI name'] as String).isEmpty
                    ? e['INN name']
                    : e['INCI name'])
                as String,
        'description': e['Chem/IUPAC Name / Description'] as String,
        'functions': List<String>.from(e['Function'] ?? []),
      });
    }

    await batch.commit();
    onProgress?.call(end, total);
  }
}
