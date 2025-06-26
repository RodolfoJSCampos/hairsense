import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_bar_config.dart';
import '../viewmodels/home_view_model.dart';
import '../models/card_item_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: Scaffold(
        appBar: const AppBarConfig(),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Consumer<HomeViewModel>(
          builder: (context, vm, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.85),
                itemCount: vm.cards.length,
                itemBuilder: (context, index) {
                  final card = vm.cards[index];
                  return _CardItem(card: card);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CardItem extends StatelessWidget {
  final CardItemModel card;

  const _CardItem({required this.card});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 320,
          height: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(card.imagem, width: 120, height: 120),
              const SizedBox(height: 24),
              Text(
                card.titulo,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                card.descricao,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}