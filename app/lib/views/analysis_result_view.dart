// lib/views/analysis_result_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../viewmodels/viewmodels.dart';
import '../widgets/widgets.dart';
import '../views/views.dart';

class AnalysisResultView extends StatefulWidget {
  final Product? product;
  final String title;

  const AnalysisResultView({
    Key? key,
    this.product,
    this.title = 'Resultado da Análise',
  }) : super(key: key);

  @override
  State<AnalysisResultView> createState() => _AnalysisResultViewState();
}

class _AnalysisResultViewState extends State<AnalysisResultView> {
  @override
  void initState() {
    super.initState();
    // Não fazemos mais clearSelected() aqui
  }

  @override
  void dispose() {
    // Limpa a lista de selected apenas ao sair do fluxo de produto
    if (widget.product != null) {
      context.read<IngredientsViewModel>().clearSelected();
      // Se tiver análise no ProductsViewModel:
      // context.read<ProductsViewModel>().clearAnalysis();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ingVM = context.watch<IngredientsViewModel>();
    final prodVM = context.watch<ProductsViewModel>();
    final primary = Theme.of(context).colorScheme.primary;

    final result = widget.product != null
        ? prodVM.analysisResult(widget.product!)
        : ingVM.analyze();

    const double topOffset = 240;
    const double bottomPadding = 80;

    return Scaffold(
      appBar: AppBarConfig(
        title: widget.product != null ? 'Detalhes do Produto' : widget.title,
        showBackButton: true,
      ),
      body: Stack(
        children: [
          Positioned(
            top: topOffset,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey.shade200, Colors.white],
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

          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: topOffset),

                Text(
                  widget.product?.name ?? 'Minha Análise Personalizada',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

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
                  ...result.topFunctions.asMap().entries.map((e) {
                    final i = e.key;
                    final func = e.value;
                    final widthFactor =
                        (result.topFunctions.length - i) /
                            result.topFunctions.length;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: GestureDetector(
                        onTap: () {
                          final def = ingVM.getFunctionDefinition(func);
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(func),
                              content: Text(def),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Fechar'),
                                ),
                              ],
                            ),
                          );
                        },
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

                Text(
                  widget.product != null
                      ? 'Ingredientes do Produto'
                      : 'Princípios Ativos',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: result.topIngredients.isEmpty
                          ? [
                              const Text(
                                'Nenhum ingrediente ativo encontrado.',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              )
                            ]
                          : result.topIngredients.map((ing) {
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.list),
          label: const Text('Lista de Ingredientes'),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SelectedIngredientsView(product: widget.product),
              ),
            );
          },
        ),
      ),
    );
  }
}