import 'package:flutter/material.dart';
import 'package:personaltrainer_desktop/providers/admin_provider.dart';

class BanUserScreen extends StatefulWidget {
  final int userId;
  final String username;

  const BanUserScreen({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  State<BanUserScreen> createState() => _BanUserScreenState();
}

class _BanUserScreenState extends State<BanUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _adminProvider = AdminProvider();

  bool _isPermanent = true;
  DateTime? _expiryDate;
  String? _expiryDateValidationError;
  bool _isLoading = false;

  // Unban related state
  bool _isBanned = false;
  bool _isCheckingBan = true;
  Map<String, dynamic>? _banInfo;

  @override
  void initState() {
    super.initState();
    _checkBanStatus();
  }

  Future<void> _checkBanStatus() async {
    setState(() => _isCheckingBan = true);

    try {
      final result = await _adminProvider.checkBan(widget.userId);
      if (mounted) {
        setState(() {
          _isBanned = result['isBanned'] ?? false;
          _banInfo = result;
          _isCheckingBan = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCheckingBan = false);
      }
    }
  }

  Future<void> _unbanUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text('Are you sure you want to unban ${widget.username}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Unban'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final result = await _adminProvider.unbanUser(widget.userId);

      if (!mounted) return;

      if (result['success']) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'User unbanned successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error while unbanning user'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error while unbanning user.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _banUser() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isPermanent && _expiryDate == null) {
      setState(() {
        _expiryDateValidationError = 'Select a ban expiry date';
      });
      return;
    }

    if (_expiryDateValidationError != null) {
      setState(() {
        _expiryDateValidationError = null;
      });
    }

    setState(() => _isLoading = true);

    try {
      final result = await _adminProvider.banUser(
        userId: widget.userId,
        reason: _reasonController.text,
        expiresAt: _isPermanent ? null : _expiryDate,
      );

      if (!mounted) return;

      if (result['success']) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'User banned successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error while banning user'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error while banning user.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingBan) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ban Management'),
          backgroundColor: Colors.grey.shade700,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_isBanned) {
      return _buildUnbanScreen();
    }

    return _buildBanScreen();
  }

  Widget _buildUnbanScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unban User'),
        backgroundColor: Colors.green.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ban info card
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.block, color: Colors.red.shade700, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade700,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'BANNED',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildBanInfoRow(
                      'Reason:',
                      _banInfo?['reason'] ?? 'Not provided',
                    ),
                    const SizedBox(height: 8),
                    _buildBanInfoRow(
                      'Banned At:',
                      _banInfo?['bannedAt'] != null
                          ? _formatDateTime(_banInfo!['bannedAt'])
                          : 'Unknown',
                    ),
                    const SizedBox(height: 8),
                    _buildBanInfoRow(
                      'Ban Type:',
                      (_banInfo?['isPermanent'] ?? true)
                          ? 'Permanent'
                          : 'Temporary',
                    ),
                    if (_banInfo?['expiresAt'] != null) ...[
                      const SizedBox(height: 8),
                      _buildBanInfoRow(
                        'Expires:',
                        _formatDateTime(_banInfo!['expiresAt']),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _unbanUser,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(
                  _isLoading ? 'Unbanning...' : 'Unban User',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildBanScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ban User'),
        backgroundColor: Colors.red.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red.shade700),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'User: ${widget.username}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: ${widget.userId}',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Ban Reason *',
                  hintText: 'e.g. Violation of community guidelines',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Reason is required';
                  }
                  if (value.length < 10) {
                    return 'Reason must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Permanent Ban'),
                      subtitle: const Text('Ban without time limit'),
                      value: _isPermanent,
                      activeThumbColor: Colors.red.shade700,
                      onChanged: (value) {
                        setState(() {
                          _isPermanent = value;
                          if (_isPermanent) {
                            _expiryDateValidationError = null;
                          }
                        });
                      },
                    ),
                    if (!_isPermanent) ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(
                          _expiryDate == null
                              ? 'Select expiry date'
                              : 'Expires: ${_formatDate(_expiryDate!)}',
                        ),
                        subtitle: _expiryDate != null
                            ? Text(_getTimeDifference())
                            : null,
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: _selectExpiryDate,
                      ),
                      if (_expiryDateValidationError != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _expiryDateValidationError!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _banUser,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.block),
                  label: Text(
                    _isLoading ? 'Banning...' : 'Ban User',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _expiryDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          _expiryDateValidationError = null;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getTimeDifference() {
    if (_expiryDate == null) return '';

    final difference = _expiryDate!.difference(DateTime.now());

    if (difference.inDays > 0) {
      return '${difference.inDays} dana od sada';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} sati od sada';
    } else {
      return '${difference.inMinutes} minuta od sada';
    }
  }
}
