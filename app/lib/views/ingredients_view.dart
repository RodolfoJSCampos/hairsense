import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/viewmodels.dart';
import '../widgets/widgets.dart';
import '../views/views.dart';

class IngredientsView extends StatefulWidget {
  const IngredientsView({super.key});

  @override
  State<IngredientsView> createState() => _IngredientsViewState();
}

class _IngredientsViewState extends State<IngredientsView> {
  late final IngredientsViewModel vm;
  late final ScrollController _scrollCtrl;

  @override
  void initState() {
    super.initState();

    vm = context.read<IngredientsViewModel>();

    _scrollCtrl = ScrollController()
      ..addListener(() {
        if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 100) {
          vm.loadMore(); 
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
      appBar: const AppBarConfig(title: 'Ingredientes', showBackButton: true),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: vm.search, // Atualiza a busca no ViewModel
              decoration: InputDecoration(
                hintText: 'Buscar…',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
              ),
            ),
          ),

          // Lista de ingredientes
          Expanded(
            child: Builder(
              builder: (_) {
                if (vm.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Estado de erro 
                if (vm.hasError) {
                  return Center(
                    child: Text(
                      'Erro: ${vm.errorMessage}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                // Lista vazia 
                if (vm.displayed.isEmpty) {
                  return const Center(
                    child: Text('Nenhum ingrediente encontrado'),
                  );
                }

                // Lista com ingredientes
                return ListView.separated(
                  controller: _scrollCtrl, 
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: vm.displayed.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (_, i) {
                    return IngredientTile(ingredient: vm.displayed[i]);
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // Botão flutuante que aparece se houver ingredientes selecionados
      floatingActionButton: vm.selected.isEmpty
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.list),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Minha Lista'),
                  const SizedBox(width: 8),

                  // Contador de ingredientes selecionados
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
                final vmInstance = context.read<IngredientsViewModel>();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) {
                      return ChangeNotifierProvider.value(
                        value: vmInstance,
                        child: const SelectedIngredientsView(),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}