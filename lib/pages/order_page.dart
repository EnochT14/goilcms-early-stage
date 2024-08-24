import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:provider/provider.dart';

class OrderPage extends StatefulWidget {
  final String customerId;

  OrderPage({required this.customerId});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final List<String> productTypes = ['Gasoline', 'Diesel', 'LPG'];
  String selectedProductType = '';
  int quantity = 0;
  String selectedDeliveryLocation = 'Select a Location';
  //stream controller for delivery locations
  final StreamController<List<String>> _locationsController =
      StreamController<List<String>>();

  @override
  void initState() {
    super.initState();
    // fetch delivery locations when the widget is created
    fetchDeliveryLocations();
  }

  @override
  void dispose() {
    _locationsController.close();
    super.dispose();
  }

  Future<void> fetchDeliveryLocations() async {
    try {
      // Create reference to the 'locations' collection for a customer
      CollectionReference locationsRef = FirebaseFirestore.instance
          .collection('consumers')
          .doc(widget.customerId)
          .collection('locations');

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('consumers')
          .doc(widget.customerId)
          .get();
      String fetchedLocationFromFirebase = userDoc.get('location');

      locationsRef.snapshots().listen((QuerySnapshot snapshot) {
        // extract location names from documents
        List<String> locations =
            snapshot.docs.map((doc) => doc['location'] as String).toList();
        locations = locations.toSet().toList(); // Remove duplicates
        _locationsController.add(locations);
      });
    } catch (e) {
      print('Error fetching delivery locations: $e');
    }
  }

  void submitOrder() {
    if (selectedProductType.isNotEmpty && quantity > 0) {
      if (_locationsController.hasListener) {
        // Use the selectedProductType and quantity to create the order object
        Order order = Order(
          productType: selectedProductType,
          quantity: quantity,
          deliveryLocation:
              selectedProductType, // Use selectedProductType as a placeholder
        );

        FirebaseFirestore.instance.collection('orders').add(order.toMap());

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Order placed successfully')));
      } else {
        // error message if the location stream is not ready
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: Delivery locations not available')));
      }
    } else {
      //error message if any required field is not filled
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please fill in all fields')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Place Order'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /*DropdownButtonFormField<String>(
              items: productTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
              onChanged: (value) {
                setState(() {
                  selectedProductType = value ?? '';
                });
              },
              value: selectedProductType,
              hint: Text('Select Product Type'),
            ),*/
            SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  quantity = int.tryParse(value) ?? 0;
                });
              },
              decoration: InputDecoration(labelText: 'Quantity'),
            ),
            SizedBox(height: 16),
            // Use StreamBuilder to listen to changes in delivery locations
            /*StreamBuilder<List<String>>(
              stream: _locationsController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return DropdownButtonFormField<String>(
                    items: snapshot.data!.map((location) => DropdownMenuItem(value: location, child: Text(location))).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedProductType = value ?? '';
                      });
                    },
                    value: selectedProductType,
                    hint: Text('Select Delivery Location'),
                  );
                } else {
                  // Show a loading indicator or placeholder while fetching data
                  return CircularProgressIndicator();
                }
              },
            ),*/
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: submitOrder,
              child: Text('Submit Order'),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('consumers')
                  .doc(widget.customerId)
                  .collection('locations')
                  .snapshots(),
              builder: (context, snapshot) {
                List<DropdownMenuItem> locationItems = [];

                if (snapshot.hasData) {
                  final locations = snapshot.data!.docs.reversed.toList();

                  // Access the 'location' field safely using null-aware operators:
                  for (var document in locations) {
                    print("Document ID: ${document.id}");
                    print("Document Data: ${document.data()}");
                    //Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    locationItems.add(DropdownMenuItem(
                      value: document.id,
                      child: Text(document['location'] ?? 'Unknown Location'),
                    ));
                  }
                } else if (snapshot.hasError) {
                  return Text('Error fetching locations: ${snapshot.error}');
                } else {
                  // progress indicator while loading:
                  return const CircularProgressIndicator();
                }

                return DropdownButton(
                  items: locationItems,
                  onChanged: (locationValue) {
                    print(locationValue);
                  },
                  hint: const Text('Select Delivery Location'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Order {
  String productType;
  int quantity;
  String deliveryLocation;

  Order({
    required this.productType,
    required this.quantity,
    required this.deliveryLocation,
  });

  // convert the object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'productType': productType,
      'quantity': quantity,
      'deliveryLocation': deliveryLocation,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
