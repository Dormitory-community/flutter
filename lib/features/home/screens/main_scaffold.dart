import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/notification_banner.dart';

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCurrentIndex();
  }

  void _updateCurrentIndex() {
    final location = GoRouterState.of(context).uri.path;
    setState(() {
      _currentIndex = _getIndexFromPath(location);
    });
  }

  int _getIndexFromPath(String path) {
    if (path == AppRoutes.landing || path == '/') return 0;
    if (path == AppRoutes.groups || path.startsWith('/groups')) return 1;
    if (path == AppRoutes.boards || path.startsWith('/boards')) return 2;
    if (path == AppRoutes.myPageMessages || path.startsWith('/my-page/chat')) return 3;
    if (path == AppRoutes.myPage || path.startsWith('/my-page')) return 4;
    return 0;
  }

  bool _shouldShowHeader() {
    final location = GoRouterState.of(context).uri.path;
    final hiddenRoutes = [AppRoutes.login, AppRoutes.myPageMessages];
    return !hiddenRoutes.any((route) => location.startsWith(route));
  }

  bool _shouldShowNotificationBanner() {
    final location = GoRouterState.of(context).uri.path;
    return location == AppRoutes.landing || location == '/';
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          // Safe Area와 Header
          if (_shouldShowHeader()) ...[
            Container(
              color: Theme.of(context).colorScheme.surface,
              child: SafeArea(
                bottom: false,
                child: const AppHeader(),
              ),
            ),
            if (_shouldShowNotificationBanner()) const NotificationBanner(),
          ],

          // Main Content
          Expanded(
            child: widget.child,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => _onTabTapped(index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.groups_outlined),
                activeIcon: Icon(Icons.groups),
                label: '그룹 모집',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: '게시판',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: '채팅',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: '마이페이지',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        context.go(AppRoutes.landing);
        break;
      case 1:
        context.go(AppRoutes.groups);
        break;
      case 2:
        context.go(AppRoutes.boards);
        break;
      case 3:
        context.go(AppRoutes.myPageMessages);
        break;
      case 4:
        context.go(AppRoutes.myPage);
        break;
    }
  }
}