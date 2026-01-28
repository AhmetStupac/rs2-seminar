import 'package:flutter/material.dart';
import 'package:personaltrainer_mobile/providers/admin_provider.dart';
import 'package:personaltrainer_mobile/screens/admin_ban_screen.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({Key? key}) : super(key: key);

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final _adminProvider = AdminProvider();
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  bool _showDeletedOnly = false;
  String _searchQuery = '';

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
    setState(() => _isLoading = true);

    try {
      final users = _showDeletedOnly
          ? await _adminProvider.getDeletedUsers()
          : await _adminProvider.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška pri učitavanju korisnika: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_searchQuery.isEmpty) {
      return _users;
    }

    final query = _searchQuery.toLowerCase();
    return _users.where((user) {
      final username = (user['username'] ?? '').toString().toLowerCase();
      final email = (user['email'] ?? '').toString().toLowerCase();
      final firstName = (user['firstName'] ?? '').toString().toLowerCase();
      final lastName = (user['lastName'] ?? '').toString().toLowerCase();

      return username.contains(query) ||
          email.contains(query) ||
          firstName.contains(query) ||
          lastName.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Korisnici'),
        actions: [
          FilterChip(
            label: Text(_showDeletedOnly ? 'Obrisani' : 'Svi'),
            selected: _showDeletedOnly,
            onSelected: (value) {
              setState(() {
                _showDeletedOnly = value;
              });
              _loadUsers();
            },
            avatar: Icon(
              _showDeletedOnly ? Icons.delete : Icons.people,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pretraga korisnika',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Pretraži po username, email, imenu ili prezimenu...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadUsers,
                    child: _filteredUsers.isEmpty
                        ? Center(
                            child: Text(
                              _searchQuery.isNotEmpty
                                  ? 'Nema rezultata pretrage'
                                  : 'Nema korisnika',
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = _filteredUsers[index];
                        final isBanned = user['isBanned'] ?? false;
                        final isDeleted = user['isDeleted'] ?? false;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isDeleted
                                  ? Colors.grey.shade700
                                  : (isBanned
                                      ? Colors.red.shade700
                                      : Colors.blue.shade700),
                              child: Icon(
                                isDeleted
                                    ? Icons.person_off
                                    : (isBanned ? Icons.block : Icons.person),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              user['username'] ?? 'N/A',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: isBanned
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user['email'] ?? 'N/A'),
                                if (isDeleted) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'OBRISAN',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                                if (isBanned && !isDeleted) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'BANOVAN: ${user['banReason'] ?? 'Bez razloga'}',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isDeleted) ...[
                                  IconButton(
                                    icon: const Icon(Icons.undo, color: Colors.green),
                                    tooltip: 'Vrati korisnika',
                                    onPressed: () => _showRestoreDialog(user),
                                  ),
                                ] else ...[
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    tooltip: 'Obriši korisnika',
                                    onPressed: () => _showDeleteDialog(user),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      isBanned ? Icons.check_circle : Icons.arrow_forward,
                                      color: isBanned ? Colors.green : Colors.red,
                                    ),
                                    onPressed: () {
                                      if (isBanned) {
                                        _showUnbanDialog(user);
                                      } else {
                                        _openBanScreen(user);
                                      }
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _openBanScreen(Map<String, dynamic> user) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => BanUserScreen(
          userId: user['id'],
          username: user['username'] ?? 'Unknown',
        ),
      ),
    );

    if (result == true) {
      _loadUsers(); // Refresh liste nakon banovanja
    }
  }

  void _showUnbanDialog(Map<String, dynamic> user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unbanuj korisnika'),
        content: Text(
          'Da li ste sigurni da želite da unbanuјete ${user['username']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Otkaži'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Unbanuj'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await _adminProvider.unbanUser(user['id']);

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Uspešno unbanovano'),
              backgroundColor: Colors.green,
            ),
          );
          _loadUsers();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Greška'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showDeleteDialog(Map<String, dynamic> user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Obriši korisnika'),
        content: Text(
          'Da li ste sigurni da želite da obrišete korisnika ${user['username']}?\n\nOvo je soft delete operacija.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Otkaži'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Obriši'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await _adminProvider.softDeleteUser(user['id']);

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Uspešno obrisano'),
              backgroundColor: Colors.green,
            ),
          );
          _loadUsers();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Greška'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showRestoreDialog(Map<String, dynamic> user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vrati korisnika'),
        content: Text(
          'Da li ste sigurni da želite da vratite korisnika ${user['username']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Otkaži'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Vrati'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await _adminProvider.restoreUser(user['id']);

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Uspešno vraćeno'),
              backgroundColor: Colors.green,
            ),
          );
          _loadUsers();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Greška'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}