import 'package:flutter/material.dart';
import 'package:personaltrainer_mobile/screens/admin_ban_screen.dart';
import 'package:personaltrainer_mobile/screens/exercise_list.dart';
import 'package:personaltrainer_mobile/screens/training_details_screen.dart';
import 'package:personaltrainer_mobile/screens/training_plan_screen.dart';
import 'package:personaltrainer_mobile/screens/user_list_screen.dart';
import 'package:personaltrainer_mobile/screens/profile_screen.dart';
import 'package:personaltrainer_mobile/screens/messaging_screen.dart';
import 'package:personaltrainer_mobile/screens/nutrition_plan_screen.dart';
import 'package:personaltrainer_mobile/providers/auth_provider.dart';

class NavBar extends StatefulWidget {
  final String title;
  final Widget child;

  const NavBar(this.title, this.child, {super.key});

  @override
  State<NavBar> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<NavBar> {
  String selectedMenu = "Plan treninga";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        // Horizontalni layout
        children: [
          // FIXED SIDEBAR - Uvek vidljiv
          _buildSidebar(),

          // MAIN CONTENT - Tvoj child widget
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 200, // Fiksna širina
      color: Color(0xFFF5F0E8), // Bež boja kao na slici
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Postavke',
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
            label: 'Profil',
            routeName: 'Profil',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
              setState(() => selectedMenu = 'Profil');
            },
          ),

          _buildMenuItem(
            icon: Icons.calendar_today,
            label: 'Kalendar',
            routeName: 'Kalendar',
            onTap: () {
              // TODO:  Navigiraj na kalendar screen
              setState(() => selectedMenu = 'Kalendar');
            },
          ),

          _buildMenuItem(
            icon: Icons.fitness_center,
            label: 'Exercise plan',
            routeName: 'Exercise plan',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => TrainingPlanScreen()),
              );
              setState(() => selectedMenu = 'Exercise plan');
            },
          ),

          _buildMenuItem(
            icon: Icons.bar_chart,
            label: 'Trening plan',
            routeName: 'Trening plan',
            onTap: () {
              // TODO: Navigiraj na statistika screen
              setState(() => selectedMenu = 'Trening plan');
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TrainingDetailsScreen(),
                ),
              );
            },
          ),

          _buildMenuItem(
            icon: Icons.location_on,
            label: 'Teretane',
            routeName: 'Teretane',
            onTap: () {
              // TODO: Navigiraj na teretane screen
              setState(() => selectedMenu = 'Teretane');
            },
          ),

          _buildMenuItem(
            icon: Icons.restaurant_menu,
            label: 'Plan ishrane',
            routeName: 'Plan ishrane',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NutritionPlanScreen(),
                ),
              );
              setState(() => selectedMenu = 'Plan ishrane');
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
              setState(() => selectedMenu = 'Messaging');
            },
          ),

          _buildMenuItem(
            icon: Icons.admin_panel_settings,
            label: 'Admin Panel',
            routeName: 'Admin Panel',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => UsersListScreen()),
              );
              setState(() => selectedMenu = 'Admin Panel');
            },
          ),

          Spacer(), // Gurni donji deo na dno
          // Logout dugme
          _buildMenuItem(
            icon: Icons.logout,
            label: 'Logout',
            routeName: 'Logout',
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Logout'),
                  content: Text('Da li ste sigurni da želite da se odjavite?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Odustani'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Odjavi se'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                AuthProvider.logout();
                // Vrati korisnika na login screen
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
          ),

          // Back dugme
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
    bool isActive = selectedMenu == routeName;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.grey[300]
            : Colors.transparent, // Highlight ako je aktivan
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
