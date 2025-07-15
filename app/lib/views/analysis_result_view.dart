// lib/views/analysis_result_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/ingredients_view_model.dart';
import 'selected_ingredients_view.dart';
import '../widgets/app_bar_config.dart';
import 'ingredient_detail_view.dart';

class AnalysisResultView extends StatelessWidget {
  const AnalysisResultView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm      = context.watch<IngredientsViewModel>();
    final result  = vm.analyze();
    final primary = Theme.of(context).colorScheme.primary;

    // Aqui definimos onde o gradiente e a borda começam
    const double topGradientOffset = 280;

    return Scaffold(
      appBar: const AppBarConfig(
        title: 'Resultado da Análise',
        showBackButton: true,
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Container com gradiente + borda arredondada
              Positioned(
                top: topGradientOffset,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey.shade200,
                        Colors.white,
                      ],
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

              // Conteúdo scrollável por cima do fundo
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Espaço para empurrar o conteúdo até o início do gradiente
                      const SizedBox(height: topGradientOffset),

                      // Título principal (sobre fundo branco)
                      Text(
                        'Minha Análise Personalizada',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 8),

                      // Seção: Principais Funções
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
                        ...List.generate(result.topFunctions.length, (i) {
                          final func = result.topFunctions[i];
                          final widthFactor = (result.topFunctions.length - i) /
                              result.topFunctions.length;
                          return GestureDetector(
                            onTap: () {
                              final def = vm.getFunctionDefinition(func);
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
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
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

                      // Seção: Princípios Ativos
                      Text(
                        'Princípios Ativos',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      if (result.topIngredients.isEmpty)
                        const Text(
                          'Nenhum ingrediente ativo encontrado.',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: result.topIngredients.map((ing) {
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

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.list),
          label: const Text('Lista de Ingredientes'),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SelectedIngredientsView(
                  showAnalyzeButton: false,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}