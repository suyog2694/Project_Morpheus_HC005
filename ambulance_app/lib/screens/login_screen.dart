import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'waiting_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _ambulanceCtrl = TextEditingController();
  final _phoneCtrl     = TextEditingController();
  final _formKey       = GlobalKey<FormState>();
  bool    _loading  = false;
  String? _errorMsg;

  static const _red    = Color(0xFFC0392B);
  static const _bgBody = Color(0xFFFDF5F5);

  @override
  void dispose() {
    _ambulanceCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _errorMsg = null; });

    final ok = await context.read<AuthService>().login(
      ambulanceId: _ambulanceCtrl.text,
      phone:       _phoneCtrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WaitingScreen()),
      );
    } else {
      setState(() => _errorMsg = 'Invalid Ambulance ID or phone number.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBody,
      body: Column(
        children: [
          // ── Red hero header ──────────────────────────────────
          _AuthHero(),

          // ── Form ─────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Sign in to your unit account',
                      style: TextStyle(fontSize: 13, color: Color(0xFFAAAAAA), fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 24),

                    _InputField(
                      controller: _ambulanceCtrl,
                      label:      'AMBULANCE ID',
                      hint:       'e.g. KA-01-HC-005',
                      icon:       Icons.directions_car_rounded,
                      validator:  (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    _InputField(
                      controller:   _phoneCtrl,
                      label:        'PHONE NUMBER',
                      hint:         '+91 00000 00000',
                      icon:         Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                      validator:    (v) => (v == null || v.trim().length < 7) ? 'Enter valid phone' : null,
                    ),

                    if (_errorMsg != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _errorMsg!,
                        style: const TextStyle(color: _red, fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ],

                    const SizedBox(height: 24),
                    _PrimaryButton(label: 'SIGN IN', loading: _loading, onTap: _signIn),
                    const SizedBox(height: 18),

                    // OR divider
                    Row(children: [
                      Expanded(child: Divider(color: _red.withOpacity(0.12))),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('OR', style: TextStyle(fontSize: 11, color: Color(0xFFCCCCCC), fontWeight: FontWeight.w700)),
                      ),
                      Expanded(child: Divider(color: _red.withOpacity(0.12))),
                    ]),
                    const SizedBox(height: 14),

                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        ),
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontFamily: 'sans-serif',
                              fontSize:   13,
                              fontWeight: FontWeight.w700,
                              color:      Color(0xFFAAAAAA),
                            ),
                            children: [
                              TextSpan(text: 'New unit?   '),
                              TextSpan(
                                text:  'Register here',
                                style: TextStyle(color: _red, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Icon(Icons.local_hospital, size: 80, color: Colors.red),
        SizedBox(height: 10),
        Text(
          "Ambulance App",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _InputField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF444444),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onTap,
      child: loading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(label),
    );
  }
}