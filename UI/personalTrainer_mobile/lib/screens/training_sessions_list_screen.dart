import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personaltrainer_mobile/models/personal_trainer.dart';
import 'package:personaltrainer_mobile/models/training_session.dart';
import 'package:personaltrainer_mobile/providers/training_session_provider.dart';
import 'package:personaltrainer_mobile/providers/auth_provider.dart';
import 'package:personaltrainer_mobile/providers/messages_provider.dart';
import 'package:personaltrainer_mobile/screens/training_session_booking_screen.dart';
import 'package:personaltrainer_mobile/screens/personal_trainer_search_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

class TrainingSessionsListScreen extends StatefulWidget {
  const TrainingSessionsListScreen({super.key});

  @override
  State<TrainingSessionsListScreen> createState() =>
      _TrainingSessionsListScreenState();
}

class _TrainingSessionsListScreenState
    extends State<TrainingSessionsListScreen> {
  final _trainingSessionProvider = TrainingSessionProvider();
  final _messagesProvider = MessagesProvider();

  List<TrainingSession> _sessions = [];
  bool _isLoading = false;
  String? _error;
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
    _loadTrainingSessions();
  }

  Future<void> _loadTrainingSessions() async {
    if (AuthProvider.userId == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _trainingSessionProvider.get(
        filter: {'ClientId': AuthProvider.userId},
      );

      setState(() {
        _sessions = result.result
          ..sort((a, b) {
            if (a.scheduledDateTime == null || b.scheduledDateTime == null) {
              return 0;
            }
            return b.scheduledDateTime!.compareTo(a.scheduledDateTime!);
          });
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelSession(TrainingSession session) async {
    if (session.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Training Session'),
        content: const Text(
          'Are you sure you want to cancel this training session?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await _trainingSessionProvider.cancel(
        session.id!,
        TrainingSessionCancelRequest(cancellationReason: 'Cancelled by client'),
      );

      // Send cancellation notification message to the trainer
      bool messageSent = false;
      if (session.personalTrainerId != null &&
          session.scheduledDateTime != null) {
        try {
          final trainerId = session.personalTrainerId.toString();
          final dateTime = DateFormat(
            'dd.MM.yyyy HH:mm',
          ).format(session.scheduledDateTime!);
          final cancellationMessage =
              'Training session for $dateTime has been cancelled by the client.';

          // Connect to messaging hub and send message
          await _messagesProvider.connect(trainerId);
          await _messagesProvider.sendMessage(cancellationMessage);
          await _messagesProvider.disconnect();

          messageSent = true;
        } catch (e) {
          // Don't show error to user, as cancellation was successful
        }
      }

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              messageSent
                  ? 'Training session cancelled. Trainer has been notified.'
                  : 'Training session cancelled successfully',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        _loadTrainingSessions();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel session: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rescheduleSession(TrainingSession session) async {
    if (session.id == null || session.personalTrainerId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to reschedule this session.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final trainer = PersonalTrainer(
      id: session.personalTrainerId,
      userFirstName: session.trainerName,
    );

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingSessionBookingScreen(
          trainer: trainer,
          existingSession: session,
        ),
      ),
    );

    if (result == true && mounted) {
      await _loadTrainingSessions();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session rescheduled successfully.')),
      );
    }
  }

  @override
  void dispose() {
    _messagesProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3), // Beige background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E6D3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Training sessions',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PersonalTrainerSearchScreen(),
            ),
          ).then((_) {
            // Refresh the list when coming back
            _loadTrainingSessions();
          });
        },
        backgroundColor: const Color(0xFFE8B44A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Book session',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (!_isLocaleInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE8B44A)),
      );
    }

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
              'Error loading training sessions',
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
              onPressed: _loadTrainingSessions,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8B44A),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No training sessions scheduled',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Book your first session with a trainer',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PersonalTrainerSearchScreen(),
                    ),
                  ).then((_) {
                    // Refresh the list when coming back
                    _loadTrainingSessions();
                  });
                },
                icon: const Icon(Icons.search),
                label: const Text('Find a Trainer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8B44A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTrainingSessions,
      color: const Color(0xFFE8B44A),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _sessions.length,
        itemBuilder: (context, index) {
          final session = _sessions[index];
          return _buildSessionCard(session);
        },
      ),
    );
  }

  Widget _buildSessionCard(TrainingSession session) {
    final scheduledDateTime = session.scheduledDateTime;
    if (scheduledDateTime == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and status indicator
          Row(
            children: [
              // Status indicator
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getStatusColor(session),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              // Date
              Text(
                DateFormat('dd.MM.yyyy').format(scheduledDateTime),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              // Action buttons
              if (session.canCancel == true)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () => _cancelSession(session),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              const SizedBox(width: 8),
              if (session.canEdit == true)
                IconButton(
                  icon: const Icon(Icons.calendar_today, size: 20),
                  onPressed: () => _rescheduleSession(session),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Training description
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF4CAF50),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  session.trainerName != null
                      ? 'Training session booked with ${session.trainerName} is ${session.durationMinutes ?? 60} minutes'
                      : 'Training session booked for ${session.durationMinutes ?? 60} minutes',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Time and location
          Row(
            children: [
              Text(
                DateFormat('HH:mm').format(scheduledDateTime),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 16),
              if (session.gymName != null) ...[
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.black54,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    session.gymName!,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // Status label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(session).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getStatusText(session),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getStatusColor(session),
              ),
            ),
          ),

          // Notes if available
          if (session.notes != null && session.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.note_outlined,
                    size: 16,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      session.notes!,
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

          // Cancellation info if cancelled
          if (session.isCancelled &&
              session.cancellationReason != null &&
              session.cancellationReason!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.cancel_outlined,
                    size: 16,
                    color: Colors.red.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cancellation reason:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          session.cancellationReason!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
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

  Color _getStatusColor(TrainingSession session) {
    if (session.isCancelled) {
      return Colors.red;
    } else if (session.isCompleted) {
      return Colors.green;
    } else if (session.isConfirmed) {
      return const Color(0xFF4CAF50); // Active green
    } else if (session.isPending) {
      return const Color(0xFFE8B44A); // Pending yellow/orange
    } else if (session.isNoShow) {
      return Colors.grey;
    }
    return Colors.grey;
  }

  String _getStatusText(TrainingSession session) {
    // Check cancelled status first, regardless of statusDisplay from backend
    if (session.isCancelled) {
      return 'Cancelled';
    }

    // Use backend statusDisplay if available
    if (session.statusDisplay != null && session.statusDisplay!.isNotEmpty) {
      return session.statusDisplay!;
    }

    // Fallback to local status determination
    if (session.isCompleted) {
      return 'Completed';
    } else if (session.isConfirmed) {
      return 'Confirmed';
    } else if (session.isPending) {
      return 'Pending';
    } else if (session.isNoShow) {
      return 'Did not show up';
    }
    return 'Unknown';
  }
}
