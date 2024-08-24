import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'unused_orderDetailsPage.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final _deliveryLocationController = TextEditingController();
  final _quantityController = TextEditingController();
  String _productType = 'Diesel';
  final _productTypes = ['LPG', 'Gasoline', 'Diesel'];

  Future<void> _placeOrder() async {
    final userUid = _auth.currentUser!.uid; // Get the current user's UID
    dynamic creditDays = 1; // Default value of 1 day
    String userName = ''; // Variable to store the user's name

    try {
      final consumerDoc =
          await _firestore.collection('consumers').doc(userUid).get();
      creditDays = consumerDoc.get('creditDays');
      userName = consumerDoc.get('name');
    } catch (e) {
      print('Error fetching consumer creditDays/name: $e');
    }

    // Get the current order count for this user to generate a unique sequential number
    final orderCount = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: userUid)
        .get()
        .then((snapshot) => snapshot.size);

    final newOrderId =
        '${userUid}_${orderCount + 1}'; // Combine user ID and sequential number

    try {
      await _firestore.collection('orders').doc(newOrderId).set({
        'userId': userUid,
        'name': userName,
        'deliveryLocation': _deliveryLocationController.text.trim(),
        'quantity': _quantityController.text.trim(),
        'productType': _productType,
        'orderDate': DateTime.now(),
        'invoice': 'N/A',
        'status': 'Pending',
        'creditDays': creditDays,
        'dueDate': DateTime.fromMicrosecondsSinceEpoch(0),
        //'dueDate': 'N/A',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );

      // Clear the form fields after success
      _deliveryLocationController.clear();
      _quantityController.clear();
    } catch (e) {
      print('Error placing order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to place order. Please try again.')),
      );
    }
  }

  Future<Map<String, dynamic>> _fetchFuelPrices() async {
    try {
      final snapshot =
          await _firestore.collection('fuelPrice').doc('price').get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        return {'diesel': 0.0, 'gasoline': 0.0, 'lpg': 0.0};
      }
    } catch (e) {
      print('Error fetching fuel prices: $e');
      return {
        'diesel': 0.0,
        'gasoline': 0.0,
        'lpg': 0.0
      }; // Default values on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Order'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            DropdownButton(
              value: _productType,
              items: _productTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _productType = value!;
                });
              },
              hint: const Text('Select Product Type'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _deliveryLocationController,
              decoration: const InputDecoration(
                labelText: 'Delivery Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            /*TextField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                 
                border: OutlineInputBorder(),
              ),*/
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _placeOrder,
              child: const Text('Place Order'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrdersHistoryPage()),
                );
              },
              child: const Text('View Order History'),
            ),
            const SizedBox(height: 16.0),
            // Fetch and display fuel prices
            FutureBuilder<Map<String, dynamic>>(
              future: _fetchFuelPrices(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error loading fuel prices: ${snapshot.error}');
                } else {
                  final fuelPrices = snapshot.data!;
                  return Column(
                    children: [
                      Text('Diesel Price: \₵${fuelPrices['diesel']}'),
                      Text('Gasoline Price: \₵${fuelPrices['gasoline']}'),
                      Text('LPG Price: \₵${fuelPrices['lpg']}'),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class OrdersHistoryPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final userUid = _auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: StreamBuilder(
        stream: _firestore
            .collection('orders')
            .where('userId', isEqualTo: userUid)
            .orderBy('orderDate', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final deliveryLocation = order['deliveryLocation'];
              final quantity = order['quantity'];
              final productType = order['productType'];
              final orderDate = (order['orderDate'] as Timestamp).toDate();
              final invoice = order['invoice'];
              final status = order['status'];
              final dueDate = order['dueDate'];
              //final dueDate = order['dueDate'] ?? DateTime.fromMicrosecondsSinceEpoch(0);

              return Card(
                margin: const EdgeInsets.all(10.0),
                child: ListTile(
                  title: Text('Product: $productType'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quantity: $quantity'),
                      Text('Invoice: $invoice'),
                      Text('Delivery Location: $deliveryLocation'),
                      Text('Order Placed: ${orderDate.toString()}'),
                      Text('Status: $status'),
                      //Text('Quantity: $quantity'),
                      //Text('Order Placed: ${orderDate.toString()}'),
                      //Text('Invoice: $invoice'),
                      //Text('Status: $status'),
                      //Text('Due Date: $dueDate'),
                    ],
                  ),
                  /*onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailsPage(order: order),
                      ),
                    );
                  },*/
                ),
              );
            },
          );
        },
      ),
    );
  }
}
