import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HC005App());
}

class HC005App extends StatelessWidget {
  const HC005App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HC005 Emergency',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const _PermissionGate(),
    );
  }
}

/// Requests location & mic permissions before showing HomeScreen.
class _PermissionGate extends StatefulWidget {
  const _PermissionGate();
  @override
  State<_PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<_PermissionGate> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [Permission.location, Permission.microphone].request();

    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        backgroundColor: Color(0xFFFBF0F1),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFFE8334A)),
              SizedBox(height: 16),
              Text(
                'Setting up permissions…',
                style: TextStyle(
                  color: Color(0xFF8A909E),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return const HomeScreen();
  }
}
