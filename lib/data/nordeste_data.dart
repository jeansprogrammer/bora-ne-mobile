/// Estados e cidades do Nordeste para seleção de endereço
const Map<String, List<String>> cidadesPorEstado = {
  'AL': [
    'Maceió', 'Arapiraca', 'Rio Largo', 'Palmeira dos Índios', 'União dos Palmares',
    'Penedo', 'São Miguel dos Campos', 'Delmiro Gouveia', 'Coruripe', 'Santana do Ipanema',
    'Marechal Deodoro', 'Batalha', 'Murici', 'Viçosa', 'Piranhas',
  ],
  'BA': [
    'Salvador', 'Feira de Santana', 'Vitória da Conquista', 'Camaçari', 'Itabuna',
    'Juazeiro', 'Lauro de Freitas', 'Ilhéus', 'Jequié', 'Teixeira de Freitas',
    'Barreiras', 'Alagoinhas', 'Porto Seguro', 'Simões Filho', 'Conquista',
    'Paulo Afonso', 'Eunápolis', 'Santo Antônio de Jesus', 'Valença', 'Jacobina',
  ],
  'CE': [
    'Fortaleza', 'Caucaia', 'Juazeiro do Norte', 'Maracanaú', 'Sobral',
    'Crato', 'Itapipoca', 'Maranguape', 'Iguatu', 'Quixadá',
    'Pacatuba', 'Canindé', 'Aquiraz', 'Crateús', 'Russas',
    'Horizonte', 'Pacajus', 'Tianguá', 'Cascavel', 'Limoeiro do Norte',
  ],
  'MA': [
    'São Luís', 'Imperatriz', 'São José de Ribamar', 'Timon', 'Caxias',
    'Codó', 'Paço do Lumiar', 'Açailândia', 'Bacabal', 'Balsas',
    'Santa Inês', 'Chapadinha', 'Pinheiro', 'Barra do Corda', 'Pedreiras',
    'São Mateus do Maranhão', 'Viana', 'Coroatá', 'Presidente Dutra', 'Grajaú',
  ],
  'PB': [
    'João Pessoa', 'Campina Grande', 'Santa Rita', 'Patos', 'Bayeux',
    'Sousa', 'Cajazeiras', 'Cabedelo', 'Guarabira', 'Sapé',
    'Monteiro', 'Pombal', 'Mamanguape', 'Esperança', 'Lagoa Seca',
    'Queimadas', 'Itabaiana', 'Solânea', 'Areia', 'Catolé do Rocha',
  ],
  'PE': [
    'Recife', 'Caruaru', 'Olinda', 'Garanhuns', 'Petrolina',
    'Paulista', 'Camarajibe', 'Jaboatão dos Guararapes', 'Cabo de Santo Agostinho',
    'Vitória de Santo Antão', 'Igarassu', 'São Lourenço da Mata', 'Abreu e Lima',
    'Araripina', 'Serra Talhada', 'Salgueiro', 'Belo Jardim', 'Santa Cruz do Capibaribe',
    'Bezerros', 'Surubim',
  ],
  'PI': [
    'Teresina', 'Parnaíba', 'Picos', 'Piripiri', 'Floriano',
    'Campo Maior', 'Barras', 'Oeiras', 'Esperantina', 'São Raimundo Nonato',
    'União', 'Altos', 'José de Freitas', 'Luís Correia', 'Batalha',
    'Corrente', 'Bom Jesus', 'Água Branca', 'Valença do Piauí', 'Pedro II',
  ],
  'RN': [
    'Natal', 'Mossoró', 'Parnamirim', 'São Gonçalo do Amarante', 'Macaíba',
    'Ceará-Mirim', 'Caicó', 'Assú', 'Currais Novos', 'João Câmara',
    'Nova Cruz', 'Santa Cruz', 'Apodi', 'Touros', 'São José de Mipibu',
    'Extremoz', 'Parelhas', 'Areia Branca', 'Canguaretama', 'Pau dos Ferros',
  ],
  'SE': [
    'Aracaju', 'Nossa Senhora do Socorro', 'Lagarto', 'Itabaiana', 'São Cristóvão',
    'Estância', 'Tobias Barreto', 'Nossa Senhora da Glória', 'Simão Dias', 'Propriá',
    'Poço Verde', 'Itabaianinha', 'Barra dos Coqueiros', 'Canindé de São Francisco',
    'Carmópolis', 'Aquidabã', 'Gararu', 'Pedrinhas', 'Neópolis', 'Japoatã',
  ],
};

const Map<String, String> nomeEstados = {
  'AL': 'Alagoas',
  'BA': 'Bahia',
  'CE': 'Ceará',
  'MA': 'Maranhão',
  'PB': 'Paraíba',
  'PE': 'Pernambuco',
  'PI': 'Piauí',
  'RN': 'Rio Grande do Norte',
  'SE': 'Sergipe',
};

List<String> get siglaEstados => cidadesPorEstado.keys.toList()..sort();

List<String> cidadesDoEstado(String uf) =>
    cidadesPorEstado[uf] ?? [];