import 'package:flutter/material.dart';
import 'package:hive_db_task_todo/models/customer_model.dart';
import 'package:hive_db_task_todo/widgets/customer_item_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../routes/locator.dart';
import '../routes/navigation_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _navigationService = locator<NavigationService>();
  late List<Customer> _customers;
  final _listKey = GlobalKey<AnimatedListState>();
  bool _isLoading = false;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setCustomers();
  }

  Future<void> setCustomers() async {
    setState(() => _isLoading = true);
    _customers =
        Hive.box<Customer>("customers").values.toList().cast<Customer>();
    //filter or sort customer list as needed
    setState(() => _isLoading = false);
  }

  List<Customer> getFilteredCustomers(String search) {
    if (search.isEmpty) {
      return _customers;
    } else {
      return _customers
          .where((customer) => customer.organizationName
              .toLowerCase()
              .contains(search.toLowerCase()))
          .toList();
    }
  }

  void onDelete(int position) async {
    final customer = _customers[position];
    customer.delete();
    _customers.removeAt(position);
    _listKey.currentState!.removeItem(
      position,
      (context, animation) => CustomerItemWidget(
        customer: customer,
        isEditable: false,
        onTap: () {},
        remainingDays: 0,
        textColor: Colors.white,
      ),
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: buildAppBar(),
        body: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : _customers.isEmpty
                  ? const Text('No customers.')
                  : Column(
                      children: [
                        buildSearchBar(),
                        Expanded(
                            child: buildAnimatedCustomerList(
                                getFilteredCustomers(_searchController.text))),
                      ],
                    ),
        ),
      );

  AppBar buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).backgroundColor,
      foregroundColor: Theme.of(context).primaryColor,
      elevation: 0.0,
      title: Text(
        'All Consumers',
        style: Theme.of(context).textTheme.subtitle1,
      ),
      centerTitle: true,
    );
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Search by Organization Name',
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (value) {
          setState(() {}); //rebuild when you type in search box
        },
      ),
    );
  }

  Widget buildAnimatedCustomerList(final customers) => ListView.builder(
        key: _listKey,
        itemCount: customers.length,
        itemBuilder: (context, index) {
          int remainingDays = customers[index]
              .lastInvoiceDate
              .add(Duration(days: customers[index].creditDuration))
              .difference(DateTime.now())
              .inDays;

          return CustomerItemWidget(
            customer: customers[index],
            isEditable: true,
            onTap: () => _navigationService.navigateTo('/customerInfo',
                arguments: customers[index]),
            remainingDays: remainingDays,
            textColor: Colors.white,
          );
        },
      );
}
