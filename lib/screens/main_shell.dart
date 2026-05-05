import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shell_provider.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import 'home/home_screen.dart';
import 'study/study_screen.dart';
import 'all_categories_screen.dart';
import 'profile/profile_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  static const List<Widget> _screens = [
    HomeScreen(),
    StudyScreen(),
    AllCategoriesScreen(),
    ProfileScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBarColor = AppTheme.palette(context).surface;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: navBarColor,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(shellIndexProvider);
    final p = AppTheme.palette(context);

    return Scaffold(
      backgroundColor: p.bg,
      body: IndexedStack(
        index: selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: p.surface,
          border: Border(top: BorderSide(color: p.border, width: 0.5)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  selected: selectedIndex == 0,
                  onTap: () {
                    if (selectedIndex != 0) {
                      final userId =
                          ref.read(currentUserIdProvider).asData?.value;
                      if (userId != null) {
                        ref.invalidate(currentUserProvider);
                        ref.invalidate(recentResultsProvider(userId));
                        ref.invalidate(weeklyResultsProvider(userId));
                      }
                    }
                    ref.read(shellIndexProvider.notifier).setIndex(0);
                  },
                ),
                _NavItem(
                  icon: Icons.menu_book_rounded,
                  label: 'Study',
                  selected: selectedIndex == 1,
                  onTap: () => ref.read(shellIndexProvider.notifier).setIndex(1),
                ),
                _NavItem(
                  icon: Icons.quiz_outlined,
                  label: 'Test',
                  selected: selectedIndex == 2,
                  onTap: () => ref.read(shellIndexProvider.notifier).setIndex(2),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  selected: selectedIndex == 3,
                  onTap: () => ref.read(shellIndexProvider.notifier).setIndex(3),
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
    final muted = AppTheme.palette(context).textMuted;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.accent.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? AppTheme.accent : muted,
              size: 24,
            ),
            Text(
              label,
              style: AppTheme.labelSmall.copyWith(
                color: selected ? AppTheme.accent : muted,
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
