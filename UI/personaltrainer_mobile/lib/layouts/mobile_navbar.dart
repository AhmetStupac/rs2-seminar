import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personaltrainer_mobile/models/user.dart';
import 'package:personaltrainer_mobile/providers/user_provider.dart';
import 'package:personaltrainer_mobile/screens/training_plan_screen.dart';
import 'package:personaltrainer_mobile/screens/nutrition_plan_screen.dart';
import 'package:personaltrainer_mobile/screens/personal_trainer_search_screen.dart';
import 'package:personaltrainer_mobile/screens/training_sessions_list_screen.dart';
import 'package:personaltrainer_mobile/screens/training_statistics_screen.dart';
import 'package:personaltrainer_mobile/screens/online_users_screen.dart';
import 'package:personaltrainer_mobile/screens/group_training_sessions_screen.dart';
import 'package:personaltrainer_mobile/screens/profile_screen.dart';
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
            child: FutureBuilder<User?>(
              future: UserProvider().getCurrentUser(),
              builder: (context, snapshot) {
                final user = snapshot.data;
                final imageUrl = user?.profileImage?.url;
                final displayName = user != null
                    ? '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim()
                    : 'Personal Trainer';
                final initials = _getInitials(user?.firstName, user?.lastName);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl)
                          : null,
                      child: imageUrl == null || imageUrl.isEmpty
                          ? Text(
                              initials,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      displayName.isNotEmpty ? displayName : 'Personal Trainer',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          _buildMenuItem(
            context,
            icon: Icons.search,
            title: 'Personal Trainer Search',
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
            title: 'Training Plans',
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
            title: 'Nutrition Plans',
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
            title: 'My Trainings',
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
            icon: Icons.group_work_outlined,
            title: 'Group Training Sessions',
            routeName: 'group_sessions',
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != 'group_sessions') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GroupTrainingSessionsScreen(),
                  ),
                );
              }
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.bar_chart,
            title: 'Training Statistics',
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
            title: 'Profile',
            routeName: 'profile',
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              }
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            routeName: 'logout',
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Odjava'),
                  content: const Text(
                    'Are you sure you want to logout?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Logout'),
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

  static String _getInitials(String? firstName, String? lastName) {
    final first = firstName?.trim().isNotEmpty == true ? firstName!.trim()[0] : '';
    final last = lastName?.trim().isNotEmpty == true ? lastName!.trim()[0] : '';
    if (first.isEmpty && last.isEmpty) return '?';
    return (first + last).toUpperCase();
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
