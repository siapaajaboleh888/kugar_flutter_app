import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AdminOrdersPage extends ConsumerStatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  ConsumerState<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends ConsumerState<AdminOrdersPage> {
  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'ORD-001',
      'customer': 'John Doe',
      'date': '2025-11-15',
      'status': 'Pending',
      'amount': 125990,
      'items': 3,
    },
    {
      'id': 'ORD-002',
      'customer': 'Jane Smith',
      'date': '2025-11-14',
      'status': 'Processing',
      'amount': 89500,
      'items': 2,
    },
    {
      'id': 'ORD-003',
      'customer': 'Bob Johnson',
      'date': '2025-11-13',
      'status': 'Shipped',
      'amount': 210750,
      'items': 5,
    },
    {
      'id': 'ORD-004',
      'customer': 'Alice Brown',
      'date': '2025-11-12',
      'status': 'Delivered',
      'amount': 156200,
      'items': 4,
    },
    {
      'id': 'ORD-005',
      'customer': 'Charlie Wilson',
      'date': '2025-11-11',
      'status': 'Cancelled',
      'amount': 75300,
      'items': 2,
    },
  ];

  String _selectedFilter = 'All';
  final List<String> _statusFilters = [
    'All',
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled'
  ];

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _selectedFilter == 'All'
        ? _orders
        : _orders.where((order) => order['status'] == _selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/dashboard'),
          tooltip: 'Kembali ke Dashboard',
        ),
        title: const Text('Manage Orders'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<String>(
              value: _selectedFilter,
              items: _statusFilters
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Filter by Status',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              isExpanded: true,
            ),
          ),
        ),
      ),
      body: _buildOrderList(filteredOrders),
    );
  }

  Widget _buildOrderList(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Text('No orders found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    
    Color statusColor;
    switch (order['status']) {
      case 'Pending':
        statusColor = Colors.orange;
        break;
      case 'Processing':
        statusColor = Colors.blue;
        break;
      case 'Shipped':
        statusColor = Colors.purple;
        break;
      case 'Delivered':
        statusColor = Colors.green;
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order['id']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      order['status'],
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    order['customer'],
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        dateFormat.format(DateTime.parse(order['date'])),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  Text(
                    currencyFormat.format(order['amount']),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order['items']} ${order['items'] == 1 ? 'item' : 'items'}\n${order['status']}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  if (order['status'] != 'Delivered' &&
                      order['status'] != 'Cancelled')
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        if (order['status'] == 'Pending')
                          const PopupMenuItem(
                            value: 'process',
                            child: Text('Mark as Processing'),
                          ),
                        if (order['status'] == 'Processing')
                          const PopupMenuItem(
                            value: 'ship',
                            child: Text('Mark as Shipped'),
                          ),
                        if (order['status'] == 'Shipped')
                          const PopupMenuItem(
                            value: 'deliver',
                            child: Text('Mark as Delivered'),
                          ),
                        if (order['status'] != 'Cancelled')
                          const PopupMenuItem(
                            value: 'cancel',
                            child: Text('Cancel Order',
                                style: TextStyle(color: Colors.red)),
                          ),
                      ],
                      onSelected: (value) {
                        _updateOrderStatus(order['id'], value);
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateOrderStatus(String orderId, String action) {
    setState(() {
      final order = _orders.firstWhere((order) => order['id'] == orderId);
      switch (action) {
        case 'process':
          order['status'] = 'Processing';
          break;
        case 'ship':
          order['status'] = 'Shipped';
          break;
        case 'deliver':
          order['status'] = 'Delivered';
          break;
        case 'cancel':
          order['status'] = 'Cancelled';
          break;
      }
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order status updated successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order['id']}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildOrderDetailItem('Order Date',
                    dateFormat.format(DateTime.parse(order['date']))),
                _buildOrderDetailItem('Customer', order['customer']),
                _buildOrderDetailItem('Status', order['status']),
                _buildOrderDetailItem('Items', '${order['items']} items'),
                _buildOrderDetailItem(
                    'Total Amount', currencyFormat.format(order['amount'])),
                const SizedBox(height: 24),
                const Text(
                  'Order Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildOrderItem('Product 1', 1, 25990),
                _buildOrderItem('Product 2', 2, 35500),
                const Divider(),
                _buildOrderTotal(currencyFormat.format(order['amount'])),
                const SizedBox(height: 24),
                if (order['status'] != 'Delivered' &&
                    order['status'] != 'Cancelled')
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _updateOrderStatus(
                                order['id'],
                                order['status'] == 'Pending'
                                    ? 'process'
                                    : order['status'] == 'Processing'
                                        ? 'ship'
                                        : 'deliver');
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.green),
                          ),
                          child: Text(
                            order['status'] == 'Pending'
                                ? 'Mark as Processing'
                                : order['status'] == 'Processing'
                                    ? 'Mark as Shipped'
                                    : 'Mark as Delivered',
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (order['status'] != 'Cancelled')
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _updateOrderStatus(order['id'], 'cancel');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Cancel Order'),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(String name, int quantity, double price) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.image, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: $quantity',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            currencyFormat.format(price * quantity),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTotal(String total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          total,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}
