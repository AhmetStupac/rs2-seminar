import 'package:flutter/material.dart';
import 'package:personaltrainer_mobile/screens/training_plan_screen.dart';
import 'package:personaltrainer_mobile/providers/auth_provider.dart';

class MobileNavBar extends StatelessWidget {
  final String currentRoute;

  const MobileNavBar({
    super.key,
    this.currentRoute = '',
  });

  @override
  Widget build(BuildContext context) {
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
          _buildMenuItem(
            context,
            icon: Icons.home,
            title: 'Početna',
            routeName: 'home',
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != 'home') {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.search,
            title: 'Pretraga trenera',
            routeName: 'search',
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != 'search') {
                Navigator.pushReplacementNamed(context, '/search');
              }
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.fitness_center,
            title: 'Planovi treninga',
            routeName: 'training_plan',
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != 'training_plan') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TrainingPlanScreen(),
                  ),
                );
              }
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.calendar_today,
            title: 'Moji treninzi',
            routeName: 'trainings',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Moji treninzi - uskoro dostupno')),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.person,
            title: 'Profil',
            routeName: 'profile',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profil - uskoro dostupno')),
              );
            },
          ),
          const Divider(),
          _buildMenuItem(
            context,
            icon: Icons.settings,
            title: 'Postavke',
            routeName: 'settings',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Postavke - uskoro dostupno')),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.logout,
            title: 'Odjava',
            routeName: 'logout',
            onTap: () async {
              Navigator.pop(context);
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Odjava'),
                  content: const Text('Da li ste sigurni da želite da se odjavite?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Odustani'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Odjavi se'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                AuthProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String routeName,
    required VoidCallback onTap,
  }) {
    final isSelected = currentRoute == routeName;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.orange.shade700 : Colors.black87,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.orange.shade700 : Colors.black87,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.orange.shade50,
      onTap: onTap,
    );
  }
}
