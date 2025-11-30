import 'package:json_annotation/json_annotation.dart';
import 'cart_item.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  final String id;
  final String orderNumber;
  final int userId;
  final List<OrderItem> items;
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;
  final String status;
  final String shippingAddress;
  final String? notes;
  final String? paymentMethod;
  final String? paymentStatus;
  final DateTime? paymentDate;
  final DateTime? shippedDate;
  final DateTime? deliveredDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
    required this.status,
    required this.shippingAddress,
    this.notes,
    this.paymentMethod,
    this.paymentStatus,
    this.paymentDate,
    this.shippedDate,
    this.deliveredDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);

  Order copyWith({
    String? id,
    String? orderNumber,
    int? userId,
    List<OrderItem>? items,
    double? subtotal,
    double? shipping,
    double? tax,
    double? total,
    String? status,
    String? shippingAddress,
    String? notes,
    String? paymentMethod,
    String? paymentStatus,
    DateTime? paymentDate,
    DateTime? shippedDate,
    DateTime? deliveredDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      shipping: shipping ?? this.shipping,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      notes: notes ?? this.notes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentDate: paymentDate ?? this.paymentDate,
      shippedDate: shippedDate ?? this.shippedDate,
      deliveredDate: deliveredDate ?? this.deliveredDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isShipped => status == 'shipped';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String get paymentStatusDisplay {
    switch (paymentStatus) {
      case 'pending':
        return 'Pending';
      case 'paid':
        return 'Paid';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return paymentStatus ?? 'Unknown';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Order(id: $id, orderNumber: $orderNumber, status: $status)';
}

@JsonSerializable()
class OrderItem {
  final int id;
  final int productId;
  final String productName;
  final String? productImage;
  final double price;
  final int quantity;
  final double total;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.quantity,
    required this.total,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemToJson(this);

  OrderItem copyWith({
    int? id,
    int? productId,
    String? productName,
    String? productImage,
    double? price,
    int? quantity,
    double? total,
  }) {
    return OrderItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      total: total ?? this.total,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'OrderItem(id: $id, productName: $productName, quantity: $quantity)';
}
