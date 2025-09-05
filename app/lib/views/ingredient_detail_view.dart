import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class IngredientDetailView extends StatelessWidget {
  final IngredientModel ingredient; 

  const IngredientDetailView({
    Key? key,
    required this.ingredient,
  }) : super(key: key);

  Future<void> _showDefinition(BuildContext context, String funcName) async {
    final funcs = await FunctionsService.findAllByName(funcName);

    if (funcs.isEmpty) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(funcName),
          content: const Text('Definição não encontrada.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
      return;
    }

    final content = SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: funcs.map((f) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${f.portuguese} (${f.english})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),

                Text(f.definition),
              ],
            ),
          );
        }).toList(),
      ),
    );

// if (!context.mounted) return;

    // Mostra o conteúdo em um AlertDialog
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Funções para: $funcName'),
        content: content,
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
            // 1) Nome INCI do ingrediente em destaque
            Text(
              ingredient.inciName,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 2) Descrição completa do ingrediente
            Text(
              ingredient.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // 3) Lista de funções do ingrediente (se houver)
            if (ingredient.functions.isNotEmpty) ...[
              // Título da seção de funções
              Text(
                'Funções',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              // Chips interativos para cada função
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: ingredient.functions.map((func) {
                  return GestureDetector(
                    // Ao tocar no chip, mostra definição da função
                    onTap: () => _showDefinition(context, func),
                    child: Chip(
                      label: Text(
                        func,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: primary.withOpacity(0.1),
                      visualDensity: const VisualDensity(
                          horizontal: -2, vertical: -2),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
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