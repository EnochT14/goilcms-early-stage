// customer_model.dart
import 'package:hive/hive.dart';

part 'customer_model.g.dart';

@HiveType(typeId: 1)
class Customer extends HiveObject {
  @HiveField(0)
  String organizationName;

  @HiveField(1)
  String personInCharge;

  @HiveField(2)
  String phoneNumber;

  @HiveField(3)
  String location;

  @HiveField(4)
  int creditDuration;

  @HiveField(5)
  String zone;

  @HiveField(6)
  DateTime lastInvoiceDate;

  @HiveField(7)
  DateTime inputDate;

  @HiveField(8)
  String? status;

  Customer({
    required this.organizationName,
    required this.personInCharge,
    required this.phoneNumber,
    required this.location,
    this.creditDuration = 0,
    this.zone = '',
    required this.lastInvoiceDate,
    required this.inputDate,
    this.status,
  });
}
