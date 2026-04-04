import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personaltrainer_mobile/models/group_training_session.dart';
import 'package:personaltrainer_mobile/providers/group_training_session_provider.dart';
import 'package:personaltrainer_mobile/providers/auth_provider.dart';

class GroupTrainingSessionDetailScreen extends StatefulWidget {
  final GroupTrainingSession session;

  const GroupTrainingSessionDetailScreen({super.key, required this.session});

  @override
  State<GroupTrainingSessionDetailScreen> createState() =>
      _GroupTrainingSessionDetailScreenState();
}

class _GroupTrainingSessionDetailScreenState
    extends State<GroupTrainingSessionDetailScreen> {
  final _provider = GroupTrainingSessionProvider();

  late GroupTrainingSession _session;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
  }

  bool get _isMySession => _session.creatorId == AuthProvider.userId;

  bool get _hasJoined =>
      _session.participants.any((p) => p.userId == AuthProvider.userId);

  Future<void> _handleJoin() async {
    final userId = AuthProvider.userId;
    if (userId == null) return;

    setState(() => _isLoading = true);
    try {
      final updated = await _provider.join(_session.id);
      setState(() {
        _session = updated;
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have joined the session!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to join: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLeave() async {
    final userId = AuthProvider.userId;
    if (userId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Session'),
        content: const Text(
          'Are you sure you want to leave this group session?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await _provider.leave(_session.id);
      // Reload session to reflect updated participants
      final result = await _provider.get(filter: {'Id': _session.id});
      if (result.result.isNotEmpty) {
        setState(() {
          _session = result.result.first;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have left the session.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to leave: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(),
                  const SizedBox(height: 20),
                  _buildInfoSection(),
                  const SizedBox(height: 20),
                  if (_session.notes != null && _session.notes!.isNotEmpty) ...[
                    _buildNotesSection(),
                    const SizedBox(height: 20),
                  ],
                  _buildCreatorSection(),
                  const SizedBox(height: 20),
                  _buildParticipantsSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: const Color(0xFF3A5A30),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3A5A30), Color(0xFF6B8F5E)],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                _buildTypeIconLarge(_session.trainingType),
                const SizedBox(height: 12),
                Text(
                  _session.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _session.trainingType,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIconLarge(String trainingType) {
    final type = trainingType.toLowerCase();
    IconData icon;

    if (type.contains('run') || type.contains('jog')) {
      icon = Icons.directions_run;
    } else if (type.contains('cycle') || type.contains('bike')) {
      icon = Icons.directions_bike;
    } else if (type.contains('swim')) {
      icon = Icons.pool;
    } else if (type.contains('yoga')) {
      icon = Icons.self_improvement;
    } else if (type.contains('weight') || type.contains('body')) {
      icon = Icons.fitness_center;
    } else if (type.contains('hike') || type.contains('trek')) {
      icon = Icons.terrain;
    } else {
      icon = Icons.sports;
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 32),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.timer_outlined,
            value: '${_session.durationMinutes}',
            unit: 'min',
            color: Colors.blue.shade600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.local_fire_department_outlined,
            value: '${_session.kcalBurned}',
            unit: 'kcal',
            color: Colors.deepOrange.shade600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.group_outlined,
            value: '${_session.participantCount}',
            unit: 'joined',
            color: Colors.green.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(unit, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.location_on_outlined, 'Location', _session.place),
          const Divider(height: 20),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            'Created',
            DateFormat('dd MMM yyyy').format(_session.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFFE8B44A)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.note_alt_outlined,
              size: 18,
              color: Colors.blue.shade600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notes',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
                const SizedBox(height: 4),
                Text(
                  _session.notes!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatorSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.orange.shade100,
            child: const Icon(Icons.person, color: Colors.orange, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Created by',
                  style: TextStyle(fontSize: 11, color: Colors.black45),
                ),
                Text(
                  _session.creatorName.isEmpty
                      ? 'Unknown'
                      : _session.creatorName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (_isMySession)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8B44A).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'You',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFE8B44A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildParticipantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.group, size: 18, color: Color(0xFFE8B44A)),
            const SizedBox(width: 8),
            Text(
              'Participants (${_session.participantCount})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_session.participants.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'No participants yet. Be the first to join!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black38, fontSize: 13),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _session.participants.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 58),
              itemBuilder: (context, index) {
                final participant = _session.participants[index];
                final isCurrentUser = participant.userId == AuthProvider.userId;
                return ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: isCurrentUser
                        ? Colors.orange.shade100
                        : Colors.grey.shade100,
                    child: Icon(
                      Icons.person,
                      size: 20,
                      color: isCurrentUser ? Colors.orange : Colors.grey,
                    ),
                  ),
                  title: Text(
                    participant.userName.isEmpty
                        ? 'User #${participant.userId}'
                        : participant.userName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isCurrentUser
                          ? FontWeight.w700
                          : FontWeight.normal,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Joined ${DateFormat('dd MMM yyyy').format(participant.joinedAt)}',
                    style: const TextStyle(fontSize: 11, color: Colors.black38),
                  ),
                  trailing: isCurrentUser
                      ? const Text(
                          'You',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFE8B44A),
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildBottomBar() {
    if (_isMySession) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFFF5E6D3),
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: _isLoading
              ? null
              : (_hasJoined ? _handleLeave : _handleJoin),
          style: ElevatedButton.styleFrom(
            backgroundColor: _hasJoined
                ? Colors.white
                : const Color(0xFFE8B44A),
            foregroundColor: _hasJoined ? Colors.red : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: _hasJoined
                  ? const BorderSide(color: Colors.red)
                  : BorderSide.none,
            ),
            elevation: _hasJoined ? 0 : 2,
          ),
          child: _isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: _hasJoined ? Colors.red : Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _hasJoined ? Icons.exit_to_app : Icons.group_add,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _hasJoined ? 'Leave Session' : 'Join Session',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
