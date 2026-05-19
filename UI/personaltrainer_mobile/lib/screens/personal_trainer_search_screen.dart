import 'dart:async';

import 'package:flutter/material.dart';
import 'package:personaltrainer_mobile/models/personal_trainer.dart';
import 'package:personaltrainer_mobile/providers/auth_provider.dart';
import 'package:personaltrainer_mobile/providers/personal_trainer_provider.dart';
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
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _personalTrainerProvider = PersonalTrainerProvider();
  List<PersonalTrainer> _trainers = [];
  List<PersonalTrainer> _filteredTrainers = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedSport;
  String? _selectedGender;
  double? _selectedMinRating;
  double? _selectedMinPrice;
  double? _selectedMaxPrice;
  PersonalTrainer? _recommendedTrainer;
  bool _isLoadingRecommendation = false;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _loadTrainers();
    _loadRecommendation();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        _loadTrainers();
      }
    });
  }

  Map<String, dynamic> _buildSearchFilter() {
    final filter = <String, dynamic>{};
    final query = _searchController.text.trim();

    if (query.isNotEmpty) {
      filter['Name'] = query;
    }
    if (_selectedSport != null && _selectedSport!.isNotEmpty) {
      filter['Sport'] = _selectedSport;
    }
    if (_selectedGender != null && _selectedGender!.isNotEmpty) {
      filter['Gender'] = _selectedGender;
    }
    if (_selectedMinRating != null) {
      filter['MinRating'] = _selectedMinRating;
    }
    if (_selectedMinPrice != null) {
      filter['MinPrice'] = _selectedMinPrice;
    }
    if (_selectedMaxPrice != null) {
      filter['MaxPrice'] = _selectedMaxPrice;
    }

    return filter;
  }

  Future<void> _loadTrainers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _personalTrainerProvider.get(
        filter: _buildSearchFilter(),
      );
      setState(() {
        _trainers = result.result;
        _filteredTrainers = result.result;
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
      setState(() {
        _isLoadingRecommendation = false;
      });
    }
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
    final selectedSport = _selectedSport ?? 'All sports';
    final selectedGender = _selectedGender ?? 'Any';
    final selectedMinRating = _selectedMinRating;
    _minPriceController.text = _selectedMinPrice?.toString() ?? '';
    _maxPriceController.text = _selectedMaxPrice?.toString() ?? '';
    final sports = _getUniqueSports();
    const genders = ['Any', 'Male', 'Female'];
    const ratingOptions = <double?>[null, 3.0, 4.0, 4.5];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String tempSport = selectedSport;
        String tempGender = selectedGender;
        double? tempMinRating = selectedMinRating;

        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Filters'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sport',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: tempSport,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: sports
                        .map(
                          (sport) => DropdownMenuItem(
                            value: sport,
                            child: Text(sport),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() => tempSport = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Gender',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: tempGender,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: genders
                        .map(
                          (gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() => tempGender = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Minimum rating',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<double?>(
                    value: tempMinRating,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: ratingOptions
                        .map(
                          (rating) => DropdownMenuItem<double?>(
                            value: rating,
                            child: Text(
                              rating == null
                                  ? 'Any'
                                  : rating.toStringAsFixed(1),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() => tempMinRating = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Price range',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _minPriceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Min price',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _maxPriceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Max price',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedSport = null;
                    _selectedGender = null;
                    _selectedMinRating = null;
                    _selectedMinPrice = null;
                    _selectedMaxPrice = null;
                  });
                  Navigator.of(context).pop();
                  _loadTrainers();
                },
                child: const Text('Reset'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final minPrice = double.tryParse(
                    _minPriceController.text.trim(),
                  );
                  final maxPrice = double.tryParse(
                    _maxPriceController.text.trim(),
                  );

                  setState(() {
                    _selectedSport = tempSport == 'All sports'
                        ? null
                        : tempSport;
                    _selectedGender = tempGender == 'Any' ? null : tempGender;
                    _selectedMinRating = tempMinRating;
                    _selectedMinPrice = minPrice;
                    _selectedMaxPrice = maxPrice;
                  });

                  Navigator.of(context).pop();
                  _loadTrainers();
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        );
      },
    );
  }

  bool get _hasActiveFilters =>
      _selectedSport != null ||
      _selectedGender != null ||
      _selectedMinRating != null ||
      _selectedMinPrice != null ||
      _selectedMaxPrice != null;

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
                              if (_hasActiveFilters)
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
          if (_hasActiveFilters)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_selectedSport != null)
                    Chip(
                      label: Text(_selectedSport!),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _selectedSport = null;
                        });
                        _loadTrainers();
                      },
                      backgroundColor: Colors.orange.shade100,
                    ),
                  if (_selectedGender != null)
                    Chip(
                      label: Text(_selectedGender!),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _selectedGender = null;
                        });
                        _loadTrainers();
                      },
                      backgroundColor: Colors.orange.shade100,
                    ),
                  if (_selectedMinRating != null)
                    Chip(
                      label: Text(
                        'Rating >= ${_selectedMinRating!.toStringAsFixed(1)}',
                      ),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _selectedMinRating = null;
                        });
                        _loadTrainers();
                      },
                      backgroundColor: Colors.orange.shade100,
                    ),
                  if (_selectedMinPrice != null || _selectedMaxPrice != null)
                    Chip(
                      label: Text(
                        'Price ${_selectedMinPrice?.toStringAsFixed(0) ?? '0'}-${_selectedMaxPrice?.toStringAsFixed(0) ?? '∞'}',
                      ),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _selectedMinPrice = null;
                          _selectedMaxPrice = null;
                          _minPriceController.clear();
                          _maxPriceController.clear();
                        });
                        _loadTrainers();
                      },
                      backgroundColor: Colors.orange.shade100,
                    ),
                ],
              ),
            ),
          if (_hasActiveFilters) const SizedBox(height: 12),

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
                    if (trainer.whyRecommended != null &&
                        trainer.whyRecommended!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              color: Colors.white70,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                trainer.whyRecommended!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
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

            // Rating
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text(
                      (trainer.averageRating ?? 0.0).toStringAsFixed(1),
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
                Text(
                  '${trainer.totalRatings ?? 0}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
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
