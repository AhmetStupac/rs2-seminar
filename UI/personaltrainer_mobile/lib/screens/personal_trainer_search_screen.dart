import 'package:flutter/material.dart';
import 'package:personaltrainer_mobile/models/personal_trainer.dart';
import 'package:personaltrainer_mobile/models/personal_trainer_rating.dart';
import 'package:personaltrainer_mobile/providers/personal_trainer_provider.dart';
import 'package:personaltrainer_mobile/providers/personal_trainer_rating_provider.dart';
import 'package:personaltrainer_mobile/screens/personal_trainer_detail_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadTrainers();
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

  Future<void> _loadRatings() async {
    final Map<int, PersonalTrainerRatingStats> ratingsMap = {};
    
    for (var trainer in _trainers) {
      if (trainer.id != null) {
        try {
          final stats = await _ratingProvider.getTrainerRatingStats(trainer.id!);
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
        final matchesSport = _selectedSport == null || 
                             _selectedSport == 'Svi sportovi' ||
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
    return ['Svi sportovi', ...sports];
  }

  void _showFilterDialog() {
    final sports = _getUniqueSports();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filtriraj po sportu'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: sports.map((sport) {
                return ListTile(
                  title: Text(sport),
                  leading: Radio<String>(
                    value: sport,
                    groupValue: _selectedSport ?? 'Svi sportovi',
                    onChanged: (String? value) {
                      setState(() {
                        _selectedSport = value == 'Svi sportovi' ? null : value;
                      });
                      _filterTrainers();
                      Navigator.of(context).pop();
                    },
                  ),
                  onTap: () {
                    setState(() {
                      _selectedSport = sport == 'Svi sportovi' ? null : sport;
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
              child: const Text('Zatvori'),
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
          'Pretraga trenera',
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
      ),
      drawer: _buildDrawer(),
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
                  hintText: 'Pretraži trenere',
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

          // Results list
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTrainers,
              child: const Text('Pokušaj ponovo'),
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
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'Nema dostupnih trenera'
                  : 'Nema rezultata za "${_searchController.text}"',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
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
                      '${trainer.yearsOfExperience} godina iskustva',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Rating stars
          Row(
            children: [
              Text(
                _ratingsMap[trainer.id]?.averageRating.toStringAsFixed(1) ?? '0.0',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.star,
                color: Colors.amber,
                size: 20,
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.orange.shade400,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.orange),
                ),
                SizedBox(height: 10),
                Text(
                  'Personal Trainer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Početna'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Pretraga trenera'),
            selected: true,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Moji treninzi'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to trainings screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profil'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to profile screen
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Postavke'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to settings screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Odjava'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement logout
            },
          ),
        ],
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
