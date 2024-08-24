import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({Key? key}) : super(key: key);

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final _firestore = FirebaseFirestore.instance;
  final _searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin View: Pending Orders'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by consumer name or invoice',
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getOrdersStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading orders'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final order = snapshot.data!.docs[index];
                    return FutureBuilder<DocumentSnapshot>(
                      future: _firestore
                          .collection('consumers')
                          .doc(order['userId'])
                          .get(),
                      builder: (context, consumerSnapshot) {
                        if (!consumerSnapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final consumerName = consumerSnapshot.data!.get('name');

                        return Card(
                          child: ListTile(
                            title: Text(order['invoice']),
                            subtitle: Text('Consumer: $consumerName'),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot<Object?>> _getOrdersStream() {
    // Inside the _getOrdersStream() function:
    Query<Map<String, dynamic>> query = _firestore.collection('orders').where(
        'status',
        whereIn: ['Pending', 'Processed', 'In Transit', 'Delivered']);

    if (searchQuery != '') {
      query = query
          .where('name', isEqualTo: searchQuery)
          .where('invoice', isEqualTo: searchQuery);
    }
    return query.snapshots();
  }
}
