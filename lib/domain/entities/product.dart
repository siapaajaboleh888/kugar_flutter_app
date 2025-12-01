class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String? category;
  final bool isAvailable;
  final double? rating;
  final int? reviewCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.category,
    this.isAvailable = true,
    this.rating,
    this.reviewCount,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Handle price that can be string or number
    double parsedPrice = 0.0;
    final hargaValue = json['harga'] ?? json['price'];
    if (hargaValue != null) {
      if (hargaValue is String) {
        parsedPrice = double.tryParse(hargaValue) ?? 0.0;
      } else if (hargaValue is num) {
        parsedPrice = hargaValue.toDouble();
      }
    }

    String? imageUrl;

    // Try direct string fields first
    imageUrl =
        json['image_url'] ??
        json['foto'] ??
        json['image'] ??
        json['gambar'] as String?;

    // If not found, check if images is an array
    if (imageUrl == null &&
        json['images'] is List &&
        (json['images'] as List).isNotEmpty) {
      final firstImage = (json['images'] as List).first;
      if (firstImage is String) {
        imageUrl = firstImage;
      } else if (firstImage is Map && firstImage['url'] != null) {
        imageUrl = firstImage['url'] as String?;
      }
    }

    // Check nested image object
    if (imageUrl == null && json['image'] is Map) {
      final imageObj = json['image'] as Map;
      imageUrl =
          imageObj['url'] ?? imageObj['path'] ?? imageObj['src'] as String?;
    }

    print(
      'DEBUG Product.fromJson: id=${json['id']}, name=${json['nama'] ?? json['name']}, imageUrl=$imageUrl',
    );
    print('DEBUG Product.fromJson: full json keys: ${json.keys.toList()}');

    return Product(
      id: (json['id'] as int?) ?? 0,
      name: json['nama'] ?? json['name'] ?? '',
      description: json['deskripsi'] ?? json['description'] ?? '',
      price: parsedPrice,
      imageUrl: imageUrl,
      category: json['kategori'] as String?,
      isAvailable: json['is_available'] ?? true,
      rating: json['rating']?.toDouble(),
      reviewCount: json['review_count'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'is_available': isAvailable,
      'rating': rating,
      'review_count': reviewCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    bool? isAvailable,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price)';
  }
}
