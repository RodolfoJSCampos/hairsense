
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/function_model.dart';

class FunctionsService {
  static List<FunctionModel>? _cache;

  /// Número máximo de edições (distância) para considerar “parecido”
  static const int _maxDistance = 2;

  /// Normaliza removendo espaços, hífens e underscores, tudo em lower case
  static String _normalize(String s) {
    return s
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[\s\-_]'), '');
  }

  /// Carrega e decodifica apenas uma vez
  static Future<List<FunctionModel>> _loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/funcoes_cosmeticos.json');
    final list = json.decode(raw) as List<dynamic>;
    _cache = list
        .map((e) => FunctionModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  /// Calcula a distância de Levenshtein entre duas strings
  static int _levenshtein(String a, String b) {
    final la = a.length;
    final lb = b.length;
    // matriz (la+1) x (lb+1)
    final dp = List.generate(la + 1, (_) => List<int>.filled(lb + 1, 0));

    for (var i = 0; i <= la; i++) dp[i][0] = i;
    for (var j = 0; j <= lb; j++) dp[0][j] = j;

    for (var i = 1; i <= la; i++) {
      for (var j = 1; j <= lb; j++) {
        final cost = (a[i - 1] == b[j - 1]) ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1, // deleção
          dp[i][j - 1] + 1, // inserção
          dp[i - 1][j - 1] + cost, // substituição
        ].reduce((v, e) => v < e ? v : e);
      }
    }
    return dp[la][lb];
  }

  /// Retorna a melhor função cujo nome (inglês ou pt) case com [name],
  /// considerando:
  ///  • igualdade exata após normalização, ou
  ///  • distância de Levenshtein <= _maxDistance
  static Future<FunctionModel?> findByName(String name) async {
    final all = await _loadAll();
    final keyNorm = _normalize(name);

    FunctionModel? bestMatch;
    int bestDist = _maxDistance + 1;

    for (final f in all) {
      final engNorm = _normalize(f.english);
      final ptNorm = _normalize(f.portuguese);

      // 1) se exato, retorna imediatamente
      if (keyNorm == engNorm || keyNorm == ptNorm) {
        return f;
      }

      // 2) calcula distâncias
      final distEng = _levenshtein(keyNorm, engNorm);
      final distPt = _levenshtein(keyNorm, ptNorm);

      // 3) verifica se entra no threshold e melhora melhor candidato
      if (distEng <= _maxDistance && distEng < bestDist) {
        bestDist = distEng;
        bestMatch = f;
      }
      if (distPt <= _maxDistance && distPt < bestDist) {
        bestDist = distPt;
        bestMatch = f;
      }
    }

    // retorna melhor correspondente ou null
    return bestMatch;
  }
}