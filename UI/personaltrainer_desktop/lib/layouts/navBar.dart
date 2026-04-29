import 'package:flutter/material.dart';
import 'package:personaltrainer_desktop/screens/exercise_details_screen.dart';
import 'package:personaltrainer_desktop/screens/gym_list_screen.dart';
import 'package:personaltrainer_desktop/screens/training_plan_screen.dart';
import 'package:personaltrainer_desktop/screens/training_session_calendar_screen.dart';
import 'package:personaltrainer_desktop/screens/user_list_screen.dart';
import 'package:personaltrainer_desktop/screens/profile_screen.dart';
import 'package:personaltrainer_desktop/screens/messaging_screen.dart';
import 'package:personaltrainer_desktop/screens/nutrition_plan_screen.dart';
import 'package:personaltrainer_desktop/providers/auth_provider.dart';

class NavBar extends StatefulWidget {
  final String title;
  final Widget child;

  const NavBar(this.title, this.child, {super.key});

  @override
  State<NavBar> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),

          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 200,
      color: Color(0xFFF5F0E8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          // Menu Items
          _buildMenuItem(
            icon: Icons.person,
            label: 'Profile',
            routeName: 'Profile',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),

          _buildMenuItem(
            icon: Icons.calendar_today,
            label: 'Calendar',
            routeName: 'Calendar',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TrainingSessionCalendarScreen(),
                ),
              );
            },
          ),

          _buildMenuItem(
            icon: Icons.fitness_center,
            label: 'Exercise',
            routeName: 'Exercise',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ExerciseDetailsScreen(),
                ),
              );
            },
          ),

          _buildMenuItem(
            icon: Icons.bar_chart,
            label: 'Exercise plan',
            routeName: 'Exercise plan',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => TrainingPlanScreen()),
              );
            },
          ),

          if (AuthProvider.isSuperAdmin)
            _buildMenuItem(
              icon: Icons.location_on,
              label: 'Gym List',
              routeName: 'Gym List',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => GymListScreen()),
                );
              },
            ),

          _buildMenuItem(
            icon: Icons.restaurant_menu,
            label: 'Nutrition Plan',
            routeName: 'Nutrition Plan',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => NutritionPlanScreen()),
              );
            },
          ),

          _buildMenuItem(
            icon: Icons.message,
            label: 'Messaging',
            routeName: 'Messaging',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MessagingScreen(),
                ),
              );
            },
          ),

          if (AuthProvider.isSuperAdmin)
            _buildMenuItem(
              icon: Icons.admin_panel_settings,
              label: 'Admin Panel',
              routeName: 'Admin Panel',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => UsersListScreen()),
                );
              },
            ),

          Spacer(),
          _buildMenuItem(
            icon: Icons.logout,
            label: 'Logout',
            routeName: 'Logout',
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Logout'),
                  content: Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Log Out'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                AuthProvider.logout();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
          ),

          _buildMenuItem(
            icon: Icons.arrow_back,
            label: 'Back',
            routeName: 'Back',
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required String routeName,
    required VoidCallback onTap,
  }) {
    bool isActive = widget.title == routeName;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.grey[300] : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, size: 20, color: Colors.black87),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        dense: true,
        onTap: onTap,
      ),
    );
  }
}
