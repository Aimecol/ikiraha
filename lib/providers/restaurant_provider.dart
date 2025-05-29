import 'package:flutter/foundation.dart';
import '../models/restaurant.dart';
import '../models/food_item.dart';

class RestaurantProvider with ChangeNotifier {
  List<Restaurant> _restaurants = [];
  List<FoodItem> _foodItems = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = '';

  // Getters
  List<Restaurant> get restaurants => List.unmodifiable(_restaurants);
  List<FoodItem> get foodItems => List.unmodifiable(_foodItems);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  // Filtered restaurants based on search and category
  List<Restaurant> get filteredRestaurants {
    var filtered = _restaurants;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((restaurant) {
        return restaurant.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               restaurant.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               restaurant.categories.any((category) => 
                   category.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    // Filter by category
    if (_selectedCategory.isNotEmpty) {
      filtered = filtered.where((restaurant) {
        return restaurant.categories.contains(_selectedCategory);
      }).toList();
    }

    return filtered;
  }

  // Get popular restaurants
  List<Restaurant> get popularRestaurants {
    return _restaurants.where((restaurant) => restaurant.isPopular).toList();
  }

  // Get featured restaurants
  List<Restaurant> get featuredRestaurants {
    return _restaurants.where((restaurant) => restaurant.isFeatured).toList();
  }

  // Get nearby restaurants (sorted by rating for now - would use location in real app)
  List<Restaurant> get nearbyRestaurants {
    var nearby = List<Restaurant>.from(_restaurants);
    nearby.sort((a, b) => b.rating.compareTo(a.rating));
    return nearby.take(10).toList();
  }

  // Get all unique categories
  List<String> get categories {
    final Set<String> categorySet = {};
    for (final restaurant in _restaurants) {
      categorySet.addAll(restaurant.categories);
    }
    return categorySet.toList()..sort();
  }

  // Get food items for a specific restaurant
  List<FoodItem> getFoodItemsForRestaurant(String restaurantId) {
    return _foodItems.where((item) => item.restaurantId == restaurantId).toList();
  }

  // Get food items by category
  List<FoodItem> getFoodItemsByCategory(String category) {
    return _foodItems.where((item) => item.category == category).toList();
  }

  // Search food items
  List<FoodItem> searchFoodItems(String query) {
    if (query.isEmpty) return _foodItems;
    
    return _foodItems.where((item) {
      return item.name.toLowerCase().contains(query.toLowerCase()) ||
             item.description.toLowerCase().contains(query.toLowerCase()) ||
             item.category.toLowerCase().contains(query.toLowerCase()) ||
             item.restaurantName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Set selected category
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = '';
    notifyListeners();
  }

  // Load restaurants (mock data for now)
  Future<void> loadRestaurants() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - in real app, this would come from API
      _restaurants = _getMockRestaurants();
      _foodItems = _getMockFoodItems();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load restaurants: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get restaurant by ID
  Restaurant? getRestaurantById(String id) {
    try {
      return _restaurants.firstWhere((restaurant) => restaurant.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get food item by ID
  FoodItem? getFoodItemById(String id) {
    try {
      return _foodItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // Mock data generators
  List<Restaurant> _getMockRestaurants() {
    return [
      Restaurant(
        id: '1',
        name: 'Pizza Palace',
        description: 'Authentic Italian pizzas with fresh ingredients',
        imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500',
        address: '123 Main St, City Center',
        latitude: 40.7128,
        longitude: -74.0060,
        phoneNumber: '+1234567890',
        email: 'info@pizzapalace.com',
        rating: 4.5,
        reviewCount: 150,
        categories: ['Italian', 'Pizza'],
        deliveryTime: 25,
        deliveryFee: 3.99,
        minimumOrder: 15.0,
        isPopular: true,
        isFeatured: true,
      ),
      Restaurant(
        id: '2',
        name: 'Burger Barn',
        description: 'Juicy burgers and crispy fries',
        imageUrl: 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=500',
        address: '456 Oak Ave, Downtown',
        latitude: 40.7589,
        longitude: -73.9851,
        phoneNumber: '+1234567891',
        email: 'hello@burgerbarn.com',
        rating: 4.2,
        reviewCount: 89,
        categories: ['American', 'Burgers'],
        deliveryTime: 20,
        deliveryFee: 2.99,
        minimumOrder: 12.0,
        isPopular: true,
      ),
      Restaurant(
        id: '3',
        name: 'Sushi Zen',
        description: 'Fresh sushi and Japanese cuisine',
        imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=500',
        address: '789 Pine St, Uptown',
        latitude: 40.7831,
        longitude: -73.9712,
        phoneNumber: '+1234567892',
        email: 'contact@sushizen.com',
        rating: 4.7,
        reviewCount: 203,
        categories: ['Japanese', 'Sushi'],
        deliveryTime: 35,
        deliveryFee: 4.99,
        minimumOrder: 20.0,
        isFeatured: true,
      ),
    ];
  }

  List<FoodItem> _getMockFoodItems() {
    return [
      // Pizza Palace items
      FoodItem(
        id: '1',
        name: 'Margherita Pizza',
        description: 'Classic pizza with tomato sauce, mozzarella, and fresh basil',
        price: 16.99,
        imageUrl: 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=500',
        category: 'Pizza',
        restaurantId: '1',
        restaurantName: 'Pizza Palace',
        rating: 4.6,
        reviewCount: 45,
        isVegetarian: true,
        preparationTime: 20,
      ),
      FoodItem(
        id: '2',
        name: 'Pepperoni Pizza',
        description: 'Delicious pizza topped with pepperoni and cheese',
        price: 18.99,
        imageUrl: 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=500',
        category: 'Pizza',
        restaurantId: '1',
        restaurantName: 'Pizza Palace',
        rating: 4.4,
        reviewCount: 38,
        preparationTime: 22,
      ),
      // Burger Barn items
      FoodItem(
        id: '3',
        name: 'Classic Cheeseburger',
        description: 'Beef patty with cheese, lettuce, tomato, and special sauce',
        price: 12.99,
        imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
        category: 'Burgers',
        restaurantId: '2',
        restaurantName: 'Burger Barn',
        rating: 4.3,
        reviewCount: 67,
        preparationTime: 15,
      ),
      // Sushi Zen items
      FoodItem(
        id: '4',
        name: 'Salmon Roll',
        description: 'Fresh salmon with avocado and cucumber',
        price: 14.99,
        imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=500',
        category: 'Sushi',
        restaurantId: '3',
        restaurantName: 'Sushi Zen',
        rating: 4.8,
        reviewCount: 92,
        preparationTime: 25,
      ),
    ];
  }
}
