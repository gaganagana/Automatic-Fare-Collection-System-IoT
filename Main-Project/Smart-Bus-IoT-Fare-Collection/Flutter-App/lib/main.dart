import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'l10n/generated/app_localizations.dart';
import 'models/models.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/firebase_setup_needed_screen.dart';
import 'screens/login_screen.dart';
import 'screens/passenger_screen.dart';
import 'state/app_state.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Object? firebaseInitError;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    // Most common first-run issue: `flutterfire configure` hasn't been run
    // yet, so firebase_options.dart still has placeholder keys. Instead of
    // letting this crash the whole app with a cryptic red screen, show a
    // clear, actionable setup screen.
    firebaseInitError = e;
  }

  runApp(SmartBusApp(firebaseInitError: firebaseInitError));
}

class SmartBusApp extends StatelessWidget {
  final Object? firebaseInitError;
  const SmartBusApp({super.key, this.firebaseInitError});

  @override
  Widget build(BuildContext context) {
    if (firebaseInitError != null) {
      return MaterialApp(
        title: 'Smart Bus Control Room',
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        home: FirebaseSetupNeededScreen(error: firebaseInitError!),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, app, _) => MaterialApp(
          title: 'Smart Bus Control Room',
          debugShowCheckedModeBanner: false,
          theme: appTheme,
          // --- Localization (English + Kannada) -----------------------------
          locale: app.locale,
          supportedLocales: const [Locale('en'), Locale('kn')],
          localizationsDelegates: const [
            AppLocalizations.delegate,          // our own strings (l10n.yaml + .arb files)
            GlobalMaterialLocalizations.delegate, // built-in Material widget strings (date pickers, etc.)
            GlobalWidgetsLocalizations.delegate,  // text direction and base widget strings
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const _RootRouter(),
        ),
      ),
    );
  }
}

/// Chooses which screen to show:
///  - Firebase session still being restored -> splash
///  - not signed in -> LoginScreen
///  - signed in as admin -> AdminDashboardScreen
///  - signed in as passenger -> PassengerScreen (restricted to their own card)
class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    Widget child;
    String key;
    if (app.authLoading) {
      key = 'splash';
      child = const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: CircularProgressIndicator(color: AppColors.green)),
      );
    } else if (app.currentUser == null) {
      key = 'login';
      child = const LoginScreen();
    } else if (app.currentUser!.role == UserRole.admin) {
      key = 'admin';
      child = const AdminDashboardScreen();
    } else {
      key = 'passenger';
      child = const PassengerScreen();
    }

    // Smooth cross-fade instead of an abrupt cut whenever auth state
    // changes (splash -> login -> dashboard) — one of the small touches
    // that makes the app feel like a finished product rather than a demo.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (widget, animation) => FadeTransition(
        opacity: animation,
        child: widget,
      ),
      child: KeyedSubtree(key: ValueKey(key), child: child),
    );
  }
}
