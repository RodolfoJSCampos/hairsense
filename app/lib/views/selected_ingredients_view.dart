
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/viewmodels.dart';
import '../widgets/widgets.dart';
import '../views/views.dart';

class SelectedIngredientsView extends StatelessWidget {
  const SelectedIngredientsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<IngredientsViewModel>();

    return Scaffold(
      appBar: const AppBarConfig(
        title: 'Selecionados',
        showBackButton: true,
      ),
      body: vm.selected.isEmpty
          ? const Center(child: Text('Nenhum ingrediente selecionado'))
          : ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: vm.selected.length,
              onReorder: vm.reorderSelected,
              buildDefaultDragHandles: false,
              itemBuilder: (context, index) {
                final ing = vm.selected[index];
                return IngredientTile(
                  key: ValueKey(ing.cosingRef),
                  ingredient: ing,
                  // handle de drag
                  leading: ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle),
                  ),
                  // botão de remoção
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                    onPressed: () => vm.toggleSelected(ing),
                  ),
                  // mantém comportamento padrão de abrir detalhes
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            IngredientDetailView(ingredient: ing),
                      ),
                    );
                  },
                );
              },
            ),
      bottomNavigationBar: vm.selected.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.analytics),
                label: const Text('Analisar'),
                onPressed: () => _showAnalysisDialog(context),
              ),
            ),
    );
  }

  void _showAnalysisDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Atenção!'),
        content: const Text(
          'A ordem dos ingredientes é importante para uma análise precisa. '
          'Os ingredientes aparecem no rótulo de acordo com a sua concentração '
          'no produto. Tenha certeza de que estão na mesma ordem do rótulo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Voltar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AnalysisResultView(),
                ),
              );
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}