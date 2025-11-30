import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/api_service.dart';
import '../../../domain/entities/cart_item.dart';

// Provider for API service
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Cart state
class CartState {
  final List<CartItem> items;
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;
  final bool isLoading;
  final bool isUpdating;
  final String? error;
  final int itemCount;

  CartState({
    this.items = const [],
    this.subtotal = 0.0,
    this.shipping = 0.0,
    this.tax = 0.0,
    this.total = 0.0,
    this.isLoading = false,
    this.isUpdating = false,
    this.error,
    this.itemCount = 0,
  });

  CartState copyWith({
    List<CartItem>? items,
    double? subtotal,
    double? shipping,
    double? tax,
    double? total,
    bool? isLoading,
    bool? isUpdating,
    String? error,
    int? itemCount,
  }) {
    final newItems = items ?? this.items;
    final calculatedSubtotal = newItems.fold<double>(0.0, (sum, item) => sum + (item.price * item.quantity));
    final newSubtotal = subtotal ?? calculatedSubtotal;
    final newShipping = shipping ?? (newSubtotal > 0 ? 10000.0 : 0.0);
    final newTax = tax ?? (newSubtotal * 0.1);
    final newTotal = total ?? (newSubtotal + newShipping + newTax);
    final newItemCount = itemCount ?? newItems.fold<int>(0, (sum, item) => sum + item.quantity);

    return CartState(
      items: newItems,
      subtotal: newSubtotal,
      shipping: newShipping,
      tax: newTax,
      total: newTotal,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      error: error ?? this.error,
      itemCount: newItemCount,
    );
  }

  double calculateSubtotal() {
    return items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  int calculateItemCount() {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}

// Cart provider
class CartProvider extends StateNotifier<CartState> {
  final ApiService _apiService;

  CartProvider(this._apiService) : super(CartState());

  Future<void> loadCart() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getCart();

      if (response['success'] == true && response['data'] != null) {
        final cartData = response['data'] as Map<String, dynamic>;
        final itemsData = cartData['items'] as List<dynamic>? ?? [];
        final items = itemsData.map((item) => CartItem.fromJson(item as Map<String, dynamic>)).toList();

        final subtotal = cartData['subtotal']?.toDouble() ?? 0.0;
        final shipping = cartData['shipping']?.toDouble() ?? 0.0;
        final tax = cartData['tax']?.toDouble() ?? 0.0;
        final total = cartData['total']?.toDouble() ?? 0.0;

        state = state.copyWith(
          items: items,
          subtotal: subtotal,
          shipping: shipping,
          tax: tax,
          total: total,
          isLoading: false,
          itemCount: items.fold<int>(0, (sum, item) => sum + item.quantity),
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> addToCart({
    required int productId,
    required String productName,
    required double price,
    required int quantity,
    String? imageUrl,
  }) async {
    state = state.copyWith(isUpdating: true, error: null);

    try {
      final response = await _apiService.addToCart({
        'product_id': productId,
        'quantity': quantity,
      });

      if (response['success'] == true) {
        // Refresh cart
        await loadCart();
        state = state.copyWith(isUpdating: false);
        return true;
      } else {
        state = state.copyWith(
          isUpdating: false,
          error: response['message'] ?? 'Failed to add item to cart',
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

  Future<bool> updateCartItem(int itemId, int quantity) async {
    state = state.copyWith(isUpdating: true, error: null);

    try {
      final response = await _apiService.updateCartItem(itemId, {'quantity': quantity});

      if (response['success'] == true) {
        // Update local state
        final updatedItems = state.items.map((item) {
          if (item.id == itemId) {
            return item.copyWith(quantity: quantity);
          }
          return item;
        }).toList();

        final newSubtotal = updatedItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
        final newTotal = newSubtotal + state.shipping + state.tax;

        state = state.copyWith(
          items: updatedItems,
          subtotal: newSubtotal,
          total: newTotal,
          isUpdating: false,
          itemCount: updatedItems.fold<int>(0, (sum, item) => sum + item.quantity),
        );
        return true;
      } else {
        state = state.copyWith(
          isUpdating: false,
          error: response['message'] ?? 'Failed to update cart item',
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

  Future<bool> removeFromCart(int itemId) async {
    state = state.copyWith(isUpdating: true, error: null);

    try {
      final response = await _apiService.removeFromCart(itemId);

      if (response['success'] == true) {
        // Update local state
        final updatedItems = state.items.where((item) => item.id != itemId).toList();
        final newSubtotal = updatedItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
        final newTotal = newSubtotal + state.shipping + state.tax;

        state = state.copyWith(
          items: updatedItems,
          subtotal: newSubtotal,
          total: newTotal,
          isUpdating: false,
          itemCount: updatedItems.fold<int>(0, (sum, item) => sum + item.quantity),
        );
        return true;
      } else {
        state = state.copyWith(
          isUpdating: false,
          error: response['message'] ?? 'Failed to remove item from cart',
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

  Future<bool> clearCart() async {
    state = state.copyWith(isUpdating: true, error: null);

    try {
      final response = await _apiService.clearCart();

      if (response['success'] == true) {
        state = CartState();
        return true;
      } else {
        state = state.copyWith(
          isUpdating: false,
          error: response['message'] ?? 'Failed to clear cart',
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

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = CartState();
  }
}

// Cart provider instance
final cartProvider = StateNotifierProvider<CartProvider, CartState>((ref) {
  return CartProvider(ref.read(apiServiceProvider));
});

// Cart item count provider (for badge)
final cartItemCountProvider = Provider<int>((ref) {
  final cartState = ref.watch(cartProvider);
  return cartState.itemCount;
});

// Cart total provider
final cartTotalProvider = Provider<double>((ref) {
  final cartState = ref.watch(cartProvider);
  return cartState.total;
});
