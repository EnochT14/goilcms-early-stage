import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    final userUid = _auth.currentUser!.uid;

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
        'deliveryLocation': _deliveryLocationController.text.trim(),
        'quantity': _quantityController.text.trim(),
        'productType': _productType,
        'orderDate': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );

      // Clear the form fields
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
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
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

              return Card(
                margin: const EdgeInsets.all(10.0),
                child: ListTile(
                  title: Text('Product: $productType'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Delivery Location: $deliveryLocation'),
                      Text('Quantity: $quantity'),
                      Text('Order Date: ${orderDate.toString()}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
