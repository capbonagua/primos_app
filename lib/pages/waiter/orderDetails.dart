import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:primos_app/pages/waiter/tables.dart';
import 'package:primos_app/pages/waiter/takeout.dart';
import 'package:primos_app/providers/isAdditionalOrder/isAdditionalOrder_provider.dart';
import 'package:primos_app/providers/kitchen/models.dart';
import 'package:primos_app/providers/waiter_menu/currentOrder_provider.dart';
import 'package:primos_app/providers/waiter_menu/isTakeout_provider.dart';
import 'package:primos_app/providers/waiter_menu/orderName_provider.dart';
import 'package:primos_app/providers/waiter_menu/subtotal_provider.dart';
import 'package:primos_app/widgets/bottomBar.dart';
import 'package:primos_app/widgets/styledButton.dart';

import '../../providers/kitchen/orderDetails_Provider.dart';
import '../../widgets/orderObject.dart';

class OrderDetailsPage extends ConsumerWidget {
  final String orderKey;
  const OrderDetailsPage({super.key, required this.orderKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersStream = ref.watch(ordersProvider);

    final orderName = ref.watch(orderNameProvider);
    final isTakeout = ref.watch(isTakeoutProvider);
    return Scaffold(
      backgroundColor: Color(0xfff8f8f7),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("ORDER DETAILS $orderName"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ordersStream.when(
                    data: (ordersMap) {
                      final orderEntries = ordersMap.entries.toList();

                      final singleOrderEntry = orderEntries.firstWhere(
                        (entry) => entry.key == orderKey,
                      );

                      final waiterName = singleOrderEntry.value['served_by'];
                      final orderDate =
                          DateTime.parse(singleOrderEntry.value['order_date']);
                      final orderData = singleOrderEntry.value['order_details']
                          as List<dynamic>?;

                      String formattedDate = DateFormat('dd-MM-yyyy hh:mm a')
                          .format(orderDate.toLocal());

                      final List<Order> ordersList =
                          orderData!.map<Order>((orderDetail) {
                        final name = orderDetail['productName'] ?? 'No Name';
                        final quantity = orderDetail['quantity'] ?? 0;
                        final variation =
                            orderDetail['variation'] ?? 'No Variation';
                        final serveStatus =
                            orderDetail['serve_status'] ?? 'Pending';
                        final price = orderDetail['productPrice'] as int;

                        return Order(
                          name: name,
                          quantity: quantity,
                          variation: variation,
                          serveStatus: serveStatus,
                          price: price,
                        );
                      }).toList();

                      int totalAmount =
                          ordersList.fold(0, (int sum, Order order) {
                        return sum + (order.quantity * order.price!.toInt());
                      });

                      return Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8))),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "WAITER",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(waiterName ?? "Waiter")
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "ORDER DATE & TIME",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(formattedDate)
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "BILL AMOUNT",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text("PHP $totalAmount")
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // ORDER ITEMS
                          const Row(
                            children: [
                              Expanded(flex: 2, child: Text("ITEM")),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                    "VARIANT",
                                    textAlign: TextAlign.end,
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                    "QTY",
                                    textAlign: TextAlign.end,
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                    "PRICE",
                                    textAlign: TextAlign.end,
                                  )),
                            ],
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color(0xff252525),
                                    width: 0.5)),
                          ),
                          const SizedBox(
                            height: 10,
                          ),

                          for (final order in ordersList)
                            Row(
                              children: [
                                Expanded(flex: 2, child: Text(order.name)),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    order.variation == "No Variation"
                                        ? "N/A"
                                        : order.variation,
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    order.quantity.toString(),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    order.price.toString(),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            )
                        ],
                      );
                    },
                    error: (error, stackTrace) => Text('Error: $error'),
                    loading: () => CircularProgressIndicator()),
                //     // ORDER DETAILS
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomBar(
        height: 100,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: StyledButton(
                  btnText: isTakeout ? "BACK TO TAKEOUTS" : "BACK TO TABLES",
                  onClick: () {
                    // reset states
                    ref.read(currentOrdersProvider.notifier).state = [];
                    ref.read(isAdditionalOrderProvider.notifier).state = false;
                    ref.read(orderNameProvider.notifier).state = null;
                    ref.read(subtotalProvider.notifier).state = 0.0;

                    // Reset isTakeout to false
                    if (isTakeout) {
                      ref.read(isTakeoutProvider.notifier).state = false;
                    }

                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) {
                        if (isTakeout) {
                          return TakeoutPage();
                        } else {
                          return WaiterTablePage();
                        }
                      }),
                      (Route<dynamic> route) => false,
                    );
                  },
                  btnColor: Color(0xfff8f8f7),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
