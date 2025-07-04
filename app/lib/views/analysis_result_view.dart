import 'package:flutter/material.dart';
import '../widgets/widgets.dart';

class AnalysisResultView extends StatelessWidget {
  const AnalysisResultView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarConfig(
        title: 'Resultado da Análise',
        showBackButton: true,
      ),
      body: const Center(
        child: Text(
          'Tela de resultados (ainda em desenvolvimento)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}