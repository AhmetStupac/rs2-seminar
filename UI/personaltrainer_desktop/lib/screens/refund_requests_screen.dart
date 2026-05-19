import 'package:flutter/material.dart';
import 'package:personaltrainer_desktop/layouts/navBar.dart';
import 'package:personaltrainer_desktop/models/personal_trainer.dart';
import 'package:personaltrainer_desktop/providers/admin_provider.dart';
import 'package:personaltrainer_desktop/providers/auth_provider.dart';
import 'package:personaltrainer_desktop/providers/personal_trainer_provider.dart';

class RefundRequestsScreen extends StatefulWidget {
  const RefundRequestsScreen({super.key});

  @override
  State<RefundRequestsScreen> createState() => _RefundRequestsScreenState();
}

class _RefundRequestsScreenState extends State<RefundRequestsScreen> {
  final _adminProvider = AdminProvider();
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;
  final Set<String> _processingIds = {};

  // Resolved for Administrator / PersonalTrainer roles
  int? _myTrainerId;

  bool get _isRestricted =>
      AuthProvider.isAdministrator || AuthProvider.isPersonalTrainer;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      // Resolve the PersonalTrainer record once for non-SuperAdmin roles
      if (_isRestricted && _myTrainerId == null) {
        final trainers = await PersonalTrainerProvider().get();
        final mine = trainers.result.firstWhere(
          (t) => t.userId == AuthProvider.userId,
          orElse: () => PersonalTrainer(),
        );
        _myTrainerId = mine.id;
      }

      final data = await _adminProvider.getRefundRequests(
        trainerId: _isRestricted ? _myTrainerId : null,
      );
      setState(() {
        _requests = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading refund requests: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleDecision(Map<String, dynamic> payment, bool approve) async {
    final intentId = payment['stripePaymentIntentId']?.toString() ?? '';
    if (intentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing Stripe Payment Intent ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final action = approve ? 'approve' : 'reject';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              approve ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: approve ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(approve ? 'Approve Refund' : 'Reject Refund'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to $action this refund request?'),
            const SizedBox(height: 12),
            _buildInfoRow('Payment ID', _shortId(intentId)),
            if (payment['amount'] != null)
              _buildInfoRow('Amount', _formatAmount(payment['amount'], payment['currency'])),
            if (payment['userEmail'] != null || payment['userName'] != null)
              _buildInfoRow('User', payment['userEmail'] ?? payment['userName'] ?? ''),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: approve ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(approve ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _processingIds.add(intentId));
    try {
      final result = await _adminProvider.refundDecision(
        stripePaymentIntentId: intentId,
        approve: approve,
      );

      if (!mounted) return;
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Done'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Operation failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _processingIds.remove(intentId));
    }
  }

  String _shortId(String id) {
    if (id.length <= 20) return id;
    return '${id.substring(0, 10)}...${id.substring(id.length - 6)}';
  }

  String _formatAmount(dynamic amount, dynamic currency) {
    final num val = (amount is num) ? amount : double.tryParse(amount.toString()) ?? 0;
    final String cur = (currency?.toString() ?? 'USD').toUpperCase();
    final double displayVal = val > 1000 ? val / 100 : val.toDouble();
    return '${displayVal.toStringAsFixed(2)} $cur';
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canAccess =
        AuthProvider.isSuperAdmin || _isRestricted;

    if (!canAccess) {
      return NavBar(
        'Refund Requests',
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'Access Denied',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'This section is only available to admins and personal trainers.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return NavBar(
      'Refund Requests',
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.currency_exchange, color: Colors.orange.shade700, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Refund Requests',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  _isLoading
                      ? 'Loading...'
                      : '${_requests.length} pending request${_requests.length != 1 ? 's' : ''}'
                            '${_isRestricted ? ' · your plans only' : ''}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadRequests,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No pending refund requests',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'All refund requests have been processed.',
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _requests.length,
        itemBuilder: (context, index) => _buildRequestCard(_requests[index]),
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> payment) {
    final intentId = payment['stripePaymentIntentId']?.toString() ?? '';
    final isProcessing = _processingIds.contains(intentId);
    final amount = payment['amount'];
    final currency = payment['currency'];
    final userEmail = payment['userEmail']?.toString() ?? payment['userName']?.toString();
    final createdAt = payment['createdAt']?.toString() ?? payment['date']?.toString();
    final refundReason = payment['refundReason']?.toString() ?? payment['notes']?.toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.orange.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, size: 12, color: Colors.orange.shade800),
                      const SizedBox(width: 4),
                      Text(
                        'Refund Requested',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (amount != null)
                  Text(
                    _formatAmount(amount, currency),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (intentId.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.tag, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      intentId,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            if (userEmail != null) ...[
              Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    userEmail,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            if (createdAt != null) ...[
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(createdAt),
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            if (refundReason != null && refundReason.isNotEmpty) ...[
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reason',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      refundReason,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isProcessing ? null : () => _handleDecision(payment, false),
                    icon: isProcessing
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.close, size: 16),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isProcessing ? null : () => _handleDecision(payment, true),
                    icon: isProcessing
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check, size: 16),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }
}
