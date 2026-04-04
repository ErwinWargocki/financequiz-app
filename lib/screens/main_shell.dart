import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'all_categories_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    AllCategoriesScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.border, width: 0.5)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  selected: _selectedIndex == 0,
                  onTap: () => setState(() => _selectedIndex = 0),
                ),
                _NavItem(
                  icon: Icons.explore_rounded,
                  label: 'Explore',
                  selected: _selectedIndex == 1,
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
                _NavItem(
                  icon: Icons.quiz_outlined,
                  label: 'Test',
                  selected: _selectedIndex == 2,
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  selected: _selectedIndex == 3,
                  onTap: () => setState(() => _selectedIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.accent.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? AppTheme.accent : AppTheme.textMuted,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTheme.labelSmall.copyWith(
                color: selected ? AppTheme.accent : AppTheme.textMuted,
                letterSpacing: 0.5,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
