import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen(
      {super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState
    extends State<OrderTrackingScreen> {
  String status = "Loading...";

  final String deliveryBase =
      "http://localhost:8004/order/";

  // Status flow shown in UI
  final List<String> statuses = [
    'PLACED',
    'PACKED',
    'OUT_FOR_DELIVERY',
    'DELIVERED'
  ];

  final Map<String, String> labels = {
    'PLACED': 'Placed',
    'PACKED': 'Packed',
    'OUT_FOR_DELIVERY': 'Out for delivery',
    'DELIVERED': 'Delivered'
  };

  String currentStatus = '';

  @override
  void initState() {
    super.initState();
    fetchStatus();
  }

  Future<void> fetchStatus() async {
    final response = await http.get(
      Uri.parse(
          "$deliveryBase${widget.orderId}/status"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        status = data["status"];
        currentStatus = data["status"];
      });
    } else {
      setState(() {
        status = "Unable to fetch status";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("Order Tracking")),
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_shipping,
                size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              "Current Status",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            // Status stepper
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: statuses.map((s) {
                  final isActive = currentStatus == s;
                  final isDone = statuses.indexOf(s) <=
                      (currentStatus.isEmpty
                          ? -1
                          : statuses.indexOf(currentStatus));

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: isDone
                              ? Colors.green
                              : (isActive ? Colors.blue : Colors.grey[300]),
                          child: Icon(
                            isDone ? Icons.check : Icons.local_shipping,
                            color: isDone || isActive
                                ? Colors.white
                                : Colors.black54,
                            size: 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(labels[s] ?? s,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              currentStatus.isEmpty ? status : currentStatus,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchStatus,
              child: const Text("Refresh"),
            )
          ],
        ),
      ),
    );
  }
}
