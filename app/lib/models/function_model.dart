
class FunctionModel {
  final String english;
  final String portuguese;
  final String definition;

  FunctionModel({
    required this.english,
    required this.portuguese,
    required this.definition,
  });

  factory FunctionModel.fromJson(Map<String, dynamic> json) {
    return FunctionModel(
      english: json['funcao_ingles'] as String,
      portuguese: json['funcao_portugues'] as String,
      definition: json['definicao'] as String,
    );
  }
}