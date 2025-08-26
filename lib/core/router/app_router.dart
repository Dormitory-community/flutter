import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
// import '../../features/auth/screens/signup_screen.dart';
import '../../features/home/screens/landing_screen.dart';
import '../../features/home/screens/main_scaffold.dart';
import '../../features/boards/screens/boards_screen.dart';
// import '../../features/boards/screens/board_detail_screen.dart';
// import '../../features/boards/screens/board_write_screen.dart';
import '../../features/groups/screens/groups_screen.dart';
import '../../features/groups/screens/group_detail_screen.dart';
import '../../features/groups/screens/group_write_screen.dart';
// import '../../features/account/screens/my_page_screen.dart';
// import '../../features/account/screens/posts_screen.dart';
// import '../../features/account/screens/comments_screen.dart';
// import '../../features/account/screens/bookmarks_screen.dart';
// import '../../features/account/screens/privacy_screen.dart';
// import '../../features/messages/screens/chat_rooms_screen.dart';
// import '../../features/messages/screens/messages_screen.dart';
// import '../../features/search/screens/search_screen.dart';
// import '../../features/notices/screens/notices_screen.dart';
// import '../../shared/screens/error_screen.dart';

class AppRoutes {
  static const String landing = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String boards = '/boards';
  static const String boardDetail = '/boards/:id';
  static const String boardWrite = '/write/:type';
  static const String groups = '/groups';
  static const String groupDetail = '/groups/:id';
  static const String groupWrite = '/groups/write';
  static const String myPage = '/my-page';
  static const String myPagePosts = '/my-page/posts';
  static const String myPageComments = '/my-page/comments';
  static const String myPageBookmarks = '/my-page/bookmarks';
  static const String myPagePrivacy = '/my-page/privacy';
  static const String myPageMessages = '/my-page/chat';
  static const String messageDetail = '/my-page/chat/:id';
  static const String search = '/search';
  static const String notices = '/notices';

  static String groupDetailPath(String id) => '/groups/$id';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    // debugLogDiagnostics: true,
    initialLocation: AppRoutes.landing,
    redirect: (context, state) {
      final isAuthenticated = authState.value != null;
      final isLoading = authState.isLoading;

      // 로딩 중에는 리다이렉트하지 않음
      if (isLoading) return null;

      // 로그인이 필요한 페이지들
      final protectedRoutes = [
        AppRoutes.boardWrite,
        AppRoutes.groupWrite,
        AppRoutes.myPage,
        AppRoutes.myPagePosts,
        AppRoutes.myPageComments,
        AppRoutes.myPageBookmarks,
        AppRoutes.myPagePrivacy,
        AppRoutes.myPageMessages,
      ];

      final currentPath = state.uri.path;
      final isProtectedRoute = protectedRoutes.any((route) {
        if (route.contains(':')) {
          final pattern = route.replaceAll(RegExp(r':[^/]+'), r'[^/]+');
          return RegExp('^$pattern\$').hasMatch(currentPath);
        }
        return currentPath.startsWith(route);
      });

      // 인증되지 않은 사용자가 보호된 페이지에 접근하려고 하면 로그인 페이지로
      if (!isAuthenticated && isProtectedRoute) {
        return AppRoutes.login;
      }

      // 이미 인증된 사용자가 로그인/회원가입 페이지에 접근하려고 하면 홈으로
      if (isAuthenticated && (currentPath == AppRoutes.login || currentPath == AppRoutes.signup)) {
        return AppRoutes.landing;
      }

      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.landing,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: LandingScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.boards,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BoardsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.groups,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: GroupsScreen(),
            ),
          ),
          // GoRoute(
          //   path: AppRoutes.myPage,
          //   pageBuilder: (context, state) => const NoTransitionPage(
          //     child: MyPageScreen(),
          //   ),
          // ),
          // GoRoute(
          //   path: AppRoutes.myPageMessages,
          //   pageBuilder: (context, state) => const NoTransitionPage(
          //     child: ChatRoomsScreen(),
          //   ),
          // ),
        ],
      ),

      // Full screen routes (without main scaffold)
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const LoginScreen(),
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
              ),
              child: child,
            );
          },
        ),
      ),
  //     GoRoute(
  //       path: AppRoutes.signup,
  //       pageBuilder: (context, state) => CustomTransitionPage(
  //         child: const SignupScreen(),
  //         transitionDuration: const Duration(milliseconds: 300),
  //         transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //           return SlideTransition(
  //             position: animation.drive(
  //               Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
  //             ),
  //             child: child,
  //           );
  //         },
  //       ),
  //     ),
  //     GoRoute(
  //       path: AppRoutes.boardDetail,
  //       pageBuilder: (context, state) {
  //         final id = state.pathParameters['id']!;
  //         return CustomTransitionPage(
  //           child: BoardDetailScreen(id: id),
  //           transitionDuration: const Duration(milliseconds: 300),
  //           transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //             return SlideTransition(
  //               position: animation.drive(
  //                 Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
  //               ),
  //               child: child,
  //             );
  //           },
  //         );
  //       },
  //     ),
  //     GoRoute(
  //       path: AppRoutes.boardWrite,
  //       pageBuilder: (context, state) {
  //         final type = state.pathParameters['type']!;
  //         return CustomTransitionPage(
  //           child: BoardWriteScreen(type: type),
  //           transitionDuration: const Duration(milliseconds: 300),
  //           transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //             return SlideTransition(
  //               position: animation.drive(
  //                 Tween(begin: const Offset(0.0, 1.0), end: Offset.zero),
  //               ),
  //               child: child,
  //             );
  //           },
  //         );
  //       },
  //     ),
      GoRoute(
        path: AppRoutes.groupDetail,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomTransitionPage(
            child: GroupDetailScreen(id: id),
            transitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
                ),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.groupWrite,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const GroupWriteScreen(),
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(begin: const Offset(0.0, 1.0), end: Offset.zero),
              ),
              child: child,
            );
          },
        ),
      ),
  //     GoRoute(
  //       path: AppRoutes.messageDetail,
  //       pageBuilder: (context, state) {
  //         final id = state.pathParameters['id']!;
  //         return CustomTransitionPage(
  //           child: MessagesScreen(chatId: id),
  //           transitionDuration: const Duration(milliseconds: 300),
  //           transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //             return SlideTransition(
  //               position: animation.drive(
  //                 Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
  //               ),
  //               child: child,
  //             );
  //           },
  //         );
  //       },
  //     ),
  //     GoRoute(
  //       path: AppRoutes.search,
  //       pageBuilder: (context, state) => CustomTransitionPage(
  //         child: const SearchScreen(),
  //         transitionDuration: const Duration(milliseconds: 300),
  //         transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //           return FadeTransition(
  //             opacity: animation,
  //             child: child,
  //           );
  //         },
  //       ),
  //     ),
  //     GoRoute(
  //       path: AppRoutes.notices,
  //       pageBuilder: (context, state) => CustomTransitionPage(
  //         child: const NoticesScreen(),
  //         transitionDuration: const Duration(milliseconds: 300),
  //         transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //           return SlideTransition(
  //             position: animation.drive(
  //               Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
  //             ),
  //             child: child,
  //           );
  //         },
  //       ),
  //     ),
  //     GoRoute(
  //       path: AppRoutes.myPagePosts,
  //       pageBuilder: (context, state) => CustomTransitionPage(
  //         child: const PostsScreen(),
  //         transitionDuration: const Duration(milliseconds: 300),
  //         transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //           return SlideTransition(
  //             position: animation.drive(
  //               Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
  //             ),
  //             child: child,
  //           );
  //         },
  //       ),
  //     ),
  //     GoRoute(
  //       path: AppRoutes.myPageComments,
  //       pageBuilder: (context, state) => CustomTransitionPage(
  //         child: const CommentsScreen(),
  //         transitionDuration: const Duration(milliseconds: 300),
  //         transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //           return SlideTransition(
  //             position: animation.drive(
  //               Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
  //             ),
  //             child: child,
  //           );
  //         },
  //       ),
  //     ),
  //     GoRoute(
  //       path: AppRoutes.myPageBookmarks,
  //       pageBuilder: (context, state) => CustomTransitionPage(
  //         child: const BookmarksScreen(),
  //         transitionDuration: const Duration(milliseconds: 300),
  //         transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //           return SlideTransition(
  //             position: animation.drive(
  //               Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
  //             ),
  //             child: child,
  //           );
  //         },
  //       ),
  //     ),
  //     GoRoute(
  //       path: AppRoutes.myPagePrivacy,
  //       pageBuilder: (context, state) => CustomTransitionPage(
  //         child: const PrivacyScreen(),
  //         transitionDuration: const Duration(milliseconds: 300),
  //         transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //           return SlideTransition(
  //             position: animation.drive(
  //               Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
  //             ),
  //             child: child,
  //           );
  //         },
  //       ),
  //     ),
    ],
  //   errorPageBuilder: (context, state) => const NoTransitionPage(
  //     child: ErrorScreen(),
  //   ),
  );
  });

class CustomTransitionPage<T> extends Page<T> {
  const CustomTransitionPage({
    required this.child,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
    this.transitionsBuilder = _defaultTransitionsBuilder,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;
  final Duration transitionDuration;
  final Duration reverseTransitionDuration;
  final RouteTransitionsBuilder transitionsBuilder;

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: reverseTransitionDuration,
      pageBuilder: (context, animation, _) => child,
      transitionsBuilder: transitionsBuilder,
    );
  }

  static Widget _defaultTransitionsBuilder(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return FadeTransition(opacity: animation, child: child);
  }
}