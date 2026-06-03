import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/route_creation_controller.dart';
import 'controllers/destination_controller.dart'; // Importe o novo controller
import 'controllers/auth_controller.dart';
import 'view/pages/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'controllers/destination_creation_controller.dart';
import 'view/pages/onboard1.dart';
import 'view/pages/onboarding.dart';
//import 'services/carga_dados_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // EXECUTE APENAS UMA VEZ E DEPOIS COMENTE A LINHA ABAIXO
  //await CargaDadosService().executarCarga();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RouteCreationController(),
        ),
        // Adicionamos o DestinationController aqui para o app todo ter acesso
        /*ChangeNotifierProvider(
          create: (_) => DestinationController(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthController(),
        ),
        ),*/
        ChangeNotifierProvider(create: (_) => DestinationCreationController()),
      ],
      child: const BoraNE(),
    ),
  );
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