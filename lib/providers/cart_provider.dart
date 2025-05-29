import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/food_item.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  
  List<CartItem> get items => List.unmodifiable(_items);
  
  int get itemCount => _items.length;
  
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);
  
  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  
  double get deliveryFee => subtotal > 50 ? 0.0 : 5.0; // Free delivery over $50
  
  double get total => subtotal + deliveryFee;
  
  bool get isEmpty => _items.isEmpty;
  
  bool get isNotEmpty => _items.isNotEmpty;

  // Add item to cart
  void addItem(FoodItem foodItem, {int quantity = 1, String? specialInstructions}) {
    final existingIndex = _items.indexWhere(
      (item) => item.foodItem.id == foodItem.id && 
                item.specialInstructions == specialInstructions,
    );

    if (existingIndex >= 0) {
      // Item already exists, update quantity
      _items[existingIndex].quantity += quantity;
    } else {
      // Add new item
      final cartItem = CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        foodItem: foodItem,
        quantity: quantity,
        specialInstructions: specialInstructions,
      );
      _items.add(cartItem);
    }
    
    notifyListeners();
  }

  // Remove item from cart
  void removeItem(String cartItemId) {
    _items.removeWhere((item) => item.id == cartItemId);
    notifyListeners();
  }

  // Update item quantity
  void updateQuantity(String cartItemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(cartItemId);
      return;
    }

    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      _items[index].quantity = newQuantity;
      notifyListeners();
    }
  }

  // Increase item quantity
  void increaseQuantity(String cartItemId) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  // Decrease item quantity
  void decreaseQuantity(String cartItemId) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        removeItem(cartItemId);
      }
      notifyListeners();
    }
  }

  // Get quantity of specific food item in cart
  int getItemQuantity(String foodItemId) {
    return _items
        .where((item) => item.foodItem.id == foodItemId)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  // Check if food item is in cart
  bool isInCart(String foodItemId) {
    return _items.any((item) => item.foodItem.id == foodItemId);
  }

  // Get cart item by food item id
  CartItem? getCartItem(String foodItemId) {
    try {
      return _items.firstWhere((item) => item.foodItem.id == foodItemId);
    } catch (e) {
      return null;
    }
  }

  // Clear entire cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Get items grouped by restaurant
  Map<String, List<CartItem>> getItemsByRestaurant() {
    final Map<String, List<CartItem>> groupedItems = {};
    
    for (final item in _items) {
      final restaurantId = item.foodItem.restaurantId;
      if (groupedItems.containsKey(restaurantId)) {
        groupedItems[restaurantId]!.add(item);
      } else {
        groupedItems[restaurantId] = [item];
      }
    }
    
    return groupedItems;
  }

  // Check if cart has items from multiple restaurants
  bool hasMultipleRestaurants() {
    if (_items.isEmpty) return false;
    
    final firstRestaurantId = _items.first.foodItem.restaurantId;
    return _items.any((item) => item.foodItem.restaurantId != firstRestaurantId);
  }

  // Get the restaurant ID of items in cart (if all from same restaurant)
  String? getCurrentRestaurantId() {
    if (_items.isEmpty) return null;
    if (hasMultipleRestaurants()) return null;
    return _items.first.foodItem.restaurantId;
  }

  // Save cart to local storage (placeholder - would implement with shared_preferences)
  Future<void> saveCart() async {
    // TODO: Implement local storage
    // final prefs = await SharedPreferences.getInstance();
    // final cartJson = _items.map((item) => item.toJson()).toList();
    // await prefs.setString('cart', jsonEncode(cartJson));
  }

  // Load cart from local storage (placeholder)
  Future<void> loadCart() async {
    // TODO: Implement local storage
    // final prefs = await SharedPreferences.getInstance();
    // final cartString = prefs.getString('cart');
    // if (cartString != null) {
    //   final cartJson = jsonDecode(cartString) as List;
    //   _items.clear();
    //   _items.addAll(cartJson.map((item) => CartItem.fromJson(item)));
    //   notifyListeners();
    // }
  }
}
