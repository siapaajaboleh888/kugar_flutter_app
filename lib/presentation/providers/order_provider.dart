import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/api_service.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/entities/cart_item.dart';

// Provider for API service
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Order state
class OrderState {
  final List<Order> orders;
  final Order? currentOrder;
  final bool isLoading;
  final bool isCreating;
  final bool isUpdating;
  final String? error;
  final bool hasMore;
  final int currentPage;
  final Map<String, Order> orderDetails;

  OrderState({
    this.orders = const [],
    this.currentOrder,
    this.isLoading = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
    this.orderDetails = const {},
  });

  OrderState copyWith({
    List<Order>? orders,
    Order? currentOrder,
    bool? isLoading,
    bool? isCreating,
    bool? isUpdating,
    String? error,
    bool? hasMore,
    int? currentPage,
    Map<String, Order>? orderDetails,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      currentOrder: currentOrder ?? this.currentOrder,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      orderDetails: orderDetails ?? this.orderDetails,
    );
  }
}

// Order provider
class OrderProvider extends StateNotifier<OrderState> {
  final ApiService _apiService;

  OrderProvider(this._apiService) : super(OrderState());

  Future<void> loadOrders({
    bool refresh = false,
    String? status,
  }) async {
    if (refresh) {
      state = state.copyWith(
        currentPage: 1,
        orders: [],
        hasMore: true,
        error: null,
      );
    }

    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getOrders(
        page: state.currentPage,
        status: status,
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final ordersData = data['data'] as List<dynamic>;
        final newOrders = ordersData.map((o) => Order.fromJson(o as Map<String, dynamic>)).toList();

        state = state.copyWith(
          orders: refresh ? newOrders : [...state.orders, ...newOrders],
          isLoading: false,
          currentPage: state.currentPage + 1,
          hasMore: newOrders.length >= 10,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> createOrder({
    required List<CartItem> items,
    required String shippingAddress,
    String? notes,
    String? paymentMethod,
  }) async {
    state = state.copyWith(isCreating: true, error: null);

    try {
      final orderItems = items.map((item) => {
        'product_id': item.productId,
        'quantity': item.quantity,
        'price': item.price,
      }).toList();

      final orderData = {
        'items': orderItems,
        'shipping_address': shippingAddress,
        if (notes != null) 'notes': notes,
        if (paymentMethod != null) 'payment_method': paymentMethod,
      };

      final response = await _apiService.createOrder(orderData);

      if (response['success'] == true && response['data'] != null) {
        final order = Order.fromJson(response['data'] as Map<String, dynamic>);
        
        state = state.copyWith(
          currentOrder: order,
          isCreating: false,
          orders: [order, ...state.orders],
        );
        return true;
      } else {
        state = state.copyWith(
          isCreating: false,
          error: response['message'] ?? 'Failed to create order',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<Order?> getOrderDetail(String orderId) async {
    // Check if already loaded
    if (state.orderDetails.containsKey(orderId)) {
      return state.orderDetails[orderId];
    }

    try {
      final response = await _apiService.getOrderDetail(orderId);

      if (response['success'] == true && response['data'] != null) {
        final order = Order.fromJson(response['data'] as Map<String, dynamic>);
        
        final updatedDetails = Map<String, Order>.from(state.orderDetails);
        updatedDetails[orderId] = order;
        
        state = state.copyWith(orderDetails: updatedDetails);
        return order;
      }
    } catch (e) {
      // Error handled by caller
    }

    return null;
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    state = state.copyWith(isUpdating: true, error: null);

    try {
      final response = await _apiService.updateOrderStatus(orderId, status);

      if (response['success'] == true) {
        // Update local state
        final updatedOrders = state.orders.map((order) {
          if (order.id == orderId) {
            return order.copyWith(status: status);
          }
          return order;
        }).toList();

        // Update order details if cached
        final updatedDetails = Map<String, Order>.from(state.orderDetails);
        if (updatedDetails.containsKey(orderId)) {
          updatedDetails[orderId] = updatedDetails[orderId]!.copyWith(status: status);
        }

        state = state.copyWith(
          orders: updatedOrders,
          orderDetails: updatedDetails,
          isUpdating: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isUpdating: false,
          error: response['message'] ?? 'Failed to update order status',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<Map<String, dynamic>?> trackOrder(String orderId) async {
    try {
      final response = await _apiService.trackOrder(orderId);

      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      }
    } catch (e) {
      // Error handled by caller
    }

    return null;
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = OrderState();
  }
}

// Order provider instance
final orderProvider = StateNotifierProvider<OrderProvider, OrderState>((ref) {
  return OrderProvider(ref.read(apiServiceProvider));
});

// Order detail provider
final orderDetailProvider = FutureProvider.family<Order?, String>((ref, orderId) async {
  final orderProviderNotifier = ref.read(orderProvider.notifier);
  return await orderProviderNotifier.getOrderDetail(orderId);
});

// Order tracking provider
final orderTrackingProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, orderId) async {
  final orderProviderNotifier = ref.read(orderProvider.notifier);
  return await orderProviderNotifier.trackOrder(orderId);
});

// Orders by status provider
final ordersByStatusProvider = FutureProvider.family<List<Order>, String>((ref, status) async {
  final apiService = ref.read(apiServiceProvider);
  try {
    final response = await apiService.getOrders(status: status);
    if (response['success'] == true && response['data'] != null) {
      final data = response['data'] as Map<String, dynamic>;
      final ordersData = data['data'] as List<dynamic>;
      return ordersData.map((o) => Order.fromJson(o as Map<String, dynamic>)).toList();
    }
  } catch (e) {
    // Return empty list on error
  }
  return [];
});
