import 'package:flutter/material.dart';
import 'details_screen.dart';
import 'nearby_services_screen.dart';

// ── Palette ─────────────────────────────────────────────────
const _red       = Color(0xFFE8334A);
const _redDark   = Color(0xFFB91C2E);
const _redSoft   = Color(0xFFFDEEF0);
const _bg        = Color(0xFFFBF0F1);
const _slate     = Color(0xFF1A1A2C);
const _muted     = Color(0xFF8A909E);
const _blue      = Color(0xFF3D7FEE);
const _blueSoft  = Color(0xFFEBF2FF);
const _blueLight = Color(0xFFEFF6FF);
const _orange    = Color(0xFFF07B3F);
const _orangeSoft= Color(0xFFFEF2EC);
const _orangeLight=Color(0xFFFEF3EC);
// ────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Confirm dialog ──────────────────────────────────────────
  void _confirmEmergency(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: _red.withOpacity(0.18),
                blurRadius: 48,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFFEE2E2), Color(0xFFFECACA)]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: _red.withOpacity(0.22),
                        blurRadius: 20,
                        offset: const Offset(0, 8)),
                  ],
                ),
                child:
                    const Icon(Icons.warning_amber_rounded, color: _red, size: 36),
              ),
              const SizedBox(height: 16),
              const Text("Confirm Emergency",
                  style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: _slate)),
              const SizedBox(height: 10),
              const Text(
                "Are you sure this is a real medical emergency? Ambulance services will be alerted and dispatched to your location.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: _muted,
                    height: 1.6,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                    color: _redSoft, borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: Color(0xFFBE123C), size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "False alarms may delay help for real emergencies",
                        style: TextStyle(
                            color: Color(0xFFBE123C),
                            fontSize: 11,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(
                            color: Color(0xFFE2E8F0), width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text("Cancel",
                          style: TextStyle(
                              color: _muted,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const DetailsScreen()));
                      },
                      icon: const Icon(Icons.shield_rounded,
                          size: 17, color: Colors.white),
                      label: const Text("Yes, Alert Now",
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _red,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 6,
                        shadowColor: _red.withOpacity(0.45),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      // 3-section Column matching wireframe exactly
      body: Column(
        children: [
          // ══ SECTION 1 · HEADER ══
          _buildHeader(),

          // ══ SECTION 2 · CARDS ══
          _buildCardsSection(context),

          // ══ SECTION 3 · EMERGENCY ══
          _buildEmergencySection(context),
        ],
      ),
    );
  }

  // ── SECTION 1: Header ──────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9B1626),
            Color(0xFFC8202E),
            _red,
            Color(0xFFF06272),
          ],
        ),
        border: Border(
            bottom: BorderSide(color: Color(0x14FFFFFF), width: 2)),
      ),
      child: Stack(
        children: [
          // bg blobs
          Positioned(
            top: -55, right: -55,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  shape: BoxShape.circle),
            ),
          ),
          Positioned(
            bottom: -30, left: -40,
            child: Container(
              width: 140, height: 140,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  shape: BoxShape.circle),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
              child: Column(
                children: [
                  // ── top bar ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // live location pill
                      Container(
                        padding: const EdgeInsets.fromLTRB(8, 5, 12, 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.24),
                              width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7, height: 7,
                              decoration: const BoxDecoration(
                                  color: Color(0xFF4ADE80),
                                  shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "HSR Layout, Bengaluru",
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.88),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      // avatar
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.16),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.28),
                              width: 1.5),
                        ),
                        child: const Icon(Icons.person_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── app name ──
                  const Text(
                    "HC005",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                        height: 1),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Your Emergency Companion",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 16),

                  // ── ECG line decoration ──
                  Opacity(
                    opacity: 0.25,
                    child: CustomPaint(
                      size: const Size(double.infinity, 22),
                      painter: _EcgPainter(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SECTION 2: Cards ───────────────────────────────────────
  Widget _buildCardsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: const BoxDecoration(
        color: _bg,
        border: Border(
            bottom: BorderSide(color: Color(0x0F000000), width: 1.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "FIND NEARBY",
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: _muted,
                letterSpacing: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SearchCard(
                  icon: Icons.local_hospital_rounded,
                  label: "Nearby\nHospitals",
                  sub: "3 within 2 km",
                  iconBg: _blueSoft,
                  iconColor: _blue,
                  cardGradient: const [Colors.white, _blueLight],
                  arrowBg: _blueSoft,
                  arrowColor: _blue,
                  shadowColor: _blue,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const NearbyServicesScreen(type: "hospital")),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SearchCard(
                  icon: Icons.airport_shuttle_rounded,
                  label: "Nearby\nAmbulances",
                  sub: "2 available",
                  iconBg: _orangeSoft,
                  iconColor: _orange,
                  cardGradient: const [Colors.white, _orangeLight],
                  arrowBg: _orangeSoft,
                  arrowColor: _orange,
                  shadowColor: _orange,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const NearbyServicesScreen(type: "ambulance")),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── SECTION 3: Emergency ───────────────────────────────────
  Widget _buildEmergencySection(BuildContext context) {
    return Expanded(
      child: Container(
        color: _bg,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // animated pulse rings + circle button
              ScaleTransition(
                scale: _scaleAnim,
                child: GestureDetector(
                  onTap: () => _confirmEmergency(context),
                  child: Container(
                    width: 112, height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _red.withOpacity(0.10),
                    ),
                    child: Center(
                      child: Container(
                        width: 90, height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [_redDark, _red, Color(0xFFF05568)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _red.withOpacity(0.50),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: _red.withOpacity(0.18),
                              blurRadius: 40,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.emergency_rounded,
                                color: Colors.white, size: 26),
                            SizedBox(height: 3),
                            Text(
                              "REPORT\nEMERGENCY",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                  height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Tap to alert & dispatch",
                style: TextStyle(
                    fontSize: 12,
                    color: _muted.withOpacity(0.9),
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Search Card
// ═══════════════════════════════════════════════
class _SearchCard extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final Color iconBg, iconColor, arrowBg, arrowColor, shadowColor;
  final List<Color> cardGradient;
  final VoidCallback onTap;

  const _SearchCard({
    required this.icon,
    required this.label,
    required this.sub,
    required this.iconBg,
    required this.iconColor,
    required this.arrowBg,
    required this.arrowColor,
    required this.shadowColor,
    required this.cardGradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        splashColor: shadowColor.withOpacity(0.08),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: cardGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
                color: shadowColor.withOpacity(0.14), width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: shadowColor.withOpacity(0.10),
                  blurRadius: 16,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                          color: iconBg,
                          borderRadius: BorderRadius.circular(14)),
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                          color: arrowBg,
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.arrow_forward_ios_rounded,
                          color: arrowColor, size: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _slate,
                      height: 1.25),
                ),
                const SizedBox(height: 3),
                Text(sub,
                    style: const TextStyle(
                        fontSize: 11,
                        color: _muted,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  ECG Line Painter
// ═══════════════════════════════════════════════
class _EcgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final w = size.width;
    final h = size.height;
    final mid = h / 2;

    path.moveTo(0, mid);
    path.lineTo(w * 0.14, mid);
    path.lineTo(w * 0.18, mid * 0.2);
    path.lineTo(w * 0.21, mid * 1.8);
    path.lineTo(w * 0.24, mid * 0.2);
    path.lineTo(w * 0.27, mid * 1.4);
    path.lineTo(w * 0.30, mid);
    path.lineTo(w * 0.50, mid);
    path.lineTo(w * 0.54, mid * 0.5);
    path.lineTo(w * 0.57, mid * 1.6);
    path.lineTo(w * 0.60, mid * 0.1);
    path.lineTo(w * 0.63, mid * 1.9);
    path.lineTo(w * 0.67, mid);
    path.lineTo(w, mid);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}