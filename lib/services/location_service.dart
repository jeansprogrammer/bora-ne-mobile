import 'package:geolocator/geolocator.dart';

class LocationService {
  // Solicita permissão e retorna a posição atual do dispositivo, se concedido.
  Future<Position?> obterPosicaoAtual() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // Verifica se os serviços de localização estão ativados.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Serviço de localização desativado.');
        return null;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Permissão de localização negada pelo usuário.');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Permissão de localização permanentemente negada.');
        return null;
      }

      // Obtém a posição atual
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Erro ao obter posição de localização: $e');
      return null;
    }
  }
}
