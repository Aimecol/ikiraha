import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/restaurant_provider.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/search_bar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load restaurants when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantProvider>().loadRestaurants();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: Consumer<RestaurantProvider>(
        builder: (context, restaurantProvider, child) {
          if (restaurantProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (restaurantProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    restaurantProvider.error!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      restaurantProvider.loadRestaurants();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => restaurantProvider.loadRestaurants(),
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  const SearchBarWidget(),
                  const SizedBox(height: 20),

                  // Categories
                  Text(
                    AppStrings.categories,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: restaurantProvider.categories.length,
                      itemBuilder: (context, index) {
                        final category = restaurantProvider.categories[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: CategoryChip(
                            label: category,
                            isSelected: restaurantProvider.selectedCategory == category,
                            onTap: () {
                              if (restaurantProvider.selectedCategory == category) {
                                restaurantProvider.setSelectedCategory('');
                              } else {
                                restaurantProvider.setSelectedCategory(category);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Featured Restaurants
                  if (restaurantProvider.featuredRestaurants.isNotEmpty) ...[
                    Text(
                      AppStrings.featuredRestaurants,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: restaurantProvider.featuredRestaurants.length,
                        itemBuilder: (context, index) {
                          final restaurant = restaurantProvider.featuredRestaurants[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: SizedBox(
                              width: 300,
                              child: RestaurantCard(
                                restaurant: restaurant,
                                isHorizontal: true,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // All Restaurants
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        restaurantProvider.selectedCategory.isNotEmpty
                            ? '${restaurantProvider.selectedCategory} Restaurants'
                            : AppStrings.restaurants,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (restaurantProvider.searchQuery.isNotEmpty ||
                          restaurantProvider.selectedCategory.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            restaurantProvider.clearFilters();
                          },
                          child: const Text('Clear Filters'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Restaurant List
                  if (restaurantProvider.filteredRestaurants.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.restaurant_outlined,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No restaurants found',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or filters',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: restaurantProvider.filteredRestaurants.length,
                      itemBuilder: (context, index) {
                        final restaurant = restaurantProvider.filteredRestaurants[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: RestaurantCard(restaurant: restaurant),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
