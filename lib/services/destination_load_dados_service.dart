import 'destination_service.dart';
import '../models/destination_model.dart';
import '../data/destination_seeds.dart';

class CargaDadosService {
  final DestinationService _DestinationService = DestinationService();

  Future<void> executarCarga() async {
    print("🚀 Iniciando importação de ${DestinationsIniciais.length} Destinos...");

    for (var item in DestinationsIniciais) {
      try {
        // O fromMap já deve estar atualizado no seu DestinationModel
        // para ler o campo 'cidade' do seu JSON.
        DestinationModel Destination = DestinationModel.fromMap(item);
        
        await _DestinationService.addDestination(Destination);
        print("✅ Sucesso: ${Destination.name} (${Destination.city})");
      } catch (e) {
        // Se der erro aqui, verifique se o 'cidade' no JSON está escrito 
        // exatamente igual ao que o fromMap espera.
        print("❌ Falha ao inserir ${item['nome']}: $e");
      }
    }
    print("🏁 Importação concluída!");
  }
}