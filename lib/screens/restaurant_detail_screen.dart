import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';
import '../models/restaurant.dart';
import '../providers/restaurant_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/food_item_card.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Restaurant Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: restaurant.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.divider,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.divider,
                  child: const Icon(
                    Icons.restaurant,
                    size: 80,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          
          // Restaurant Info
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    restaurant.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Rating and Info Row
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 20,
                        color: AppColors.star,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.formattedRating,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        ' (${restaurant.reviewCount} reviews)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: restaurant.isCurrentlyOpen 
                              ? AppColors.success 
                              : AppColors.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          restaurant.isCurrentlyOpen ? 'Open' : 'Closed',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Delivery Info
                  Row(
                    children: [
                      _buildInfoChip(
                        context,
                        Icons.access_time,
                        '${restaurant.deliveryTime} min',
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        context,
                        Icons.delivery_dining,
                        restaurant.deliveryFee == 0 
                            ? 'Free delivery' 
                            : '\$${restaurant.deliveryFee.toStringAsFixed(2)}',
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        context,
                        Icons.shopping_cart,
                        'Min \$${restaurant.minimumOrder.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                  
                  // Categories
                  if (restaurant.categories.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: restaurant.categories.map((category) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Menu Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Menu',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          
          // Menu Items
          Consumer<RestaurantProvider>(
            builder: (context, restaurantProvider, child) {
              final foodItems = restaurantProvider.getFoodItemsForRestaurant(restaurant.id);
              
              if (foodItems.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Menu coming soon',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final foodItem = foodItems[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: FoodItemCard(foodItem: foodItem),
                      );
                    },
                    childCount: foodItems.length,
                  ),
                ),
              );
            },
          ),
          
          // Bottom padding for cart button
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
      
      // Floating Cart Button
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isEmpty) return const SizedBox.shrink();
          
          return FloatingActionButton.extended(
            onPressed: () {
              // Navigate to cart
              DefaultTabController.of(context).animateTo(1);
              Navigator.of(context).pop();
            },
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.shopping_cart),
            label: Text(
              '${cartProvider.itemCount} items • \$${cartProvider.total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
