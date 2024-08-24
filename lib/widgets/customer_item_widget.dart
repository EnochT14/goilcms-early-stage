import 'package:flutter/material.dart';
import 'package:hive_db_task_todo/models/customer_model.dart';

class CustomerItemWidget extends StatelessWidget {
  final Customer customer;
  final Function() onTap;
  final bool isEditable;
  //final Function onUpdate;
  final int remainingDays;
  final Color textColor;

  const CustomerItemWidget({
    required this.customer,
    required this.onTap,
    required this.isEditable,
    required this.remainingDays,
    required this.textColor,
    //required this.onUpdate,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: InkWell(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.organizationName,
                    style: TextStyle(
                      color: textColor,
                      //color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contact: ${customer.personInCharge}\nPhone: ${customer.phoneNumber}\nLocation: ${customer.location}',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  /*Text(
                      customer.organizationName,
                      style: TextStyle(
                          color: remainingDays <= 3 ? Colors.red : Colors.black, 
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                      ),
                  )*/
                ],
              ),
            ),
          ),
          /*if (isEditable) 
            IconButton(
              onPressed: () => onUpdate(),
              icon: Icon(Icons.edit),
            ),*/
        ],
      ),
    );
  }
}
