
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../viewmodels/viewmodels.dart';
import '../views/views.dart';

class IngredientTile extends StatelessWidget {
  final IngredientModel ingredient;

  /// Callback ao clicar no tile (por padrão abre detalhes)
  final VoidCallback? onTap;

  /// Widget opcional para exibir antes do ícone padrão
  final Widget? leading;

  /// Widget opcional para exibir no lugar do botão add/close
  final Widget? trailing;

  const IngredientTile({
    Key? key,
    required this.ingredient,
    this.onTap,
    this.leading,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<IngredientsViewModel>();
    final isSelected = vm.selected.contains(ingredient);

    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardColor = Theme.of(context).cardColor;

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap ??
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      IngredientDetailView(ingredient: ingredient),
                ),
              );
            },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // leading custom ou ícone placeholder
              if (leading != null)
                leading!
              else
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
                    // Descrição resumida (2 linhas + fade)
                    Text(
                      ingredient.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    // Funções como chips
                    if (ingredient.functions.isNotEmpty)
                      SizedBox(
                        height: 24,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ingredient.functions.map((func) {
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
                                  labelPadding:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  label: Text(
                                    func,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor:
                                      primaryColor.withOpacity(0.1),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // trailing custom ou botão padrão de selecionar/deselecionar
              if (trailing != null)
                trailing!
              else
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