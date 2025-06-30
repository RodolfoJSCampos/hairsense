import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/models.dart';

class IngredientRepository {
  Future<List<IngredientModel>> loadAll() async {
    final raw = await rootBundle.loadString('assets/data/cosing_dados_pt-br.json');
    final list = json.decode(raw) as List<dynamic>;
    return list.map((e) => IngredientModel.fromJson(e)).toList();
  }
}