import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/ingredients_view_model.dart';

class IngredientsView extends StatelessWidget {
  const IngredientsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pega o VM (ainda vazio) pra manter o padrão MVVM + Provider
    context.watch<IngredientsViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredientes'),
      ),
      // Só um Container vazio expandido pra mostrar o fundo
      body: const SizedBox.expand(),
    );
  }
}