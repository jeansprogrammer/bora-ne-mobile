enum CategoriaDestino {
  religioso,
  lazer,
  gastronomia,
  aventura,
  musicaEventos

}

class DestinoModel {
  String nome;
  List<String> categorias; // Firestore armazena listas como List<dynamic> ou List<String>
  String descricao;
  String imagem;
  String local;

  DestinoModel({
    required this.nome,
    required this.categorias,
    required this.descricao,
    required this.imagem,
    required this.local,
  });

  // Converte um documento do Firestore (Map) para o Objeto DestinoModel
  factory DestinoModel.fromMap(Map<String, dynamic> data) {
    return DestinoModel(
      nome: data['nome'] ?? '',
      categorias: List<String>.from(data['categorias'] ?? []),
      descricao: data['descricao'] ?? '',
      imagem: data['imagem'] ?? '',
      local: data['local'] ?? '',
    );
  }

  // Converte o Objeto DestinoModel para um Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'categorias': categorias,
      'descricao': descricao,
      'imagem': imagem,
      'local': local,
    };
  }
}