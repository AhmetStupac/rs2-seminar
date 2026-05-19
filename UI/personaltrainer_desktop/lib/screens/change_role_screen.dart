import 'package:flutter/material.dart';
import 'package:personaltrainer_desktop/providers/admin_provider.dart';
import 'package:personaltrainer_desktop/providers/auth_provider.dart';

class ChangeRoleScreen extends StatefulWidget {
  final int userId;
  final String username;
  final List<dynamic> currentRoles;

  const ChangeRoleScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.currentRoles,
  });

  @override
  State<ChangeRoleScreen> createState() => _ChangeRoleScreenState();
}

class _ChangeRoleScreenState extends State<ChangeRoleScreen> {
  static const _roles = [
    {'id': 1, 'name': 'Admin', 'description': 'Can manage content and users', 'icon': Icons.admin_panel_settings, 'color': Colors.blue},
    {'id': 2, 'name': 'Kupac', 'description': 'Regular user / customer', 'icon': Icons.person, 'color': Colors.green},
    {'id': 3, 'name': 'SuperAdmin', 'description': 'Full access to all features', 'icon': Icons.security, 'color': Colors.deepPurple},
  ];

  int? _selectedRoleId;
  bool _isLoading = false;
  final _adminProvider = AdminProvider();

  @override
  void initState() {
    super.initState();
    // Pre-select the user's first current role if any
    if (widget.currentRoles.isNotEmpty) {
      final first = widget.currentRoles.first;
      final roleId = first is Map ? first['id'] : null;
      if (roleId != null) {
        _selectedRoleId = roleId as int;
      }
    }
  }

  Future<void> _applyRole() async {
    if (_selectedRoleId == null) return;

    setState(() => _isLoading = true);

    final result = await _adminProvider.changeUserRole(widget.userId, _selectedRoleId!);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Role updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to update role'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthProvider.isSuperAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Change Role')),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Access Denied',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Only SuperAdmins can change user roles.'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Change Role — ${widget.username}'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.manage_accounts, size: 28, color: Colors.deepPurple),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Select a new role for "${widget.username}"',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'The user will be assigned only the selected role.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: _roles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final role = _roles[index];
                  final roleId = role['id'] as int;
                  final color = role['color'] as Color;
                  final isSelected = _selectedRoleId == roleId;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedRoleId = roleId),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withOpacity(0.08) : Colors.white,
                        border: Border.all(
                          color: isSelected ? color : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isSelected
                            ? [BoxShadow(color: color.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3))]
                            : [],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(role['icon'] as IconData, color: color, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  role['name'] as String,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? color : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  role['description'] as String,
                                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle, color: color, size: 26)
                          else
                            Icon(Icons.radio_button_unchecked, color: Colors.grey[400], size: 26),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: (_selectedRoleId == null || _isLoading) ? null : _applyRole,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isLoading ? 'Saving...' : 'Apply Role',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
