import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/route_creation_controller.dart';
import 'view/pages/splash.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RouteCreationController(),
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

      routes: {
        '/login1': (context) => const Login1Screen(),
        '/login2': (context) => const Login2Screen(),
      },
    );
  }
}
