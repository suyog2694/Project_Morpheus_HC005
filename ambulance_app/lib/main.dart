// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'services/mission_controller.dart';
// import 'screens/waiting_screen.dart';

// void main() {
//   runApp(const AmbulanceApp());
// }

// class AmbulanceApp extends StatelessWidget {
//   const AmbulanceApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => MissionController(),
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'HC005 Ambulance',
//         theme: ThemeData(primarySwatch: Colors.red),
//         home: const WaitingScreen(),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/mission_controller.dart';
import 'screens/login_screen.dart';
import 'screens/waiting_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ← needed for SharedPreferences

  // Restore saved login before app renders
  final auth = AuthService();
  await auth.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider(create: (_) => MissionController()),
      ],
      child: const AmbulanceApp(),
    ),
  );
}

class AmbulanceApp extends StatelessWidget {
  const AmbulanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HC005 Ambulance',
      theme: ThemeData(
        colorSchemeSeed: Colors.red,
        useMaterial3: true,
    ),
    
      home: const _RootNavigator(),
    );
  }
}

/// Shows LoginScreen for new users, WaitingScreen for returning logged-in users.
class _RootNavigator extends StatelessWidget {
  const _RootNavigator();

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthService>().isLoggedIn;
    return isLoggedIn ? const WaitingScreen() : const LoginScreen();
  }
}