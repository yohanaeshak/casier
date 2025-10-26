import 'package:flutter/material.dart';
import 'package:untitled3/screens/table_selection.dart';
import '../data/drink_data.dart';
import '../models/cart_item.dart';
import '../models/drinks_item.dart';
import '../services/cart_manger.dart';
import '../widgets/custom_appBar.dart';
import 'item_selection_food.dart';

class ItemSelectionScreenDrink extends StatefulWidget {
  final String userName;
  final String category;

  const ItemSelectionScreenDrink({
    super.key,
    required this.userName,
    required this.category,
  });

  @override
  State<ItemSelectionScreenDrink> createState() =>
      _ItemSelectionScreenDrinkState();
}

class _ItemSelectionScreenDrinkState extends State<ItemSelectionScreenDrink> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _categoryKeys = {};
  String _searchQuery = '';

  List<DrinksItem> get _drinkItems {
    if (widget.category == 'Cafe') return cafeItems;
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
            Expanded(child: _buildDrinkItemsList(groupedItems)),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search drinks...',
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
                    builder: (context) => ItemSelectionScreenFood(
                      userName: widget.userName,
                      category: 'Restaurant',
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
            tooltip: 'Open Restaurant',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ItemSelectionScreenFood(
                    userName: widget.userName,
                    category: 'Restaurant',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.restaurant, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Map<String, List<DrinksItem>> _groupItemsByCategory() {
    final Map<String, List<DrinksItem>> groupedItems = {};
    final query = _searchQuery.toLowerCase();
    for (var item in _drinkItems) {
      if (query.isNotEmpty && !item.name.toLowerCase().contains(query)) continue;
      groupedItems.putIfAbsent(item.subCategory, () => []).add(item);
    }
    return groupedItems;
  }

  Widget _buildDrinkItemsList(Map<String, List<DrinksItem>> groupedItems) {
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
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.6,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                return _buildDrinkCard(item);
              },
            ),
            const SizedBox(height: 10),
            const Divider(color: Colors.grey, thickness: 0.5),
          ],
        );
      },
    );
  }

  Widget _buildDrinkCard(DrinksItem drinksItem) {
    final cartItem = CartManager.cartDrinkItems.firstWhere(
          (item) => item.drinksItem.id == drinksItem.id,
      orElse: () => CartItemDrink(
        drinksItem:
        DrinksItem(id: '', name: '', price: 0, category: '', subCategory: ''),
      ),
    );
    final isInCart = cartItem.drinksItem.id == drinksItem.id;

    return GestureDetector(
      onTap: () {
        if (!isInCart) {
          setState(() => CartManager.addToCartDrink(drinksItem));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_cafe, color: Colors.black, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    drinksItem.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${drinksItem.price.toStringAsFixed(0)} EGP',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: isInCart
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove,
                        size: 20, color: Colors.black),
                    onPressed: () =>
                        _updateDrinkQuantity(drinksItem, -1),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 30),
                  Text(
                    '${cartItem.quantity}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 30),
                  IconButton(
                    icon: const Icon(Icons.add,
                        size: 20, color: Colors.black),
                    onPressed: () =>
                        _updateDrinkQuantity(drinksItem, 1),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              )
                  : const Center(
                child: Text(
                  'Tap to add',
                  style: TextStyle(
                    fontSize: 16,
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

  void _updateDrinkQuantity(DrinksItem drinksItem, int change) =>
      setState(() => CartManager.updateQuantityDrink(drinksItem, change));

  void _navigateToOrderConfirmation() {
    if (CartManager.itemCount == 0) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TableSelection()),
    );
  }
}
