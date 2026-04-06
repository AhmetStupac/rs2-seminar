import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personaltrainer_desktop/models/training_session.dart';
import 'package:personaltrainer_desktop/models/gym.dart';
import 'package:personaltrainer_desktop/models/personal_trainer.dart';
import 'package:personaltrainer_desktop/providers/training_session_provider.dart';
import 'package:personaltrainer_desktop/providers/gym_provider.dart';
import 'package:personaltrainer_desktop/providers/personal_trainer_provider.dart';
import 'package:personaltrainer_desktop/layouts/navBar.dart';

class TrainingSessionCalendarScreen extends StatefulWidget {
  const TrainingSessionCalendarScreen({super.key});

  @override
  State<TrainingSessionCalendarScreen> createState() =>
      _TrainingSessionCalendarScreenState();
}

class _TrainingSessionCalendarScreenState
    extends State<TrainingSessionCalendarScreen> {
  final _trainingSessionProvider = TrainingSessionProvider();
  final _timeScrollController = ScrollController();
  final _calendarScrollController = ScrollController();

  List<TrainingSession> _sessions = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  String _viewType = 'Week'; // Week, Month
  int? _filterPersonalTrainerId;
  int? _filterClientId;
  int? _filterStatus;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  @override
  void dispose() {
    _timeScrollController.dispose();
    _calendarScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);

    try {
      final filter = {
        'PersonalTrainerId': _filterPersonalTrainerId,
        'ClientId': _filterClientId,
        'Status': _filterStatus,
        'DateFrom': _viewType == 'Month'
            ? _getMonthStart(_selectedDate).toIso8601String()
            : _getWeekStart(_selectedDate).toIso8601String(),
        'DateTo': _viewType == 'Month'
            ? _getMonthEnd(_selectedDate).toIso8601String()
            : _getWeekEnd(_selectedDate).toIso8601String(),
        'IncludeCancelled': true,
      };

      filter.removeWhere((key, value) => value == null);

      final result = await _trainingSessionProvider.get(filter: filter);

      setState(() {
        _sessions = result.result ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load sessions.')));
      }
    }
  }

  DateTime _getWeekStart(DateTime date) {
    final weekStart = date.subtract(Duration(days: date.weekday - 1));
    return DateTime(weekStart.year, weekStart.month, weekStart.day, 0, 0, 0);
  }

  DateTime _getWeekEnd(DateTime date) {
    final weekEnd = date.add(Duration(days: 7 - date.weekday));
    return DateTime(weekEnd.year, weekEnd.month, weekEnd.day, 23, 59, 59);
  }

  DateTime _getMonthStart(DateTime date) {
    return DateTime(date.year, date.month, 1, 0, 0, 0);
  }

  DateTime _getMonthEnd(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  void _previousWeek() {
    setState(() {
      if (_viewType == 'Month') {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month - 1,
          1,
        );
      } else {
        _selectedDate = _selectedDate.subtract(const Duration(days: 7));
      }
    });
    _loadSessions();
  }

  void _nextWeek() {
    setState(() {
      if (_viewType == 'Month') {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month + 1,
          1,
        );
      } else {
        _selectedDate = _selectedDate.add(const Duration(days: 7));
      }
    });
    _loadSessions();
  }

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
    });
    _loadSessions();
  }

  @override
  Widget build(BuildContext context) {
    return NavBar(
      'Training Session Calendar',
      Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Training Session Calendar',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Column(
          children: [
            _buildToolbar(),
            _buildCalendarHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _viewType == 'Month'
                  ? _buildMonthView()
                  : _buildWeekView(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddSessionDialog(),
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          // Filter button
          OutlinedButton.icon(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list, size: 18),
            label: const Text('Filter'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(width: 12),
          // View type buttons
          _buildViewTypeButton('Week', isActive: _viewType == 'Week'),
          _buildViewTypeButton('Month', isActive: _viewType == 'Month'),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildViewTypeButton(String type, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: TextButton(
        onPressed: () {
          setState(() => _viewType = type);
          _loadSessions();
        },
        style: TextButton.styleFrom(
          backgroundColor: isActive ? Colors.red : Colors.transparent,
          foregroundColor: isActive ? Colors.white : Colors.grey[700],
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(type),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    String headerText;
    if (_viewType == 'Month') {
      headerText = DateFormat('MMMM yyyy').format(_selectedDate);
    } else {
      final weekStart = _getWeekStart(_selectedDate);
      final weekEnd = _getWeekEnd(_selectedDate);
      headerText =
          '${DateFormat('MMM').format(weekStart)} ${weekStart.day} - ${DateFormat('MMM').format(weekEnd)} ${weekEnd.day}';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousWeek,
          ),
          TextButton(
            onPressed: _goToToday,
            child: const Text(
              'Today',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextWeek,
          ),
          const SizedBox(width: 16),
          Text(
            headerText,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildWeekView() {
    final weekStart = _getWeekStart(_selectedDate);
    final days = List.generate(
      7,
      (index) => weekStart.add(Duration(days: index)),
    );

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Day headers
          _buildDayHeaders(days),
          // Time slots and sessions
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time labels
                _buildTimeLabels(),
                // Day columns
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification is ScrollUpdateNotification) {
                        _timeScrollController.jumpTo(
                          _calendarScrollController.offset,
                        );
                      }
                      return false;
                    },
                    child: SingleChildScrollView(
                      controller: _calendarScrollController,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: days
                            .map((day) => Expanded(child: _buildDayColumn(day)))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayHeaders(List<DateTime> days) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 60), // Space for time labels
          ...days.map((day) {
            final isToday =
                DateFormat('yyyy-MM-dd').format(day) ==
                DateFormat('yyyy-MM-dd').format(DateTime.now());

            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('EEE').format(day),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isToday ? Colors.blue : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isToday ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimeLabels() {
    final hours = List.generate(16, (index) => index + 6); // 6 AM to 10 PM

    return SizedBox(
      width: 60,
      child: SingleChildScrollView(
        controller: _timeScrollController,
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: hours.map((hour) {
            return Container(
              height: 60,
              alignment: Alignment.topRight,
              padding: const EdgeInsets.only(right: 8, top: 4),
              child: Text(
                '${hour.toString().padLeft(2, '0')}:00',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDayColumn(DateTime day) {
    final dayStart = DateTime(day.year, day.month, day.day, 6, 0);
    final daySessions = _sessions
        .where(
          (session) =>
              session.scheduledDateTime != null &&
              DateFormat('yyyy-MM-dd').format(session.scheduledDateTime!) ==
                  DateFormat('yyyy-MM-dd').format(day),
        )
        .toList();

    return Container(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Stack(
        children: [
          // Hour lines
          Column(
            children: List.generate(16, (index) {
              return Container(
                height: 60,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
              );
            }),
          ),
          // Sessions
          ...daySessions.map((session) {
            return _buildSessionCard(session, dayStart);
          }),
        ],
      ),
    );
  }

  Widget _buildSessionCard(TrainingSession session, DateTime dayStart) {
    final startMinutes =
        session.scheduledDateTime!.hour * 60 +
        session.scheduledDateTime!.minute -
        (6 * 60); // Offset from 6 AM
    final top = (startMinutes / 60) * 60.0;
    final height = ((session.durationMinutes ?? 60) / 60) * 60.0;

    Color cardColor;
    if (session.isConfirmed) {
      cardColor = Colors.blue[100]!;
    } else if (session.isPending) {
      cardColor = Colors.orange[100]!;
    } else if (session.isCompleted) {
      cardColor = Colors.green[100]!;
    } else if (session.isCancelled) {
      cardColor = Colors.red[100]!;
    } else {
      cardColor = Colors.grey[200]!;
    }

    return Positioned(
      top: top,
      left: 4,
      right: 4,
      height: height - 4,
      child: GestureDetector(
        onTap: () => _showSessionDetails(session),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: cardColor.withOpacity(0.5), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    DateFormat('HH:mm').format(session.scheduledDateTime!),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (session.statusDisplay != null)
                    Icon(
                      _getStatusIcon(session.status ?? 0),
                      size: 12,
                      color: Colors.black54,
                    ),
                ],
              ),
              if (height > 40) ...[
                const SizedBox(height: 2),
                Text(
                  session.trainerName ?? 'Training Session',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (height > 60 && session.gymName != null) ...[
                const SizedBox(height: 2),
                Text(
                  session.gymName!,
                  style: TextStyle(fontSize: 9, color: Colors.grey[700]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(int status) {
    switch (status) {
      case 0:
        return Icons.pending;
      case 1:
        return Icons.check_circle;
      case 2:
        return Icons.done_all;
      case 3:
        return Icons.cancel;
      case 4:
        return Icons.warning;
      default:
        return Icons.circle;
    }
  }

  void _showSessionDetails(TrainingSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Training Session Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Trainer', session.trainerName ?? 'N/A'),
              _buildDetailRow('Client', session.clientName ?? 'N/A'),
              _buildDetailRow('Gym', session.gymName ?? 'N/A'),
              _buildDetailRow(
                'Date & Time',
                session.scheduledDateTime != null
                    ? DateFormat(
                        'MMM dd, yyyy HH:mm',
                      ).format(session.scheduledDateTime!)
                    : 'N/A',
              ),
              _buildDetailRow(
                'Duration',
                '${session.durationMinutes ?? 0} minutes',
              ),
              _buildDetailRow('Status', session.statusDisplay ?? 'N/A'),
              if (session.notes != null && session.notes!.isNotEmpty)
                _buildDetailRow('Notes', session.notes!),
              if (session.cancellationReason != null &&
                  session.cancellationReason!.isNotEmpty)
                _buildDetailRow(
                  'Cancellation Reason',
                  session.cancellationReason!,
                ),
            ],
          ),
        ),
        actions: [
          if (session.canCancel == true && !session.isCancelled)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _cancelSession(session);
              },
              child: const Text(
                'Cancel Session',
                style: TextStyle(color: Colors.red),
              ),
            ),
          if (session.isPending)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _confirmSession(session);
              },
              child: const Text('Confirm'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSession(TrainingSession session) async {
    try {
      await _trainingSessionProvider.confirm(session.id!);
      _loadSessions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session confirmed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to confirm session.')));
      }
    }
  }

  Future<void> _cancelSession(TrainingSession session) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Training Session'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Cancellation Reason',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Back'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Session'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final request = TrainingSessionCancelRequest(
          cancellationReason: reasonController.text,
        );
        await _trainingSessionProvider.cancel(session.id!, request);
        _loadSessions();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session cancelled successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to cancel session.')),
          );
        }
      }
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Sessions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [const Text('Filter options coming soon...')],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddSessionDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTrainingSessionDialog(
        onSave: (session) {
          // Reload all sessions from the API to ensure consistency
          _loadSessions();
        },
      ),
    );
  }

  Widget _buildMonthView() {
    final monthStart = _getMonthStart(_selectedDate);
    final monthEnd = _getMonthEnd(_selectedDate);

    // Get first day of calendar (start from Monday of the week containing the 1st)
    final firstDayOfMonth = DateTime(monthStart.year, monthStart.month, 1);
    final firstCalendarDay = firstDayOfMonth.subtract(
      Duration(days: firstDayOfMonth.weekday - 1),
    );

    // Calculate total days to show (6 weeks = 42 days)
    final totalDays = 42;
    final calendarDays = List.generate(
      totalDays,
      (index) => firstCalendarDay.add(Duration(days: index)),
    );

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Weekday headers
          Row(
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.2,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: calendarDays.length,
              itemBuilder: (context, index) {
                final day = calendarDays[index];
                final isCurrentMonth = day.month == _selectedDate.month;
                final isToday =
                    DateFormat('yyyy-MM-dd').format(day) ==
                    DateFormat('yyyy-MM-dd').format(DateTime.now());

                final daySessions = _sessions.where((session) {
                  return session.scheduledDateTime != null &&
                      DateFormat(
                            'yyyy-MM-dd',
                          ).format(session.scheduledDateTime!) ==
                          DateFormat('yyyy-MM-dd').format(day);
                }).toList();

                return GestureDetector(
                  onTap: () => _showDaySessions(day, daySessions),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isToday ? Colors.blue[50] : Colors.white,
                      border: Border.all(
                        color: isToday ? Colors.blue : Colors.grey[300]!,
                        width: isToday ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isCurrentMonth
                                  ? (isToday ? Colors.blue : Colors.black87)
                                  : Colors.grey[400],
                            ),
                          ),
                        ),
                        if (daySessions.isNotEmpty)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              child: ListView.builder(
                                itemCount: daySessions.length > 3
                                    ? 3
                                    : daySessions.length,
                                itemBuilder: (context, i) {
                                  if (i == 2 && daySessions.length > 3) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 2),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Text(
                                        '+${daySessions.length - 2} more',
                                        style: const TextStyle(fontSize: 8),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }
                                  final session = daySessions[i];
                                  Color sessionColor;
                                  if (session.isConfirmed) {
                                    sessionColor = Colors.blue[300]!;
                                  } else if (session.isPending) {
                                    sessionColor = Colors.orange[300]!;
                                  } else if (session.isCompleted) {
                                    sessionColor = Colors.green[300]!;
                                  } else if (session.isCancelled) {
                                    sessionColor = Colors.red[300]!;
                                  } else {
                                    sessionColor = Colors.grey[300]!;
                                  }

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 2),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: sessionColor,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      session.scheduledDateTime != null
                                          ? DateFormat(
                                              'HH:mm',
                                            ).format(session.scheduledDateTime!)
                                          : '',
                                      style: const TextStyle(
                                        fontSize: 8,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDaySessions(DateTime day, List<TrainingSession> sessions) {
    if (sessions.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Sessions on ${DateFormat('MMM dd, yyyy').format(day)}',
          style: const TextStyle(fontSize: 18),
        ),
        content: SizedBox(
          width: 400,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(session.trainerName ?? 'Training Session'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (session.scheduledDateTime != null)
                        Text(
                          'Time: ${DateFormat('HH:mm').format(session.scheduledDateTime!)}',
                        ),
                      if (session.clientName != null)
                        Text('Client: ${session.clientName}'),
                      if (session.gymName != null)
                        Text('Gym: ${session.gymName}'),
                      Text('Status: ${session.statusDisplay ?? 'N/A'}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      Navigator.pop(context);
                      _showSessionDetails(session);
                    },
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class AddTrainingSessionDialog extends StatefulWidget {
  final Function(TrainingSession) onSave;

  const AddTrainingSessionDialog({super.key, required this.onSave});

  @override
  State<AddTrainingSessionDialog> createState() =>
      _AddTrainingSessionDialogState();
}

class _AddTrainingSessionDialogState extends State<AddTrainingSessionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _trainingSessionProvider = TrainingSessionProvider();
  final _gymProvider = GymProvider();
  final _personalTrainerProvider = PersonalTrainerProvider();

  List<Gym> _gyms = [];
  List<PersonalTrainer> _trainers = [];
  bool _isLoading = false;

  int? _selectedPersonalTrainerId;
  int? _selectedGymId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _durationMinutes = 60;
  String _notes = '';
  String _trainerNotes = '';
  int _status =
      0; // 0: Pending, 1: Confirmed, 2: Completed, 3: Cancelled, 4: NoShow

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final gymsResult = await _gymProvider.get();
      final trainersResult = await _personalTrainerProvider.get();

      setState(() {
        _gyms = gymsResult.result ?? [];
        _trainers = trainersResult.result ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load data.')));
      }
    }
  }

  Future<void> _saveSession() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate time restriction
    if (_selectedTime.hour < 6 || _selectedTime.hour >= 21) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Treninzi se mogu zakazati samo izmeÄ‘u 6:00 i 21:00!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      final scheduledDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final request = TrainingSessionUpsertRequest(
        personalTrainerId: _selectedPersonalTrainerId,
        gymId: _selectedGymId,
        scheduledDateTime: scheduledDateTime,
        durationMinutes: _durationMinutes,
        notes: _notes.isEmpty ? null : _notes,
        status: _status,
        trainerNotes: _trainerNotes.isEmpty ? null : _trainerNotes,
      );

      final newSession = await _trainingSessionProvider.insert(request);

      if (mounted) {
        widget.onSave(newSession);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Training session created successfully'),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create session.')));
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      // Validate time is between 6 AM and 9 PM
      if (picked.hour < 6 || picked.hour >= 21) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Treninzi se mogu zakazati samo izmeÄ‘u 6:00 i 21:00!',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: _isLoading && _gyms.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Add Training Session',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Personal Trainer Dropdown
                      DropdownButtonFormField<int>(
                        initialValue: _selectedPersonalTrainerId,
                        decoration: const InputDecoration(
                          labelText: 'Personal Trainer *',
                          border: OutlineInputBorder(),
                        ),
                        items: _trainers.map((trainer) {
                          return DropdownMenuItem<int>(
                            value: trainer.id,
                            child: Text(trainer.userFirstName ?? 'Unknown'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPersonalTrainerId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a personal trainer';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Gym Dropdown
                      DropdownButtonFormField<int>(
                        initialValue: _selectedGymId,
                        decoration: const InputDecoration(
                          labelText: 'Gym (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        items: _gyms.map((gym) {
                          return DropdownMenuItem<int>(
                            value: gym.id,
                            child: Text(gym.name ?? 'Unknown'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedGymId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Date and Time Row
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _selectDate,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date *',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(_selectedDate),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: _selectTime,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Time *',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(_selectedTime.format(context)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Duration
                      TextFormField(
                        initialValue: _durationMinutes.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Duration (minutes) *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter duration';
                          }
                          final duration = int.tryParse(value);
                          if (duration == null || duration <= 0) {
                            return 'Please enter a valid duration';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _durationMinutes = int.parse(value!);
                        },
                      ),
                      const SizedBox(height: 16),
                      // Status Dropdown
                      DropdownButtonFormField<int>(
                        initialValue: _status,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('Pending')),
                          DropdownMenuItem(value: 1, child: Text('Confirmed')),
                          DropdownMenuItem(value: 2, child: Text('Completed')),
                          DropdownMenuItem(value: 3, child: Text('Cancelled')),
                          DropdownMenuItem(value: 4, child: Text('No Show')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _status = value ?? 0;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Notes
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onSaved: (value) {
                          _notes = value ?? '';
                        },
                      ),
                      const SizedBox(height: 16),
                      // Trainer Notes
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Trainer Notes (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onSaved: (value) {
                          _trainerNotes = value ?? '';
                        },
                      ),
                      const SizedBox(height: 24),
                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _saveSession,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Save',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

