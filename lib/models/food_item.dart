class FoodItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final String restaurantId;
  final String restaurantName;
  final double rating;
  final int reviewCount;
  final bool isVegetarian;
  final bool isVegan;
  final bool isSpicy;
  final List<String> ingredients;
  final int preparationTime; // in minutes
  final bool isAvailable;
  final double? discountPrice;
  final String? allergens;

  FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.restaurantId,
    required this.restaurantName,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isVegetarian = false,
    this.isVegan = false,
    this.isSpicy = false,
    this.ingredients = const [],
    this.preparationTime = 30,
    this.isAvailable = true,
    this.discountPrice,
    this.allergens,
  });

  // Calculate effective price (discount price if available, otherwise regular price)
  double get effectivePrice => discountPrice ?? price;

  // Check if item has discount
  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  // Calculate discount percentage
  double get discountPercentage {
    if (!hasDiscount) return 0.0;
    return ((price - discountPrice!) / price) * 100;
  }

  // Create FoodItem from JSON
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      restaurantId: json['restaurantId'] ?? '',
      restaurantName: json['restaurantName'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      isVegetarian: json['isVegetarian'] ?? false,
      isVegan: json['isVegan'] ?? false,
      isSpicy: json['isSpicy'] ?? false,
      ingredients: List<String>.from(json['ingredients'] ?? []),
      preparationTime: json['preparationTime'] ?? 30,
      isAvailable: json['isAvailable'] ?? true,
      discountPrice: json['discountPrice']?.toDouble(),
      allergens: json['allergens'],
    );
  }

  // Convert FoodItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'rating': rating,
      'reviewCount': reviewCount,
      'isVegetarian': isVegetarian,
      'isVegan': isVegan,
      'isSpicy': isSpicy,
      'ingredients': ingredients,
      'preparationTime': preparationTime,
      'isAvailable': isAvailable,
      'discountPrice': discountPrice,
      'allergens': allergens,
    };
  }

  // Create a copy with updated values
  FoodItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    String? restaurantId,
    String? restaurantName,
    double? rating,
    int? reviewCount,
    bool? isVegetarian,
    bool? isVegan,
    bool? isSpicy,
    List<String>? ingredients,
    int? preparationTime,
    bool? isAvailable,
    double? discountPrice,
    String? allergens,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isVegan: isVegan ?? this.isVegan,
      isSpicy: isSpicy ?? this.isSpicy,
      ingredients: ingredients ?? this.ingredients,
      preparationTime: preparationTime ?? this.preparationTime,
      isAvailable: isAvailable ?? this.isAvailable,
      discountPrice: discountPrice ?? this.discountPrice,
      allergens: allergens ?? this.allergens,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FoodItem(id: $id, name: $name, price: $price, restaurantName: $restaurantName)';
  }
}
