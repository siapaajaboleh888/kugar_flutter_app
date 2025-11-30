// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  id: json['id'] as String,
  orderNumber: json['orderNumber'] as String,
  userId: (json['userId'] as num).toInt(),
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  subtotal: (json['subtotal'] as num).toDouble(),
  shipping: (json['shipping'] as num).toDouble(),
  tax: (json['tax'] as num).toDouble(),
  total: (json['total'] as num).toDouble(),
  status: json['status'] as String,
  shippingAddress: json['shippingAddress'] as String,
  notes: json['notes'] as String?,
  paymentMethod: json['paymentMethod'] as String?,
  paymentStatus: json['paymentStatus'] as String?,
  paymentDate: json['paymentDate'] == null
      ? null
      : DateTime.parse(json['paymentDate'] as String),
  shippedDate: json['shippedDate'] == null
      ? null
      : DateTime.parse(json['shippedDate'] as String),
  deliveredDate: json['deliveredDate'] == null
      ? null
      : DateTime.parse(json['deliveredDate'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'id': instance.id,
  'orderNumber': instance.orderNumber,
  'userId': instance.userId,
  'items': instance.items,
  'subtotal': instance.subtotal,
  'shipping': instance.shipping,
  'tax': instance.tax,
  'total': instance.total,
  'status': instance.status,
  'shippingAddress': instance.shippingAddress,
  'notes': instance.notes,
  'paymentMethod': instance.paymentMethod,
  'paymentStatus': instance.paymentStatus,
  'paymentDate': instance.paymentDate?.toIso8601String(),
  'shippedDate': instance.shippedDate?.toIso8601String(),
  'deliveredDate': instance.deliveredDate?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
  id: (json['id'] as num).toInt(),
  productId: (json['productId'] as num).toInt(),
  productName: json['productName'] as String,
  productImage: json['productImage'] as String?,
  price: (json['price'] as num).toDouble(),
  quantity: (json['quantity'] as num).toInt(),
  total: (json['total'] as num).toDouble(),
);

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
  'id': instance.id,
  'productId': instance.productId,
  'productName': instance.productName,
  'productImage': instance.productImage,
  'price': instance.price,
  'quantity': instance.quantity,
  'total': instance.total,
};
