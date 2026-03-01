import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:personaltrainer_mobile/models/monthly_training_statistics.dart';
import 'package:personaltrainer_mobile/providers/monthly_training_statistics_provider.dart';
import 'package:personaltrainer_mobile/providers/auth_provider.dart';

class TrainingStatisticsScreen extends StatefulWidget {
  const TrainingStatisticsScreen({super.key});

  @override
  State<TrainingStatisticsScreen> createState() =>
      _TrainingStatisticsScreenState();
}

class _TrainingStatisticsScreenState extends State<TrainingStatisticsScreen> {
  final _statisticsProvider = MonthlyTrainingStatisticsProvider();

  List<MonthlyTrainingStatistics> _statistics = [];
  bool _isLoading = false;
  String? _error;
  int _selectedYear = DateTime.now().year;
  bool _isLocaleInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('bs', null);
    setState(() {
      _isLocaleInitialized = true;
    });
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await _statisticsProvider.getMyStatisticsByYear(
        _selectedYear,
      );
      setState(() {
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading statistics: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _changeYear(int delta) {
    setState(() {
      _selectedYear += delta;
    });
    _loadStatistics();
  }

  int get _totalSessions {
    return _statistics.fold(
      0,
      (sum, stat) => sum + (stat.trainingSessionCount ?? 0),
    );
  }

  int get _maxCount {
    if (_statistics.isEmpty) return 10;
    final max = _statistics
        .map((s) => s.trainingSessionCount ?? 0)
        .reduce((a, b) => a > b ? a : b);
    return max > 0 ? max : 10;
  }

  String _getEnglishMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return month >= 1 && month <= 12 ? months[month - 1] : '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E6D3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Training statistics',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: !_isLocaleInitialized
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE8B44A)),
            )
          : _buildBody(),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadStatistics,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8B44A),
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Year selector
            _buildYearSelector(),
            const SizedBox(height: 24),

            // Summary card
            _buildSummaryCard(),
            const SizedBox(height: 24),

            // Monthly statistics
            const Text(
              'Monthly Training Sessions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Monthly bars
            ..._statistics.map((stat) => _buildMonthBar(stat)),
          ],
        ),
      ),
    );
  }

  Widget _buildYearSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeYear(-1),
            icon: const Icon(Icons.chevron_left, size: 32),
            color: const Color(0xFFE8B44A),
          ),
          Text(
            _selectedYear.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          IconButton(
            onPressed: _selectedYear < DateTime.now().year
                ? () => _changeYear(1)
                : null,
            icon: const Icon(Icons.chevron_right, size: 32),
            color: _selectedYear < DateTime.now().year
                ? const Color(0xFFE8B44A)
                : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE8B44A),
            const Color(0xFFE8B44A).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8B44A).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fitness_center, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Text(
                _totalSessions.toString(),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Total trainings this year',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthBar(MonthlyTrainingStatistics stat) {
    final count = stat.trainingSessionCount ?? 0;
    final percentage = _maxCount > 0 ? count / _maxCount : 0.0;
    // Use English month names from month number
    final monthName = _getEnglishMonthName(stat.month ?? 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: count > 0
                          ? const Color(0xFFE8B44A).withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count sessions',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: count > 0
                            ? const Color(0xFFE8B44A)
                            : Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      stat.comment != null && stat.comment!.isNotEmpty
                          ? Icons.edit_note
                          : Icons.add_comment,
                      color: const Color(0xFFE8B44A),
                      size: 24,
                    ),
                    onPressed: () => _showCommentDialog(stat),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                count > 0 ? const Color(0xFFE8B44A) : Colors.grey,
              ),
            ),
          ),
          if (stat.comment != null && stat.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8B44A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.note, size: 16, color: Color(0xFFE8B44A)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      stat.comment!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showCommentDialog(MonthlyTrainingStatistics stat) async {
    final commentController = TextEditingController(text: stat.comment ?? '');

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${stat.monthName} Comment'),
        content: TextField(
          controller: commentController,
          decoration: const InputDecoration(
            hintText: 'Add a comment about this month...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          maxLength: 200,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, commentController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8B44A),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      await _saveComment(stat, result);
    }
  }

  Future<void> _saveComment(
    MonthlyTrainingStatistics stat,
    String comment,
  ) async {
    if (AuthProvider.userId == null) return;

    try {
      final request = MonthlyCommentUpsertRequest(
        year: stat.year,
        month: stat.month,
        comment: comment.isEmpty ? null : comment,
      );

      await _statisticsProvider.updateMonthlyComment(
        AuthProvider.userId!,
        request,
      );

      // Refresh statistics
      await _loadStatistics();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error saving comment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save comment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
