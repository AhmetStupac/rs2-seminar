import 'package:flutter/material.dart';
import 'package:personaltrainer_mobile/providers/admin_provider.dart';

class BanUserScreen extends StatefulWidget {
  final int userId;
  final String username;

  const BanUserScreen({
    Key? key,
    required this.userId,
    required this.username,
  }) : super(key: key);

  @override
  State<BanUserScreen> createState() => _BanUserScreenState();
}

class _BanUserScreenState extends State<BanUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _adminProvider = AdminProvider();

  bool _isPermanent = true;
  DateTime? _expiryDate;
  bool _isLoading = false;

  Future<void> _banUser() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isPermanent && _expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izaberite datum isteka bana')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ⭐ Ispravljeno: koristi named parametre
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
            content: Text(result['message'] ?? 'Korisnik uspešno banovan'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Greška pri banovanju'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška: $e'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banuj korisnika'),
        backgroundColor: Colors.red.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info card
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
                              'Korisnik: ${widget.username}',
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

              // Razlog
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Razlog banovanja *',
                  hintText: 'npr. Kršenje pravila zajednice',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Razlog je obavezan';
                  }
                  if (value.length < 10) {
                    return 'Razlog mora imati minimum 10 karaktera';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Tip bana
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Permanentno banovanje'),
                      subtitle: const Text('Ban bez vremenskog ograničenja'),
                      value: _isPermanent,
                      activeColor: Colors.red.shade700,
                      onChanged: (value) {
                        setState(() => _isPermanent = value);
                      },
                    ),
                    if (!_isPermanent) ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(
                          _expiryDate == null
                              ? 'Izaberi datum isteka'
                              : 'Ističe: ${_formatDate(_expiryDate!)}',
                        ),
                        subtitle: _expiryDate != null
                            ? Text(_getTimeDifference())
                            : null,
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: _selectExpiryDate,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Dugme za banovanje
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
                    _isLoading ? 'Banovanje...' : 'Banuj korisnika',
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