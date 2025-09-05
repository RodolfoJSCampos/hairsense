import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/viewmodels.dart';          
import '../widgets/product_card.dart';            
import '../widgets/app_bar_config.dart';          

class ProductsView extends StatefulWidget {
  const ProductsView({Key? key}) : super(key: key);

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  late final ProductsViewModel vm;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();

    vm = context.read<ProductsViewModel>();

    _searchController = TextEditingController();


    WidgetsBinding.instance.addPostFrameCallback((_) => vm.init());
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductsViewModel>();
    final term = _searchController.text.trim();

    return Scaffold(
      appBar: const AppBarConfig(
        title: 'Produtos',
        showBackButton: true,
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: vm.search, 
              decoration: InputDecoration(
                hintText: 'Buscar…',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              ),
            ),
          ),

          // Área que exibe os produtos
          Expanded(
            child: Builder(builder: (_) {
              if (vm.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (vm.hasError) {
                return Center(
                  child: Text('Erro: ${vm.errorMessage}'),
                );
              }

              if (vm.displayed.isEmpty) {
                if (term.isNotEmpty) {
                  return Center(
                    child: Text('Nenhum produto encontrado para “$term”'),
                  );
                }

                return const Center(child: Text('Nenhum produto disponível'));
              }

              // Exibe os produtos em um grid
              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,         
                  mainAxisSpacing: 8,        
                  crossAxisSpacing: 8,       
                  childAspectRatio: 0.7,    
                ),
                itemCount: vm.displayed.length,
                itemBuilder: (_, index) {
                  return ProductCard(product: vm.displayed[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}