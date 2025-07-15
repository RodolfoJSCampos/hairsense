

import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/function_model.dart';

class FunctionsService {
  static List<FunctionModel>? _cache;
  static const int _maxDistance = 2;

  /// Normaliza removendo espaços, hífens e underscores, tudo em lowercase
  static String _normalize(String s) =>
      s.toLowerCase().trim().replaceAll(RegExp(r'[\s\-_]'), '');

  /// Carrega e decodifica o JSON apenas uma vez
  static Future<List<FunctionModel>> _loadAll() async {
    if (_cache != null) return _cache!;
    final raw =
        await rootBundle.loadString('assets/data/funcoes_cosmeticos.json');
    final jsonList = json.decode(raw) as List<dynamic>;
    _cache = jsonList
        .map((e) => FunctionModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  /// Distância de Levenshtein para fuzzy match
  static int _levenshtein(String a, String b) {
    final la = a.length, lb = b.length;
    final dp = List.generate(la + 1, (_) => List<int>.filled(lb + 1, 0));
    for (var i = 0; i <= la; i++) dp[i][0] = i;
    for (var j = 0; j <= lb; j++) dp[0][j] = j;
    for (var i = 1; i <= la; i++) {
      for (var j = 1; j <= lb; j++) {
        final cost = (a[i - 1] == b[j - 1]) ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1,
          dp[i][j - 1] + 1,
          dp[i - 1][j - 1] + cost,
        ].reduce((v, e) => v < e ? v : e);
      }
    }
    return dp[la][lb];
  }

  /// Busca exata ou fuzzy para um nome simples. Retorna null se não achar.
  static FunctionModel? _matchSingle(
      List<FunctionModel> all, String rawName) {
    final key = _normalize(rawName);

    // 1) exato
    for (final f in all) {
      if (_normalize(f.english) == key ||
          _normalize(f.portuguese) == key) {
        return f;
      }
    }

    // 2) fuzzy
    FunctionModel? best;
    var bestDist = _maxDistance + 1;
    for (final f in all) {
      final de = _levenshtein(key, _normalize(f.english));
      if (de <= _maxDistance && de < bestDist) {
        bestDist = de;
        best = f;
      }
      final dp = _levenshtein(key, _normalize(f.portuguese));
      if (dp <= _maxDistance && dp < bestDist) {
        bestDist = dp;
        best = f;
      }
    }
    return best;
  }

  /// Para strings compostos (ex: "skinconditioning-emollient"), quebra apenas
  /// em hífen/underscore (ignorando espaços) e busca cada parte isoladamente.
  static Future<List<FunctionModel>> findAllByName(String name) async {
    final all = await _loadAll();

    // split só em hífen ou underscore, sem quebrar por espaços
    final parts = name
        .split(RegExp(r'\s*[-_]\s*'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toSet();

    final results = <FunctionModel>[];
    for (final part in parts) {
      final match = _matchSingle(all, part);
      if (match != null && !results.contains(match)) {
        results.add(match);
      }
    }

    // fallback: busca como string inteira se nada encontrado
    if (results.isEmpty) {
      final full = _matchSingle(all, name);
      if (full != null) results.add(full);
    }

    return results;
  }
}