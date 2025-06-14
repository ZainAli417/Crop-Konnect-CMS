// web_routes.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Constant/Forget Password.dart';

import 'Screens/Job_Seeker/Login.dart';
import 'Screens/Job_Seeker/Sign Up.dart';
import 'Screens/Job_Seeker/dashboard.dart';

import 'Constant/Splash.dart';

class AuthNotifier extends ChangeNotifier {
  late final StreamSubscription<User?> _authSubscription;

  AuthNotifier() {
    // Listen to auth state changes and notify listeners.
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}

CustomTransitionPage<T> _buildPageWithAnimation<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 370),
    reverseTransitionDuration: const Duration(milliseconds: 370),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fadeAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      );
      final scaleAnimation = Tween<double>(begin: 0.99, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      );
      return FadeTransition(
        opacity: fadeAnimation,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: child,
        ),
      );
    },
  );
}

// Create a single, top-level instance of the AuthNotifier.
final _authNotifier = AuthNotifier();

final GoRouter router = GoRouter(
  initialLocation: '/',
  // Use the AuthNotifier instance for the refreshListenable.
  refreshListenable: _authNotifier,
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isOnSplash   = state.fullPath == '/';

    // split “auth‐pages” into two groups:
    final isOnJSAuth = [
      '/login',
      '/register',
      '/recover-password',
    ].contains(state.fullPath);

    final isOnRecAuth = [
      '/recruiter-login',
      '/recruiter-signup',
    ].contains(state.fullPath);

    // 1) If not logged in and not on any auth page (JS or Rec) and not on splash → force Job‐Seeker login
    if (!isLoggedIn && !isOnJSAuth && !isOnRecAuth && !isOnSplash) {
      return '/';
    }

    // 2) If signed in and tries to hit a Job‐Seeker auth page → send to Job‐Seeker dashboard
    if (isLoggedIn && isOnJSAuth) {
      return '/dashboard';
    }



    // 4) If already signed in and landing on Splash → send to Job‐Seeker dashboard by default
    if (isLoggedIn && isOnSplash) {
      return '/dashboard';
    }

    // Otherwise, allow navigation
    return null;
  },  routes: [
  GoRoute(
    path: '/',
    pageBuilder: (context, state) =>
        _buildPageWithAnimation(child: const SplashScreen(), context: context, state: state),
  ),
  GoRoute(
    path: '/recover-password',
    pageBuilder: (context, state) => _buildPageWithAnimation(
      child: const ForgotPasswordScreen(),
      context: context,
      state: state,
    ),
  ),







  GoRoute(
    path: '/login',
    pageBuilder: (context, state) => _buildPageWithAnimation(
      child: const farmer_login(),
      context: context,
      state: state,
    ),
  ),
  GoRoute(
    path: '/register',
    pageBuilder: (context, state) => _buildPageWithAnimation(
      child: const farmer_signup(),
      context: context,
      state: state,
    ),
  ),
  GoRoute(
    path: '/dashboard',
    pageBuilder: (context, state) => _buildPageWithAnimation(
      child:  farmer_dashboard(),
      context: context,
      state: state,
    ),
  ),









],
);