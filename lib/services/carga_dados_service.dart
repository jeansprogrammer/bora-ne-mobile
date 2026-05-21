import 'destino_service.dart';
import '../models/destino_model.dart';
import '../data/destinos_seeds.dart';

class CargaDadosService {
  final DestinoService _destinoService = DestinoService();

  Future<void> executarCarga() async {
    print("🚀 Iniciando importação de ${destinosIniciais.length} destinos...");

    for (var item in destinosIniciais) {
      try {
        // O fromMap já deve estar atualizado no seu DestinoModel
        // para ler o campo 'cidade' do seu JSON.
        DestinoModel destino = DestinoModel.fromMap(item);
        
        await _destinoService.addDestino(destino);
        print("✅ Sucesso: ${destino.nome} (${destino.cidade})");
      } catch (e) {
        // Se der erro aqui, verifique se o 'cidade' no JSON está escrito 
        // exatamente igual ao que o fromMap espera.
        print("❌ Falha ao inserir ${item['nome']}: $e");
      }
    }
    print("🏁 Importação concluída!");
  }
}