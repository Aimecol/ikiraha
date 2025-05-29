# Ikiraha - Smart Advanced Food Ordering App

A Flutter-based food ordering application with modern UI design, state management using Provider, and comprehensive features for browsing restaurants, managing cart, and placing orders.

## Features

### ✅ Completed Features

#### 🏗️ Project Structure & Setup

- ✅ Flutter project initialized with proper folder structure
- ✅ Provider state management setup
- ✅ Custom app theme with consistent colors and typography
- ✅ Asset management configuration
- ✅ Dependencies: Provider, HTTP, Cached Network Image

#### 🎨 UI Components & Navigation

- ✅ Splash screen with animated logo and branding
- ✅ Bottom navigation bar with 4 main sections
- ✅ Custom app theme with Material 3 design
- ✅ Responsive design principles

#### 🏠 Home Screen

- ✅ Search bar with filter functionality
- ✅ Category chips for filtering restaurants
- ✅ Featured restaurants horizontal scroll
- ✅ Restaurant listing with cards
- ✅ Pull-to-refresh functionality

#### 🏪 Shop/Restaurant Features

- ✅ Restaurant cards with images, ratings, delivery info
- ✅ Restaurant detail screen with menu
- ✅ Food item cards with add to cart functionality
- ✅ Mock data for restaurants and food items
- ✅ Category-based filtering

#### 🛒 Cart Management

- ✅ Add/remove items from cart
- ✅ Quantity controls (increase/decrease)
- ✅ Cart item display with images and details
- ✅ Order summary with subtotal, delivery fee, total
- ✅ Free delivery calculation (over $50)
- ✅ Cart badge on navigation bar
- ✅ Empty cart state with call-to-action

#### 💳 Checkout Process

- ✅ Checkout screen with order summary
- ✅ Delivery address section
- ✅ Payment method selection
- ✅ Special instructions input
- ✅ Place order functionality with loading states
- ✅ Order confirmation dialog

#### 👤 Profile & Settings

- ✅ Profile screen with user info
- ✅ Menu items for various settings
- ✅ About dialog with app information
- ✅ Logout functionality

## Technical Implementation

### 🏗️ Architecture

- **State Management**: Provider pattern
- **Navigation**: Bottom navigation with IndexedStack
- **Theme**: Custom Material 3 theme with consistent colors
- **Models**: Comprehensive data models for Restaurant, FoodItem, CartItem
- **Widgets**: Reusable custom widgets for UI components

### 📁 Project Structure

```
lib/
├── constants/          # App colors, strings, theme
├── models/            # Data models (Restaurant, FoodItem, CartItem)
├── providers/         # State management (CartProvider, RestaurantProvider)
├── screens/           # Main app screens
├── widgets/           # Reusable UI components
├── services/          # API services (placeholder)
└── utils/             # Utility functions (placeholder)
```

### 🎨 Design System

- **Primary Color**: Orange-red (#FF6B35) - appetizing for food apps
- **Secondary Color**: Green (#2E7D32) - fresh/healthy association
- **Typography**: Material 3 text styles with custom weights
- **Components**: Cards, buttons, chips with consistent styling
- **Icons**: Material Design icons throughout

### 📱 Screens Implemented

1. **Splash Screen** - Animated app intro
2. **Home Screen** - Restaurant browsing and search
3. **Cart Screen** - Shopping cart management
4. **Checkout Screen** - Order placement flow
5. **Orders Screen** - Order history (placeholder)
6. **Profile Screen** - User settings and info
7. **Restaurant Detail** - Menu browsing and item selection

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- IDE (VS Code, Android Studio, or IntelliJ)

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

### Available Platforms

- ✅ Windows (tested)
- ✅ Android (should work)
- ✅ iOS (should work)
- ✅ Web (should work)

## Dependencies

- `provider: ^6.1.5` - State management
- `cached_network_image: ^3.4.1` - Image caching and loading
- `http: ^1.4.0` - HTTP requests (for future API integration)

## Future Enhancements

### 🚀 Planned Features

- [ ] User authentication and registration
- [ ] Real API integration with Node.js backend
- [ ] MySQL database integration with XAMPP
- [ ] Real-time order tracking
- [ ] Push notifications
- [ ] Payment gateway integration
- [ ] Location services and maps
- [ ] Reviews and ratings system
- [ ] Favorites and order history
- [ ] Admin panel for restaurant management

### 🔧 Technical Improvements

- [ ] Unit and widget tests
- [ ] Integration tests
- [ ] Error handling and retry mechanisms
- [ ] Offline support with local storage
- [ ] Performance optimizations
- [ ] Accessibility improvements
- [ ] Internationalization (i18n)

## Development Notes

### State Management

The app uses Provider for state management with two main providers:

- `CartProvider`: Manages shopping cart state
- `RestaurantProvider`: Manages restaurant and food item data

### Mock Data

Currently using mock data for demonstration. The app includes:

- 3 sample restaurants (Pizza Palace, Burger Barn, Sushi Zen)
- 4 sample food items with various categories
- Realistic pricing and restaurant information

### Testing

To test the app functionality:

1. Browse restaurants on the home screen
2. Tap on a restaurant to view menu
3. Add items to cart using the + button
4. View cart and adjust quantities
5. Proceed to checkout and place order
6. Explore other screens via bottom navigation

## Contributing

This is a learning project for Flutter development. Feel free to explore the code and suggest improvements!

## License

This project is for educational purposes.
