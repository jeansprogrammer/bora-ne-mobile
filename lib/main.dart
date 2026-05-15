import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/route_creation_controller.dart';
import 'controllers/destino_controller.dart'; // Importe o novo controller
import 'view/pages/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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