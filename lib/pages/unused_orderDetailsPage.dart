import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Order {
  final String userId;
  final String deliveryLocation;
  final String quantity;
  final String productType;
  final DateTime orderDate;
  final String invoice;
  final String status;
  final DateTime dueDate;

  Order({
    required this.userId,
    required this.deliveryLocation,
    required this.quantity,
    required this.productType,
    required this.orderDate,
    required this.invoice,
    required this.status,
    required this.dueDate,
  });

  factory Order.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Order(
      userId: data['userId'] ?? '',
      deliveryLocation: data['deliveryLocation'] ?? '',
      quantity: data['quantity'] ?? '',
      productType: data['productType'] ?? '',
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      invoice: data['invoice'] ?? '',
      status: data['status'] ?? '',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
    );
  }
}

class OrderDetailsPage extends StatelessWidget {
  final Order order;

  OrderDetailsPage({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product: ${order.productType}'),
            Text('Delivery Location: ${order.deliveryLocation}'),
            Text('Quantity: ${order.quantity}'),
            Text('Order Placed Date: ${order.orderDate.toString()}'),
            Text('Invoice: ${order.invoice}'),
            Text('Status: ${order.status}'),
            Text('Due Date: ${order.dueDate}'),
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
              final order = Order.fromDocumentSnapshot(orders[index]);

              return Card(
                margin: const EdgeInsets.all(10.0),
                child: ListTile(
                  title: Text('Product: ${order.productType}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Delivery Location: ${order.deliveryLocation}'),
                      Text('Quantity: ${order.quantity}'),
                      Text('Order Placed Date: ${order.orderDate.toString()}'),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailsPage(order: order),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
