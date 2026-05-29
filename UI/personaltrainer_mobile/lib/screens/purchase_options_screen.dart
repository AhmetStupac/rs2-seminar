import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personaltrainer_mobile/models/membership.dart';
import 'package:personaltrainer_mobile/models/nutrition_plan.dart';
import 'package:personaltrainer_mobile/models/personal_trainer.dart';
import 'package:personaltrainer_mobile/models/training_plan.dart';
import 'package:personaltrainer_mobile/providers/membership_provider.dart';
import 'package:personaltrainer_mobile/providers/nutrition_plan_provider.dart';
import 'package:personaltrainer_mobile/providers/training_plan_provider.dart';
import 'package:personaltrainer_mobile/screens/payment_screen.dart';

class PurchaseOptionsScreen extends StatefulWidget {
  final PersonalTrainer trainer;

  const PurchaseOptionsScreen({super.key, required this.trainer});

  @override
  State<PurchaseOptionsScreen> createState() => _PurchaseOptionsScreenState();
}

class _PurchaseOptionsScreenState extends State<PurchaseOptionsScreen> {
  final _trainingPlanProvider = TrainingPlanProvider();
  final _nutritionPlanProvider = NutritionPlanProvider();
  final _membershipProvider = MembershipProvider();

  List<TrainingPlan> _trainingPlans = [];
  List<NutritionPlan> _nutritionPlans = [];

  bool _loadingTrainingPlans = false;
  bool _loadingNutritionPlans = false;

  bool _trainingExpanded = false;
  bool _nutritionExpanded = false;

  // Membership state
  bool _checkingMembership = true;
  bool _hasActiveMembership = false;
  Membership? _activeMembership;
  int _activeClientCount = 0;
  bool _trainerFull = false;

  @override
  void initState() {
    super.initState();
    _loadTrainingPlans();
    _loadNutritionPlans();
    _loadMembershipStatus();
  }

  Future<void> _loadTrainingPlans() async {
    setState(() => _loadingTrainingPlans = true);
    try {
      final result = await _trainingPlanProvider.get(
        filter: {
          if (widget.trainer.id != null) 'personalTrainerId': widget.trainer.id,
          'pageSize': 50,
        },
      );
      setState(() {
        _trainingPlans = result.result;
        _loadingTrainingPlans = false;
      });
    } catch (e) {
      setState(() => _loadingTrainingPlans = false);
    }
  }

  Future<void> _loadNutritionPlans() async {
    setState(() => _loadingNutritionPlans = true);
    try {
      final result = await _nutritionPlanProvider.get(
        filter: {
          if (widget.trainer.id != null) 'personalTrainerId': widget.trainer.id,
          'pageSize': 50,
        },
      );
      setState(() {
        _nutritionPlans = result.result;
        _loadingNutritionPlans = false;
      });
    } catch (e) {
      setState(() => _loadingNutritionPlans = false);
    }
  }

  Future<void> _loadMembershipStatus() async {
    if (widget.trainer.id == null) {
      setState(() => _checkingMembership = false);
      return;
    }

    setState(() => _checkingMembership = true);

    try {
      final results = await Future.wait([
        _membershipProvider.hasActiveMembership(widget.trainer.id!),
        _membershipProvider.getActiveClientCount(widget.trainer.id!),
        _membershipProvider.getMyMemberships(),
      ]);

      final hasActive = results[0] as bool;
      final clientCount = results[1] as int;
      final myMemberships = results[2] as List<Membership>;

      Membership? activeMembership;
      if (hasActive) {
        activeMembership = myMemberships
            .where(
              (m) => m.personalTrainerId == widget.trainer.id && m.isActive,
            )
            .firstOrNull;
      }

      setState(() {
        _hasActiveMembership = hasActive;
        _activeMembership = activeMembership;
        _activeClientCount = clientCount;
        _trainerFull = clientCount >= 5;
        _checkingMembership = false;
      });
    } catch (_) {
      setState(() => _checkingMembership = false);
    }
  }

  Future<void> _navigateToPayment({
    required int itemType,
    int? itemId,
    required String itemName,
    String? priceLabel,
  }) async {
    final paymentSuccess = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          itemType: itemType,
          itemId: itemId,
          itemName: itemName,
          priceLabel: priceLabel,
        ),
      ),
    );

    if (!mounted) return;

    if (itemType == 2 && paymentSuccess == true) {
      // Refresh membership status after a successful purchase
      await _loadMembershipStatus();
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.trainer.userFirstName != null
              ? 'Purchase — ${widget.trainer.userFirstName}'
              : 'Purchase options',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose what you want to buy',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // --- Training Plan ---
              _buildExpandableOption(
                icon: Icons.fitness_center,
                color: const Color(0xFF4CAF50),
                title: 'Training plan',
                subtitle: 'Buy personalized training plan',
                isExpanded: _trainingExpanded,
                isLoading: _loadingTrainingPlans,
                onToggle: () =>
                    setState(() => _trainingExpanded = !_trainingExpanded),
                itemsBuilder: () => _buildPlanList(
                  isLoading: _loadingTrainingPlans,
                  items: _trainingPlans
                      .map(
                        (p) => _PlanItem(
                          id: p.id ?? 0,
                          name: p.title ?? 'No name',
                          price: p.basePrice != null
                              ? '€${p.basePrice!.toStringAsFixed(2)}'
                              : null,
                        ),
                      )
                      .toList(),
                  emptyMessage: 'No available training plans.',
                  onSelect: (item) => _navigateToPayment(
                    itemType: 0,
                    itemId: item.id,
                    itemName: item.name,
                    priceLabel: item.price,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // --- Nutrition Plan ---
              _buildExpandableOption(
                icon: Icons.restaurant_menu,
                color: const Color(0xFF2196F3),
                title: 'Nutrition plan',
                subtitle: 'Buy personalized nutrition plan',
                isExpanded: _nutritionExpanded,
                isLoading: _loadingNutritionPlans,
                onToggle: () =>
                    setState(() => _nutritionExpanded = !_nutritionExpanded),
                itemsBuilder: () => _buildPlanList(
                  isLoading: _loadingNutritionPlans,
                  items: _nutritionPlans
                      .map(
                        (p) => _PlanItem(
                          id: p.id ?? 0,
                          name: p.title ?? 'No name',
                          price: p.price != null
                              ? '€${p.price!.toStringAsFixed(2)}'
                              : null,
                        ),
                      )
                      .toList(),
                  emptyMessage: 'No available nutrition plans.',
                  onSelect: (item) => _navigateToPayment(
                    itemType: 1,
                    itemId: item.id,
                    itemName: item.name,
                    priceLabel: item.price,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // --- Membership ---
              _buildMembershipSection(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMembershipSection() {
    if (_checkingMembership) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: const Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFE8B44A),
            ),
          ),
        ),
      );
    }

    // User already has an active membership
    if (_hasActiveMembership) {
      return _buildActiveMembershipCard();
    }

    // Trainer is full
    if (_trainerFull) {
      return _buildMembershipFullCard();
    }

    // Normal buy button
    return _buildBuyMembershipCard();
  }

  Widget _buildActiveMembershipCard() {
    final days = _activeMembership?.daysRemaining ?? 0;
    final expiry = _activeMembership?.expiryDate;
    final expiryLabel = expiry != null
        ? DateFormat('dd.MM.yyyy').format(expiry)
        : null;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.4),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF4CAF50),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active membership',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  days > 0
                      ? 'Expires in $days day${days == 1 ? '' : 's'}'
                          '${expiryLabel != null ? ' ($expiryLabel)' : ''}'
                      : expiryLabel != null
                      ? 'Expires $expiryLabel'
                      : 'Membership active',
                  style: TextStyle(fontSize: 13, color: Colors.green[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipFullCard() {
    return Column(
      children: [
        // Warning banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.orange.shade700, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "This trainer's client spots are full (5/5). Memberships are not available.",
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Greyed-out card
        Opacity(
          opacity: 0.45,
          child: _buildBuyMembershipCard(disabled: true),
        ),
      ],
    );
  }

  Widget _buildBuyMembershipCard({bool disabled = false}) {
    final membershipPrice = widget.trainer.membershipPrice;
    final priceConfigured = membershipPrice != null && membershipPrice > 0;
    final priceLabel = priceConfigured
        ? '€${membershipPrice!.toStringAsFixed(2)}'
        : null;

    return InkWell(
      onTap: disabled || !priceConfigured
          ? null
          : () => _navigateToPayment(
                itemType: 2,
                itemId: widget.trainer.id,
                itemName:
                    'Membership — ${widget.trainer.userFirstName ?? "Trainer"}',
                priceLabel: priceLabel,
              ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: disabled
                ? [Colors.grey.shade400, Colors.grey.shade500]
                : const [Color(0xFFE8B44A), Color(0xFFD4A030)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFFE8B44A).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.card_membership,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Membership',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    priceConfigured
                        ? 'Monthly subscription — $priceLabel'
                        : 'Membership price not configured',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableOption({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool isExpanded,
    required bool isLoading,
    required VoidCallback onToggle,
    required Widget Function() itemsBuilder,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded ? color.withOpacity(0.4) : Colors.grey[200]!,
          width: isExpanded ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: itemsBuilder(),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanList({
    required bool isLoading,
    required List<_PlanItem> items,
    required String emptyMessage,
    required void Function(_PlanItem) onSelect,
  }) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        children: items.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              onTap: () => onSelect(item),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 4,
              ),
              title: Text(
                item.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.price != null)
                    Text(
                      item.price!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE8B44A),
                      ),
                    ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PlanItem {
  final int id;
  final String name;
  final String? price;

  const _PlanItem({required this.id, required this.name, this.price});
}
