import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personaltrainer_mobile/layouts/mobile_navbar.dart';
import 'package:personaltrainer_mobile/models/membership.dart';
import 'package:personaltrainer_mobile/providers/membership_provider.dart';

class MyMembershipsScreen extends StatefulWidget {
  const MyMembershipsScreen({super.key});

  @override
  State<MyMembershipsScreen> createState() => _MyMembershipsScreenState();
}

class _MyMembershipsScreenState extends State<MyMembershipsScreen> {
  final _provider = MembershipProvider();

  List<Membership> _memberships = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final memberships = await _provider.getMyMemberships();
      // Sort: active first, then by expiry descending
      memberships.sort((a, b) {
        if (a.isActive && !b.isActive) return -1;
        if (!a.isActive && b.isActive) return 1;
        return b.expiryDate.compareTo(a.expiryDate);
      });
      setState(() {
        _memberships = memberships;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text(
          'My Memberships',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      drawer: const MobileNavBar(currentRoute: 'memberships'),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE8B44A)),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 56, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _load,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8B44A),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_memberships.isEmpty) {
      return const Center(
        child: Text(
          'No memberships yet.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: const Color(0xFFE8B44A),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _memberships.length,
        itemBuilder: (context, index) =>
            _MembershipCard(membership: _memberships[index]),
      ),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  final Membership membership;

  const _MembershipCard({required this.membership});

  @override
  Widget build(BuildContext context) {
    final isPast = !membership.isActive && !membership.isRevoked;
    final expiryLabel = DateFormat('dd.MM.yyyy').format(membership.expiryDate);
    final startLabel = DateFormat('dd.MM.yyyy').format(membership.startDate);
    final now = DateTime.now();
    final expired = membership.expiryDate.isBefore(now);

    final (chipLabel, chipColor) = _statusStyle();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: trainer name + status chip
            Row(
              children: [
                const Icon(
                  Icons.card_membership,
                  color: Color(0xFFE8B44A),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    membership.trainerFullName ?? 'Personal Trainer',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: chipColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    chipLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: chipColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Expiry row
            _infoRow(
              icon: Icons.event,
              label: expired || isPast
                  ? 'Expired on: $expiryLabel'
                  : 'Expires: $expiryLabel',
              color: expired || isPast ? Colors.grey : Colors.black87,
            ),

            // Days remaining (only when active)
            if (membership.isActive && membership.daysRemaining > 0) ...[
              const SizedBox(height: 6),
              _infoRow(
                icon: Icons.timelapse,
                label: '${membership.daysRemaining} day'
                    '${membership.daysRemaining == 1 ? '' : 's'} remaining',
                color: membership.daysRemaining <= 7
                    ? Colors.orange.shade700
                    : const Color(0xFF2E7D32),
              ),
            ],

            // Start date (smaller, grey)
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.play_circle_outline, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 6),
                Text(
                  'Started: $startLabel',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  (String, Color) _statusStyle() {
    if (membership.isRevoked) {
      return ('Revoked', Colors.red);
    }
    if (!membership.isActive) {
      return ('Expired', Colors.grey);
    }
    if (membership.daysRemaining <= 7) {
      return ('Expiring soon', Colors.orange);
    }
    return ('Active', const Color(0xFF4CAF50));
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    Color color = Colors.black87,
  }) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color.withOpacity(0.7)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 13, color: color)),
      ],
    );
  }
}
