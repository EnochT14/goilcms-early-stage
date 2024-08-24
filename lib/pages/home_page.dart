import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  final String customerId;

  const HomePage({Key? key, required this.customerId}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Widget _buildOrderCard(BuildContext context, QueryDocumentSnapshot order) {
    //DD-MM-YYYY format
    String formatTimestamp(Timestamp timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('dd-MM-yyyy').format(dateTime);
    }

    // Calculate the difference in days between the dueDate and current date
    int daysDifference = (order['dueDate'] as Timestamp)
        .toDate()
        .difference(DateTime.now())
        .inDays;

    // Determine if the order is within 7 days from the dueDate
    bool isWithin7Days = daysDifference <= 7;

    return Card(
      color: isWithin7Days ? Colors.red : null, // Set card color to red
      child: ExpansionTile(
        title: Text(order['productType']),
        subtitle: Text('Status: ${order['status']}'),
        trailing: Icon(Icons.arrow_drop_down),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Invoice: ${order['invoice']}'),
              Text('Due Date: ${formatTimestamp(order['dueDate'])}'),
              Text('Quantity: ${order['quantity']}'),
              Text('Delivery Location: ${order['deliveryLocation']}'),
              Text('Order Date: ${formatTimestamp(order['orderDate'])}'),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _firestore = FirebaseFirestore.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;

    String getCurrentCustomerId() {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return user.uid;
      } else {
        return ''; //default value if user is not logged in
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>(
          future: _firestore
              .collection('consumers')
              .doc(_auth.currentUser!.uid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error loading user data: ${snapshot.error}');
            }

            if (snapshot.hasData && snapshot.data!.exists) {
              Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;
              String userName = data['name'] ?? 'User';
              return Text(userName);
            }

            return Text('Home');
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _signOut(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Pending Invoice'),
            Tab(text: 'Processing'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Manage'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/manage');
              },
            ),
            ListTile(
              title: Text('Add Consumer'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/create');
              },
            ),
            /*ListTile(
              title: Text('Order Page'),
              onTap: () {
                Navigator.pop(context); 
                final customerId = getCurrentCustomerId();
                Navigator.pushNamed(context, '/order', arguments: {'customerId': customerId});
              },
            ),*/
            ListTile(
              title: Text('Order Page Test'),
              onTap: () {
                Navigator.pop(context);
                final customerId = getCurrentCustomerId();
                Navigator.pushNamed(context, '/orderTest',
                    arguments: {'customerId': customerId});
              },
            ),
            ListTile(
              title: Text('Order History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/orderHistory');
              },
            ),
            ListTile(
              title: Text('Pending Orders - chat'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/adminPending');
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(context, ['In Transit', 'Delivered']),
          _buildOrderList(context, ['Pending', 'Processed']),
          _buildOrderList(context, ['Completed']),
        ],
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, List<String> statuses) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('status', whereIn: statuses)
          .orderBy('dueDate')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading orders: ${snapshot.error}'));
        }

        if (snapshot.hasData) {
          final orders = snapshot.data!.docs;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(context, order);
            },
          );
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }

  void _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      print("Error signing out: $e");
      // TODO: Handle sign-out error
    }
  }
}
