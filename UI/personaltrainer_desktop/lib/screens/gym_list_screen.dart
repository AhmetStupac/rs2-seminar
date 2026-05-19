import 'package:flutter/material.dart';
import 'package:personaltrainer_desktop/models/gym.dart';
import 'package:personaltrainer_desktop/providers/auth_provider.dart';
import 'package:personaltrainer_desktop/providers/gym_provider.dart';
import 'package:personaltrainer_desktop/screens/gym_screen.dart';
import 'package:personaltrainer_desktop/layouts/navBar.dart';
import 'package:personaltrainer_desktop/widgets/network_image_loader.dart';

class GymListScreen extends StatefulWidget {
  const GymListScreen({super.key});

  @override
  State<GymListScreen> createState() => _GymListScreenState();
}

class _GymListScreenState extends State<GymListScreen> {
  final _gymProvider = GymProvider();
  final _searchController = TextEditingController();
  List<Gym> _gyms = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadGyms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGyms() async {
    setState(() => _isLoading = true);

    try {
      final result = await _gymProvider.get();
      setState(() {
        _gyms = result.result ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading gyms.')));
      }
    }
  }

  List<Gym> get _filteredGyms {
    if (_searchQuery.isEmpty) {
      return _gyms;
    }

    final query = _searchQuery.toLowerCase();
    return _gyms.where((gym) {
      final name = (gym.name ?? '').toLowerCase();
      final city = (gym.cityName ?? '').toLowerCase();
      final country = (gym.countryName ?? '').toLowerCase();
      final address = (gym.address ?? '').toLowerCase();

      return name.contains(query) ||
          city.contains(query) ||
          country.contains(query) ||
          address.contains(query);
    }).toList();
  }

  Future<void> _deleteGym(Gym gym) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
        title: const Text(
          'Confirm Deletion',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this gym?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.fitness_center, color: Colors.purple[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      gym.name ?? 'N/A',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This action cannot be undone!',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            icon: const Icon(Icons.delete_forever),
            label: const Text('Delete Gym'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _gymProvider.delete(gym.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gym deleted successfully')),
          );
          _loadGyms();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting gym.')));
        }
      }
    }
  }

  Future<void> _navigateToGymScreen([Gym? gym]) async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => GymScreen(gym: gym)));

    if (result == true) {
      _loadGyms();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthProvider.isSuperAdmin) {
      return NavBar(
        'Gyms',
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'Access Denied',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'This section is only available to SuperAdmins.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return NavBar(
      'Gyms',
      Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Search Gyms',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText:
                              'Search by name, city, country, or address...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _navigateToGymScreen(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Gym'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadGyms,
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadGyms,
                    child: _filteredGyms.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.fitness_center,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'No search results'
                                      : 'No gyms found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (_searchQuery.isEmpty) ...[
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () => _navigateToGymScreen(),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add First Gym'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredGyms.length,
                            itemBuilder: (context, index) {
                              final gym = _filteredGyms[index];
                              return _buildGymCard(gym);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGymCard(Gym gym) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToGymScreen(gym),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Gym icon or image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: gym.imageUrl != null && gym.imageUrl!.isNotEmpty
                      ? NetworkImageLoader(
                          imageUrl: gym.imageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorWidget: Icon(
                            Icons.fitness_center,
                            size: 32,
                            color: Colors.purple[700],
                          ),
                        )
                      : Icon(
                          Icons.fitness_center,
                          size: 32,
                          color: Colors.purple[700],
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // Gym details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gym.name ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (gym.address != null && gym.address!.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              gym.address!,
                              style: TextStyle(color: Colors.grey[600]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    if (gym.cityName != null || gym.countryName != null)
                      Row(
                        children: [
                          Icon(Icons.public, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            [gym.cityName, gym.countryName]
                                .where((e) => e != null && e.isNotEmpty)
                                .join(', '),
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    if (gym.workTime != null && gym.workTime!.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            gym.workTime!,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _navigateToGymScreen(gym),
                    tooltip: 'Edit',
                    color: Colors.blue[700],
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteGym(gym),
                    tooltip: 'Delete',
                    color: Colors.red[700],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
