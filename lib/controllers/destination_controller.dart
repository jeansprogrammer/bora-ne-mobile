import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import '../services/destination_service.dart';

class DestinationController extends ChangeNotifier {
  // Instância do serviço que criamos anteriormente
  final DestinationService _DestinationService = DestinationService();

  // Lista privada que armazenará os Destinos vindos do banco
  List<DestinationModel> _Destinations = [];

  // Getter para que a View possa ler os Destinos, mas não alterá-los diretamente
  List<DestinationModel> get Destinations => _Destinations;

  // Variável para controlar o estado de carregamento (loading)
  bool _estaCarregando = false;
  bool get estaCarregando => _estaCarregando;

  // FUNÇÃO PRINCIPAL: Busca os Destinos e atualiza a lista
  void carregarDestinations() {
    _estaCarregando = true;
    notifyListeners(); // Avisa a View para mostrar um ícone de carregamento

    // Chamamos o Stream do Service
    _DestinationService.getDestinations().listen((listaDeDestinations) {
      _Destinations = listaDeDestinations;
      _estaCarregando = false;
      
      // O notifyListeners() é o "aviso" que você mencionou: 
      // Ele diz para a View: "Os dados chegaram, redesenhe a tela!"
      notifyListeners();
    }, onError: (erro) {
      _estaCarregando = false;
      print("Erro no Controller ao carregar Destinos: $erro");
      notifyListeners();
    });
  }

  // Função para adicionar um novo Destino através da interface
  Future<void> adicionarNovoDestination(DestinationModel novoDestination) async {
    try {
      await _DestinationService.addDestination(novoDestination);
      // Não precisamos atualizar a lista manualmente aqui, 
      // pois o Stream no carregarDestinations() fará isso automaticamente!
    } catch (e) {
      print("Erro ao adicionar Destino: $e");
    }
  }
}