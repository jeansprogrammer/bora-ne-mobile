import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'geoapify_service.dart';

// Singleton: mantém a cidade ativa (detectada por GPS ou escolhida
// manualmente) em um único lugar, para que a Home e o Editar Perfil
// fiquem sempre sincronizados entre si e com o Firestore.
class LocationService extends ChangeNotifier {
  LocationService._internal();
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;

  static const _kCidadeDetectadaPref = 'home_cidade_detectada';
  static const _kCidadeManualPref = 'home_cidade_manual';

  String? cidadeDetectada;
  String? cidadeManual;
  bool estaCarregando = false;
  bool _carregado = false;

  String? get cidadeAtiva => cidadeManual ?? cidadeDetectada;

  // Solicita permissão e retorna a posição atual do dispositivo, se concedido.
  Future<Position?> obterPosicaoAtual() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
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

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Erro ao obter posição de localização: $e');
      return null;
    }
  }

  // Carrega a cidade salva localmente (ou detecta via GPS na primeira vez).
  // Seguro para chamar múltiplas vezes: só executa de fato uma vez por sessão.
  Future<void> init() async {
    if (_carregado) return;
    _carregado = true;

    final prefs = await SharedPreferences.getInstance();
    cidadeDetectada = prefs.getString(_kCidadeDetectadaPref);
    cidadeManual = prefs.getString(_kCidadeManualPref);

    if (cidadeDetectada == null && cidadeManual == null) {
      await detectarLocalizacao();
    } else {
      notifyListeners();
    }
  }

  // Só deve ser chamada explicitamente (primeira vez sem cidade salva, ou
  // quando o usuário toca em "Usar minha localização").
  Future<void> detectarLocalizacao() async {
    estaCarregando = true;
    notifyListeners();
    try {
      final pos = await obterPosicaoAtual();
      if (pos != null) {
        final cidade = await GeoapifyService()
            .obterCidadePorCoordenadas(pos.latitude, pos.longitude);
        if (cidade != null) {
          cidadeDetectada = cidade;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_kCidadeDetectadaPref, cidade);
        }
      }
    } catch (e) {
      debugPrint('Erro ao obter localização: $e');
    } finally {
      estaCarregando = false;
      notifyListeners();
    }
  }

  // Usuário escolheu uma cidade manualmente (na Home ou no Editar Perfil).
  Future<void> selecionarCidadeManual(String cidade) async {
    cidadeManual = cidade;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCidadeManualPref, cidade);
    await _sincronizarComFirestore(cidade);
  }

  // Usuário tocou em "Usar minha localização": limpa a escolha manual e
  // força uma nova detecção por GPS.
  Future<void> usarMinhaLocalizacao() async {
    cidadeManual = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCidadeManualPref);
    await detectarLocalizacao();

    if (cidadeDetectada != null) {
      await _sincronizarComFirestore(cidadeDetectada!);
    }
  }

  Future<void> _sincronizarComFirestore(String cidade) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'city': cidade}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Erro ao sincronizar cidade com o Firestore: $e');
    }
  }
}
