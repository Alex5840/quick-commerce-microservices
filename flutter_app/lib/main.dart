import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const QuickCommerceApp());
}

class QuickCommerceApp extends StatelessWidget {
  const QuickCommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Quick Commerce",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
