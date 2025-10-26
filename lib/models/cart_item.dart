import 'drinks_item.dart';
import 'food_item.dart';

class CartItem {
  final FoodItem foodItem;
  int quantity;

  CartItem({required this.foodItem, this.quantity = 1});

  double get totalPrice => foodItem.price * quantity;
}

class CartItemDrink {
  final DrinksItem drinksItem;
  int quantity;

  CartItemDrink({required this.drinksItem, this.quantity = 1});

  double get totalPrice => drinksItem.price * quantity;
}
