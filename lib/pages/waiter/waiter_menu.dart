import 'package:flutter/material.dart';
import 'package:primos_app/pages/waiter/waiter_menu_cart.dart';
import 'package:primos_app/providers/categoryFilter/activeCategory_provider.dart';
import 'package:primos_app/providers/waiter_menu/currentOrder_provider.dart';
import 'package:primos_app/providers/waiter_menu/menuItems_provider.dart';
import 'package:primos_app/widgets/bottomBar.dart';
import 'package:primos_app/widgets/filterBtns.dart';
import 'package:primos_app/widgets/searchBar.dart';
import 'package:primos_app/widgets/styledButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/waiter_menu/subtotal_provider.dart';
import '../../widgets/itemCard.dart';
import '../../widgets/styledDropdown.dart';
import '../../providers/kitchen/variation_provider.dart';

import 'package:primos_app/widgets/orderObject.dart';

// STATE MANAGEMENT
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WaiterMenu extends ConsumerWidget {
  WaiterMenu({super.key});

  double calculateSubtotal(List<OrderObject> orders) {
    return orders.fold(0, (double sum, OrderObject order) {
      return sum + (order.price * order.quantity);
    });
  }

  void updateSubtotal(WidgetRef ref) {
    final currentOrders = ref.watch(currentOrdersProvider);
    ref.read(subtotalProvider.notifier).state =
        calculateSubtotal(currentOrders);
  }

  void removeOrder(WidgetRef ref, int index) {
    ref.read(currentOrdersProvider.notifier).state.removeAt(index);
    updateSubtotal(ref);
  }

  Future<void> addModal(BuildContext context, WidgetRef ref, productId,
      productName, productPrice, productVariation, imageUrl) async {
    final currentOrders = ref.watch(currentOrdersProvider);

    // final quantity = ref.watch(quantityProvider);
    int localQuantity = 0;

    // final variation = ref.watch(variationProvider);
    String? localVariation;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    productName,
                    textAlign: TextAlign.left,
                  ),
                ),
                Divider(height: 0),
                Container(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        productVariation != null
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    flex: 1,
                                    child: Text("Variation: "),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: StyledDropdown(
                                      width: double.infinity,
                                      dropdownColor: Color(0xFFf8f8f7),
                                      value:
                                          localVariation, //TODO =================
                                      onChange: (String? newValue) {
                                        setState(() {
                                          localVariation = newValue;
                                        });
                                      },
                                      hintText: "Select Variation",
                                      items: const [
                                        'Small',
                                        'Medium',
                                        'Large',
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : SizedBox(),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Quantity: "),
                            Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFFf8f8f7),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(50),
                                ),
                              ),
                              height: 40,
                              width: 150,
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          if (localQuantity != 0) {
                                            localQuantity--;
                                          }
                                        });
                                      },
                                      icon: const Icon(Icons.remove_circle),
                                      iconSize: 25,
                                    ),
                                    Text(
                                      // ref.watch(quantityProvider).toString(),
                                      localQuantity.toString(),
                                      style: const TextStyle(
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          localQuantity++;
                                        });
                                      },
                                      icon: const Icon(Icons.add_circle),
                                      iconSize: 25,
                                    )
                                  ]),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            StyledButton(
                                btnText: "Cancel",
                                onClick: () {
                                  Navigator.of(context).pop();
                                }),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              flex: 1,
                              child: StyledButton(
                                  btnText: "Confirm",
                                  onClick: () {
                                    // Check if an order with the same details already exists in currentOrders
                                    int existingIndex =
                                        currentOrders.indexWhere(
                                      (order) =>
                                          order.name == productName &&
                                          order.variation == localVariation &&
                                          order.price == productPrice,
                                    );

                                    if (existingIndex != -1) {
                                      ref
                                          .read(currentOrdersProvider.notifier)
                                          .state[existingIndex]
                                          .quantity += localQuantity;
                                    } else {
                                      // If no existing order found, create a new order and add to currentOrders
                                      final currentOrder = OrderObject(
                                        id: productId,
                                        name: productName,
                                        price: productPrice,
                                        variation: localVariation,
                                        quantity: localQuantity,
                                        imageUrl: imageUrl,
                                      );

                                      ref
                                          .read(currentOrdersProvider.notifier)
                                          .state
                                          .add(currentOrder);

                                      print(currentOrders);
                                    }
                                    updateSubtotal(ref);

                                    Navigator.of(context)
                                        .pop(); //close the modal
                                  }),
                            ),
                          ],
                        ),
                      ],
                    ))
              ]);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtotal = ref.watch(subtotalProvider);
    final menuItems = ref.watch(menuItemsStreamProvider);

    return WillPopScope(
      onWillPop: () async {
        // Reset the currentOrdersProvider state when navigating back
        ref.read(currentOrdersProvider.notifier).state = [];
        updateSubtotal(ref);
        return true; // Allow navigation
      },
      child: Scaffold(
        backgroundColor: Color(0xfff8f8f7),
        appBar: AppBar(
          leading: IconButton(
            //manual handle back button
            icon: const Icon(Icons.keyboard_arrow_left),
            iconSize: 35,
            onPressed: () {
              // RESET CURRENT ORDERS
              ref.read(currentOrdersProvider.notifier).state = [];
              updateSubtotal(ref);
              Navigator.of(context).pop();
            },
          ),
          title: Text("MENU"),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomSearchBar(),
                FilterBtns(),
                Consumer(builder: ((context, ref, child) {
                  final activeCategory = ref.watch(activeCategoryProvider);
                  return menuItems.when(
                      data: (itemDocs) {
                        // FILTER BASED ON ACTIVE CATEGORY
                        final filteredItems = itemDocs.where((itemDoc) {
                          final productCategory = itemDoc['category'] as String;
                          return activeCategory == "All" ||
                              productCategory == activeCategory;
                        }).toList();

                        return Padding(
                          padding: EdgeInsets.all(16),
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: filteredItems.map((itemDoc) {
                              final productId = itemDoc
                                  .id; // Get the document ID as the productId
                              final productName = itemDoc['itemName'] as String;
                              final itemPrice = itemDoc['itemPrice'];
                              final double productPrice = (itemPrice is double)
                                  ? itemPrice
                                  : (itemPrice is int)
                                      ? itemPrice.toDouble()
                                      : 0.0;
                              final imageUrl = itemDoc['imageURL'] as String;

                              final dynamic productVariation =
                                  null; //todo GRAB THE PRODUCT VARIATION FROM DB, ex. MEDIUM, LARGE, CHICKEN, BEEF

                              return ItemCard(
                                key: ValueKey(productId),
                                productId: productId, // Pass the productId
                                productName: productName,
                                productPrice: productPrice,
                                imageUrl: imageUrl,
                                // cardHeight: 300,
                                footerSection: Column(
                                  children: [
                                    StyledButton(
                                        btnIcon: Icon(Icons.add),
                                        noShadow: true,
                                        btnWidth: double.infinity,
                                        btnHeight: 35,
                                        btnText: "Add",
                                        onClick: () {
                                          addModal(
                                              context,
                                              ref,
                                              productId,
                                              productName,
                                              productPrice,
                                              productVariation,
                                              imageUrl);
                                        })
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                      error: (error, stackTrace) => Text("Error: $error"),
                      loading: () => CircularProgressIndicator());
                }))
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomBar(
          height: 100,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: StyledButton(
                    btnIcon: Icon(Icons.shopping_cart_checkout),
                    noShadow: true,
                    btnText: "View Orders",
                    secondText: "PHP $subtotal",
                    onClick: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                          return WaiterMenuCart(
                              // orderData: currentOrders,
                              // onDelete: removeOrder,
                              // onDelete: (int) {},
                              );
                        }),
                      );
                    },
                    btnColor: const Color(0xfff8f8f7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
