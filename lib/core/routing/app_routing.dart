import 'package:fitual/presentation/screens/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/auth_screen.dart';
import '../../presentation/screens/detail_screen.dart';
import '../../presentation/screens/history_screen.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter/material.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/auth',
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'detail/:workoutId',
            builder: (context, state) {
              final workoutId = state.pathParameters['workoutId']!;
              return DetailScreen(workoutId: workoutId);
            },
          ),
          GoRoute(
            path: 'history',
            builder: (context, state) => const HistoryScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) async {
      final auth = ref.read(firebaseAuthProvider);
      final user = auth.currentUser;
      if (user == null && state.matchedLocation != '/auth') {
        return '/auth';
      }
      if (user != null && state.matchedLocation == '/auth') {
        return '/home';
      }
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Route not found: ${state.uri}',
          style: const TextStyle(fontSize: 18, color: Colors.red),
        ),
      ),
    ),
  );
});