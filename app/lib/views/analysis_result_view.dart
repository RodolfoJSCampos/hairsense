// lib/views/analysis_result_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../viewmodels/viewmodels.dart';
import '../widgets/widgets.dart';
import '../views/views.dart';

class AnalysisResultView extends StatelessWidget {
  final Product? product;
  final String title;

  const AnalysisResultView({
    Key? key,
    this.product,
    this.title = 'Resultado da Análise',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ingVM = context.watch<IngredientsViewModel>();
    final prodVM = context.watch<ProductsViewModel>();
    final primary = Theme.of(context).colorScheme.primary;

    final result = product != null
        ? prodVM.analysisResult(product!)
        : ingVM.analyze();

    // Reduzimos topOffset de 280 para 240
    const double topOffset = 240;

    // Reduzimos bottomPadding de 96 para 80
    const double bottomPadding = 80;

    return Scaffold(
      appBar: AppBarConfig(
        title: product != null ? 'Detalhes do Produto' : title,
        showBackButton: true,
      ),
      body: Stack(
        children: [
          // fundo gradient
          Positioned(
            top: topOffset,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey.shade200, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border.all(color: Colors.grey.shade500),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título e funções ficam fixos até topOffset
                SizedBox(height: topOffset),
                Text(
                  product?.name ?? 'Minha Análise Personalizada',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'Principais Funções',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (result.topFunctions.isEmpty)
                  const Text(
                    'Nenhuma função relevante encontrada.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  )
                else
                  ...result.topFunctions.asMap().entries.map((e) {
                    final i = e.key;
                    final func = e.value;
                    final widthFactor =
                        (result.topFunctions.length - i) /
                            result.topFunctions.length;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: GestureDetector(
                        onTap: () {
                          final def = ingVM.getFunctionDefinition(func);
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(func),
                              content: Text(def),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(),
                                  child: const Text('Fechar'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(func),
                            const SizedBox(height: 4),
                            LayoutBuilder(
                              builder: (_, cons) => Container(
                                width: cons.maxWidth * widthFactor,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: primary.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 2,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 24),

                // Header de ingredientes
                Text(
                  product != null
                      ? 'Ingredientes do Produto'
                      : 'Princípios Ativos',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Só esta parte é rolável
                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: result.topIngredients.isEmpty
                          ? [
                              const Text(
                                'Nenhum ingrediente ativo encontrado.',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              )
                            ]
                          : result.topIngredients.map((ing) {
                              return ActionChip(
                                label: Text(ing.inciName),
                                backgroundColor: primary.withOpacity(0.15),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          IngredientDetailView(ingredient: ing),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.list),
          label: const Text('Lista de Ingredientes'),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SelectedIngredientsView(product: product),
              ),
            );
          },
        ),
      ),
    );
  }
}