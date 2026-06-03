import 'package:boranemobile/models/profile_model.dart';
import 'package:boranemobile/services/profile_service.dart';

class ProfileController {
  // Instancia o serviço criado para esta regra de negócio
  final ProfileLoadDadosService _loadDadosService = ProfileLoadDadosService();
  
  UserModel? currentUser;
  bool isLoading = true;

  // Função disparada pela View para inicializar a tela
  Future<void> carregarPerfil(Function updateState) async {
    try {
      isLoading = true;
      updateState(); // Ativa o setState na View para exibir o loading

      // Solicita os dados estruturados ao Service
      currentUser = await _loadDadosService.fetchUserData();
    } catch (e) {
      print("Erro ao processar dados do perfil: $e");
    } finally {
      isLoading = false;
      updateState(); // Desativa o loading e exibe os dados reais na View
    }
  }

  void navegarParaEdicao() {
    print("Abrir tela de edição de perfil...");
  }

  Future<void> executarLogout() async {
    await _loadDadosService.logoutAccount();
  }
}