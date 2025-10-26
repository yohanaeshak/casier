import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/table_model.dart';
import '../data/table_repository.dart';
import '../services/cart_manger.dart';
import '../widgets/custom_appBar.dart';
import '../utils/notification_helper.dart';
import 'dashboard.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final String userName;
  final String category;
  final String diningOption;
  const OrderConfirmationScreen({
    super.key,
    required this.userName,
    required this.category,
    required this.diningOption,
  });

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  String? _selectedDiningOption;
  TableModel? _selectedTable;

  final List<TableModel> firstFloorTables = TableRepository().firstFloorTables;
  final List<TableModel> secondFloorTables = TableRepository().secondFloorTables;

  @override
  void initState() {
    super.initState();
    _selectedDiningOption = widget.diningOption;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: custom_appBar()),
              ],
            ),
            const SizedBox(height: 10),
            _buildAppNameBanner(),
                            IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
            const SizedBox(height: 15),
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: CartManager.itemCountNotifier,
                builder: (context, value, _) {
                  return Column(
                    children: [
                      Expanded(child: _buildOrderItemsList()),
                      const SizedBox(height: 15),
                      _buildTotalSection(),
                      const SizedBox(height: 15),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: CartManager.itemCount == 0 ? null : _confirmOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: Colors.black.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            CartManager.itemCount == 0 ? 'CART IS EMPTY' : 'CONFIRM ORDER',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppNameBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
      decoration: BoxDecoration(
        color: Color(0xffD9D9D9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'ORDER CONFIRMATION',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildOrderItemsList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CartManager.itemCount == 0
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 50,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No items in cart',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (CartManager.cartItems.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.0),
                    child: Text('Food', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  ...CartManager.cartItems.map((ci) => _buildOrderItem(ci, CartManager.cartItems.indexOf(ci))),
                ],
                if (CartManager.cartDrinkItems.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.0),
                    child: Text('Drinks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  ...CartManager.cartDrinkItems.map((ci) => _buildOrderItemDrink(ci, CartManager.cartDrinkItems.indexOf(ci))),
                ],
              ],
            ),
    );
  }

  void _removeDrinkItem(int index) {
    setState(() {
      final cartItem = CartManager.cartDrinkItems[index];
      CartManager.removeFromCartDrink(cartItem.drinksItem);
    });
  }

  Widget _buildOrderItemDrink(CartItemDrink cartItem, int index) {
    return Dismissible(
      key: Key(cartItem.drinksItem.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.black,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white, size: 25),
      ),
      onDismissed: (direction) => _removeDrinkItem(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.coffee,
                color: Colors.black,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.drinksItem.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Quantity: ${cartItem.quantity}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${cartItem.drinksItem.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 3),
                Text(
                  '\$${cartItem.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(CartItem cartItem, int index) {
    return Dismissible(
      key: Key(cartItem.foodItem.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.black,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white, size: 25),
      ),
      onDismissed: (direction) => _removeItem(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: widget.category == 'Restaurant'
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.category == 'Restaurant' ? Icons.restaurant : Icons.coffee,
                color: widget.category == 'Restaurant'
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFAB47BC),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.foodItem.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Quantity: ${cartItem.quantity}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${cartItem.foodItem.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 3),
                Text(
                  '\$${cartItem.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSection() {
    final isTakeAway = _selectedDiningOption == 'Take Away';
    final serviceType = isTakeAway
        ? 'Take Away'
        : _selectedTable != null
            ? 'Service (Table ${_selectedTable!.name})'
            : (widget.diningOption.isNotEmpty ? widget.diningOption : 'Not selected');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Service Type:',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              Text(
                serviceType,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          // Show subtotal, tax (if dine-in) and final total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              Text(
                '${CartManager.totalAmount.toStringAsFixed(2)} EGP',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isTakeAway ? 'Tax (0%)' : 'Tax (14%)',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              Text(
                '${(isTakeAway ? 0.0 : CartManager.totalAmount * 0.14).toStringAsFixed(2)} EGP',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${(CartManager.totalAmount + (isTakeAway ? 0.0 : CartManager.totalAmount * 0.14)).toStringAsFixed(2)} EGP',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableChip(TableModel table) {
    final isSelected = _selectedTable?.id == table.id && _selectedDiningOption != 'Take Away';
    return ChoiceChip(
      label: Text(table.name),
      selected: isSelected,
      selectedColor: Colors.green,
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedTable = table;
            _selectedDiningOption = 'Service';
          });
        }
      },
    );
  }

  

  void _removeItem(int index) {
    setState(() {
      final cartItem = CartManager.cartItems[index];
      CartManager.removeFromCart(cartItem.foodItem);
    });
  }

  void _confirmOrder() {
    // Use the dining option supplied to this screen; compute totals and confirm
    final subtotal = CartManager.totalAmount;
    final tax = widget.diningOption == 'Take Away' ? 0.0 : subtotal * 0.14;
    final finalTotal = subtotal + tax;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Service Type: ${widget.diningOption}'),
              const SizedBox(height: 8),
              Text('Subtotal: ${subtotal.toStringAsFixed(2)} EGP'),
              const SizedBox(height: 6),
              Text('Tax: ${tax.toStringAsFixed(2)} EGP'),
              const SizedBox(height: 6),
              Text('Total Amount: ${finalTotal.toStringAsFixed(2)} EGP'),
              const SizedBox(height: 8),
              const Text('Are you sure you want to confirm this order?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Mark table as occupied if selected
                if (_selectedTable != null) {
                  setState(() {
                    _selectedTable!.available = false;
                  });
                }
                showConfirmOrderNotification(
                  context,
                  'Order confirmed successfully for ${finalTotal.toStringAsFixed(2)} EGP!',
                );
                // record sale before clearing the cart
                CartManager.recordSale(finalTotal);
                CartManager.clearAll();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DashboardScreen(userName: widget.userName),
                  ),
                  (route) => false,
                );
              },
              child: const Text(
                'Confirm',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }
}
