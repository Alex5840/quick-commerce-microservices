import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/order_confirmation_screen.dart';
import 'screens/order_tracking_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quick Commerce App',

      initialRoute: '/login',

      // 🔥 Static routes (no arguments)
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/cart': (context) => const CartScreen(),
        '/order-confirmation': (context) =>
            const OrderConfirmationScreen(),
      },

      // 🔥 Dynamic route handler (for order tracking)
      onGenerateRoute: (settings) {
        if (settings.name == '/order-tracking') {
          final orderId = settings.arguments as String;

          return MaterialPageRoute(
            builder: (context) =>
                OrderTrackingScreen(orderId: orderId),
          );
        }

        return null;
      },
    );
  }
}
