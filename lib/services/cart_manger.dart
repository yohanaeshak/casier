import '../models/cart_item.dart';
import '../models/food_item.dart';
import '../models/drinks_item.dart';
import 'package:flutter/foundation.dart';

class CartManager {
  static List<CartItem> _cartItems = [];
  static List<CartItemDrink> _cartDrinkItems = [];

  static List<CartItem> get cartItems => List.from(_cartItems);
  static List<CartItemDrink> get cartDrinkItems => List.from(_cartDrinkItems);

  // Notifier to let UI widgets rebuild when cart contents change.
  static final ValueNotifier<int> itemCountNotifier = ValueNotifier<int>(0);
  // Accumulated total of confirmed orders (sales)
  static double _totalSales = 0.0;
  static double get totalSales => _totalSales;
  static final ValueNotifier<double> salesNotifier = ValueNotifier<double>(_totalSales);

  /// Record a confirmed sale amount and notify listeners.
  static void recordSale(double amount) {
    if (amount <= 0) return;
    _totalSales += amount;
    salesNotifier.value = _totalSales;
  }

  static void addToCart(FoodItem foodItem) {
    final existingItem = _cartItems.indexWhere(
      (item) => item.foodItem.id == foodItem.id,
    );
    if (existingItem >= 0) {
      _cartItems[existingItem].quantity++;
    } else {
      _cartItems.add(CartItem(foodItem: foodItem));
    }
    itemCountNotifier.value = itemCount;
  }

  static void addToCartDrink(DrinksItem drinksItem) {
    final existingItem = _cartDrinkItems.indexWhere(
      (item) => item.drinksItem.id == drinksItem.id,
    );
    if (existingItem >= 0) {
      _cartDrinkItems[existingItem].quantity++;
    } else {
      _cartDrinkItems.add(CartItemDrink(drinksItem: drinksItem));
    }
    itemCountNotifier.value = itemCount;
  }

  static void updateQuantity(FoodItem foodItem, int change) {
    final existingItem = _cartItems.indexWhere(
      (item) => item.foodItem.id == foodItem.id,
    );
    if (existingItem >= 0) {
      _cartItems[existingItem].quantity += change;
      if (_cartItems[existingItem].quantity <= 0) {
        _cartItems.removeAt(existingItem);
      }
    }
    itemCountNotifier.value = itemCount;
  }

  static void updateQuantityDrink(DrinksItem drinksItem, int change) {
    final existingItem = _cartDrinkItems.indexWhere(
      (item) => item.drinksItem.id == drinksItem.id,
    );
    if (existingItem >= 0) {
      _cartDrinkItems[existingItem].quantity += change;
      if (_cartDrinkItems[existingItem].quantity <= 0) {
        _cartDrinkItems.removeAt(existingItem);
      }
    }
    itemCountNotifier.value = itemCount;
  }

  static void removeFromCart(FoodItem foodItem) {
    _cartItems.removeWhere((item) => item.foodItem.id == foodItem.id);
    itemCountNotifier.value = itemCount;
  }

  static void removeFromCartDrink(DrinksItem drinksItem) {
    _cartDrinkItems.removeWhere((item) => item.drinksItem.id == drinksItem.id);
    itemCountNotifier.value = itemCount;
  }

  static void clearCart() {
    _cartItems.clear();
    itemCountNotifier.value = itemCount;
  }

  static void clearDrinkCart() {
    _cartDrinkItems.clear();
    itemCountNotifier.value = itemCount;
  }

  /// Clear all cart data (both food and drinks).
  static void clearAll() {
    _cartItems.clear();
    _cartDrinkItems.clear();
    itemCountNotifier.value = itemCount;
  }

  static double get totalAmount {
    final foodTotal = _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    final drinkTotal = _cartDrinkItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    return foodTotal + drinkTotal;
  }

  static int get itemCount => _cartItems.length + _cartDrinkItems.length;
}
