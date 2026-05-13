import 'package:flutter/material.dart';
import '../models/destino_model.dart';
import '../services/firestore_service.dart';

class DestinoController extends ChangeNotifier {
  // Instância do serviço que criamos anteriormente
  final FirestoreService _firestoreService = FirestoreService();

  // Lista privada que armazenará os destinos vindos do banco
  List<DestinoModel> _destinos = [];

  // Getter para que a View possa ler os destinos, mas não alterá-los diretamente
  List<DestinoModel> get destinos => _destinos;

  // Variável para controlar o estado de carregamento (loading)
  bool _estaCarregando = false;
  bool get estaCarregando => _estaCarregando;

  // FUNÇÃO PRINCIPAL: Busca os destinos e atualiza a lista
  void carregarDestinos() {
    _estaCarregando = true;
    notifyListeners(); // Avisa a View para mostrar um ícone de carregamento

    // Chamamos o Stream do Service
    _firestoreService.getDestinos().listen((listaDeDestinos) {
      _destinos = listaDeDestinos;
      _estaCarregando = false;
      
      // O notifyListeners() é o "aviso" que você mencionou: 
      // Ele diz para a View: "Os dados chegaram, redesenhe a tela!"
      notifyListeners();
    }, onError: (erro) {
      _estaCarregando = false;
      print("Erro no Controller ao carregar destinos: $erro");
      notifyListeners();
    });
  }

  // Função para adicionar um novo destino através da interface
  Future<void> adicionarNovoDestino(DestinoModel novoDestino) async {
    try {
      await _firestoreService.addDestino(novoDestino);
      // Não precisamos atualizar a lista manualmente aqui, 
      // pois o Stream no carregarDestinos() fará isso automaticamente!
    } catch (e) {
      print("Erro ao adicionar destino: $e");
    }
  }
}