import 'package:flutter/material.dart';
import 'package:untitled3/screens/table_selection.dart';
import '../data/food_data.dart';
import '../models/cart_item.dart';
import '../models/food_item.dart';
import '../services/cart_manger.dart';
import '../widgets/custom_appBar.dart';
import 'item_selection_drink.dart';
import 'order_confirmation.dart';

class ItemSelectionScreenFood extends StatefulWidget {
  final String userName;
  final String category;

  const ItemSelectionScreenFood({
    super.key,
    required this.userName,
    required this.category,
  });

  @override
  State<ItemSelectionScreenFood> createState() => _ItemSelectionScreenState();
}

class _ItemSelectionScreenState extends State<ItemSelectionScreenFood> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _categoryKeys = {};
  String _searchQuery = '';

  List<FoodItem> get _foodItems {
    if (widget.category == 'Restaurant') return restaurantItems;
    return [];
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupedItems = _groupItemsByCategory();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            custom_appBar(),
            const SizedBox(height: 20),
            _buildHeaderBanner(),
            const SizedBox(height: 12),
            _buildSearchBar(),
            const SizedBox(height: 10),
            Expanded(child: _buildFoodItemsList(groupedItems)),
            ValueListenableBuilder<int>(
              valueListenable: CartManager.itemCountNotifier,
              builder: (context, value, child) {
                if (value == 0) return const SizedBox.shrink();
                return _buildCartSummary();
              },
            ),
          ],
        ),
      ),
    );
  }

  // 🔍 Search bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search food items...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: const Color(0xFFF2F2F2),
          contentPadding:
          const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) => setState(() => _searchQuery = value.trim()),
      ),
    );
  }

  // 🍽️ Header banner with navigation
  Widget _buildHeaderBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemSelectionScreenDrink(
                      userName: widget.userName,
                      category: 'Cafe',
                    ),
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              child: Text(
                widget.category.toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Open Drinks',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ItemSelectionScreenDrink(
                    userName: widget.userName,
                    category: 'Cafe',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.local_cafe, color: Colors.black),
          ),
        ],
      ),
    );
  }

  // 🍱 Group food items by category
  Map<String, List<FoodItem>> _groupItemsByCategory() {
    final Map<String, List<FoodItem>> groupedItems = {};
    final query = _searchQuery.toLowerCase();
    for (var item in _foodItems) {
      if (query.isNotEmpty && !item.name.toLowerCase().contains(query)) continue;
      groupedItems.putIfAbsent(item.category, () => []).add(item);
    }
    return groupedItems;
  }

  // 🧾 Main list of categories and grid of items
  Widget _buildFoodItemsList(Map<String, List<FoodItem>> groupedItems) {
    final sortedKeys = groupedItems.keys.toList()..sort();
    if (sortedKeys.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40.0),
          child: Text('No items found', style: TextStyle(fontSize: 16)),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final category = sortedKeys[index];
        final items = groupedItems[category]!;

        final key = GlobalKey();
        _categoryKeys[category] = key;

        return Column(
          key: key,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              child: Text(
                category,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            // ✅ Responsive Grid
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount =
                (constraints.maxWidth / 220).floor().clamp(1, 6);
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.8,
                  children: items.map((item) {
                    return _buildFoodItemRow(item);
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 10),
            const Divider(color: Colors.grey, thickness: 0.5),
          ],
        );
      },
    );
  }

  // 🍔 Single food item display with tap-to-add
  Widget _buildFoodItemRow(FoodItem foodItem) {
    final cartItem = CartManager.cartItems.firstWhere(
          (item) => item.foodItem.id == foodItem.id,
      orElse: () =>
          CartItem(foodItem: FoodItem(id: '', name: '', price: 0, category: '')),
    );
    final isInCart = cartItem.foodItem.id == foodItem.id;

    return GestureDetector(
      onTap: () {
        if (!isInCart) {
          _addToCart(foodItem);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.fastfood, color: Colors.black, size: 18),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        foodItem.name,
                        style: TextStyle(
                          fontSize:
                          MediaQuery.of(context).size.width > 1200 ? 15 : 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${foodItem.price.toStringAsFixed(0)} EGP',
                        style: TextStyle(
                          fontSize:
                          MediaQuery.of(context).size.width > 1200 ? 14 : 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: isInCart
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove,
                        size: 20, color: Colors.black),
                    onPressed: () => _updateQuantity(foodItem, -1),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 50),
                  Text(
                    '${cartItem.quantity}',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width > 1200
                          ? 13
                          : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 50),
                  IconButton(
                    icon: const Icon(Icons.add,
                        size: 20, color: Colors.black),
                    onPressed: () => _updateQuantity(foodItem, 1),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              )
                  : const Center(
                child: Text(
                  'Tap to add',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black45,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🛒 Cart Summary
  Widget _buildCartSummary() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Items: ${CartManager.itemCount}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '${CartManager.totalAmount.toStringAsFixed(0)} EGP',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: _navigateToOrderConfirmation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'PROCEED TO CHECKOUT',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🧠 Helpers
  void _addToCart(FoodItem foodItem) =>
      setState(() => CartManager.addToCart(foodItem));

  void _updateQuantity(FoodItem foodItem, int change) =>
      setState(() => CartManager.updateQuantity(foodItem, change));

  void _navigateToOrderConfirmation() {
    if (CartManager.itemCount == 0) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TableSelection(),
      ),
    );
  }
}
