// lib/widgets/ingredient_tile.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../viewmodels/viewmodels.dart';
import '../views/views.dart';

class IngredientTile extends StatelessWidget {
  final IngredientModel ingredient;

  const IngredientTile({Key? key, required this.ingredient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('🔨 IngredientTile.build para ${ingredient.cosingRef}');

    final vm = context.watch<IngredientsViewModel>();
    final isSelected = vm.selected.contains(ingredient);

    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardColor = Theme.of(context).cardColor;

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        // Ao tocar no tile inteiro, abre detalhes
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => IngredientDetailView(ingredient: ingredient),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícone placeholder
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.spa, color: Colors.grey, size: 24),
              ),
              const SizedBox(width: 10),

              // Coluna de textos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome
                    Text(
                      ingredient.inciName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Descrição resumida
                    Text(
                      ingredient.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),

                    const SizedBox(height: 6),

                    // Funções como chips, numa linha scrollável
                    if (ingredient.functions.isNotEmpty)
                      SizedBox(
                        height: 24,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                ingredient.functions.map((func) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Chip(
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: const VisualDensity(
                                        horizontal: -4,
                                        vertical: -4,
                                      ),
                                      padding: EdgeInsets.zero,
                                      labelPadding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 0,
                                      ),
                                      label: Text(
                                        func,
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      backgroundColor: primaryColor.withOpacity(
                                        0.1,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Botão de marcar/desmarcar
              IconButton(
                icon: Icon(isSelected ? Icons.close : Icons.add, size: 20),
                color: primaryColor,
                onPressed: () => vm.toggleSelected(ingredient),
                splashRadius: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
