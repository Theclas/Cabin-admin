import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/ads/ads_screen.dart';
import '../screens/ads/popup_ads_screen.dart';
import '../screens/ads/popup_ad_form_screen.dart';
import '../screens/ads/popup_ad_stats_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/places/places_screen.dart';
import '../screens/places/place_form_screen.dart';
import '../screens/places/pendientes_screen.dart';
import '../screens/users/users_screen.dart';
import '../screens/reviews/reviews_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/promotions/promotions_screen.dart';
import '../screens/analytics/analytics_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../widgets/layout/admin_layout.dart';

class AppRoutes {
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const places = '/places';
  static const placeNew = '/places/new';
  static const placeEdit = '/places/edit';
  static const pendientes = '/pendientes';
  static const users = '/users';
  static const reviews = '/reviews';
  static const reports = '/reports';
  static const promotions = '/promotions';
  static const analytics = '/analytics';
  static const settings = '/settings';
  static const profile = '/profile';
  static const ads = '/ads';
  static const popupAds = '/popup-ads';
  static const popupAdNew = '/popup-ads/new';
  static const popupAdEdit = '/popup-ads/edit';
  static const popupAdStats = '/popup-ads/stats';
}

GoRouter buildRouter(BuildContext context) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    redirect: (ctx, state) {
      final auth = ctx.read<AuthProvider>();
      final loggedIn = auth.status == AuthStatus.authenticated;
      final loggingIn = state.matchedLocation == AppRoutes.login;
      if (auth.status == AuthStatus.loading) return null;
      if (!loggedIn && !loggingIn) return AppRoutes.login;
      if (loggedIn && loggingIn) return AppRoutes.dashboard;
      return null;
    },
    refreshListenable: context.read<AuthProvider>(),
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (_, __, child) => AdminLayout(child: child),
        routes: [
          GoRoute(path: AppRoutes.dashboard, builder: (_, __) => const DashboardScreen()),
          GoRoute(path: AppRoutes.places, builder: (_, __) => const PlacesScreen()),
          GoRoute(path: AppRoutes.pendientes, builder: (_, __) => const PendientesScreen()),
          GoRoute(path: AppRoutes.placeNew, builder: (_, __) => const PlaceFormScreen()),
          GoRoute(
            path: '${AppRoutes.placeEdit}/:id',
            builder: (_, state) => PlaceFormScreen(placeId: state.pathParameters['id']),
          ),
          GoRoute(path: AppRoutes.users, builder: (_, __) => const UsersScreen()),
          GoRoute(path: AppRoutes.reviews, builder: (_, __) => const ReviewsScreen()),
          GoRoute(path: AppRoutes.reports, builder: (_, __) => const ReportsScreen()),
          GoRoute(path: AppRoutes.promotions, builder: (_, __) => const PromotionsScreen()),
          GoRoute(path: AppRoutes.analytics, builder: (_, __) => const AnalyticsScreen()),
          GoRoute(path: AppRoutes.settings, builder: (_, __) => const SettingsScreen()),
          GoRoute(path: AppRoutes.profile, builder: (_, __) => const ProfileScreen()),
          GoRoute(path: AppRoutes.ads, builder: (_, __) => const AdsScreen()),
          GoRoute(path: AppRoutes.popupAds, builder: (_, __) => const PopupAdsScreen()),
          GoRoute(path: AppRoutes.popupAdNew, builder: (_, __) => const PopupAdFormScreen()),
          GoRoute(
            path: '${AppRoutes.popupAdEdit}/:id',
            builder: (_, state) =>
                PopupAdFormScreen(popupId: state.pathParameters['id']),
          ),
          GoRoute(
            path: '${AppRoutes.popupAdStats}/:id',
            builder: (_, state) =>
                PopupAdStatsScreen(popupId: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
}
