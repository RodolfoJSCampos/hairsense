// lib/views/selected_ingredients_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/ingredients_view_model.dart';
import '../widgets/app_bar_config.dart'; // ou use AppBar normal se preferir

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
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: vm.selected.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, i) {
                final ing = vm.selected[i];
                return ListTile(
                  title: Text(ing.inciName),
                  subtitle: Text(ing.description),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => vm.toggleSelected(ing),
                  ),
                );
              },
            ),
      bottomNavigationBar: vm.selected.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.search),
                label: const Text('Pesquisar produtos'),
                onPressed: () {
                  // Por enquanto só feedback visual
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funcionalidade de busca não implementada'),
                    ),
                  );
                },
              ),
            ),
    );
  }
}