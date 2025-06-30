// lib/widgets/ingredient_tile.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ingredient_model.dart';
import '../viewmodels/ingredients_view_model.dart';

class IngredientTile extends StatelessWidget {
  final IngredientModel ingredient;

  const IngredientTile({Key? key, required this.ingredient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<IngredientsViewModel>();
    final isSelected = vm.selected.contains(ingredient);

    final cardColor = Theme.of(context).cardColor;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.03 * 255).round()),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone ou placeholder
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

                // Descrição
                Text(
                  ingredient.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                const SizedBox(height: 6),

                // Lista de funções como chips
                if (ingredient.functions.isNotEmpty)
                  SizedBox(
                    height: 24, // altura fixa para os chips
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
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.1),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Botão de selecionar
          IconButton(
            icon: Icon(
              isSelected ? Icons.check_circle : Icons.add_circle_outline,
              size: 20,
            ),
            color: primaryColor,
            onPressed: () => vm.toggleSelected(ingredient),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}
