import 'package:flutter/material.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String status;

  const OrderTrackingScreen({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order Tracking")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_shipping,
                size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              "Current Status",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              status,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
