import 'package:flutter/material.dart';
import 'package:personaltrainer_mobile/layouts/mobile_navbar.dart';
import 'package:personaltrainer_mobile/models/payment_record.dart';
import 'package:personaltrainer_mobile/providers/auth_provider.dart';
import 'package:personaltrainer_mobile/providers/payment_provider.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final _paymentProvider = PaymentProvider();

  List<PaymentRecord> _payments = [];
  bool _isLoading = false;
  String? _errorMessage;
  final Set<String> _refundInProgress = {};

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    if (AuthProvider.userId == null) {
      setState(() {
        _errorMessage = 'User not logged in';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final payments = await _paymentProvider.getUserPayments();
      setState(() {
        _payments = payments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = _userMessageFromError(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefund(PaymentRecord payment) async {
    final stripeId = payment.stripePaymentIntentId;
    if (stripeId == null || stripeId.isEmpty) {
      _showSnackBar('Missing Stripe identifier.');
      return;
    }

    setState(() {
      _refundInProgress.add(stripeId);
    });

    try {
      await _paymentProvider.refundPayment(stripeId);
      if (!mounted) return;
      _showSnackBar('Refund request submitted.');
      await _loadPayments();
    } catch (e) {
      if (mounted) {
        _showSnackBar(_userMessageFromError(e));
      }
    } finally {
      if (mounted) {
        setState(() {
          _refundInProgress.remove(stripeId);
        });
      }
    }
  }

  String _userMessageFromError(Object error) {
    final message = error.toString().replaceAll('Exception: ', '').trim();
    final match = RegExp(r'API Error \((\d+)\):\s*(.*)').firstMatch(message);
    if (match != null) {
      final code = match.group(1) ?? '';
      final detail = (match.group(2) ?? '').trim();
      if (code == '400') {
        return detail.isNotEmpty ? detail : 'Invalid request.';
      }
      if (code == '403') {
        return detail.isNotEmpty ? detail : 'You are not allowed to refund.';
      }
      if (code == '404') {
        return detail.isNotEmpty ? detail : 'Payment not found.';
      }
    }
    return message.isNotEmpty ? message : 'Something went wrong.';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _canRefund(PaymentRecord payment) {
    final status = (payment.status ?? '').toLowerCase();
    if (status == 'refunded' || status == 'refund_pending') {
      return false;
    }
    if (status != 'succeeded') {
      return false;
    }
    final stripeId = payment.stripePaymentIntentId;
    return stripeId != null && stripeId.isNotEmpty;
  }

  String _formatAmount(int? cents) {
    if (cents == null) return '-';
    final euros = cents / 100;
    return 'EUR ${euros.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final local = date.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _itemTypeLabel(int? itemType) {
    switch (itemType) {
      case 0:
        return 'Training Plan';
      case 1:
        return 'Nutrition Plan';
      case 2:
        return 'Membership';
      default:
        return 'Item';
    }
  }

  String _displayName(PaymentRecord payment) {
    if (payment.itemName != null && payment.itemName!.isNotEmpty) {
      return payment.itemName!;
    }
    return _itemTypeLabel(payment.itemType);
  }

  String _refundKey(PaymentRecord payment) {
    return payment.stripePaymentIntentId ?? payment.id?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8E1),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Payments', style: TextStyle(color: Colors.black87)),
        centerTitle: true,
      ),
      drawer: const MobileNavBar(currentRoute: 'payments'),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPayments,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    if (_payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No payments to display.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPayments,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _payments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final payment = _payments[index];
          final status = payment.status ?? 'unknown';
          final canRefund = _canRefund(payment);
          final refundKey = _refundKey(payment);
          final isRefunding =
              refundKey.isNotEmpty && _refundInProgress.contains(refundKey);

          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _displayName(payment),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        _formatAmount(payment.amountInCents),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Status: $status',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${_formatDate(payment.createdAt)}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: canRefund && !isRefunding
                          ? () => _handleRefund(payment)
                          : null,
                      child: isRefunding
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Refund'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
