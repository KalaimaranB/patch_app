import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/supabase_service.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/main_shell.dart';
import '../screens/dashboard_screen.dart';
import '../screens/devices_screen.dart';
import '../screens/dosage_history_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/help_screen.dart';
import '../screens/account_deleted_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  redirect: (context, state) {
    final isLoggedIn = SupabaseService.currentUser != null;
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/account-deleted';

    if (!isLoggedIn && !isAuthRoute) return '/login';
    if (isLoggedIn && (state.matchedLocation == '/login' || state.matchedLocation == '/register')) {
      return '/dashboard';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/account-deleted',
      builder: (context, state) => const AccountDeletedScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/devices',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DevicesScreen(),
          ),
        ),
        GoRoute(
          path: '/dosage-history',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DosageHistoryScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
        GoRoute(
          path: '/help',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HelpScreen(),
          ),
        ),
      ],
    ),
  ],
);
