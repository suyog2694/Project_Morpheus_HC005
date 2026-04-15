import 'package:flutter/material.dart';
import '../models/emergency_model.dart';
import 'tracking_screen.dart';

// ── Palette ──────────────────────────────────────────────
const _red = Color(0xFFD11A2A);
const _green = Color(0xFF16A34A);
const _greenSoft = Color(0xFFDCFCE7);
const _greenBorder = Color(0xFFA7F3D0);
const _slate = Color(0xFF1A1A2C);
const _muted = Color(0xFF8A909E);
const _bgPage = Color(0xFFF7F0F0);
// ─────────────────────────────────────────────────────────

class AssignmentScreen extends StatefulWidget {
  final EmergencyModel emergency;

  const AssignmentScreen({super.key, required this.emergency});

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkCtrl;
  late Animation<double> _checkScale;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    // Checkmark pop animation
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _checkScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut));

    // Slide-up cards animation
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));

    // Stagger: check first, then cards
    _checkCtrl.forward().then((_) {
      _slideCtrl.forward();
    });
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  // ── Header ─────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD11A2A), Color(0xFFA50F1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4ADE80),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Flexible(
                            child: Text(
                              "Emergency Active",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                "Help Is On The Way",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Case ID: ${widget.emergency.id}",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Success badge ──────────────────────────────────────
  Widget _buildSuccessBadge() {
    return ScaleTransition(
      scale: _checkScale,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _green.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Emergency Submitted",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Your request has been processed",
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Ambulance card ─────────────────────────────────────
  Widget _buildAmbulanceCard() {
    final hasAmbulance =
        widget.emergency.ambulanceNumber != null &&
        widget.emergency.ambulanceNumber!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasAmbulance
              ? const Color(0xFFFFCDD2)
              : const Color(0xFFE8E8E8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _red.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: _red,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasAmbulance
                          ? "Ambulance Assigned"
                          : "Finding Ambulance...",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _slate,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasAmbulance
                          ? "Dispatched to your location"
                          : "Locating nearest available unit",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasAmbulance)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: _green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        "Assigned",
                        style: TextStyle(
                          color: _green,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (hasAmbulance) ...[
            // Ambulance details
            _detailTile(
              Icons.directions_bus_rounded,
              "Vehicle No",
              widget.emergency.ambulanceNumber ?? "--",
            ),
            const SizedBox(height: 10),
            _detailTile(
              Icons.person_rounded,
              "Driver",
              widget.emergency.driverName ?? "Assigned",
            ),
            if (widget.emergency.driverPhone != null) ...[
              const SizedBox(height: 10),
              _detailTile(
                Icons.phone_rounded,
                "Contact",
                widget.emergency.driverPhone!,
              ),
            ],
            if (widget.emergency.ambulanceEta != null) ...[
              const SizedBox(height: 10),
              _detailTile(
                Icons.timer_rounded,
                "ETA",
                "${widget.emergency.ambulanceEta} min",
              ),
            ],
          ] else ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: _red,
                        strokeWidth: 2.5,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Searching for nearest ambulance...",
                      style: TextStyle(
                        fontSize: 12,
                        color: _muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Hospital card ──────────────────────────────────────
  Widget _buildHospitalCard() {
    final hasHospital =
        widget.emergency.hospitalName != null &&
        widget.emergency.hospitalName!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasHospital ? _greenBorder : const Color(0xFFE8E8E8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _green.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _greenSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.local_hospital_rounded,
                  color: Colors.green.shade700,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasHospital
                          ? "Hospital Assigned"
                          : "Coordinating Hospital...",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _slate,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasHospital
                          ? "Emergency team notified"
                          : "Finding best-fit hospital nearby",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasHospital)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: _green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        "Ready",
                        style: TextStyle(
                          color: _green,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (hasHospital) ...[
            _detailTile(
              Icons.business_rounded,
              "Hospital",
              widget.emergency.hospitalName!,
            ),
            if (widget.emergency.hospitalDepartment != null) ...[
              const SizedBox(height: 10),
              _detailTile(
                Icons.medical_services_rounded,
                "Department",
                widget.emergency.hospitalDepartment!,
              ),
            ],
            if (widget.emergency.hospitalDistance != null) ...[
              const SizedBox(height: 10),
              _detailTile(
                Icons.straighten_rounded,
                "Distance",
                "${widget.emergency.hospitalDistance} km",
              ),
            ],
            if (widget.emergency.hospitalEta != null) ...[
              const SizedBox(height: 10),
              _detailTile(
                Icons.timer_rounded,
                "ETA",
                "${widget.emergency.hospitalEta} min",
              ),
            ],
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: Colors.green.shade600,
                        strokeWidth: 2.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Matching with nearest suitable hospital...",
                      style: TextStyle(
                        fontSize: 12,
                        color: _muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Detail tile helper ─────────────────────────────────
  Widget _detailTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _muted),
          const SizedBox(width: 10),
          Text(
            "$label:",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _muted,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _slate,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Calm message ───────────────────────────────────────
  Widget _buildCalmBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFED7AA), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Color(0xFFF59E0B),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Stay calm. Help is being dispatched to you right now.",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF92400E),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Track Emergency button ─────────────────────────────
  Widget _buildTrackButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: _red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: _red.withOpacity(0.4),
        ),
        icon: const Icon(Icons.gps_fixed_rounded, size: 20),
        label: const Text(
          "TRACK EMERGENCY",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => TrackingScreen(emergency: widget.emergency),
            ),
          );
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              child: Column(
                children: [
                  _buildSuccessBadge(),
                  const SizedBox(height: 18),
                  SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Column(
                        children: [
                          _buildAmbulanceCard(),
                          const SizedBox(height: 14),
                          _buildHospitalCard(),
                          const SizedBox(height: 14),
                          _buildCalmBanner(),
                          const SizedBox(height: 22),
                          _buildTrackButton(),
                        ],
                      ),
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
}
