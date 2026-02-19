import 'package:flutter/material.dart';
import '../models/product_model.dart';

class CartScreen extends StatelessWidget {
  final List<Product> cart;

  const CartScreen({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    double total = 0;
    for (var item in cart) {
      total += item.price;
    }

    return Scaffold(
      appBar:
          AppBar(title: const Text("My Cart")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(cart[index].name),
                  subtitle:
                      Text("₹ ${cart[index].price}"),
                );
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.all(16),
            child: Text(
              "Total: ₹ $total",
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
