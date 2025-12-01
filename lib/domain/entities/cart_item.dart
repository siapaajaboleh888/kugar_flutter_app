class CartItem {
  final int id;
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final String? imageUrl;
  final DateTime? addedAt;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.addedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: (json['id'] as int?) ?? 0,
      productId: (json['product_id'] as int?) ?? 0,
      productName: json['product_name'] ?? json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: (json['quantity'] as int?) ?? 1,
      imageUrl: json['image_url'] as String?,
      addedAt: json['added_at'] != null
          ? DateTime.parse(json['added_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'image_url': imageUrl,
      'added_at': addedAt?.toIso8601String(),
    };
  }

  CartItem copyWith({
    int? id,
    int? productId,
    String? productName,
    double? price,
    int? quantity,
    String? imageUrl,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  double get totalPrice => price * quantity;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CartItem(id: $id, productName: $productName, quantity: $quantity)';
  }
}
