import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/route_creation_controller.dart';
import 'controllers/destino_controller.dart'; // Importe o novo controller
import 'models/destino_model.dart';          // Importe o model para o teste
import 'view/pages/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- BLOCO DO TESTE DE FOGO ---
  // Executamos o teste logo após a inicialização
  await realizarTesteDeFogo();
  // ------------------------------

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RouteCreationController(),
        ),
        // Adicionamos o DestinoController aqui para o app todo ter acesso
        ChangeNotifierProvider(
          create: (_) => DestinoController(),
        ),
      ],
      child: const BoraNE(),
    ),
  );
}

/// Função de suporte para o teste
Future<void> realizarTesteDeFogo() async {
  print("🔥 Iniciando Teste de Fogo no Firestore...");
  try {
    // Criamos um destino fake para testar a gravação
    final testeDestino = DestinoModel(
      nome: "Praia de Boa Viagem",
      categorias: ["lazer", "gastronomia"],
      descricao: "Teste automático de conexão do BoraNE",
      imagem: "https://link-da-imagem.com/foto.jpg",
      local: "Recife, PE",
    );

    // Chamamos o controller diretamente para testar o fluxo completo
    final controller = DestinoController();
    await controller.adicionarNovoDestino(testeDestino);
    
    print("✅ Sucesso! O documento foi enviado para a coleção 'destinos'.");
  } catch (e) {
    print("❌ Erro no Teste de Fogo: $e");
  }
}

class BoraNE extends StatelessWidget {
  const BoraNE({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bora NE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
      ),
      home: const SplashScreen(),
    );
  }
}