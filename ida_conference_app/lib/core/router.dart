import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/home/home_screen.dart';
import '../features/schedule/schedule_screen.dart';
import '../features/speakers/speakers_list_screen.dart';
import '../features/updates/updates_screen.dart';
import '../core/models/speaker.dart';
import '../features/venue/venue_screen.dart';
import '../features/speakers/speaker_detail_screen.dart';
import '../shared/scaffold_with_navbar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/schedule',
                builder: (context, state) => const ScheduleScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/speakers',
                builder: (context, state) => const SpeakersListScreen(),
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (context, state) {
                      final speaker = state.extra as Speaker;
                      return SpeakerDetailScreen(speaker: speaker);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/updates',
                builder: (context, state) => const UpdatesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/venue',
                builder: (context, state) => const VenueScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
