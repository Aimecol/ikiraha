import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/restaurant_provider.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.text = context.read<RestaurantProvider>().searchQuery;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: (value) {
          context.read<RestaurantProvider>().setSearchQuery(value);
        },
        decoration: InputDecoration(
          hintText: '${AppStrings.search} restaurants, cuisines...',
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    _controller.clear();
                    context.read<RestaurantProvider>().setSearchQuery('');
                    _focusNode.unfocus();
                  },
                )
              : IconButton(
                  icon: const Icon(
                    Icons.tune,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    _showFilterBottomSheet(context);
                  },
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }
}

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Filter & Sort',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            
            // Sort Options
            Text(
              'Sort by',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            
            _buildSortOption(context, 'Rating', Icons.star),
            _buildSortOption(context, 'Delivery Time', Icons.access_time),
            _buildSortOption(context, 'Delivery Fee', Icons.delivery_dining),
            _buildSortOption(context, 'Distance', Icons.location_on),
            
            const SizedBox(height: 24),
            
            // Filter Options
            Text(
              'Filters',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            
            _buildFilterOption(context, 'Free Delivery', false),
            _buildFilterOption(context, 'Open Now', false),
            _buildFilterOption(context, 'Featured', false),
            _buildFilterOption(context, 'Popular', false),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // TODO: Apply filters
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(BuildContext context, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      trailing: Radio<String>(
        value: title,
        groupValue: null, // TODO: Implement sort state
        onChanged: (value) {
          // TODO: Handle sort selection
        },
        activeColor: AppColors.primary,
      ),
      onTap: () {
        // TODO: Handle sort selection
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildFilterOption(BuildContext context, String title, bool isSelected) {
    return ListTile(
      title: Text(title),
      trailing: Switch(
        value: isSelected,
        onChanged: (value) {
          // TODO: Handle filter toggle
        },
        activeColor: AppColors.primary,
      ),
      onTap: () {
        // TODO: Handle filter toggle
      },
      contentPadding: EdgeInsets.zero,
    );
  }
}
