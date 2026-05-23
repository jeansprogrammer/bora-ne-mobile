class DestinoModel {
  final String? id;           // ID do documento no Firestore
  String nome;
  String descricao;
  List<String> fotos;         // Lista de URLs das fotos
  String fotoCapa;            // URL da foto capa (uma das fotos acima)
  List<String> categorias;    // Múltiplas categorias

  // Endereço detalhado
  String rua;
  String numero;
  String bairro;
  String cep;
  String cidade;
  String uf;

  // Coordenadas (preenchidas via Geoapify pelo endereço)
  double latitude;
  double longitude;

  // Favoritos: lista de UIDs dos usuários que favoritaram
  List<String> favoritadoPor;

  DestinoModel({
    this.id,
    required this.nome,
    this.descricao = '',
    this.fotos = const [],
    this.fotoCapa = '',
    this.categorias = const [],
    this.rua = '',
    this.numero = '',
    this.bairro = '',
    this.cep = '',
    required this.cidade,
    this.uf = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.favoritadoPor = const [],
  });

  // Getter: campo "local" usado para exibição (compatível com código existente)
  String get local => '${bairro.isNotEmpty ? '$bairro, ' : ''}$cidade – $uf';

  // Getter: contagem de favoritos
  int get totalFavoritos => favoritadoPor.length;

  // Verifica se um usuário específico favoritou
  bool favoritadoPorUsuario(String uid) => favoritadoPor.contains(uid);

  factory DestinoModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return DestinoModel(
      id: id,
      nome: data['nome'] ?? '',
      descricao: data['descricao'] ?? '',
      fotos: List<String>.from(data['fotos'] ?? []),
      fotoCapa: data['fotoCapa'] ?? data['imagem'] ?? '',
      categorias: List<String>.from(data['categorias'] ?? []),
      rua: data['rua'] ?? '',
      numero: data['numero'] ?? '',
      bairro: data['bairro'] ?? '',
      cep: data['cep'] ?? '',
      cidade: data['cidade'] ?? '',
      uf: data['uf'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      favoritadoPor: List<String>.from(data['favoritadoPor'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'descricao': descricao,
      'fotos': fotos,
      'fotoCapa': fotoCapa,
      'categorias': categorias,
      'rua': rua,
      'numero': numero,
      'bairro': bairro,
      'cep': cep,
      'cidade': cidade,
      'uf': uf,
      // campo "local" gerado automaticamente pelo getter, não salvo
      'latitude': latitude,
      'longitude': longitude,
      'favoritadoPor': favoritadoPor,
    };
  }

  // Cópia com campos modificados
  DestinoModel copyWith({
    String? id,
    String? nome,
    String? descricao,
    List<String>? fotos,
    String? fotoCapa,
    List<String>? categorias,
    String? rua,
    String? numero,
    String? bairro,
    String? cep,
    String? cidade,
    String? uf,
    double? latitude,
    double? longitude,
    List<String>? favoritadoPor,
  }) {
    return DestinoModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      fotos: fotos ?? this.fotos,
      fotoCapa: fotoCapa ?? this.fotoCapa,
      categorias: categorias ?? this.categorias,
      rua: rua ?? this.rua,
      numero: numero ?? this.numero,
      bairro: bairro ?? this.bairro,
      cep: cep ?? this.cep,
      cidade: cidade ?? this.cidade,
      uf: uf ?? this.uf,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      favoritadoPor: favoritadoPor ?? this.favoritadoPor,
    );
  }
}