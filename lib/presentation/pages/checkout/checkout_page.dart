import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/user.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String _selectedPaymentMethod = 'cash';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authState = ref.read(authProvider);
    final user = authState.user;
    
    if (user != null) {
      _addressController.text = user.address ?? '';
      _phoneController.text = user.phone ?? '';
    }
  }

  Future<void> _processCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    final cartState = ref.read(cartProvider);
    if (cartState.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final success = await ref.read(orderProvider.notifier).createOrder(
        items: cartState.items,
        shippingAddress: _addressController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        paymentMethod: _selectedPaymentMethod,
      );

      if (success) {
        // Clear cart
        await ref.read(cartProvider.notifier).clearCart();
        
        // Navigate to order tracking
        final orderState = ref.read(orderProvider);
        if (orderState.currentOrder != null) {
          context.go('${AppRouter.orderTracking}/${orderState.currentOrder!.id}');
        } else {
          context.go(AppRouter.orders);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final authState = ref.watch(authProvider);
    final orderState = ref.watch(orderProvider);

    if (!authState.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.login_outlined, size: 64),
              const SizedBox(height: 16),
              const Text('Please login to continue checkout'),
              const SizedBox(height: 16),
              CustomButton(
                onPressed: () => context.go(AppRouter.login),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    if (cartState.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_cart_outlined, size: 64),
              const SizedBox(height: 16),
              const Text('Your cart is empty'),
              const SizedBox(height: 16),
              CustomButton(
                onPressed: () => context.go(AppRouter.productCatalog),
                child: const Text('Browse Products'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary
              _buildOrderSummary(cartState),
              const SizedBox(height: 24),
              
              // Shipping Information
              _buildShippingInformation(authState.user),
              const SizedBox(height: 24),
              
              // Payment Method
              _buildPaymentMethod(),
              const SizedBox(height: 24),
              
              // Order Notes
              _buildOrderNotes(),
              const SizedBox(height: 32),
              
              // Place Order Button
              _buildPlaceOrderButton(orderState.isCreating),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(cartState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Items List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cartState.items.length,
              itemBuilder: (context, index) {
                final item = cartState.items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.productName} x${item.quantity}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(item.price * item.quantity),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              },
            ),
            
            const Divider(),
            const SizedBox(height: 8),
            
            // Totals
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal', style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(cartState.subtotal),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Shipping', style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(cartState.shipping),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tax', style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(cartState.tax),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(cartState.total),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingInformation(User? user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shipping Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // User Info
            if (user != null) ...[
              Text(
                user.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                user.email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Phone Number
            CustomTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hintText: 'Enter your phone number',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Phone number is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Shipping Address
            CustomTextField(
              controller: _addressController,
              label: 'Shipping Address',
              hintText: 'Enter your complete shipping address',
              maxLines: 3,
              prefixIcon: Icons.location_on,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Shipping address is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            RadioListTile<String>(
              title: const Text('Cash on Delivery'),
              subtitle: const Text('Pay when you receive your order'),
              value: 'cash',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
              secondary: const Icon(Icons.money),
            ),
            RadioListTile<String>(
              title: const Text('Bank Transfer'),
              subtitle: const Text('Transfer to our bank account'),
              value: 'transfer',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
              secondary: const Icon(Icons.account_balance),
            ),
            RadioListTile<String>(
              title: const Text('E-Wallet'),
              subtitle: const Text('Pay with your e-wallet'),
              value: 'ewallet',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
              secondary: const Icon(Icons.account_balance_wallet),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderNotes() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Notes (Optional)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _notesController,
              label: 'Notes',
              hintText: 'Add any special instructions for your order',
              maxLines: 3,
              prefixIcon: Icons.note,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceOrderButton(bool isCreating) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        onPressed: (_isProcessing || isCreating) ? null : _processCheckout,
        child: (_isProcessing || isCreating)
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Place Order'),
      ),
    );
  }
}
