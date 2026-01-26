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
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    try {
      final users = await _adminProvider.getAllUsers();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Korisnici'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUsers,
              child: _users.isEmpty
                  ? const Center(child: Text('Nema korisnika'))
                  : ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        final isBanned = user['isBanned'] ?? false;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isBanned
                                  ? Colors.red.shade700
                                  : Colors.blue.shade700,
                              child: Icon(
                                isBanned ? Icons.block : Icons.person,
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
                                if (isBanned) ...[
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
                            trailing: IconButton(
                              icon: Icon(
                                isBanned ? Icons.check_circle : Icons.block,
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
                          ),
                        );
                      },
                    ),
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
}