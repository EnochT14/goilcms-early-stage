import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class AdminPendingOrdersPage extends StatefulWidget {
  @override
  _AdminPendingOrdersPageState createState() => _AdminPendingOrdersPageState();
}

class _AdminPendingOrdersPageState extends State<AdminPendingOrdersPage> {
  final TextEditingController _searchController = TextEditingController();
  late String _searchQuery;
  late FirebaseFirestore _firestore;
  late FirebaseAuth _auth;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;
    _searchQuery = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Pending Orders'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
              decoration: InputDecoration(
                labelText: 'Search by name or invoice',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _buildOrderList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('orders')
          .where('status',
              whereIn: ['Pending', 'Processed', 'In Transit', 'Delivered'])
          .orderBy('orderDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final orders = snapshot.data!.docs;

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return FutureBuilder<String>(
              future: _getConsumerName(order['userId']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }

                final name = snapshot.data ?? 'N/A';
                final invoice = order['invoice'];
                final status = order['status'];
                final orderDate = (order['orderDate'] as Timestamp).toDate();

                if (_shouldIncludeOrder(name, invoice)) {
                  return _buildOrderCard(
                      order, name, invoice, status, orderDate);
                } else {
                  return const SizedBox.shrink();
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildOrderCard(
    DocumentSnapshot order,
    String name,
    String invoice,
    String status,
    DateTime orderDate,
  ) {
    return Card(
      margin: const EdgeInsets.all(10.0),
      child: ListTile(
        title: Text('Consumer: $name'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Invoice: $invoice'),
            Text('Status: $status'),
            Text('Order Date: ${orderDate.toString()}'),
          ],
        ),
        onTap: () {
          _handleOrderTap(order);
        },
      ),
    );
  }

  Future<String> _getConsumerName(String userId) async {
    final userUid = userId.split('_')[0];

    try {
      final consumerDocument =
          await _firestore.collection('consumers').doc(userUid).get();
      if (consumerDocument.exists) {
        return consumerDocument['name'];
      } else {
        return 'N/A';
      }
    } catch (error) {
      print('Error fetching name: $error');
      return 'N/A';
    }
  }

  bool _shouldIncludeOrder(String name, String invoice) {
    final lowerQuery = _searchQuery.toLowerCase();
    return name.toLowerCase().contains(lowerQuery) ||
        invoice.toLowerCase().contains(lowerQuery);
  }

  void _handleOrderTap(DocumentSnapshot order) {
    // Check if the logged-in user is an admin
    final currentUserUid = _auth.currentUser?.uid;
    if (currentUserUid != null) {
      _firestore
          .collection('admins')
          .doc(currentUserUid)
          .get()
          .then((adminSnapshot) {
        if (adminSnapshot.exists) {
          // If the user is an admin, navigate to the order details/edit page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsEditPage(order: order),
            ),
          );
        } else {
          // If the user is not an admin, show an error
          _showErrorDialog();
        }
      });
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Access Denied'),
          content: Text('You do not have permission to edit orders.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class OrderDetailsEditPage extends StatefulWidget {
  final DocumentSnapshot order;

  const OrderDetailsEditPage({Key? key, required this.order}) : super(key: key);

  @override
  _OrderDetailsEditPageState createState() => _OrderDetailsEditPageState();
}

class _OrderDetailsEditPageState extends State<OrderDetailsEditPage> {
  late TextEditingController _statusController;
  late TextEditingController _invoiceController;
  late TextEditingController _quantityController;
  late FirebaseFirestore _firestore;

  @override
  void initState() {
    super.initState();
    _statusController = TextEditingController(text: widget.order['status']);
    _invoiceController = TextEditingController(text: widget.order['invoice']);
    _quantityController = TextEditingController(text: widget.order['quantity']);
    _firestore = FirebaseFirestore.instance;
  }

  void _deleteOrder() {
    if (!mounted) return; // Check if the widget is still mounted
    final orderId = widget.order.id;
    _firestore.collection('orders').doc(orderId).delete().then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order deleted successfully!')),
      );
    }).catchError((error) {
      print('Error deleting order: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete order. Please try again.')),
      );
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Order'),
          content: Text('Are you sure you want to delete this order?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteOrder();
                Navigator.pop(context);
                //Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Order'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Consumer: ${widget.order['name']}'),
            Text('Invoice: ${widget.order['invoice']}'),
            Text('Status:'),
            DropdownButton<String>(
              value: _statusController.text,
              items: [
                'Pending',
                'Processed',
                'In Transit',
                'Delivered',
                'Completed'
              ]
                  .map((status) => DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _statusController.text = value!;
                });
              },
            ),
            Text('Quantity:'),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
            ),
            Text('Invoice:'),
            TextField(
              controller: _invoiceController,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Save changes to Firestore
                _saveChanges();
              },
              child: Text('Save Changes'),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // Use a distinctive color for deletion
              ),
              onPressed: () {
                _showDeleteConfirmationDialog(context);
              },
              child: Text('Delete Order'),
            ),
          ],
        ),
      ),
    );
  }

/*void _saveChanges() {
  final orderId = widget.order.id;
  final updatedData = {
    'status': _statusController.text,
    'invoice': _invoiceController.text,
    'quantity': _quantityController.text,
  };

  try {
    _firestore.collection('orders').doc(orderId).update(updatedData).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order updated successfully!')),
      );
      Navigator.pop(context);
    }).catchError((error) {
      print('Error updating order: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update order. Please try again.')),
      );
    });

    if (_statusController.text == 'In Transit' || _statusController.text == 'Delivered') {
      _updateDueDate(orderId);
    }
  } catch (error) {
    print('Unexpected error: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An unexpected error occurred. Please try again later.')),
    );
  }
}*/

  void _saveChanges() {
    final orderId = widget.order.id;
    final updatedData = {
      'status': _statusController.text,
      'invoice': _invoiceController.text,
      'quantity': _quantityController.text,
    };

    try {
      _firestore
          .collection('orders')
          .doc(orderId)
          .update(updatedData)
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order updated successfully!')),
        );

        Navigator.pop(context);

        // Send notification after successful update
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 10, // Unique notification ID
            channelKey: 'basic_channel',
            title: 'Order Status Updated',
            body:
                'Order ${widget.order['invoice']} has been updated to ${_statusController.text}.',
          ),
        );
      }).catchError((error) {
        print('Error updating order: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update order. Please try again.')),
        );
      });

      if (_statusController.text == 'In Transit' ||
          _statusController.text == 'Delivered') {
        _updateDueDate(orderId);
      }
    } catch (error) {
      print('Unexpected error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('An unexpected error occurred. Please try again later.')),
      );
    }
  }

  String customerDeviceToken = '';

  Future<String> _getCustomerDeviceToken(String userId) async {
    // Retrieve the customer's device token from Firestore or other storage
    final userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.get('deviceToken');
  }

  Future<void> _updateDueDate(String orderId) async {
    final orderDoc = await _firestore.collection('orders').doc(orderId).get();
    final userId = orderDoc['userId'];

    final consumerDoc =
        await _firestore.collection('consumers').doc(userId).get();
    final creditDays = consumerDoc['creditDays'];

    final dueDate = DateTime.now().add(Duration(days: creditDays));

    // Update the order document with the calculated dueDate
    await _firestore
        .collection('orders')
        .doc(orderId)
        .update({'dueDate': dueDate});
  }
}

void main() {
  runApp(
    MaterialApp(
      home: AdminPendingOrdersPage(),
    ),
  );
}
