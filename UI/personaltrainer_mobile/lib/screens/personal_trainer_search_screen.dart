import 'package:flutter/material.dart';
import 'package:personaltrainer_mobile/models/personal_trainer.dart';
import 'package:personaltrainer_mobile/models/personal_trainer_rating.dart';
import 'package:personaltrainer_mobile/providers/auth_provider.dart';
import 'package:personaltrainer_mobile/providers/personal_trainer_provider.dart';
import 'package:personaltrainer_mobile/providers/personal_trainer_rating_provider.dart';
import 'package:personaltrainer_mobile/screens/personal_trainer_detail_screen.dart';
import 'package:personaltrainer_mobile/layouts/mobile_navbar.dart';

class PersonalTrainerSearchScreen extends StatefulWidget {
  const PersonalTrainerSearchScreen({super.key});

  @override
  State<PersonalTrainerSearchScreen> createState() =>
      _PersonalTrainerSearchScreenState();
}

class _PersonalTrainerSearchScreenState
    extends State<PersonalTrainerSearchScreen> {
  final _searchController = TextEditingController();
  final _personalTrainerProvider = PersonalTrainerProvider();
  final _ratingProvider = PersonalTrainerRatingProvider();
  List<PersonalTrainer> _trainers = [];
  List<PersonalTrainer> _filteredTrainers = [];
  Map<int, PersonalTrainerRatingStats> _ratingsMap = {};
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedSport;
  PersonalTrainer? _recommendedTrainer;
  bool _isLoadingRecommendation = false;

  @override
  void initState() {
    super.initState();
    _loadTrainers();
    _loadRecommendation();
    _searchController.addListener(_filterTrainers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTrainers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _personalTrainerProvider.get();
      setState(() {
        _trainers = result.result;
        _filteredTrainers = result.result;
      });

      // Load ratings for all trainers
      await _loadRatings();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRecommendation() async {
    final userId = AuthProvider.userId;
    if (userId == null) return;

    setState(() {
      _isLoadingRecommendation = true;
    });

    try {
      final recommended = await _personalTrainerProvider.recommend();
      setState(() {
        _recommendedTrainer = recommended;
        _isLoadingRecommendation = false;
      });
    } catch (e) {
      print('Error loading recommendation: $e');
      setState(() {
        _isLoadingRecommendation = false;
      });
    }
  }

  Future<void> _loadRatings() async {
    final Map<int, PersonalTrainerRatingStats> ratingsMap = {};

    for (var trainer in _trainers) {
      if (trainer.id != null) {
        try {
          final stats = await _ratingProvider.getTrainerRatingStats(
            trainer.id!,
          );
          ratingsMap[trainer.id!] = stats;
        } catch (e) {
          print('Error loading rating for trainer ${trainer.id}: $e');
          // Continue loading other ratings even if one fails
        }
      }
    }

    setState(() {
      _ratingsMap = ratingsMap;
    });
  }

  void _filterTrainers() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _filteredTrainers = _trainers.where((trainer) {
        // Filter by name
        final name = trainer.userFirstName?.toLowerCase() ?? '';
        final matchesName = query.isEmpty || name.contains(query);

        // Filter by sport
        final matchesSport =
            _selectedSport == null ||
            _selectedSport == 'All sports' ||
            trainer.sport == _selectedSport;

        return matchesName && matchesSport;
      }).toList();
    });
  }

  List<String> _getUniqueSports() {
    final sports = _trainers
        .where((trainer) => trainer.sport != null && trainer.sport!.isNotEmpty)
        .map((trainer) => trainer.sport!)
        .toSet()
        .toList();
    sports.sort();
    return ['All sports', ...sports];
  }

  void _showFilterDialog() {
    final sports = _getUniqueSports();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter by sport'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: sports.map((sport) {
                return ListTile(
                  title: Text(sport),
                  leading: Radio<String>(
                    value: sport,
                    groupValue: _selectedSport ?? 'All sports',
                    onChanged: (String? value) {
                      setState(() {
                        _selectedSport = value == 'All sports' ? null : value;
                      });
                      _filterTrainers();
                      Navigator.of(context).pop();
                    },
                  ),
                  onTap: () {
                    setState(() {
                      _selectedSport = sport == 'All sports' ? null : sport;
                    });
                    _filterTrainers();
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
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
          'Trainer search',
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
      ),
      drawer: const MobileNavBar(currentRoute: 'search'),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search trainers',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : IconButton(
                          icon: Stack(
                            children: [
                              const Icon(Icons.tune, color: Colors.grey),
                              if (_selectedSport != null)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 8,
                                      minHeight: 8,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          onPressed: _showFilterDialog,
                        ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Active filter chip
          if (_selectedSport != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text(_selectedSport!),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        _selectedSport = null;
                      });
                      _filterTrainers();
                    },
                    backgroundColor: Colors.orange.shade100,
                  ),
                ],
              ),
            ),
          if (_selectedSport != null) const SizedBox(height: 12),

          // Recommended trainer
          if (_isLoadingRecommendation)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (_recommendedTrainer != null)
            _buildRecommendationCard(),

          // Results list
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard() {
    final trainer = _recommendedTrainer!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PersonalTrainerDetailScreen(trainer: trainer),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withOpacity(0.3),
                child: const Icon(Icons.star, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recommended for you',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      trainer.userFirstName ?? 'Unknown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (trainer.sport != null && trainer.sport!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          trainer.sport!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
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
              onPressed: _loadTrainers,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    if (_filteredTrainers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'No available trainers'
                  : 'No results for "${_searchController.text}"',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredTrainers.length,
      itemBuilder: (context, index) {
        final trainer = _filteredTrainers[index];
        return _buildTrainerCard(trainer);
      },
    );
  }

  Widget _buildTrainerCard(PersonalTrainer trainer) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PersonalTrainerDetailScreen(trainer: trainer),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
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
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[300],
              child: Text(
                _getInitials(trainer.userFirstName ?? ''),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trainer.userFirstName ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  if (trainer.sport != null && trainer.sport!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        trainer.sport!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (trainer.yearsOfExperience != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${trainer.yearsOfExperience} years of experience',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                ],
              ),
            ),

            // Rating stars
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text(
                      _ratingsMap[trainer.id]?.averageRating.toStringAsFixed(
                            1,
                          ) ??
                          '0.0',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
