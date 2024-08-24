// add_customer_page.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:hive_db_task_todo/models/customer_model.dart';
import 'package:intl/intl.dart';

class AddCustomerPage extends StatefulWidget {
  const AddCustomerPage({Key? key}) : super(key: key);

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final _organizationNameController = TextEditingController();
  final _personInChargeController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _locationController = TextEditingController();
  //final _creditDurationController = TextEditingController();
  //final _zoneController = TextEditingController();
  final _lastInvoiceDateController = TextEditingController();

  String? _selectedZone; // Added to track the selected zone
  String? _selectedDuration; // Added to track the selected duration
  String? _selectedStatus; // Added to track the selected status

  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _addCustomer() async {
    // Validate your inputs here
    if (_organizationNameController.text.isEmpty) {
      _showToast('Organization name cannot be empty', isError: true);
      return;
    }

    DateTime? lastInvoiceDate;
    try {
      lastInvoiceDate = DateFormat('yyyy-MM-dd').parseStrict(_lastInvoiceDateController.text);
    } catch (e) {
      _showToast('Invalid date format for Last Invoice Date', isError: true);
      return;
    }

    // Validate the selected zone
    if (_selectedZone == null) {
      _showToast('Please select a zone', isError: true);
      return;
    }

    if (_selectedDuration == null) {
      _showToast('Please select a Credit Duration', isError: true);
      return;
    }

    if (_selectedStatus == null) {
      _showToast('Please select a Status', isError: true);
      return;
    }

    // Create a new Customer instance
    final newCustomer = Customer(
      organizationName: _organizationNameController.text,
      personInCharge: _personInChargeController.text,
      phoneNumber: _phoneNumberController.text,
      location: _locationController.text,
      //creditDuration: int.tryParse(_creditDurationController.text) ?? 0,
      //zone: _zoneController.text,
      zone: _selectedZone!, // Use the selected zone
      creditDuration: int.tryParse(_selectedDuration!) ?? 0, // Use the selected duration

      lastInvoiceDate: lastInvoiceDate,
      inputDate: DateTime.now(),
      status: _selectedStatus!,
    );

    // Open the Hive box for customers
    final customerBox = await Hive.openBox<Customer>('customers');

    // Add the new customer to the box
    await customerBox.add(newCustomer);

    _showToast('Customer added successfully!');
    Navigator.of(context).pop(); // Close the dialog
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AlertDialog(
        title: const Text('Add Consumer'),
        content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Your TextFields and input widgets
          TextField(
            controller: _organizationNameController,
            decoration: InputDecoration(labelText: 'Organization Name'),
          ),
          TextField(
            controller: _personInChargeController,
            decoration: InputDecoration(labelText: 'Person In Charge'),
          ),
          TextField(
            controller: _phoneNumberController,
            decoration: InputDecoration(labelText: 'Phone Number'),
            keyboardType: TextInputType.phone,
          ),
          TextField(
            controller: _locationController,
            decoration: InputDecoration(labelText: 'Location'),
          ),
          /*TextField(
            controller: _creditDurationController,
            decoration: InputDecoration(labelText: 'Credit Duration'),
          ),*/
          DropdownButtonFormField<String>(
            value: _selectedDuration,
            onChanged: (String? newValue) {
              setState(() {
                _selectedDuration = newValue;
              });
            },
            items: ['7', '14', '21', '30', 'Prepaid'].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            decoration: InputDecoration(labelText: 'Credit Duration'),
          ),
          /*TextField(
            controller: _zoneController,
            decoration: InputDecoration(labelText: 'Zone'),
          ),*/
          // Replace TextField for "Zone" with DropdownButtonFormField
          DropdownButtonFormField<String>(
            value: _selectedZone,
            onChanged: (String? newValue) {
              setState(() {
                _selectedZone = newValue;
              });
            },
            items: <String>[
              'South',
              'South East',
              'Middle Belt',
              'Upper Middle Belt',
              'North',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            decoration: InputDecoration(labelText: 'Zone'),
          ),
          TextField(
            controller: _lastInvoiceDateController,
            decoration: InputDecoration(labelText: 'Last Invoice Date (Y-M-D)'),
            onTap: () async {
                final
            
            DateTime?
            
            pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );

                if (pickedDate != null) {
                  final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                  _lastInvoiceDateController.text = formattedDate;
                }
              },
          ),
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            onChanged: (String? newValue) {
              setState(() {
                _selectedStatus = newValue;
              });
            },
            items: <String>[
              'Active',
              'Inactive',
              'Closed',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            decoration: InputDecoration(labelText: 'Status'),
          ),
        
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await _addCustomer();
          },
          child: const Text('Add'),
        ),
      ],
      ),
      
    );

  }
}
