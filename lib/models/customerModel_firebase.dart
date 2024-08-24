import 'package:cloud_firestore/cloud_firestore.dart';


class Consumer {
  String accountNumber;
  String consumerName;
  int creditDays;
  int creditLimit; 
  double discount; 
  Timestamp dueDate; 
  String email;
  String invoice;
  String phone;
  String region;
  String status;
  int quantity;
  Timestamp createdAt; 
  String location;

  Consumer({
    required this.accountNumber,
    required this.consumerName,
    required this.creditDays,
    required this.creditLimit,
    required this.discount,
    required this.dueDate,
    required this.email,
    required this.invoice,
    required this.phone,
    required this.region,
    required this.status,
    required this.quantity,
    required this.createdAt,
    required this.location,
  });

  // Create a method to convert the object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'accountNumber': accountNumber,
      'consumerName': consumerName,
      'creditDays': creditDays,
      'creditLimit': creditLimit,
      'discount': discount,
      'dueDate': dueDate,
      'email': email,
      'invoice': invoice,
      'phone': phone,
      'region': region,
      'status': status,
      'quantity': quantity,
      'createdAt': createdAt,
      'location': location,
    };
  }
}
