import 'package:boranemobile/view/pages/login_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const BoraNE());
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
      home: const LoginScreen(),
      
    );
  }
}
