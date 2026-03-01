import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personaltrainer_desktop/layouts/navBar.dart';
import 'package:personaltrainer_desktop/models/dashboard_report.dart';
import 'package:personaltrainer_desktop/providers/dashboard_provider.dart';
import 'package:personaltrainer_desktop/utils/pdf_report_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    return NavBar('Statistics Dashboard', _buildBody());
  }

  Widget _buildBody() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 56, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text(
                  provider.error!,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => provider.fetchReport(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final report = provider.report;
        if (report == null) {
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
              _buildHeader(context, provider, report),
              const SizedBox(height: 28),
              _buildSummaryCards(context, report),
              const SizedBox(height: 32),
              _buildTopTrainersSection(context, report),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, DashboardProvider provider, DashboardReport report) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.bar_chart_rounded,
              size: 32, color: Colors.deepPurple.shade600),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'System Overview',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Real-time platform statistics',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => provider.fetchReport(),
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
          style: IconButton.styleFrom(
            backgroundColor: Colors.deepPurple.shade50,
            foregroundColor: Colors.deepPurple,
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => PdfReportService.downloadSuperAdminReport(report),
          icon: const Icon(Icons.download),
          label: const Text('Download PDF'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context, DashboardReport report) {
    final cards = [
      _StatCard(
        label: 'Personal Trainers',
        value: report.totalPersonalTrainers.toString(),
        icon: Icons.sports,
        color: Colors.blue,
      ),
      _StatCard(
        label: 'Registered Users',
        value: report.totalUsers.toString(),
        icon: Icons.people_alt_outlined,
        color: Colors.green,
      ),
      _StatCard(
        label: 'Gyms',
        value: report.totalGyms.toString(),
        icon: Icons.fitness_center,
        color: Colors.orange,
      ),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = constraints.maxWidth > 700 ? 3 : 1;
      return GridView.count(
        crossAxisCount: crossAxisCount,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.4,
        children: cards
            .map((c) => _buildStatCard(context, c))
            .toList(),
      );
    });
  }

  Widget _buildStatCard(BuildContext context, _StatCard card) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: card.color.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: card.color.withOpacity(0.15)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: card.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(card.icon, color: card.color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                card.value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: card.color,
                ),
              ),
              Text(
                card.label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopTrainersSection(
      BuildContext context, DashboardReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.emoji_events_rounded,
                color: Colors.amber[700], size: 26),
            const SizedBox(width: 10),
            Text(
              'Top Rated Trainers',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Best performing personal trainers by average rating',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        const SizedBox(height: 16),
        if (report.topTrainers.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: const Center(
              child: Text('No rated trainers yet.'),
            ),
          )
        else
          ...report.topTrainers.asMap().entries.map((entry) {
            return _buildTrainerTile(context, entry.value, entry.key);
          }),
      ],
    );
  }

  Widget _buildTrainerTile(
      BuildContext context, TopTrainerReportItem trainer, int index) {
    final medals = [Colors.amber[600]!, Colors.grey[500]!, Colors.brown[400]!];
    final medalLabels = ['1st', '2nd', '3rd'];
    final medalColor = index < medals.length ? medals[index] : Colors.blue;
    final medalLabel =
        index < medalLabels.length ? medalLabels[index] : '#${index + 1}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: medalColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              medalLabel,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: medalColor,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            backgroundColor: Colors.deepPurple.shade100,
            radius: 22,
            child: Text(
              trainer.trainerFullName.isNotEmpty
                  ? trainer.trainerFullName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade700,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trainer.trainerFullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${trainer.ratingCount} review${trainer.ratingCount == 1 ? '' : 's'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          _buildStarRating(trainer.averageRating),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                trainer.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                'out of 5',
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (rating >= i + 1) {
          return Icon(Icons.star_rounded, color: Colors.amber[600], size: 18);
        } else if (rating >= i + 0.5) {
          return Icon(Icons.star_half_rounded,
              color: Colors.amber[600], size: 18);
        } else {
          return Icon(Icons.star_outline_rounded,
              color: Colors.grey[300], size: 18);
        }
      }),
    );
  }
}

class _StatCard {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}
