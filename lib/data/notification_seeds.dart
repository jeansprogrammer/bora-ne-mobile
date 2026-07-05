/// Gera notificações de exemplo com datas relativas a "agora", para que
/// apareçam corretamente agrupadas em "Hoje", "Ontem" etc. na tela de
/// notificações.
List<Map<String, dynamic>> gerarNotificacoesIniciais() {
  final agora = DateTime.now();

  return [
    {
      'title': 'Roteiro salvo',
      'description': 'Praia de Maracaípe foi adicionado aos seus favoritos.',
      'type': 'favorito',
      'date': agora.subtract(const Duration(hours: 1)),
      'read': false,
    },
    {
      'title': 'Novidade no destino',
      'description': 'Novas dicas de passeios em Porto de Galinhas para você!',
      'type': 'destino',
      'date': agora.subtract(const Duration(hours: 3)),
      'read': false,
    },
    {
      'title': 'Roteiro atualizado',
      'description':
          'Seu roteiro "Fim de semana em Olinda" foi atualizado com novas atrações.',
      'type': 'roteiro',
      'date': agora.subtract(const Duration(hours: 5)),
      'read': true,
    },
    {
      'title': 'Promoção especial',
      'description': 'Descontos exclusivos em passeios selecionados. Aproveite!',
      'type': 'promocao',
      'date': agora.subtract(const Duration(days: 1, hours: 2)),
      'read': true,
    },
    {
      'title': 'Avalie sua experiência',
      'description': 'Como foi seu passeio na Cachoeira de Bonito? Conte pra gente!',
      'type': 'avaliacao',
      'date': agora.subtract(const Duration(days: 1, hours: 6)),
      'read': false,
    },
    {
      'title': 'Dica boraNE',
      'description':
          'Não esqueça de levar protetor solar e água para curtir o melhor do dia!',
      'type': 'dica',
      'date': agora.subtract(const Duration(days: 2)),
      'read': true,
    },
    {
      'title': 'Roteiro salvo',
      'description': 'Cachoeira do Paty foi adicionado aos seus favoritos.',
      'type': 'favorito',
      'date': agora.subtract(const Duration(days: 3)),
      'read': true,
    },
    {
      'title': 'Novo destino na região',
      'description': 'Um novo ponto turístico foi cadastrado perto de você.',
      'type': 'destino',
      'date': agora.subtract(const Duration(days: 4)),
      'read': true,
    },
    {
      'title': 'Promoção especial',
      'description': 'Última chance: descontos em rotas para o litoral sul.',
      'type': 'promocao',
      'date': agora.subtract(const Duration(days: 6)),
      'read': true,
    },
    {
      'title': 'Bem-vindo ao boraNE',
      'description': 'Explore destinos, monte roteiros e favorite seus lugares preferidos.',
      'type': 'sistema',
      'date': agora.subtract(const Duration(days: 8)),
      'read': true,
    },
  ];
}
