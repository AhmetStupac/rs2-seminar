import 'package:flutter/material.dart';
import 'package:personaltrainer_mobile/layouts/mobile_navbar.dart';
import 'package:personaltrainer_mobile/models/nutrition_plan.dart';
import 'package:personaltrainer_mobile/providers/nutrition_plan_provider.dart';
import 'package:personaltrainer_mobile/providers/auth_provider.dart';

class NutritionPlanScreen extends StatefulWidget {
  const NutritionPlanScreen({super.key});

  @override
  State<NutritionPlanScreen> createState() => _NutritionPlanScreenState();
}

class _NutritionPlanScreenState extends State<NutritionPlanScreen> {
  final _nutritionPlanProvider = NutritionPlanProvider();

  List<NutritionPlan> _nutritionPlans = [];
  NutritionPlan? _selectedPlan;

  bool _isLoadingPlans = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNutritionPlans();
  }

  Future<void> _loadNutritionPlans() async {
    if (AuthProvider.userId == null) {
      setState(() {
        _errorMessage = 'User not logged in';
      });
      return;
    }

    setState(() {
      _isLoadingPlans = true;
      _errorMessage = null;
    });

    try {
      // Get nutrition plans for the logged-in user
      final result = await _nutritionPlanProvider.get(
        filter: {'userId': AuthProvider.userId.toString()},
      );

      print(
        '📋 Loaded ${result.result.length} nutrition plans for user ${AuthProvider.userId}',
      );
      for (var plan in result.result) {
        print(
          '  - Plan ID: ${plan.id}, Title: ${plan.title}, UserId: ${plan.userId}',
        );
      }

      setState(() {
        _nutritionPlans = result.result;
        _isLoadingPlans = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoadingPlans = false;
      });
    }
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
        title: const Text(
          'Moji planovi ishrane',
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
      ),
      drawer: const MobileNavBar(currentRoute: 'nutrition_plan'),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoadingPlans) {
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
              onPressed: _loadNutritionPlans,
              child: const Text('Pokušaj ponovo'),
            ),
          ],
        ),
      );
    }

    if (_nutritionPlans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nemate dodijeljenih planova ishrane',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Show nutrition plan detail view if a plan is selected
    if (_selectedPlan != null) {
      return _buildNutritionDetailView();
    }

    // Show list of nutrition plans
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _nutritionPlans.length,
      itemBuilder: (context, index) {
        final plan = _nutritionPlans[index];
        return _buildNutritionPlanCard(plan);
      },
    );
  }

  Widget _buildNutritionPlanCard(NutritionPlan plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPlan = plan;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.restaurant_menu,
                  color: Colors.orange.shade700,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.title ?? 'Plan ishrane',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (plan.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        plan.description!,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionDetailView() {
    return Column(
      children: [
        // Custom header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.only(top: 40, bottom: 16),
          child: Column(
            children: [
              // Header with back button, title, and menu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black87),
                      onPressed: () {
                        setState(() {
                          _selectedPlan = null;
                        });
                      },
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Plan ishrane',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.black87),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              // Plan icon
              const SizedBox(height: 16),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.orange.shade400,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _selectedPlan?.title ?? 'Plan ishrane',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Description
              if (_selectedPlan?.description != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    _selectedPlan!.description!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // Price
              if (_selectedPlan?.price != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_selectedPlan?.price?.toStringAsFixed(2)} KM',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
        // Nutrition details
        Expanded(
          child: Container(
            color: Colors.white,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Nutritional information card
                _buildNutritionInfoCard(),
                const SizedBox(height: 16),
                // Macros breakdown
                _buildMacrosCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Informacije o ishrani',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const Divider(height: 24),
            if (_selectedPlan?.totalCalories != null) ...[
              _buildInfoRow(
                'Ukupne kalorije',
                '${_selectedPlan?.totalCalories} kcal',
                Icons.local_fire_department,
                Colors.red.shade400,
              ),
              const SizedBox(height: 12),
            ],
            if (_selectedPlan?.createdAt != null) ...[
              _buildInfoRow(
                'Kreiran',
                _formatDate(_selectedPlan?.createdAt),
                Icons.calendar_today,
                Colors.blue.shade400,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMacrosCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Makronutrijenti',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const Divider(height: 24),
            if (_selectedPlan?.protein != null) ...[
              _buildMacroRow(
                'Proteini',
                '${_selectedPlan?.protein}g',
                Colors.blue.shade400,
                0.8,
              ),
              const SizedBox(height: 16),
            ],
            if (_selectedPlan?.carbs != null) ...[
              _buildMacroRow(
                'Ugljeni hidrati',
                '${_selectedPlan?.carbs}g',
                Colors.orange.shade400,
                0.6,
              ),
              const SizedBox(height: 16),
            ],
            if (_selectedPlan?.fats != null) ...[
              _buildMacroRow(
                'Masti',
                '${_selectedPlan?.fats}g',
                Colors.green.shade400,
                0.4,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacroRow(
    String label,
    String value,
    Color color,
    double percentage,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}.${date.month}.${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
