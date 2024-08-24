//home_page.dart
import 'package:flutter/material.dart';
import 'package:hive_db_task_todo/models/customer_model.dart';
import 'package:hive_db_task_todo/routes/locator.dart';
import 'package:hive_db_task_todo/routes/navigation_service.dart';
import 'package:hive_db_task_todo/widgets/customer_item_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../widgets/circle_tab_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManagePage extends StatefulWidget {
  const ManagePage({Key? key}) : super(key: key);

  @override
  State<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> with TickerProviderStateMixin {
  final _navigationService = locator<NavigationService>();
  late List<Customer> _customers;
  bool _isLoading = false;
  bool _isDark = false;
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _isDark = context.read<ThemeManager>().themeMode == ThemeMode.dark;
    _tabController = TabController(length: 3, initialIndex: 0, vsync: this);
    setCustomerList(0);
    _tabController.addListener(() {
      setCustomerList(_tabController.index);
    });
  }

  void setCustomerList(int index) async {
    setState(() => _isLoading = true);
    _customers =
        Hive.box<Customer>("customers").values.toList().cast<Customer>();

    switch (index) {
      case 0:
        _customers.retainWhere((customer) => customer.status == "Active");
        _customers.sort((a, b) {
          DateTime aCreditDate =
              a.lastInvoiceDate.add(Duration(days: a.creditDuration));
          DateTime bCreditDate =
              b.lastInvoiceDate.add(Duration(days: b.creditDuration));

          int aRemainingDays = aCreditDate.difference(a.lastInvoiceDate).inDays;
          int bRemainingDays = bCreditDate.difference(b.lastInvoiceDate).inDays;

          if (aRemainingDays < bRemainingDays) return -1; // Closer to due date
          if (aRemainingDays > bRemainingDays)
            return 1; // Further from due date

          return aCreditDate.millisecondsSinceEpoch <
                  bCreditDate.millisecondsSinceEpoch
              ? -1
              : 1;
        });
        break;
      case 1:
        _customers.retainWhere((customer) => customer.status == 'Inactive');
        _customers.sort((a, b) {
          DateTime aCreditDate =
              a.lastInvoiceDate.add(Duration(days: a.creditDuration));
          DateTime bCreditDate =
              b.lastInvoiceDate.add(Duration(days: b.creditDuration));

          int aRemainingDays = aCreditDate.difference(a.lastInvoiceDate).inDays;
          int bRemainingDays = bCreditDate.difference(b.lastInvoiceDate).inDays;

          if (aRemainingDays < bRemainingDays) return -1;
          if (aRemainingDays > bRemainingDays) return 1;

          return aCreditDate.millisecondsSinceEpoch <
                  bCreditDate.millisecondsSinceEpoch
              ? -1
              : 1;
        });
        break;
      case 2:
        _customers.retainWhere((customer) => customer.status == 'Closed');
        _customers.sort((a, b) {
          DateTime aCreditDate =
              a.lastInvoiceDate.add(Duration(days: a.creditDuration));
          DateTime bCreditDate =
              b.lastInvoiceDate.add(Duration(days: b.creditDuration));

          int aRemainingDays = aCreditDate.difference(a.lastInvoiceDate).inDays;
          int bRemainingDays = bCreditDate.difference(b.lastInvoiceDate).inDays;

          if (aRemainingDays < bRemainingDays) return -1;
          if (aRemainingDays > bRemainingDays) return 1;

          return aCreditDate.millisecondsSinceEpoch <
                  bCreditDate.millisecondsSinceEpoch
              ? -1
              : 1;
        });
        break;
    }

    debugPrint(_customers.toString());
    setState(() => _isLoading = false);
  }

  String getCurrentCustomerId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      return ''; //default value if user is not logged in
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: buildAppBar(),
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
            )
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildContent(_tabController),
        ],
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).backgroundColor,
      foregroundColor: Theme.of(context).primaryColor,
      elevation: 0.0,
      leading: IconButton(
        icon: const Icon(Icons.menu), // Use a hamburger menu icon
        onPressed: () => _scaffoldKey.currentState!
            .openDrawer(), // Use a GlobalKey to access Scaffold
      ),
      title: Text(
        'Home',
        style: Theme.of(context).textTheme.subtitle1,
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {
            context.read<ThemeManager>().toggleTheme(!_isDark);
            setState(() => _isDark = !_isDark);
          },
          icon: _isDark
              ? const Icon(Icons.light_mode_rounded)
              : const Icon(Icons.dark_mode_rounded),
        ),
      ],
    );
  }

  Widget buildContent(TabController tabController) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hey Enoch', style: Theme.of(context).textTheme.subtitle1),
            const SizedBox(height: 5),
            TabBar(
              controller: tabController,
              labelColor: Theme.of(context).primaryColor,
              labelStyle: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontWeight: FontWeight.w500),
              indicator: CircleTabIndicator(
                  color: Theme.of(context).primaryColor, radius: 3),
              tabs: const [
                Tab(text: 'Active', icon: Icon(Icons.check_circle_rounded)),
                Tab(text: 'Inactive', icon: Icon(Icons.close_rounded)),
                Tab(text: 'Closed', icon: Icon(Icons.bedtime_outlined)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: SizedBox(
                width: double.maxFinite,
                height: 505,
                child: TabBarView(
                  controller: tabController,
                  children: [
                    buildCustomerList(_customers),
                    buildCustomerList(_customers),
                    buildCustomerList(_customers),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget buildCustomerList(List<Customer> customers) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : customers.isNotEmpty
            ? ValueListenableBuilder(
                valueListenable: Hive.box<Customer>('customers').listenable(),
                builder: (context, box, _) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      int remainingDays = customers[index]
                          .lastInvoiceDate
                          .add(Duration(days: customers[index].creditDuration))
                          .difference(DateTime.now())
                          .inDays;

                      Color textColor = remainingDays <= 5
                          ? Colors.red
                          : Color.fromARGB(255, 41, 211, 7);

                      return CustomerItemWidget(
                        customer: customers[index],
                        isEditable: true,
                        onTap: () => _navigationService.navigateTo(
                            '/customerInfo',
                            arguments: customers[index]),
                        remainingDays: remainingDays,
                        textColor: textColor,
                      );
                    },
                  );
                },
              )
            : Text(
                "No customers.",
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
              );
  }
}
