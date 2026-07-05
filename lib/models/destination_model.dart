class DestinationModel {
  final String? id; // ID do documento no Firestore
  String name;
  String description;
  List<String> photos; // Lista de URLs das photos
  String coverPhoto; // URL da foto capa (uma das photos acima)
  List<String> categories;

  // Endereço detalhado
  String street;
  String number;
  String neighborhood;
  String cep;
  String city;
  String state;

  // Coordenadas (preenchidas via Geoapify pelo endereço)
  double latitude;
  double longitude;

  // Favoritos: lista de UIDs dos usuários que favoritaram
  List<String> favoritedBy;
  // Comentários do destino
  List<String> comments;
  // UID do usuário que criou o destino (só ele pode editar)
  String createdBy;

  DestinationModel({
    this.id,
    required this.name,
    this.description = '',
    this.photos = const [],
    this.coverPhoto = '',
    this.categories = const [],
    this.street = '',
    this.number = '',
    this.neighborhood = '',
    this.cep = '',
    required this.city,
    this.state = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.favoritedBy = const [],
    this.comments = const [],
    this.createdBy = '',
  });

  // Getter: campo "local" usado para exibição (compatível com código existente)
  String get local =>
      '${neighborhood.isNotEmpty ? '$neighborhood, ' : ''}$city – $state';

  // Getter: contagem de favoritos
  int get totalFavoritos => favoritedBy.length;

  // Verifica se um usuário específico favoritou
  bool favoritedByUsuario(String uid) => favoritedBy.contains(uid);

  factory DestinationModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return DestinationModel(
      id: id ?? data['id'],
      name: data['name'] ?? data['nome'] ?? '',
      description: data['description'] ?? data['descricao'] ?? '',
      photos: List<String>.from(data['photos'] ?? []),
      coverPhoto: data['coverPhoto'] ?? data['image'] ?? data['imagem'] ?? '',
      categories: List<String>.from(data['categories'] ?? data['categorias'] ?? []),
      street: data['street'] ?? data['local'] ?? '',
      number: data['number'] ?? '',
      neighborhood: data['neighborhood'] ?? '',
      cep: data['cep'] ?? '',
      city: data['city'] ?? data['cidade'] ?? '',
      state: data['state'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      favoritedBy: List<String>.from(data['favoritedBy'] ?? []),
      comments: List<String>.from(data['comments'] ?? []),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'photos': photos,
      'coverPhoto': coverPhoto,
      'categories': categories,
      'street': street,
      'number': number,
      'neighborhood': neighborhood,
      'cep': cep,
      'city': city,
      'state': state,
      // campo "local" gerado automaticamente pelo getter, não salvo
      'latitude': latitude,
      'longitude': longitude,
      'favoritedBy': favoritedBy,
      'comments': comments,
      'createdBy': createdBy,
    };
  }

  // Cópia com campos modificados
  DestinationModel copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? photos,
    String? coverPhoto,
    List<String>? categories,
    String? street,
    String? number,
    String? neighborhood,
    String? cep,
    String? city,
    String? state,
    double? latitude,
    double? longitude,
    List<String>? favoritedBy,
    List<String>? comments,
    String? createdBy,
  }) {
    return DestinationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      photos: photos ?? this.photos,
      coverPhoto: coverPhoto ?? this.coverPhoto,
      categories: categories ?? this.categories,
      street: street ?? this.street,
      number: number ?? this.number,
      neighborhood: neighborhood ?? this.neighborhood,
      cep: cep ?? this.cep,
      city: city ?? this.city,
      state: state ?? this.state,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      favoritedBy: favoritedBy ?? this.favoritedBy,
      comments: comments ?? this.comments,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
