import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/food_item.dart';
import '../providers/cart_provider.dart';

class FoodItemCard extends StatelessWidget {
  final FoodItem foodItem;

  const FoodItemCard({
    super.key,
    required this.foodItem,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food Name
                  Text(
                    foodItem.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Description
                  Text(
                    foodItem.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Tags (Vegetarian, Vegan, Spicy)
                  Row(
                    children: [
                      if (foodItem.isVegetarian)
                        _buildTag(context, '🥬', 'Vegetarian', AppColors.success),
                      if (foodItem.isVegan)
                        _buildTag(context, '🌱', 'Vegan', AppColors.success),
                      if (foodItem.isSpicy)
                        _buildTag(context, '🌶️', 'Spicy', AppColors.warning),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Rating and Prep Time
                  Row(
                    children: [
                      if (foodItem.rating > 0) ...[
                        Icon(
                          Icons.star,
                          size: 16,
                          color: AppColors.star,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          foodItem.rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          ' (${foodItem.reviewCount})',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${foodItem.preparationTime} min',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Price and Add Button
                  Row(
                    children: [
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (foodItem.hasDiscount) ...[
                            Text(
                              '\$${foodItem.price.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            '\$${foodItem.effectivePrice.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                          ),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Add to Cart Button
                      Consumer<CartProvider>(
                        builder: (context, cartProvider, child) {
                          final quantity = cartProvider.getItemQuantity(foodItem.id);
                          
                          if (quantity == 0) {
                            return ElevatedButton(
                              onPressed: foodItem.isAvailable
                                  ? () {
                                      cartProvider.addItem(foodItem);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(AppStrings.addedToCart),
                                          backgroundColor: AppColors.success,
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                foodItem.isAvailable ? 'Add' : 'Unavailable',
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }
                          
                          // Quantity Controls
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.primary),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    final cartItem = cartProvider.getCartItem(foodItem.id);
                                    if (cartItem != null) {
                                      cartProvider.decreaseQuantity(cartItem.id);
                                    }
                                  },
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(8),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(
                                      Icons.remove,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: const BoxDecoration(
                                    border: Border.symmetric(
                                      vertical: BorderSide(color: AppColors.primary),
                                    ),
                                  ),
                                  child: Text(
                                    '$quantity',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    cartProvider.addItem(foodItem);
                                  },
                                  borderRadius: const BorderRadius.horizontal(
                                    right: Radius.circular(8),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(
                                      Icons.add,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Food Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: foodItem.imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 100,
                  height: 100,
                  color: AppColors.divider,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 100,
                  height: 100,
                  color: AppColors.divider,
                  child: const Icon(
                    Icons.fastfood,
                    size: 40,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String emoji, String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
