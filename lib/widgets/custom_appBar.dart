import 'dart:async';

import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../data/table_repository.dart';

import '../screens/dashboard.dart';
import '../screens/login_page.dart';
import '../services/cart_manger.dart';

class custom_appBar extends StatefulWidget {
  const custom_appBar({super.key});

  @override
  State<custom_appBar> createState() => _custom_appBarState();
}

class _custom_appBarState extends State<custom_appBar> {
  void _showTableStatusDialog(BuildContext context) {
  final List<TableModel> firstFloorTables = TableRepository().firstFloorTables;
  final List<TableModel> secondFloorTables = TableRepository().secondFloorTables;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Widget buildTableList(String title, List<TableModel> tables) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ...tables.map((table) => ListTile(
                        leading: Icon(
                          Icons.circle,
                          color: table.available ? Colors.green : Colors.red,
                          size: 18,
                        ),
                        title: Text(table.name),
                        subtitle: Text('${table.seats} seats'),
                        trailing: Switch(
                          value: table.available,
                          onChanged: (val) {
                            setDialogState(() {
                              table.available = val;
                            });
                            setState(() {}); // update appbar if needed
                          },
                          activeColor: Colors.green,
                          inactiveThumbColor: Colors.red,
                        ),
                      )),
                ],
              );
            }
            return AlertDialog(
              title: const Text('Table Status'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTableList('First Floor', firstFloorTables),
                    const SizedBox(height: 12),
                    buildTableList('Second Floor', secondFloorTables),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  late Timer _timer;
  String _currentTime = '';
  String _currentDate = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
      _currentDate =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 130,
        width: double.infinity,
        color: const Color(0xff9D9D9D),
        alignment: Alignment.center,
        child: FractionallySizedBox(
          widthFactor: 0.97,
          child: Container(
            height: 75,
            decoration: BoxDecoration(
              color: const Color(0xffD9D9D9),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              children: [
                const SizedBox(width: 25),

                // ===== LOGO بدل كلمة Logo القديمة =====
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DashboardScreen(userName: 'Admin'),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          text: 'S',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xff6fad99),
                            fontSize: 28,
                            letterSpacing: 2.0,
                          ),
                          children: [
                            TextSpan(
                              text: 'PRS',
                              style: TextStyle(
                                fontSize: 28,
                                letterSpacing: 1.0,
                                color: Color(0xff4a4a4a),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: const TextSpan(
                          text: 'Where ',
                          style: TextStyle(
                            fontWeight: FontWeight.w200,
                            color: Color(0xff4a4a4a),
                            fontSize: 8,
                            letterSpacing: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text: 'Coffee ',
                              style: TextStyle(
                                fontSize: 8,
                                letterSpacing: 1.5,
                                color: Color(0xff6fad99),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: 'Meet Vibes',
                              style: TextStyle(
                                fontWeight: FontWeight.w200,
                                color: Color(0xff4a4a4a),
                                fontSize: 8,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Table status icon


                const Spacer(),

                // Date and user info
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: _currentTime,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: '\t$_currentDate',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Hi, ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: 'admin',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Sales summary button (small, left of logout)
                IconButton(
                  tooltip: 'Total Sales',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Total Sales'),
                        content: ValueListenableBuilder<double>(
                          valueListenable: CartManager.salesNotifier,
                          builder: (context, sales, _) =>
                              Text('${sales.toStringAsFixed(0)} EGP'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.paid, size: 28),
                ),

                // Logout button
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              CartManager.clearAll();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Logout',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.exit_to_app, size: 40),
                ),
                // Cart button
                Padding(
                  padding: const EdgeInsets.only(right: 0.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (context, setModalState) {
                                  final foodItems = CartManager.cartItems;
                                  final drinkItems = CartManager.cartDrinkItems;
                                  final hasItems =
                                      foodItems.isNotEmpty ||
                                      drinkItems.isNotEmpty;
                                  return SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.75,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Order Cart',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                icon: const Icon(Icons.close),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!hasItems)
                                          const Expanded(
                                            child: Center(
                                              child: Text('Cart is empty'),
                                            ),
                                          )
                                        else
                                          Expanded(
                                            child: ListView(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              children: [
                                                if (foodItems.isNotEmpty) ...[
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          vertical: 6.0,
                                                        ),
                                                    child: Text(
                                                      'Food',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  ...foodItems.map(
                                                    (cartItem) => Card(
                                                      child: ListTile(
                                                        title: Text(
                                                          cartItem
                                                              .foodItem
                                                              .name,
                                                        ),
                                                        subtitle: Text(
                                                          '${cartItem.foodItem.price.toStringAsFixed(0)} EGP',
                                                        ),
                                                        trailing: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons.remove,
                                                              ),
                                                              onPressed: () {
                                                                CartManager.updateQuantity(
                                                                  cartItem
                                                                      .foodItem,
                                                                  -1,
                                                                );
                                                                setModalState(
                                                                  () {},
                                                                );
                                                                setState(() {});
                                                              },
                                                            ),
                                                            Text(
                                                              '${cartItem.quantity}',
                                                            ),
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons.add,
                                                              ),
                                                              onPressed: () {
                                                                CartManager.updateQuantity(
                                                                  cartItem
                                                                      .foodItem,
                                                                  1,
                                                                );
                                                                setModalState(
                                                                  () {},
                                                                );
                                                                setState(() {});
                                                              },
                                                            ),
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons.delete,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                              onPressed: () {
                                                                CartManager.removeFromCart(
                                                                  cartItem
                                                                      .foodItem,
                                                                );
                                                                setModalState(
                                                                  () {},
                                                                );
                                                                setState(() {});
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                if (drinkItems.isNotEmpty) ...[
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          vertical: 6.0,
                                                        ),
                                                    child: Text(
                                                      'Drinks',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  ...drinkItems.map(
                                                    (cartItem) => Card(
                                                      child: ListTile(
                                                        title: Text(
                                                          cartItem
                                                              .drinksItem
                                                              .name,
                                                        ),
                                                        subtitle: Text(
                                                          '${cartItem.drinksItem.price.toStringAsFixed(0)} EGP',
                                                        ),
                                                        trailing: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons.remove,
                                                              ),
                                                              onPressed: () {
                                                                CartManager.updateQuantityDrink(
                                                                  cartItem
                                                                      .drinksItem,
                                                                  -1,
                                                                );
                                                                setModalState(
                                                                  () {},
                                                                );
                                                                setState(() {});
                                                              },
                                                            ),
                                                            Text(
                                                              '${cartItem.quantity}',
                                                            ),
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons.add,
                                                              ),
                                                              onPressed: () {
                                                                CartManager.updateQuantityDrink(
                                                                  cartItem
                                                                      .drinksItem,
                                                                  1,
                                                                );
                                                                setModalState(
                                                                  () {},
                                                                );
                                                                setState(() {});
                                                              },
                                                            ),
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons.delete,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                              onPressed: () {
                                                                CartManager.removeFromCartDrink(
                                                                  cartItem
                                                                      .drinksItem,
                                                                );
                                                                setModalState(
                                                                  () {},
                                                                );
                                                                setState(() {});
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                const SizedBox(height: 12),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6.0,
                                                      ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Total: ${CartManager.totalAmount.toStringAsFixed(0)} EGP',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          CartManager.clearAll();
                                                          setModalState(() {});
                                                          setState(() {});
                                                        },
                                                        child: const Text(
                                                          'Clear Cart',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.shopping_cart, size: 36),
                      ),
                      // badge (only show when there are items)
                      if (CartManager.itemCount > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Text(
                              '${CartManager.itemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                  IconButton(
                  tooltip: 'Table Status',
                  icon: const Icon(Icons.table_bar, size: 35, color: Colors.black54),
                  onPressed: () => _showTableStatusDialog(context),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
