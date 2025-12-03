import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdminUsersPage extends ConsumerStatefulWidget {
  const AdminUsersPage({super.key});

  @override
  ConsumerState<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends ConsumerState<AdminUsersPage> {
  final List<Map<String, dynamic>> _users = [
    {
      'id': '1',
      'name': 'John Doe',
      'email': 'john@example.com',
      'role': 'user',
      'status': 'active',
      'createdAt': '2023-01-15',
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'role': 'user',
      'status': 'inactive',
      'createdAt': '2023-02-20',
    },
    // Add more sample users as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddUserDialog(),
          ),
        ],
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(user['name'][0]),
            ),
            title: Text(user['name']),
            subtitle: Text(user['email']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(
                  label: Text(
                    user['status'],
                    style: TextStyle(
                      color: user['status'] == 'active'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  backgroundColor: user['status'] == 'active'
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit User'),
                    ),
                    PopupMenuItem(
                      value: 'status',
                      child: Text(user['status'] == 'active'
                          ? 'Deactivate'
                          : 'Activate'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditUserDialog(user);
                        break;
                      case 'status':
                        _toggleUserStatus(user['id']);
                        break;
                      case 'delete':
                        _deleteUser(user['id']);
                        break;
                    }
                  },
                ),
              ],
            ),
            onTap: () => _showUserDetails(user),
          ),
        );
      },
    );
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                items: ['user', 'admin']
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        ))
                    .toList(),
                onChanged: (value) {},
                decoration: const InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Add user logic here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User added successfully')),
              );
            },
            child: const Text('Add User'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    // Similar to add user dialog but pre-filled with user data
    // Implementation omitted for brevity
  }

  void _toggleUserStatus(String userId) {
    setState(() {
      final index = _users.indexWhere((user) => user['id'] == userId);
      if (index != -1) {
        _users[index]['status'] =
            _users[index]['status'] == 'active' ? 'inactive' : 'active';
      }
    });
  }

  void _deleteUser(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _users.removeWhere((user) => user['id'] == userId);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User deleted successfully')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user['name']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email', user['email']),
              const SizedBox(height: 8),
              _buildDetailRow('Role', user['role']),
              const SizedBox(height: 8),
              _buildDetailRow('Status', user['status']),
              const SizedBox(height: 8),
              _buildDetailRow('Member Since', user['createdAt']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
