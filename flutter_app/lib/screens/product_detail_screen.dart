import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen(
      {super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(product.name)),
      body: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Image.network(
              product.imageUrl,
              height: 250,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Text(
              product.name,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(product.description),
            const SizedBox(height: 10),
            Text(
              "₹ ${product.price}",
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
