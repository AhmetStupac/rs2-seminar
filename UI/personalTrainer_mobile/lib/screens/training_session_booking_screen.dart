import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:personaltrainer_mobile/models/personal_trainer.dart';
import 'package:personaltrainer_mobile/models/training_session.dart';
import 'package:personaltrainer_mobile/providers/training_session_provider.dart';
import 'package:personaltrainer_mobile/providers/auth_provider.dart';
import 'package:personaltrainer_mobile/screens/purchase_options_screen.dart';
import 'package:personaltrainer_mobile/services/membership_access_service.dart';

class TrainingSessionBookingScreen extends StatefulWidget {
  final PersonalTrainer trainer;
  final TrainingSession? existingSession;

  const TrainingSessionBookingScreen({
    super.key,
    required this.trainer,
    this.existingSession,
  });

  @override
  State<TrainingSessionBookingScreen> createState() =>
      _TrainingSessionBookingScreenState();
}

class _TrainingSessionBookingScreenState
    extends State<TrainingSessionBookingScreen> {
  final _trainingSessionProvider = TrainingSessionProvider();

  DateTime _selectedDate = DateTime.now();
  int? _selectedHour;
  bool _isCheckingAvailability = false;
  bool? _isAvailable;
  bool _isBooking = false;
  List<DateTime> _availableSlots = [];
  bool _isLoadingSlots = false;
  bool _isLocaleInitialized = false;
  bool _isCheckingMembership = true;
  bool _hasMembership = false;

  bool get _isEditMode => widget.existingSession != null;

  @override
  void initState() {
    super.initState();

    final scheduledDateTime = widget.existingSession?.scheduledDateTime;
    if (scheduledDateTime != null) {
      _selectedDate = DateTime(
        scheduledDateTime.year,
        scheduledDateTime.month,
        scheduledDateTime.day,
      );
      _selectedHour = scheduledDateTime.hour;
      _isAvailable = true;
    }

    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('bs', null);
    setState(() {
      _isLocaleInitialized = true;
    });
    _checkMembershipAndLoadSlots();
  }

  Future<void> _checkMembershipAndLoadSlots() async {
    if (widget.trainer.id == null) {
      setState(() {
        _isCheckingMembership = false;
        _hasMembership = false;
      });
      return;
    }

    final hasMembership = await MembershipAccessService.hasMembershipForTrainer(
      widget.trainer.id!,
    );

    if (!mounted) return;

    setState(() {
      _hasMembership = hasMembership;
      _isCheckingMembership = false;
    });

    if (hasMembership) {
      await _loadAvailableSlots();
    }
  }

  Future<void> _loadAvailableSlots() async {
    if (widget.trainer.id == null || !_hasMembership) return;

    setState(() => _isLoadingSlots = true);

    try {
      final slots = await _trainingSessionProvider.getAvailableSlots(
        widget.trainer.id!,
        _selectedDate,
      );

      setState(() {
        _availableSlots = slots;
        _isLoadingSlots = false;
      });
    } catch (e) {
      setState(() => _isLoadingSlots = false);
    }
  }

  Future<void> _checkAvailability(int hour) async {
    if (widget.trainer.id == null || !_hasMembership) return;

    if (_isOriginalSlotSelected(hour)) {
      setState(() {
        _selectedHour = hour;
        _isCheckingAvailability = false;
        _isAvailable = true;
      });
      return;
    }

    setState(() {
      _selectedHour = hour;
      _isCheckingAvailability = true;
      _isAvailable = null;
    });

    try {
      final scheduledDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        hour,
      );

      final available = await _trainingSessionProvider.checkAvailability(
        widget.trainer.id!,
        scheduledDateTime,
        60, // Default 60 minutes duration
      );

      setState(() {
        _isAvailable = available;
        _isCheckingAvailability = false;
      });
    } catch (e) {
      setState(() {
        _isCheckingAvailability = false;
        _isAvailable = false;
      });
    }
  }

  bool _isOriginalSlotSelected(int hour) {
    final original = widget.existingSession?.scheduledDateTime;
    if (original == null) return false;

    return original.year == _selectedDate.year &&
        original.month == _selectedDate.month &&
        original.day == _selectedDate.day &&
        original.hour == hour;
  }

  Future<void> _saveTrainingSession() async {
    if (!_hasMembership) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'You need an active trainer membership before booking a session.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (_isEditMode && widget.existingSession?.id == null) {
      return;
    }

    if (widget.trainer.id == null ||
        _selectedHour == null ||
        _isAvailable != true)
      return;

    setState(() => _isBooking = true);

    try {
      final scheduledDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedHour!,
      );

      final request = TrainingSessionUpsertRequest(
        personalTrainerId: widget.trainer.id,
        scheduledDateTime: scheduledDateTime,
        durationMinutes: 60,
        status: _isEditMode ? (widget.existingSession?.status ?? 0) : 0,
      );

      if (_isEditMode) {
        await _trainingSessionProvider.update(
          widget.existingSession!.id!,
          request,
        );
      } else {
        await _trainingSessionProvider.insert(request);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Training session rescheduled successfully!'
                  : 'Training session booked successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(
          context,
          true,
        ); // Return true to indicate booking was made
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Failed to reschedule training session: $e'
                  : 'Failed to book training session: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }

  void _selectDate(DateTime date) {
    if (!_hasMembership) return;

    setState(() {
      _selectedDate = date;
      _selectedHour = null;
      _isAvailable = null;
    });
    _loadAvailableSlots();
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
        title: Text(
          _isEditMode ? 'Reschedule session' : 'Calendar',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: !_isLocaleInitialized
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE8B44A)),
            )
          : _isCheckingMembership
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE8B44A)),
            )
          : !_hasMembership
          ? _buildMembershipRequiredView()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date display
                    Center(
                      child: Text(
                        DateFormat('EEEE, dd MMMM', 'bs').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Calendar grid
                    _buildCalendar(),
                    const SizedBox(height: 32),

                    // Day labels
                    _buildDayLabels(),
                    const SizedBox(height: 24),

                    // Time slot selector
                    _buildTimeSlotSelector(),
                    const SizedBox(height: 16),

                    // Availability status
                    if (_isCheckingAvailability)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(
                            color: Color(0xFFE8B44A),
                          ),
                        ),
                      )
                    else if (_isAvailable != null)
                      Center(
                        child: Text(
                          _isAvailable! ? 'Free slot' : 'Slot not available',
                          style: TextStyle(
                            color: _isAvailable!
                                ? const Color(0xFF4CAF50)
                                : Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Book button
                    if (_isAvailable == true)
                      Center(
                        child: ElevatedButton(
                          onPressed: _isBooking ? null : _saveTrainingSession,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE8B44A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isBooking
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _isEditMode ? 'Reschedule slot' : 'Book slot',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMembershipRequiredView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8B44A).withOpacity(0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 48,
                color: Color(0xFFE8B44A),
              ),
              const SizedBox(height: 16),
              const Text(
                'Membership required',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              const Text(
                'You must buy a membership from this trainer before booking a training session.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PurchaseOptionsScreen(trainer: widget.trainer),
                      ),
                    );

                    if (!mounted) return;

                    if (result == true) {
                      setState(() {
                        _isCheckingMembership = true;
                      });
                      await _checkMembershipAndLoadSlots();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8B44A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Buy membership'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    final now = DateTime.now();
    final daysInMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month + 1,
      0,
    ).day;
    final firstDayOfMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      1,
    );
    final firstWeekday = firstDayOfMonth.weekday;

    return Column(
      children: [
        for (int week = 0; week < 5; week++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int day = 1; day <= 7; day++)
                  Builder(
                    builder: (context) {
                      final dayNumber = week * 7 + day - firstWeekday + 1;
                      if (dayNumber < 1 || dayNumber > daysInMonth) {
                        return const SizedBox(width: 40, height: 40);
                      }

                      final date = DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        dayNumber,
                      );
                      final isSelected = _selectedDate.day == dayNumber;
                      final isToday =
                          date.year == now.year &&
                          date.month == now.month &&
                          date.day == now.day;

                      return GestureDetector(
                        onTap: () => _selectDate(date),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFE8B44A)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: isToday
                                ? Border.all(
                                    color: const Color(0xFFE8B44A),
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              dayNumber.toString(),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: isSelected || isToday
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDayLabels() {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: days.map((day) {
        final isToday =
            day == DateFormat('E', 'bs').format(DateTime.now()).substring(0, 3);

        return SizedBox(
          width: 40,
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: day == 'Tue' ? const Color(0xFFE8B44A) : Colors.black54,
              fontWeight: day == 'Tue' ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeSlotSelector() {
    final hours = List.generate(13, (index) => index + 6); // 6 AM to 6 PM

    return Column(
      children: [
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: hours.length,
            itemBuilder: (context, index) {
              final hour = hours[index];
              final isSelected = _selectedHour == hour;

              return GestureDetector(
                onTap: () => _checkAvailability(hour),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE8B44A) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFE8B44A)
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${hour.toString().padLeft(2, '0')}:00',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
