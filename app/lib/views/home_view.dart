import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../viewmodels/viewmodels.dart';  
import '../models/models.dart';          
import '../services/services.dart';      
import '../widgets/widgets.dart';        

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final PageController _pageController =
      PageController(viewportFraction: 0.85);
  bool _validando = true;

  @override
  void initState() {
    super.initState();
    _validarPerfil();
  }

  Future<void> _validarPerfil() async {
    final ok = await UsuarioValidadorService()
        .validarUsuarioLogadoComPerfil();
    if (!ok && mounted) {
      Navigator.pushReplacementNamed(context, '/login_view');
    } else {
      setState(() => _validando = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_validando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // VM já injetado no main.dart pela rota /home_view
    final vm = context.watch<HomeViewModel>();

    return Scaffold(
      appBar: const AppBarConfig(), 
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const SizedBox(height: 24),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: vm.cards.length,
              itemBuilder: (context, index) {
                final card = vm.cards[index];
                return GestureDetector(
                  onTap: () {
                    if (card.titulo.toLowerCase() == 'ingredientes') {
                      Navigator.pushNamed(context, '/ingredients_view');
                    }
                  },
                  child: _CardItem(card: card),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SmoothPageIndicator(
            controller: _pageController,
            count: vm.cards.length,
            effect: WormEffect(
              dotHeight: 10,
              dotWidth: 10,
              spacing: 12,
              dotColor: Colors.grey.shade400,
              activeDotColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
        ],
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
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