import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primos_app/pages/waiter/takeout.dart';
import 'package:primos_app/pages/waiter/waiter_menu.dart';
import 'package:primos_app/providers/bottomNavBar/currentIndex_provider.dart';
import 'package:primos_app/providers/table/table_provider.dart';
import 'package:primos_app/widgets/bottomBar.dart';
import 'package:primos_app/widgets/pageObject.dart';
import 'package:primos_app/widgets/sideMenu.dart';
import 'package:primos_app/widgets/tableBox.dart';

import '../../providers/waiter_menu/currentOrder_provider.dart';

class WaiterTablePage extends ConsumerWidget {
  WaiterTablePage({super.key});

//   @override
//   State<WaiterTablePage> createState() => _WaiterTablePageState();
// }

// class _WaiterTablePageState extends State<WaiterTablePage> {

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Reset the currentOrdersProvider when navigating back to WaiterTablePage
    // useEffect(() {
    //   return () {
    //     ref.read(currentOrdersProvider.notifier).state = [];
    //   };
    // }, []);
    // Reset the currentOrdersProvider when navigating back to WaiterTablePage
    // ref.read(currentOrdersProvider.notifier).state = [];
    // Listen for route changes and reset currentOrdersProvider if returning to WaiterTablePage
    // Future.microtask(() {
    //   ModalRoute.of(context)?.addScopedWillPopCallback(() {
    //     ref.read(currentOrdersProvider.notifier).state = [];
    //     return Future.value(true);
    //   });
    // });

    final tableItems = ref.watch(tableItemsProvider);

    // print(tableItems);

    int currentIndex = ref.watch(currentIndex_provider);
    return Scaffold(
      backgroundColor: Color(0xfff8f8f7),
      drawer: SideMenu(pages: waiterPages),
      appBar: AppBar(
        title: Text("TABLES"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            child: Consumer(builder: ((context, ref, child) {
          return tableItems.when(
              data: (itemDocs) {
                itemDocs.sort((a, b) {
                  // Extract the numeric part of the table names
                  int tableNumberA =
                      int.parse(RegExp(r'[0-9]+').firstMatch(a)!.group(0)!);
                  int tableNumberB =
                      int.parse(RegExp(r'[0-9]+').firstMatch(b)!.group(0)!);
                  return tableNumberA.compareTo(tableNumberB);
                });
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(
                      itemDocs.length,
                      (index) => FractionallySizedBox(
                        widthFactor: 0.31, // Take up 30% of available width
                        child: TableBox(
                          tableName: itemDocs[index],
                        ), // You can use 'index + 1' if you want table numbers to start from 1
                      ),
                    ),
                  ),
                );
              },
              error: (error, stackTrace) => Text("Error: $error"),
              loading: () => CircularProgressIndicator());
        }))),
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -3), // changes position of shadow
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              ref.read(currentIndex_provider.notifier).state = index;

              if (index == 0) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (BuildContext context) {
                    return WaiterTablePage();
                  }),
                );
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (BuildContext context) {
                    return TakeoutPage();
                  }),
                );
              }
            },
            unselectedItemColor: Color(0xFF252525),
            selectedItemColor: Color(0xFFFE3034),
            backgroundColor: Color(0xFFE2B563),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.table_bar),
                label: "Dine-In",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.takeout_dining),
                label: "Takeout",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
