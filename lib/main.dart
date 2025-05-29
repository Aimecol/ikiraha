import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'constants/app_strings.dart';
import 'providers/cart_provider.dart';
import 'providers/restaurant_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/auth_wrapper.dart';

void main() {
  runApp(const IkirahaApp());
}

class IkirahaApp extends StatelessWidget {
  const IkirahaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
