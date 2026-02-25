import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personaltrainer_desktop/providers/auth_provider.dart';

class BannedScreen extends StatelessWidget {
  final String reason;
  final DateTime? bannedAt;
  final DateTime? expiresAt;
  final bool isPermanent;

  const BannedScreen({
    super.key,
    required this.reason,
    this.bannedAt,
    this.expiresAt,
    this.isPermanent = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.block,
                      size: 80,
                      color: Colors.red.shade700,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Nalog je banovan',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Razlog:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(reason, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (bannedAt != null)
                      Text(
                        'Banovano: ${DateFormat('dd.MM.yyyy HH:mm').format(bannedAt!)}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                    const SizedBox(height: 8),
                    if (isPermanent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Permanentno',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else if (expiresAt != null)
                      Text(
                        'Ističe: ${DateFormat('dd.MM.yyyy HH:mm').format(expiresAt!)}',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        AuthProvider.logout();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/login',
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Odjavi se'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}