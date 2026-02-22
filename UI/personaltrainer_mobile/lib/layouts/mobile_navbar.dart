import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personaltrainer_mobile/screens/training_plan_screen.dart';
import 'package:personaltrainer_mobile/screens/nutrition_plan_screen.dart';
import 'package:personaltrainer_mobile/screens/personal_trainer_search_screen.dart';
import 'package:personaltrainer_mobile/screens/training_sessions_list_screen.dart';
import 'package:personaltrainer_mobile/screens/training_statistics_screen.dart';
import 'package:personaltrainer_mobile/screens/online_users_screen.dart';
import 'package:personaltrainer_mobile/providers/auth_provider.dart';
import 'package:personaltrainer_mobile/providers/signalr_provider.dart';
import 'package:personaltrainer_mobile/providers/messages_provider.dart';
import 'package:personaltrainer_mobile/main.dart';

class MobileNavBar extends StatelessWidget {
  final String currentRoute;

  const MobileNavBar({super.key, this.currentRoute = ''});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.orange.shade400),
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PersonalTrainerSearchScreen(),
                  ),
                );
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PersonalTrainerSearchScreen(),
                  ),
                );
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
            icon: Icons.restaurant_menu,
            title: 'Planovi ishrane',
            routeName: 'nutrition_plan',
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != 'nutrition_plan') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NutritionPlanScreen(),
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
              if (currentRoute != 'trainings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TrainingSessionsListScreen(),
                  ),
                );
              }
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.bar_chart,
            title: 'Statistics',
            routeName: 'statistics',
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != 'statistics') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TrainingStatisticsScreen(),
                  ),
                );
              }
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.chat,
            title: 'Chat',
            routeName: 'chat',
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != 'chat') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OnlineUsersScreen(),
                  ),
                );
              }
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
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Odjava'),
                  content: const Text(
                    'Da li ste sigurni da želite da se odjavite?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text('Odustani'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Odjavi se'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                // Disconnect from SignalR before logout
                final signalRProvider = Provider.of<SignalRProvider>(
                  context,
                  listen: false,
                );
                final messagesProvider = Provider.of<MessagesProvider>(
                  context,
                  listen: false,
                );
                await signalRProvider.disconnect();
                await messagesProvider.disconnect();

                AuthProvider.logout();
                Navigator.of(context).pop(); // Close drawer
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
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
