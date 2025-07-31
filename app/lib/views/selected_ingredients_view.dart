// lib/views/selected_ingredients_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../viewmodels/ingredients_view_model.dart';
import '../widgets/app_bar_config.dart';
import '../widgets/ingredient_tile.dart';
import 'analysis_result_view.dart';
import 'ingredient_detail_view.dart';

class SelectedIngredientsView extends StatefulWidget {
  final Product? product;

  const SelectedIngredientsView({Key? key, this.product}) : super(key: key);

  @override
  State<SelectedIngredientsView> createState() =>
      _SelectedIngredientsViewState();
}

class _SelectedIngredientsViewState extends State<SelectedIngredientsView> {
  @override
  void initState() {
    super.initState();

    // Se vier de um produto, pré-seleciona os ingredientes
    if (widget.product != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final vm = context.read<IngredientsViewModel>();
        for (final inci in widget.product!.ingredients) {
          for (final ing in vm.allIngredients) {
            if (ing.inciName.toLowerCase() == inci.toLowerCase()) {
              vm.toggleSelected(ing);
              break;
            }
          }
        }
      });
    }
  }

  @override
  void dispose() {
    // Ao sair da tela de produtos (fluxo product != null), limpa o selected
    if (widget.product != null) {
      context.read<IngredientsViewModel>().clearSelected();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<IngredientsViewModel>();
    final selected = vm.selected;
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
              onReorder: vm.reorderSelected,
              buildDefaultDragHandles: false,
              itemBuilder: (ctx, i) {
                final ing = selected[i];
                return IngredientTile(
                  key: ValueKey(ing.cosingRef),
                  ingredient: ing,
                  leading: fromProduct
                      ? null
                      : ReorderableDragStartListener(
                          index: i,
                          child: const Icon(Icons.drag_handle),
                        ),
                  trailing: fromProduct
                      ? null
                      : IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => vm.toggleSelected(ing),
                        ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => IngredientDetailView(ingredient: ing),
                    ),
                  ),
                );
              },
            ),
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
                        'A ordem dos ingredientes é importante para uma '
                        'análise precisa. '
                        'Eles aparecem no rótulo conforme concentração.',
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