import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class IngredientDetailView extends StatelessWidget {
  final IngredientModel ingredient;

  const IngredientDetailView({
    Key? key,
    required this.ingredient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: const AppBarConfig(
        title: 'Detalhes',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1) Nome em destaque
            Text(
              ingredient.inciName,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // 2) Descrição completa
            Text(
              ingredient.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            // 3) Lista de funções (chips)
            if (ingredient.functions.isNotEmpty) ...[
              Text(
                'Funções',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: ingredient.functions.map((func) {
                  return Chip(
                    label: Text(
                      func,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: primary.withOpacity(0.1),
                    visualDensity: const VisualDensity(
                        horizontal: -2, vertical: -2),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}