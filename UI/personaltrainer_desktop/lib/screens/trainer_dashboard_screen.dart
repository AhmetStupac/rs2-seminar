import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personaltrainer_desktop/layouts/navBar.dart';
import 'package:personaltrainer_desktop/models/trainer_dashboard.dart';
import 'package:personaltrainer_desktop/providers/dashboard_provider.dart';
import 'package:personaltrainer_desktop/utils/pdf_report_service.dart';

class TrainerDashboardScreen extends StatefulWidget {
  const TrainerDashboardScreen({super.key});

  @override
  State<TrainerDashboardScreen> createState() => _TrainerDashboardScreenState();
}

class _TrainerDashboardScreenState extends State<TrainerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchTrainerDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return NavBar('My Dashboard', _buildBody());
  }

  Widget _buildBody() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        if (provider.isTrainerLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.trainerError != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 56, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text(
                  provider.trainerError!,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => provider.fetchTrainerDashboard(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final d = provider.trainerDashboard;
        if (d == null) {
          return const Center(child: Text('No data available.'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
              ),
              const SizedBox(height: 8),
              _buildHeader(context, provider, d),
              const SizedBox(height: 28),
              _buildSectionTitle(context, Icons.attach_money, 'Revenue', Colors.green),
              const SizedBox(height: 12),
              _buildRevenueCard(context, d),
              const SizedBox(height: 24),
              _buildSectionTitle(context, Icons.shopping_cart_outlined, 'Sales', Colors.blue),
              const SizedBox(height: 12),
              _buildSalesRow(context, d),
              const SizedBox(height: 24),
              _buildSectionTitle(context, Icons.assignment_outlined, 'Plans Created', Colors.orange),
              const SizedBox(height: 12),
              _buildPlansRow(context, d),
              const SizedBox(height: 24),
              _buildSectionTitle(context, Icons.star_rounded, 'Rating', Colors.amber),
              const SizedBox(height: 12),
              _buildRatingCard(context, d),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, DashboardProvider provider, TrainerDashboard d) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.teal.shade100,
          child: Text(
            d.trainerFullName.isNotEmpty ? d.trainerFullName[0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                d.trainerFullName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${d.totalClients} total client${d.totalClients == 1 ? '' : 's'}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => provider.fetchTrainerDashboard(),
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
          style: IconButton.styleFrom(
            backgroundColor: Colors.teal.shade50,
            foregroundColor: Colors.teal,
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => PdfReportService.downloadTrainerReport(d),
          icon: const Icon(Icons.download),
          label: const Text('Download PDF'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildRevenueCard(BuildContext context, TrainerDashboard d) {
    return _card(
      color: Colors.green,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.euro, color: Colors.green, size: 32),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '€${d.totalEarnedEur.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Text(
                'Total Revenue',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalesRow(BuildContext context, TrainerDashboard d) {
    return Row(
      children: [
        Expanded(
          child: _statTile(
            icon: Icons.fitness_center,
            label: 'Training Plans',
            value: d.soldTrainingPlans.toString(),
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statTile(
            icon: Icons.restaurant_menu,
            label: 'Nutrition Plans',
            value: d.soldNutritionPlans.toString(),
            color: Colors.purple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statTile(
            icon: Icons.card_membership,
            label: 'Memberships',
            value: d.soldMemberships.toString(),
            color: Colors.teal,
          ),
        ),
      ],
    );
  }

  Widget _buildPlansRow(BuildContext context, TrainerDashboard d) {
    return Row(
      children: [
        Expanded(
          child: _statTile(
            icon: Icons.assignment,
            label: 'Training Plans',
            value: d.totalTrainingPlansCreated.toString(),
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statTile(
            icon: Icons.menu_book,
            label: 'Nutrition Plans',
            value: d.totalNutritionPlansCreated.toString(),
            color: Colors.deepOrange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statTile(
            icon: Icons.people,
            label: 'Total Clients',
            value: d.totalClients.toString(),
            color: Colors.indigo,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingCard(BuildContext context, TrainerDashboard d) {
    return _card(
      color: Colors.amber,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.star_rounded, color: Colors.amber, size: 32),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    d.averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, left: 4),
                    child: Text(
                      '/ 5',
                      style: TextStyle(color: Colors.grey[500], fontSize: 16),
                    ),
                  ),
                ],
              ),
              Text(
                '${d.ratingCount} review${d.ratingCount == 1 ? '' : 's'}',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
          const SizedBox(width: 20),
          _buildStars(d.averageRating),
        ],
      ),
    );
  }

  Widget _buildStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (rating >= i + 1) {
          return Icon(Icons.star_rounded, color: Colors.amber[600], size: 22);
        } else if (rating >= i + 0.5) {
          return Icon(Icons.star_half_rounded, color: Colors.amber[600], size: 22);
        } else {
          return Icon(Icons.star_outline_rounded, color: Colors.grey[300], size: 22);
        }
      }),
    );
  }

  Widget _statTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return _card(
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _card({required Color color, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: child,
    );
  }
}
