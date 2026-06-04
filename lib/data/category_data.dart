import '../models/category_model.dart';

/// Lista canônica de categorias do BoraNE com sinônimos para busca.
/// Gerada a partir do arquivo Categorias_Turismo_Subcategorias.xlsx
const List<CategoryModel> categoriasBoraNE = [
  CategoryModel(
    name: 'Cultural',
    emoji: '🏛️',
    synonyms: [
      'Arte', 'Folclore', 'Artesanato', 'Tradições', 'Música', 'Dança',
      'Literatura', 'Cinema', 'Teatro', 'Exposição', 'Galeria',
      'Centro Cultural', 'Patrimônio Cultural', 'Feira Cultural',
      'Oficina Cultural', 'Manifestação Popular', 'Cultura Regional',
      'Cultura Indígena', 'Cultura Afro-brasileira', 'Intercâmbio Cultural',
    ],
  ),
  CategoryModel(
    name: 'Histórico',
    emoji: '🏰',
    synonyms: [
      'Monumento', 'Museu Histórico', 'Sítio Histórico',
      'Patrimônio Histórico', 'Ruínas', 'Memorial', 'Centro Histórico',
      'Forte', 'Castelo', 'Marco Histórico', 'Praça Histórica',
      'Arquitetura Colonial', 'Arquitetura Antiga', 'Batalha Histórica',
      'Personagem Histórico', 'Acervo Histórico', 'Trilha Histórica',
      'Igreja Histórica', 'Casarão Histórico', 'Cidade Histórica',
    ],
  ),
  CategoryModel(
    name: 'Religioso',
    emoji: '⛪',
    synonyms: [
      'Igreja', 'Capela', 'Santuário', 'Templo', 'Mosteiro', 'Convento',
      'Catedral', 'Basílica', 'Peregrinação', 'Romaria', 'Festa Religiosa',
      'Centro Espírita', 'Mesquita', 'Sinagoga', 'Comunidade Religiosa',
      'Retiro Espiritual', 'Turismo de Fé', 'Via Sacra',
      'Monumento Religioso', 'Local Sagrado',
    ],
  ),
  CategoryModel(
    name: 'Natureza',
    emoji: '🌿',
    synonyms: [
      'Parque', 'Praia', 'Cachoeira', 'Lago', 'Rio', 'Serra', 'Montanha',
      'Mirante', 'Reserva Ambiental', 'Floresta', 'Manguezal',
      'Jardim Botânico', 'Trilha Ecológica', 'Vale', 'Gruta', 'Caverna',
      'Ilha', 'Duna', 'Parque Nacional', 'Ecoturismo',
    ],
  ),
  CategoryModel(
    name: 'Lazer',
    emoji: '🎪',
    synonyms: [
      'Praça', 'Área de Convivência', 'Parque Urbano', 'Piquenique',
      'Passeio', 'Recreação', 'Descanso', 'Passeio de Barco',
      'Passeio Turístico', 'Centro de Lazer', 'Clube', 'Balneário',
      'Espaço Público', 'Orla', 'Parque Recreativo', 'Atividades Familiares',
      'Passeio Guiado', 'Áreas Verdes', 'Ponto de Encontro', 'Relaxamento',
    ],
  ),
  CategoryModel(
    name: 'Entretenimento',
    emoji: '🎬',
    synonyms: [
      'Cinema', 'Teatro', 'Show', 'Casa de Espetáculos', 'Parque Temático',
      'Parque Aquático', 'Vida Noturna', 'Bar', 'Pub', 'Boate', 'Festival',
      'Apresentação Musical', 'Stand-up', 'Karaokê', 'Evento Cultural',
      'Arena de Eventos', 'Espetáculo', 'Game Center', 'Boliche', 'Diversão',
    ],
  ),
  CategoryModel(
    name: 'Aventura',
    emoji: '🧗',
    synonyms: [
      'Trilha', 'Rapel', 'Escalada', 'Tirolesa', 'Arvorismo', 'Canoagem',
      'Caiaque', 'Rafting', 'Mergulho', 'Balonismo', 'Parapente',
      'Asa-delta', 'Off-road', 'Camping', 'Expedição', 'Exploração',
      'Travessia', 'Turismo Radical', 'Mountain Bike', 'Sobrevivência',
    ],
  ),
  CategoryModel(
    name: 'Esportes',
    emoji: '⚽',
    synonyms: [
      'Corrida', 'Ciclismo', 'Mountain Bike', 'Natação', 'Surf',
      'Stand Up Paddle', 'Futebol', 'Vôlei', 'Beach Tennis', 'Skate',
      'Patins', 'Escalada Esportiva', 'Triatlo', 'Pesca Esportiva',
      'Remo', 'Vela', 'Crossfit', 'Caminhada', 'Treinamento Funcional',
      'Competição',
    ],
  ),
  CategoryModel(
    name: 'Gastronomia',
    emoji: '🍔',
    synonyms: [
      'Restaurante', 'Cafeteria', 'Lanchonete', 'Bar', 'Bistrô', 'Pizzaria',
      'Churrascaria', 'Hamburgueria', 'Padaria', 'Confeitaria', 'Food Truck',
      'Mercado Gastronômico', 'Culinária Regional', 'Culinária Internacional',
      'Frutos do Mar', 'Doceria', 'Adega', 'Vinícola', 'Cervejaria',
      'Degustação',
    ],
  ),
  CategoryModel(
    name: 'Compras',
    emoji: '🛍️',
    synonyms: [
      'Shopping', 'Centro Comercial', 'Feira', 'Mercado Público',
      'Artesanato', 'Loja de Souvenirs', 'Outlet', 'Feira Livre',
      'Galeria Comercial', 'Empório', 'Loja Regional', 'Moda', 'Acessórios',
      'Tecnologia', 'Presentes', 'Produtos Locais', 'Antiguidades',
      'Mercado de Rua', 'Feira Noturna', 'Comércio Popular',
    ],
  ),
  CategoryModel(
    name: 'Hospedagem',
    emoji: '🏨',
    synonyms: [
      'Hotel', 'Pousada', 'Hostel', 'Resort', 'Camping', 'Glamping',
      'Chalé', 'Flat', 'Apartamento', 'Casa de Temporada', 'Hotel Fazenda',
      'Eco Lodge', 'Pensão', 'Albergue', 'Hospedagem Rural',
      'Hospedagem Boutique', 'Hospedagem Familiar', 'Beira-mar',
      'Montanha', 'Luxo',
    ],
  ),
  CategoryModel(
    name: 'Eventos',
    emoji: '🎉',
    synonyms: [
      'Festival', 'Feira', 'Congresso', 'Seminário', 'Workshop', 'Exposição',
      'Show', 'Competição', 'Festa Popular', 'Evento Esportivo',
      'Evento Cultural', 'Evento Gastronômico', 'Encontro', 'Convenção',
      'Carnaval', 'São João', 'Festival de Música', 'Mostra', 'Lançamento',
      'Celebração',
    ],
  ),
  CategoryModel(
    name: 'Experiências',
    emoji: '✨',
    synonyms: [
      'Pôr do Sol', 'Nascer do Sol', 'Fotografia', 'Tour Guiado',
      'Experiência Local', 'Vivência Cultural', 'Turismo Rural',
      'Observação de Aves', 'Observação de Estrelas', 'Passeio de Barco',
      'Degustação', 'Imersão Cultural', 'Interação com Comunidades',
      'Rota Cênica', 'Experiência Gastronômica', 'Bem-estar', 'Spa',
      'Aventura Personalizada', 'Experiência Romântica', 'Experiência Exclusiva',
    ],
  ),
];

/// Nomes das categorias para usar em dropdowns e chips
List<String> get nomesCategorias =>
    categoriasBoraNE.map((c) => c.name).toList();

/// Busca categorias que batem com uma query (nome ou sinônimo)
List<CategoryModel> buscarCategorias(String query) {
  if (query.trim().isEmpty) return categoriasBoraNE;
  return categoriasBoraNE.where((c) => c.matches(query)).toList();
}

/// Retorna todos os sinônimos de uma categoria pelo nome
List<String> sionimosDaCategoria(String nome) {
  try {
    return categoriasBoraNE.firstWhere((c) => c.name == nome).synonyms;
  } catch (_) {
    return [];
  }
}

/// Expande uma query incluindo sinônimos de categorias relacionadas
List<String> expandirQueryComSinonimos(String query) {
  final termos = <String>{query.toLowerCase()};
  for (final cat in categoriasBoraNE) {
    if (cat.matches(query)) {
      termos.add(cat.name.toLowerCase());
      termos.addAll(cat.synonyms.map((s) => s.toLowerCase()));
    }
  }
  return termos.toList();
}