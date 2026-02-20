import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../services/product_service.dart';
import 'order_tracking_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<dynamic> cartItems = [];
  double total = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCart();
  }

  Future<void> fetchCart() async {
    final userId = AuthService.currentUser;

    if (userId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("http://localhost:8003/cart?user_id=$userId"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          cartItems = data;
          total = cartItems.fold(
            0,
            (sum, item) => sum + ((item['price'] ?? 0) * (item['quantity'] ?? 1)),
          );
          isLoading = false;
        });
      } else {
        print('fetchCart failed status=${response.statusCode} body=${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load cart: ${response.statusCode}')),
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e, st) {
      print('fetchCart exception: $e');
      print(st);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error fetching cart: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> placeOrder() async {
    final userId = AuthService.currentUser;

    if (userId == null || cartItems.isEmpty) {
      return;
    }

    final response = await http.post(
      Uri.parse(
        "http://localhost:8003/order/create?user_id=$userId",
      ),
    );

    // Backend returns 201 on success; accept any 2xx.
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final orderId = data['order_id'];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderTrackingScreen(orderId: orderId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create order')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(child: Text("Cart is empty"))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];

                          return ListTile(
                            title: Text(item['name'] ?? 'Product'),
                            subtitle: Text(
                              "₹${item['price'] ?? 0} x ${item['quantity'] ?? 1}",
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                final userId = AuthService.currentUser;
                                if (userId == null) return;

                                final productId = item['product_id'];
                                try {
                                  await ProductService.removeFromCart(
                                    userId: userId,
                                    productId: productId,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Removed from cart')),
                                  );
                                  await fetchCart();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Failed to remove')),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            "Total: ₹$total",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                await placeOrder();
                              },
                              child: const Text("Place Order"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
