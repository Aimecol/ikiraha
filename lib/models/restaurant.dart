import 'dart:math';

class Restaurant {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String address;
  final double latitude;
  final double longitude;
  final String phoneNumber;
  final String email;
  final double rating;
  final int reviewCount;
  final List<String> categories;
  final int deliveryTime; // in minutes
  final double deliveryFee;
  final double minimumOrder;
  final bool isOpen;
  final String openingHours;
  final String closingHours;
  final bool isPopular;
  final bool isFeatured;
  final List<String> paymentMethods;
  final String? logoUrl;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phoneNumber,
    required this.email,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.categories = const [],
    this.deliveryTime = 30,
    this.deliveryFee = 0.0,
    this.minimumOrder = 0.0,
    this.isOpen = true,
    this.openingHours = '09:00',
    this.closingHours = '22:00',
    this.isPopular = false,
    this.isFeatured = false,
    this.paymentMethods = const ['Cash', 'Card'],
    this.logoUrl,
  });

  // Calculate distance from user location (placeholder - would need actual implementation)
  double calculateDistance(double userLat, double userLng) {
    // This is a simplified calculation - in real app, use proper distance calculation
    const double earthRadius = 6371; // km
    double dLat = _degreesToRadians(latitude - userLat);
    double dLng = _degreesToRadians(longitude - userLng);

    double a =
        (dLat / 2) * (dLat / 2) +
        _degreesToRadians(userLat) *
            _degreesToRadians(latitude) *
            (dLng / 2) *
            (dLng / 2);
    double c = 2 * sqrt(a);
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  // Check if restaurant is currently open
  bool get isCurrentlyOpen {
    if (!isOpen) return false;

    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return currentTime.compareTo(openingHours) >= 0 &&
        currentTime.compareTo(closingHours) <= 0;
  }

  // Get formatted rating
  String get formattedRating => rating.toStringAsFixed(1);

  // Create Restaurant from JSON
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      categories: List<String>.from(json['categories'] ?? []),
      deliveryTime: json['deliveryTime'] ?? 30,
      deliveryFee: (json['deliveryFee'] ?? 0.0).toDouble(),
      minimumOrder: (json['minimumOrder'] ?? 0.0).toDouble(),
      isOpen: json['isOpen'] ?? true,
      openingHours: json['openingHours'] ?? '09:00',
      closingHours: json['closingHours'] ?? '22:00',
      isPopular: json['isPopular'] ?? false,
      isFeatured: json['isFeatured'] ?? false,
      paymentMethods: List<String>.from(
        json['paymentMethods'] ?? ['Cash', 'Card'],
      ),
      logoUrl: json['logoUrl'],
    );
  }

  // Convert Restaurant to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phoneNumber': phoneNumber,
      'email': email,
      'rating': rating,
      'reviewCount': reviewCount,
      'categories': categories,
      'deliveryTime': deliveryTime,
      'deliveryFee': deliveryFee,
      'minimumOrder': minimumOrder,
      'isOpen': isOpen,
      'openingHours': openingHours,
      'closingHours': closingHours,
      'isPopular': isPopular,
      'isFeatured': isFeatured,
      'paymentMethods': paymentMethods,
      'logoUrl': logoUrl,
    };
  }

  // Create a copy with updated values
  Restaurant copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? address,
    double? latitude,
    double? longitude,
    String? phoneNumber,
    String? email,
    double? rating,
    int? reviewCount,
    List<String>? categories,
    int? deliveryTime,
    double? deliveryFee,
    double? minimumOrder,
    bool? isOpen,
    String? openingHours,
    String? closingHours,
    bool? isPopular,
    bool? isFeatured,
    List<String>? paymentMethods,
    String? logoUrl,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      categories: categories ?? this.categories,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      minimumOrder: minimumOrder ?? this.minimumOrder,
      isOpen: isOpen ?? this.isOpen,
      openingHours: openingHours ?? this.openingHours,
      closingHours: closingHours ?? this.closingHours,
      isPopular: isPopular ?? this.isPopular,
      isFeatured: isFeatured ?? this.isFeatured,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Restaurant && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Restaurant(id: $id, name: $name, rating: $rating, deliveryTime: ${deliveryTime}min)';
  }
}
