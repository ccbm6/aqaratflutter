import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'favorites/favorites_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'property/add_property_screen.dart';
import 'auth/login_screen.dart';

/// الحاوية الرئيسية التي تضم شريط التنقل السفلي بين أقسام التطبيق
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    FavoritesScreen(),
    SizedBox(), // placeholder لزر الإضافة الوسطي
    ProfileScreen(),
  ];

  void _onAddTap() {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPropertyScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddTap,
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        child: SizedBox(
          height: 58,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_rounded, 'الرئيسية', 0),
              _navItem(Icons.favorite_rounded, 'المفضلة', 1),
              const SizedBox(width: 40), // مساحة لزر الإضافة العائم
              _navItem(Icons.person_rounded, 'حسابي', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int i) {
    final selected = _index == i;
    return InkWell(
      onTap: () => setState(() => _index = i),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: selected ? AppColors.primary : Colors.grey, size: 24),
          Text(label,
              style: TextStyle(
                  fontSize: 10.5,
                  color: selected ? AppColors.primary : Colors.grey,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
