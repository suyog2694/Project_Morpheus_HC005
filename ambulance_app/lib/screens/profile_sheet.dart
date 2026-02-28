import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

/// Call this from any screen's profile icon onTap:
///   ProfileSheet.show(context);
class ProfileSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ProfileSheetContent(),
    );
  }
}

class _ProfileSheetContent extends StatefulWidget {
  const _ProfileSheetContent();
  @override State<_ProfileSheetContent> createState() => _ProfileSheetContentState();
}

class _ProfileSheetContentState extends State<_ProfileSheetContent> {
  bool _editing = false;
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  bool _saving = false;
  final _formKey = GlobalKey<FormState>();

  static const _red = Color(0xFFC0392B);

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().user;
    _nameCtrl  = TextEditingController(text: user?.name ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await context.read<AuthService>().updateProfile(
      name: _nameCtrl.text,
      phone: _phoneCtrl.text,
    );
    if (!mounted) return;
    setState(() { _saving = false; _editing = false; });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().user;
    if (user == null) return const SizedBox.shrink();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),

            // Avatar
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFDECEA),
                border: Border.all(color: _red.withOpacity(0.15), width: 2),
              ),
              child: const Icon(Icons.person_rounded, color: Color(0xFFC0392B), size: 30),
            ),
            const SizedBox(height: 10),

            if (!_editing) ...[
              Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 3),
              Text(user.phone, style: const TextStyle(fontSize: 13, color: Color(0xFFAAAAAA), fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),

              // Ambulance ID badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDECEA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _red.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.directions_car_rounded, color: _red, size: 14),
                    const SizedBox(width: 6),
                    Text(user.ambulanceId, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _red, letterSpacing: 0.8)),
                  ],
                ),
              ),

              Divider(color: _red.withOpacity(0.08), height: 28),

              // Info rows
              _InfoRow(label: 'FULL NAME', value: user.name),
              const SizedBox(height: 10),
              _InfoRow(label: 'PHONE',     value: user.phone),
              const SizedBox(height: 18),

              // Edit button
              OutlinedButton.icon(
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text('Edit Profile'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _red,
                  side: BorderSide(color: _red.withOpacity(0.3)),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.6),
                ),
                onPressed: () => setState(() => _editing = true),
              ),
              const SizedBox(height: 10),

              // Logout
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await context.read<AuthService>().logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
                    );
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.grey.shade400),
                child: const Text('Sign out', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              ),

            ] else ...[
              // ── Edit mode ──
              const Text('Edit Profile', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 16),

              _EditField(controller: _nameCtrl, label: 'FULL NAME', icon: Icons.person_rounded,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
              const SizedBox(height: 14),
              _EditField(controller: _phoneCtrl, label: 'PHONE NUMBER', icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().length < 7) ? 'Enter valid phone' : null),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _editing = false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade500,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        gradient: const LinearGradient(colors: [Color(0xFFE8362A), Color(0xFFC0392B)]),
                        boxShadow: [BoxShadow(color: _red.withOpacity(0.28), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                          foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                        ),
                        child: _saving
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Save Changes'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFBBBBBB), letterSpacing: 1.5)),
      Text(value,  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
    ],
  );
}

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _EditField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  static const _red = Color(0xFFC0392B);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFBBBBBB), letterSpacing: 1.5)),
      const SizedBox(height: 5),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: _red, size: 19),
          filled: true, fillColor: const Color(0xFFFDF5F5),
          contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _red.withOpacity(0.12))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _red.withOpacity(0.12))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _red, width: 1.5)),
        ),
      ),
    ],
  );
}