class DestinoModel {
  String nome;
  List<String> categorias;
  String descricao;
  String imagem;
  String local;
  String cidade; // 1. Novo campo aqui

  DestinoModel({
    required this.nome,
    required this.categorias,
    required this.descricao,
    required this.imagem,
    required this.local,
    required this.cidade, // 2. Adicione ao construtor
  });

  factory DestinoModel.fromMap(Map<String, dynamic> data) {
    return DestinoModel(
      nome: data['nome'] ?? '',
      categorias: List<String>.from(data['categorias'] ?? []),
      descricao: data['descricao'] ?? '',
      imagem: data['imagem'] ?? '',
      local: data['local'] ?? '',
      cidade: data['cidade'] ?? '', // 3. Mapeie do JSON/Firestore
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'categorias': categorias,
      'descricao': descricao,
      'imagem': imagem,
      'local': local,
      'cidade': cidade, // 4. Mapeie para o Firestore
    };
  }
}