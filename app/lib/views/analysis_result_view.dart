import 'package:flutter/material.dart';
import '../widgets/widgets.dart';

class AnalysisResultView extends StatefulWidget {
  const AnalysisResultView({Key? key}) : super(key: key);

  @override
  State<AnalysisResultView> createState() => _AnalysisResultViewState();
}

class _AnalysisResultViewState extends State<AnalysisResultView> {
  bool isUploading = false;
  double progress = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarConfig(
        title: 'Resultado da Análise',
        showBackButton: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          
        ),
      ),
    );
  }
}