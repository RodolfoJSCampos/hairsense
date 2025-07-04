import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Salva o progresso localmente
Future<void> _saveUploadProgress(int lastIndex) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('upload_offset', lastIndex);
}

// Recupera o último ponto do upload
Future<int> _getUploadProgress() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('upload_offset') ?? 0;
}

// Apaga progresso (se quiser recomeçar do zero)
Future<void> resetUploadProgress() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('upload_offset');
  print('🧹 Progresso de upload zerado');
}

// Upload em partes com progresso persistente
Future<void> uploadIngredientsToFirestore({
  required void Function(int done, int total)? onProgress,
  int batchSize = 100, // ajustável
  bool resetBeforeUpload = false, // novo parâmetro
}) async {
  // Zera progresso antes de começar (se solicitado)
  if (resetBeforeUpload) {
    await resetUploadProgress();
  }

  final raw = await rootBundle.loadString(
    'assets/data/cosing_dados_pt-br.json',
  );
  final data = json.decode(raw);
  final list = (data is List)
      ? data
      : (data is Map)
          ? data.values.toList()
          : <dynamic>[];

  final total = list.length;
  final col = FirebaseFirestore.instance.collection('ingredients');
  final startOffset = await _getUploadProgress();

  for (var offset = startOffset; offset < total; offset += batchSize) {
    final end = min(offset + batchSize, total);
    final batch = FirebaseFirestore.instance.batch();

    for (var i = offset; i < end; i++) {
      final e = list[i] as Map<String, dynamic>;
      final docRef = col.doc();
      batch.set(docRef, {
        'cosingRef': e['COSING Ref No'] as String,
        'inciName': ((e['INCI name'] as String).isEmpty
            ? e['INN name']
            : e['INCI name']) as String,
        'description': e['Chem/IUPAC Name / Description'] as String,
        'functions': List<String>.from(e['Function'] ?? []),
      });
    }

    await batch.commit();
    await _saveUploadProgress(end); // salva progresso após cada batch
    onProgress?.call(end, total);
  }
}