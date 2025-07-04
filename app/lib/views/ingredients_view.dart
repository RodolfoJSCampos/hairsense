// lib/views/ingredients_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/ingredients_view_model.dart';
import '../widgets/ingredient_tile.dart';
import '../widgets/app_bar_config.dart';
import '../views/selected_ingredients_view.dart';

class IngredientsView extends StatefulWidget {
  const IngredientsView({Key? key}) : super(key: key);

  @override
  State<IngredientsView> createState() => _IngredientsViewState();
}

class _IngredientsViewState extends State<IngredientsView> {
  late final ScrollController _scrollCtrl;
  late final IngredientsViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = context.read<IngredientsViewModel>();

    _scrollCtrl = ScrollController()
      ..addListener(() {
        final pos = _scrollCtrl.position;
        if (pos.pixels >= pos.maxScrollExtent - 100 &&
            !vm.isLoading &&
            vm.hasMore) {
          vm.fetchNextPage();
        }
      });

    WidgetsBinding.instance.addPostFrameCallback((_) => vm.init());
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<IngredientsViewModel>();

    return Scaffold(
      appBar: const AppBarConfig(
        title: 'Ingredientes',
        showBackButton: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (text) {
                vm.search(text);
                _scrollCtrl.jumpTo(0);
              },
              decoration: InputDecoration(
                hintText: 'Buscar…',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              ),
            ),
          ),

          Expanded(
            child: Builder(builder: (_) {
              if (vm.isLoading && vm.displayed.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (vm.hasError && vm.displayed.isEmpty) {
                return Center(
                  child: Text(
                    'Erro: ${vm.errorMessage}',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              if (vm.displayed.isEmpty) {
                return const Center(
                  child: Text('Nenhum ingrediente encontrado'),
                );
              }

              return ListView.separated(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: vm.displayed.length + (vm.hasMore ? 1 : 0),
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 16,
                  endIndent: 16,
                ),
                itemBuilder: (_, index) {
                  if (index < vm.displayed.length) {
                    final ing = vm.displayed[index];
                    return IngredientTile(
                      key: ValueKey(ing.cosingRef),
                      ingredient: ing,
                    );
                  }

                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
      floatingActionButton: vm.selected.isEmpty
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.list),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Minha Lista'),
                  const SizedBox(width: 8),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${vm.selected.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: vm,
                      child: const SelectedIngredientsView(),
                    ),
                  ),
                );
              },
            ),
    );
  }
}