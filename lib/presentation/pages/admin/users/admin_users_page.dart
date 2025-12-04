import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/models/admin_user_model.dart';
import '../../../../data/providers/admin_provider.dart';
import '../../../../data/services/admin_service.dart';

class AdminUsersPage extends ConsumerStatefulWidget {
  const AdminUsersPage({super.key});

  @override
  ConsumerState<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends ConsumerState<AdminUsersPage> {
  final _searchController = TextEditingController();
  String? _selectedRole;
  int _currentPage = 1;
  final int _perPage = 15;
  List<AdminUser> _users = [];
  bool _isLoading = false;
  String? _error;
  int _totalPages = 1;
  int _totalUsers = 0;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final adminService = ref.read(adminServiceProvider);
      final response = await adminService.getUsers(
        page: _currentPage,
        perPage: _perPage,
        search: _searchController.text.isEmpty ? null : _searchController.text,
        role: _selectedRole,
      );

      if (response['success'] == true) {
        final data = response['data'] as List;
        setState(() {
          _users = data.map((e) => AdminUser.fromJson(e as Map<String, dynamic>)).toList();
          _currentPage = response['current_page'] as int? ?? 1;
          _totalPages = response['last_page'] as int? ?? 1;
          _totalUsers = response['total'] as int? ?? 0;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] as String? ?? 'Failed to load users';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteUser(int userId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin ingin menghapus user "$userName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final adminService = ref.read(adminServiceProvider);
      final response = await adminService.deleteUser(userId);

      if (response['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User berhasil dihapus')),
        );
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus user: $e')),
        );
      }
    }
  }

  void _showUserForm({AdminUser? user}) {
    final nameController = TextEditingController(text: user?.name);
    final emailController = TextEditingController(text: user?.email);
    final phoneController = TextEditingController(text: user?.phone);
    final passwordController = TextEditingController();
    String selectedRole = user?.role ?? 'user';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user == null ? 'Tambah User' : 'Edit User'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email harus diisi';
                    }
                    if (!value.contains('@')) {
                      return 'Email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'No. HP (Opsional)',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: user == null ? 'Password' : 'Password (kosongkan jika tidak diubah)',
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (user == null && (value == null || value.isEmpty)) {
                      return 'Password harus diisi';
                    }
                    if (value != null && value.isNotEmpty && value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.supervisor_account),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('User')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'staff', child: Text('Staff')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      selectedRole = value;
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final userData = <String, dynamic>{
                'name': nameController.text,
                'email': emailController.text,
                'role': selectedRole,
              };

              if (phoneController.text.isNotEmpty) {
                userData['phone'] = phoneController.text;
              }

              if (passwordController.text.isNotEmpty) {
                userData['password'] = passwordController.text;
                userData['password_confirmation'] = passwordController.text;
              }

              try {
                final adminService = ref.read(adminServiceProvider);
                final response = user == null
                    ? await adminService.createUser(userData)
                    : await adminService.updateUser(user.id, userData);

                if (response['success'] == true && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        user == null
                            ? 'User berhasil ditambahkan'
                            : 'User berhasil diupdate',
                      ),
                    ),
                  );
                  _loadUsers();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: Text(user == null ? 'Tambah' : 'Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/dashboard'),
          tooltip: 'Kembali ke Dashboard',
        ),
        title: const Text('Manage Users'),
        actions: [
          if (_totalUsers > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  'Total: $_totalUsers',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUserForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah User'),
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari nama, email, atau HP...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _currentPage = 1;
                              _loadUsers();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: (_) {
                    _currentPage = 1;
                    _loadUsers();
                  },
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Semua'),
                        selected: _selectedRole == null,
                        onSelected: (_) {
                          setState(() => _selectedRole = null);
                          _currentPage = 1;
                          _loadUsers();
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('User'),
                        selected: _selectedRole == 'user',
                        onSelected: (_) {
                          setState(() => _selectedRole = 'user');
                          _currentPage = 1;
                          _loadUsers();
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Admin'),
                        selected: _selectedRole == 'admin',
                        onSelected: (_) {
                          setState(() => _selectedRole = 'admin');
                          _currentPage = 1;
                          _loadUsers();
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Staff'),
                        selected: _selectedRole == 'staff',
                        onSelected: (_) {
                          setState(() => _selectedRole = 'staff');
                          _currentPage = 1;
                          _loadUsers();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // User List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(_error!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadUsers,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      )
                    : _users.isEmpty
                        ? const Center(child: Text('Tidak ada user'))
                        : RefreshIndicator(
                            onRefresh: _loadUsers,
                            child: ListView.builder(
                              itemCount: _users.length,
                              itemBuilder: (context, index) {
                                final user = _users[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      child: Text(user.name[0].toUpperCase()),
                                    ),
                                    title: Text(user.name),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(user.email),
                                        if (user.phone != null)
                                          Text(user.phone!),
                                      ],
                                    ),
                                    trailing: Chip(
                                      label: Text(
                                        user.role.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: user.role == 'admin'
                                              ? Colors.red.shade900
                                              : user.role == 'staff'
                                                  ? Colors.blue.shade900
                                                  : Colors.green.shade900,
                                        ),
                                      ),
                                      backgroundColor: user.role == 'admin'
                                          ? Colors.red.shade200
                                          : user.role == 'staff'
                                              ? Colors.blue.shade200
                                              : Colors.green.shade200,
                                    ),
                                    onTap: () => _showUserForm(user: user),
                                    onLongPress: () => _deleteUser(user.id, user.name),
                                  ),
                                );
                              },
                            ),
                          ),
          ),

          // Pagination
          if (_totalPages > 1)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _currentPage > 1
                        ? () {
                            setState(() => _currentPage--);
                            _loadUsers();
                          }
                        : null,
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Previous'),
                  ),
                  Text(
                    'Page $_currentPage of $_totalPages',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton.icon(
                    onPressed: _currentPage < _totalPages
                        ? () {
                            setState(() => _currentPage++);
                            _loadUsers();
                          }
                        : null,
                    icon: const Icon(Icons.chevron_right),
                    label: const Text('Next'),
                    iconAlignment: IconAlignment.end,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
