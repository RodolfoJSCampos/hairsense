import 'package:flutter/foundation.dart';

class Product {
  final String code;
  final String name;
  final String imageFrontUrl;
  final String ingredientsText;

  Product({
    required this.code,
    required this.name,
    required this.imageFrontUrl,
    required this.ingredientsText,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    debugPrint('⤷ Raw JSON product: $json');

    final rawUrl = json['image_front_url'] as String? ?? '';
    final imageUrl = rawUrl.isNotEmpty
        ? rawUrl
        : 'https://static.openbeautyfacts.org/images/products/'
          '${json['code']}/front.2.full.jpg';

    return Product(
      code: json['code'] as String,
      name: json['name'] as String,
      imageFrontUrl: imageUrl,
      ingredientsText: json['ingredients_text'] as String? ?? '',
    );
  }

  /// Converte a string do JSON em lista de ingredientes
  List<String> get ingredients {
    if (ingredientsText.trim().isEmpty) return [];
    return ingredientsText
        .split(RegExp(r',|;|\r?\n'))     // separa por vírgula, ponto‐e‐vírgula ou quebra de linha
        .map((item) => item.trim())      // remove espaços
        .where((item) => item.isNotEmpty)
        .toList();
  }
}