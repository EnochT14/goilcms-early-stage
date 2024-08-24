import 'package:flutter/material.dart';
import 'package:hive_db_task_todo/models/customer_model.dart';
import 'package:hive_db_task_todo/widgets/customer_item_widget.dart';

class CustomerListPage extends StatelessWidget {
  final List<Customer> customers; // Pass your list of customers here

  const CustomerListPage({
    required this.customers,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer List'),
      ),
      body: buildCustomerList(),
    );
  }

  Widget buildCustomerList() {
    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return CustomerItemWidget(
          customer: customer,
          isEditable: true,
          /*onUpdate: () {
            // TODO: Handle onUpdate action for a customer
          },*/
          onTap: () {
            // TODO:Handle onTap action for a customer
          },
          remainingDays: 0,
          textColor: Theme.of(context).primaryColor,
        );
      },
    );
  }
}
