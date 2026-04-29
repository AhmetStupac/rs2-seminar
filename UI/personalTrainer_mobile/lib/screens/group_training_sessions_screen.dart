import 'package:flutter/material.dart';
import 'package:personaltrainer_mobile/models/group_training_session.dart';
import 'package:personaltrainer_mobile/providers/group_training_session_provider.dart';
import 'package:personaltrainer_mobile/providers/auth_provider.dart';
import 'package:personaltrainer_mobile/screens/group_training_session_create_screen.dart';
import 'package:personaltrainer_mobile/screens/group_training_session_detail_screen.dart';
import 'package:personaltrainer_mobile/layouts/mobile_navbar.dart';

class GroupTrainingSessionsScreen extends StatefulWidget {
  const GroupTrainingSessionsScreen({super.key});

  @override
  State<GroupTrainingSessionsScreen> createState() =>
      _GroupTrainingSessionsScreenState();
}

class _GroupTrainingSessionsScreenState
    extends State<GroupTrainingSessionsScreen> {
  final _provider = GroupTrainingSessionProvider();

  List<GroupTrainingSession> _sessions = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _provider.get();
      setState(() {
        _sessions = result.result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSession(GroupTrainingSession session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Session'),
        content: Text(
          'Are you sure you want to delete "${session.name}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _provider.deleteSession(session.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        _loadSessions();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete session: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  int get _totalParticipants =>
      _sessions.fold(0, (sum, s) => sum + s.participantCount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E6D3),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Group Sessions',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      drawer: const MobileNavBar(currentRoute: 'group_sessions'),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const GroupTrainingSessionCreateScreen(),
            ),
          ).then((_) => _loadSessions());
        },
        backgroundColor: const Color(0xFFE8B44A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Create Session',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _loadSessions,
      color: const Color(0xFFE8B44A),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeroSection()),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFE8B44A)),
              ),
            )
          else if (_error != null)
            SliverFillRemaining(child: _buildError())
          else if (_sessions.isEmpty)
            SliverFillRemaining(child: _buildEmpty())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildSessionCard(_sessions[index]),
                  childCount: _sessions.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF4A6741),
        image: const DecorationImage(
          image: AssetImage('assets/images/outdoor_training.jpg'),
          fit: BoxFit.cover,
          onError: _noImageError,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.55),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Discover New Activities',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Join a session and meet new people',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildParticipantAvatars(),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_totalParticipants',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Currently active: ${_sessions.length} sessions',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantAvatars() {
    final colors = [
      Colors.orange.shade300,
      Colors.blue.shade300,
      Colors.green.shade300,
      Colors.purple.shade300,
    ];
    return SizedBox(
      width: 60,
      height: 28,
      child: Stack(
        children: List.generate(
          colors.length.clamp(0, 4),
          (i) => Positioned(
            left: i * 14.0,
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: colors[i],
                child: const Icon(Icons.person, size: 14, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionCard(GroupTrainingSession session) {
    final isMySession = session.creatorId == AuthProvider.userId;
    final hasJoined = session.participants
        .any((p) => p.userId == AuthProvider.userId);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                GroupTrainingSessionDetailScreen(session: session),
          ),
        ).then((_) => _loadSessions());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildTypeIcon(session.trainingType),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          session.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isMySession) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8B44A).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Mine',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFFE8B44A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _deleteSession(session),
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.delete_outline,
                              size: 16,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ),
                      ] else if (hasJoined)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Joined',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.trainingType,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined,
                          size: 14, color: Colors.black45),
                      const SizedBox(width: 3),
                      Text(
                        '${session.durationMinutes} min',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.local_fire_department_outlined,
                          size: 14, color: Colors.deepOrange),
                      const SizedBox(width: 3),
                      Text(
                        '${session.kcalBurned} kcal',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Icon(Icons.group_outlined,
                        size: 15, color: Colors.black45),
                    const SizedBox(width: 3),
                    Text(
                      '${session.participantCount}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: Colors.black38),
                    const SizedBox(width: 2),
                    SizedBox(
                      width: 70,
                      child: Text(
                        session.place,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black45),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeIcon(String trainingType) {
    final type = trainingType.toLowerCase();
    IconData icon;
    Color color;
    Color bg;

    if (type.contains('run') || type.contains('jog')) {
      icon = Icons.directions_run;
      color = Colors.orange.shade700;
      bg = Colors.orange.shade50;
    } else if (type.contains('cycle') || type.contains('bike')) {
      icon = Icons.directions_bike;
      color = Colors.blue.shade700;
      bg = Colors.blue.shade50;
    } else if (type.contains('swim')) {
      icon = Icons.pool;
      color = Colors.lightBlue.shade700;
      bg = Colors.lightBlue.shade50;
    } else if (type.contains('yoga')) {
      icon = Icons.self_improvement;
      color = Colors.purple.shade600;
      bg = Colors.purple.shade50;
    } else if (type.contains('weight') || type.contains('body')) {
      icon = Icons.fitness_center;
      color = Colors.red.shade600;
      bg = Colors.red.shade50;
    } else if (type.contains('hike') || type.contains('trek')) {
      icon = Icons.terrain;
      color = Colors.green.shade700;
      bg = Colors.green.shade50;
    } else {
      icon = Icons.sports;
      color = const Color(0xFFE8B44A);
      bg = const Color(0xFFFFF8E1);
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 26),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_work_outlined, size: 72, color: Colors.grey[350]),
            const SizedBox(height: 16),
            Text(
              'No group sessions yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to create a group training session!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GroupTrainingSessionCreateScreen(),
                  ),
                ).then((_) => _loadSessions());
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Session'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8B44A),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Failed to load sessions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadSessions,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8B44A)),
              child: const Text('Retry',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

void _noImageError(Object error, StackTrace? stackTrace) {
  // silently ignore missing asset
}
