import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'config/firebase_options_web.dart';
import 'providers/auth_provider.dart';
import 'providers/places_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/navigation_provider.dart';
import 'theme/app_theme.dart';
import 'config/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: FirebaseOptionsWeb.web);
  runApp(const CabinAdminApp());
}

class CabinAdminApp extends StatelessWidget {
  const CabinAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PlacesProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: Builder(
        builder: (context) {
          final router = buildRouter(context);
          return MaterialApp.router(
            title: 'Cabin Admin',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
