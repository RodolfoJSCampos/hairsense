import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../viewmodels/viewmodels.dart';
// Ajuste o import abaixo para apontar à sua tela de detalhes/análise:
import '../views/analysis_result_view.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  void _showFunctionDefinition(
    BuildContext context,
    String function,
    String definition,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(function),
        content: Text(definition),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<ProductsViewModel>();
    // pega as 3 funções principais
    final top3 = vm.getFunctionsFor(product, maxFuncs: 3);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagem
          Expanded(
            child: Image.network(
              product.imageFrontUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) => Icon(
                Icons.broken_image,
                size: 48,
                color: Colors.grey.shade400,
              ),
            ),
          ),

          // Nome do produto
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Linha com os 3 chips + botão de exclamação
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                // chips das 3 funções principais
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: top3.map((func) {
                      return GestureDetector(
                        onTap: () {
                          final def = vm.getFunctionDefinition(func);
                          _showFunctionDefinition(context, func, def);
                        },
                        child: Chip(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity:
                              const VisualDensity(horizontal: -2, vertical: -2),
                          padding: EdgeInsets.zero,
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          backgroundColor: Colors.blue.shade50,
                          label: Text(
                            func,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // botão de exclamação que leva à tela de detalhes
                IconButton(
                  icon: Icon(Icons.error_outline, color: Colors.blueAccent),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AnalysisResultView(
                          product: product,
                          title: 'Detalhes do produto',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}