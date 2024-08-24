import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_db_task_todo/routes/locator.dart';
import 'package:hive_db_task_todo/routes/navigation_service.dart';
import '../models/customer_model.dart';

class CustomerInfoPage extends StatefulWidget {
  final Customer customer;

  const CustomerInfoPage({Key? key, required this.customer}) : super(key: key);

  @override
  State<CustomerInfoPage> createState() => _CustomerInfoPageState();
}

class _CustomerInfoPageState extends State<CustomerInfoPage> {
  final NavigationService _navigationService = locator<NavigationService>();
  final _organizationNameController = TextEditingController();
  final _personInChargeController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _locationController = TextEditingController();
  final _creditDurationController = TextEditingController();
  final _zoneController = TextEditingController();
  final _lastInvoiceDateController = TextEditingController();
  final _statusController = TextEditingController();
  

  @override
  void initState() {
    super.initState();
    _organizationNameController.text = widget.customer.organizationName;
    _personInChargeController.text = widget.customer.personInCharge;
    _phoneNumberController.text = widget.customer.phoneNumber;
    _locationController.text = widget.customer.location;
    _creditDurationController.text = widget.customer.creditDuration.toString();
    _zoneController.text = widget.customer.zone;
    _lastInvoiceDateController.text =
        formatDate(widget.customer.lastInvoiceDate, [yyyy, '-', mm, '-', dd]);
    _statusController.text = widget.customer.status ?? '';
  }

  void onSave() {
    widget.customer.organizationName = _organizationNameController.text;
    widget.customer.personInCharge = _personInChargeController.text;
    widget.customer.phoneNumber = _phoneNumberController.text;
    widget.customer.location = _locationController.text;
    widget.customer.creditDuration =
        int.tryParse(_creditDurationController.text) ?? 0;
    widget.customer.zone = _zoneController.text;
    widget.customer.lastInvoiceDate = DateTime.parse(
        _lastInvoiceDateController.text); // Parse the date string to DateTime
    widget.customer.status = _statusController.text;

    widget.customer.save();

    Fluttertoast.showToast(
      msg: 'Customer saved.',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Theme.of(context).primaryColor,
      textColor: Color.fromARGB(255, 81, 230, 11),
      fontSize: 16.0,
    );
  }

  void onDelete() {
    widget.customer.delete();
    _navigationService.navigateTo('/');
  }

  void openDatePicker() async {
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: widget.customer.lastInvoiceDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(3000),
    );
    if (newDate != null) {
      setState(() {
        _lastInvoiceDateController.text =
            formatDate(newDate, [yyyy, '-', mm, '-', dd]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            buildTextField(
              label: 'Organization Name',
              controller: _organizationNameController,
            ),
            const Divider(color: Colors.grey),
            buildTextField(
              label: 'Person in Charge',
              controller: _personInChargeController,
            ),
            const Divider(color: Colors.grey),
            buildTextField(
              label: 'Phone Number',
              controller: _phoneNumberController,
            ),
            const Divider(color: Colors.grey),
            buildTextField(
              label: 'Location',
              controller: _locationController,
            ),
            const Divider(color: Colors.grey),
            buildTextField(
              label: 'Credit Duration',
              controller: _creditDurationController,
            ),
            const Divider(color: Colors.grey),
            buildTextField(
              label: 'Zone',
              controller: _zoneController,
            ),
            const Divider(color: Colors.grey),
            InkWell(
              onTap: openDatePicker,
              child: buildTextField(
                label: 'Last Invoice Date',
                controller: _lastInvoiceDateController,
              ),
            ),
            const Divider(color: Colors.grey),
            buildTextField(controller: _statusController, label: 'Status'
            )
          ],
        ),
      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onSave,
        icon: const Icon(Icons.edit_rounded),
        label: const Text('Save'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).backgroundColor,
      foregroundColor: Theme.of(context).primaryColor,
      elevation: 0.0,
      title: Text(
        'Edit Customer',
        style: Theme.of(context).textTheme.subtitle1,
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_rounded),
        ),
      ],
    );
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontFamily: GoogleFonts.firaSans().fontFamily,
                color: Colors.grey,
              ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: Theme.of(context).textTheme.bodySmall!,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(0),
          ),
        ),
      ],
    );
  }
}
