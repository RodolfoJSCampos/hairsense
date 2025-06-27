import 'package:flutter/material.dart';
import '../models/models.dart';

class HomeViewModel extends ChangeNotifier {
  final List<CardItemModel> cards = [
    CardItemModel(
      titulo: 'Ingredientes',
      descricao: 'Encontre ingredientes específicos',
      imagem: 'assets/ingredientes_icon.png',
    ),
    CardItemModel(
      titulo: 'Produtos',
      descricao: 'Busque diretamente um produto',
      imagem: 'assets/produtos_icon.png',
    ),
  ];
}