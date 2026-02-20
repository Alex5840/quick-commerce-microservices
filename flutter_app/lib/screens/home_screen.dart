import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import 'cart_screen.dart';
import '../services/product_service.dart';
import '../services/cart_service.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List products = [];
  int cartCount = 0;

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchCartCount();
  }

  Future<void> fetchCartCount() async {
    final userId = AuthService.currentUser;
    if (userId == null) return;
    final c = await CartService.fetchCartCount(userId);
    setState(() {
      cartCount = c;
    });
  }

  Future<void> fetchProducts() async {
    final response =
        await http.get(Uri.parse("http://localhost:8002/products"));

    if (response.statusCode == 200) {
      setState(() {
        products = jsonDecode(response.body);
      });
    }
  }

 Future<void> addToCart(String productId) async {
  if (AuthService.currentUser==null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("User not logged in")),
    );
    return;
  }

  final response = await http.post(
    Uri.parse(
        "http://localhost:8003/cart/add?user_id=${AuthService.currentUser}&product_id=$productId&quantity=1"),
  );

  print("ADD CART STATUS: ${response.statusCode}");
  print("ADD CART BODY: ${response.body}");

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Added to cart")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to add")),
    );
  }
}





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  onPressed: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CartScreen()));
                    // refresh count when returning
                    fetchCartCount();
                  },
                  icon: const Icon(Icons.shopping_cart),
                ),
                if (cartCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        cartCount.toString(),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                    ),
                  )
              ],
            ),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];

          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              title: Text(product["name"]),
              subtitle: Text("₹ ${product["price"]}"),
              trailing: ElevatedButton(
               onPressed: () async {
  if (AuthService.currentUser == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User not logged in")),
    );
    return;
  }

  print("USER ID: ${AuthService.currentUser}");

  try {
    await ProductService.addToCart(
      userId: AuthService.currentUser!,
      productId: product["id"],
      quantity: 1,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Added to cart")),
    );
    // update badge count immediately
    await fetchCartCount();
  } catch (e) {
    print('addToCart failed: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to add to cart: $e')),
    );
  }
},

                child: const Text("Add"),
              ),
            ),
          );
        },
      ),
    );
  }
}
