import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_db_task_todo/pages/home_page.dart';
import 'package:hive_db_task_todo/pages/login_page.dart';
import 'package:hive_db_task_todo/pages/consumerCreate.dart';
import 'package:hive_db_task_todo/pages/manage_page.dart';
import 'package:hive_db_task_todo/pages/signup_page.dart';
import 'package:hive_db_task_todo/pages/order_page.dart';
import 'package:hive_db_task_todo/pages/orderPage.dart';
import 'package:hive_db_task_todo/routes/navigation_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/customer_model.dart';
import 'theme/theme_constants.dart';
import 'theme/theme_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_db_task_todo/pages/adminPendingOrders.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

//import 'package:hive_db_task_todo/pages/orderDetailsPage.dart';

late Box box;
late Box<Customer> customerBox;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelGroupKey: "basic_channel_group",
      channelKey: 'order_updates',
      channelName: 'Order Updates',
      channelDescription: 'Notification for order status updates',
      defaultColor: Color.fromARGB(255, 248, 134, 3),
      ledColor: Color.fromARGB(255, 240, 156, 0),
      playSound: true,
      enableVibration: true,
      importance: NotificationImportance.High,
    )
  ], channelGroups: [
    NotificationChannelGroup(
      channelGroupKey: 'order_updates',
      channelGroupName: 'Order Updates',
    )
  ]);

  //final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await FirebaseAppCheck.instance
      .activate(androidProvider: AndroidProvider.debug);

  OneSignal.initialize("522bc81a-e6e4-4eb6-9c05-6a35947ef6c2");
  OneSignal.Notifications.requestPermission(true);

  await Hive.initFlutter();
  Hive.registerAdapter<Customer>(CustomerAdapter());
  customerBox = await Hive.openBox<Customer>('customers');

  GetIt.instance.registerSingleton<NavigationService>(NavigationService());

  bool isAllowedToSendNotifications =
      await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowedToSendNotifications) {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeManager()),
      ],
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Consumer App',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: context.watch<ThemeManager>().themeMode,
          initialRoute: '/login', // Set the initial route to login
          onGenerateRoute: (settings) {
            if (settings.name == '/order') {
              final Map<String, dynamic>? args =
                  settings.arguments as Map<String, dynamic>?;
              final String customerId = args?['customerId'] ?? '';

              return MaterialPageRoute(
                builder: (context) => OrderPage(customerId: customerId),
              );
            }

            if (settings.name == '/orderHistory') {
              return MaterialPageRoute(
                  builder: (context) => OrdersHistoryPage());
            }

            return null;
          },
          onGenerateInitialRoutes: (String initialRoute) {
            // Check if the user is logged in
            User? user = FirebaseAuth.instance.currentUser;

            if (user != null) {
              return [
                MaterialPageRoute(
                  settings: RouteSettings(name: '/home'),
                  builder: (context) => HomePage(customerId: user.uid),
                ),
              ];
            } else {
              return [
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              ];
            }
          },
          routes: {
            '/login': (context) => LoginPage(),
            '/signup': (context) => SignUpPage(),
            '/manage': (context) => ManagePage(),
            '/home': (context) => HomePage(customerId: ''),
            '/create': (context) => AdminUserCreationPage(),
            '/orderTest': (context) => OrdersPage(),
            '/orderHistory': (context) => OrdersHistoryPage(),
            '/adminPending': (context) => AdminPendingOrdersPage(),

            //'/orderDetails': (context) => OrderDetailsPage(),
          },
        );
      },
    );
  }
}
