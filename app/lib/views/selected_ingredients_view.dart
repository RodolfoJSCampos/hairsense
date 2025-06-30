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
                return ListTile(
                  key: ValueKey(ing.cosingRef),
                  title: Text(ing.inciName),
                  subtitle: Text(ing.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Icons.drag_handle),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => vm.toggleSelected(ing),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: vm.selected.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.analytics),
                label: const Text('Analisar'),      // já renomeado
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
          'no produto. Tenha certeza que os produtos estão na mesma ordem em que '
          'aparecem no rótulo.',
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