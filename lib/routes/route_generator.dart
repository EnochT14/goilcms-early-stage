import 'package:flutter/material.dart';
import 'package:hive_db_task_todo/pages/add_customer_page.dart'; // Update the import statement
import 'package:hive_db_task_todo/pages/history_page.dart';
import 'package:hive_db_task_todo/pages/signup_page.dart';
import 'package:page_transition/page_transition.dart';
import '../models/customer_model.dart'; // Update the import statement
import '../pages/manage_page.dart';
import '../pages/customer_info_page.dart';
import '../pages/login_page.dart';


class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/manage':
        return PageTransition(child: const ManagePage(), type: PageTransitionType.fade);

      case '/addTask':
        return PageTransition(child: const AddCustomerPage(), type: PageTransitionType.fade); // Update the page

      case '/history':
        return PageTransition(child: const HistoryPage(), type: PageTransitionType.fade);

      case '/login':
        return MaterialPageRoute(builder: (_) => LoginPage());
      
      //case '/signup':
        // return MaterialPageRoute(builder: (_) => SignUpPage()); 

      case '/customerInfo':
        if (args is Customer) { // Update the model type
          return PageTransition(child: CustomerInfoPage(customer: args), type: PageTransitionType.bottomToTop); // Update the page and model
        } else {
          return _errorRoute();
        }

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return const Scaffold(
        body: Center(
          child: Text('Oops.. Something went wrong.'),
        ),
      );
    });
  }
}
