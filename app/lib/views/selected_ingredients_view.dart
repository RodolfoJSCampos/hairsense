import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../viewmodels/ingredients_view_model.dart';
import '../widgets/app_bar_config.dart';
import '../widgets/ingredient_tile.dart';
import 'analysis_result_view.dart';
import 'ingredient_detail_view.dart';

class SelectedIngredientsView extends StatefulWidget {
  /// Produto que vai pré-selecionar ingredientes
  final Product? product;

  const SelectedIngredientsView({
    Key? key,
    this.product,
  }) : super(key: key);

  @override
  State<SelectedIngredientsView> createState() =>
      _SelectedIngredientsViewState();
}

class _SelectedIngredientsViewState extends State<SelectedIngredientsView> {
  late final IngredientsViewModel vm;
  bool _populated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_populated && widget.product != null) {
      vm = context.read<IngredientsViewModel>();
      vm.clearSelected();
      for (final name in widget.product!.ingredients) {
        for (final ing in vm.allIngredients) {
          if (ing.inciName.toLowerCase() == name.toLowerCase()) {
            vm.toggleSelected(ing);
            break;
          }
        }
      }
      _populated = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = context.watch<IngredientsViewModel>().selected;
    final fromProduct = widget.product != null;

    return Scaffold(
      appBar: const AppBarConfig(
        title: 'Selecionados',
        showBackButton: true,
      ),
      body: selected.isEmpty
          ? const Center(child: Text('Nenhum ingrediente selecionado'))
          : ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: selected.length,
              onReorder: context.read<IngredientsViewModel>().reorderSelected,
              buildDefaultDragHandles: false,
              itemBuilder: (context, index) {
                final ing = selected[index];
                return IngredientTile(
                  key: ValueKey(ing.cosingRef),
                  ingredient: ing,
                  leading: ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle),
                  ),
                  // oculta remover quando for fluxo de produto
                  trailing: fromProduct
                      ? null
                      : IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () =>
                              context.read<IngredientsViewModel>().toggleSelected(ing),
                        ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => IngredientDetailView(ingredient: ing),
                    ),
                  ),
                );
              },
            ),
      // só mostra botão “Analisar” no fluxo manual
      bottomNavigationBar: (!fromProduct && selected.isNotEmpty)
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.analytics),
                label: const Text('Analisar'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Atenção!'),
                      content: const Text(
                        'A ordem dos ingredientes é importante para uma análise precisa. '
                        'Eles aparecem no rótulo conforme concentração. '
                        'Certifique-se que a ordem corresponde ao rótulo.',
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
                                builder: (_) => AnalysisResultView(
                                  product: widget.product,
                                ),
                              ),
                            );
                          },
                          child: const Text('Continuar'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          : null,
    );
  }
}