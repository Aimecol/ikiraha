import 'food_item.dart';

class CartItem {
  final String id;
  final FoodItem foodItem;
  int quantity;
  final String? specialInstructions;
  final DateTime addedAt;

  CartItem({
    required this.id,
    required this.foodItem,
    this.quantity = 1,
    this.specialInstructions,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  // Calculate total price for this cart item
  double get totalPrice => foodItem.effectivePrice * quantity;

  // Create CartItem from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '',
      foodItem: FoodItem.fromJson(json['foodItem'] ?? {}),
      quantity: json['quantity'] ?? 1,
      specialInstructions: json['specialInstructions'],
      addedAt: json['addedAt'] != null 
          ? DateTime.parse(json['addedAt']) 
          : DateTime.now(),
    );
  }

  // Convert CartItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodItem': foodItem.toJson(),
      'quantity': quantity,
      'specialInstructions': specialInstructions,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  // Create a copy with updated values
  CartItem copyWith({
    String? id,
    FoodItem? foodItem,
    int? quantity,
    String? specialInstructions,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      foodItem: foodItem ?? this.foodItem,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && 
           other.id == id && 
           other.foodItem.id == foodItem.id;
  }

  @override
  int get hashCode => id.hashCode ^ foodItem.id.hashCode;

  @override
  String toString() {
    return 'CartItem(id: $id, foodItem: ${foodItem.name}, quantity: $quantity, totalPrice: $totalPrice)';
  }
}
