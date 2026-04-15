import 'package:flutter/material.dart';
import '../models/hospital.dart';
import '../models/ambulance.dart';
import '../services/api_service.dart';

// ── Palette ─────────────────────────────────────────────────
const _blueDark = Color(0xFF1E3A8A);
const _blueMid = Color(0xFF1D4ED8);
const _blue = Color(0xFF2563EB);
const _blueSoft = Color(0xFFEFF6FF);
const _blueBorder = Color(0xFFDBEAFE);
const _teal = Color(0xFF0D9488);
const _tealSoft = Color(0xFFCCFBF1);
const _bg = Color(0xFFF0F7FF);
const _slate = Color(0xFF1E293B);
const _muted = Color(0xFF64748B);
const _green = Color(0xFF16A34A);
const _greenSoft = Color(0xFFDCFCE7);
const _red = Color(0xFFE8334A);
const _redSoft = Color(0xFFFEE2E2);

class NearbyServicesScreen extends StatefulWidget {
  final String type;
  const NearbyServicesScreen({super.key, required this.type});

  @override
  State<NearbyServicesScreen> createState() => _NearbyServicesScreenState();
}

class _NearbyServicesScreenState extends State<NearbyServicesScreen> {
  List<Hospital> hospitals = [];
  List<Ambulance> ambulances = [];
  bool isLoading = true;

  bool get isHospital => widget.type == "hospital";

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (isHospital) {
      hospitals = await ApiService.getAllHospitals();
    } else {
      ambulances = await ApiService.getAllAmbulances();
    }
    if (mounted) setState(() => isLoading = false);
  }

  int get _totalCount => isHospital ? hospitals.length : ambulances.length;

  int get _availableCount => isHospital
      ? hospitals
            .where((h) => h.resources != null && h.resources!.bedAvailable > 0)
            .length
      : ambulances.where((a) => a.isAvailable).length;

  @override
  Widget build(BuildContext context) {
    final title = isHospital ? "Nearby Hospitals" : "Nearby Ambulances";
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildHeader(context, title),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: _blue,
                      strokeWidth: 2.5,
                    ),
                  )
                : _totalCount == 0
                ? _buildEmpty()
                : _buildContent(context),
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, String title) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_blueDark, _blueMid, _blue, Color(0xFF60A5FA)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -55,
            right: -55,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                children: [
                  // top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.26),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      _locationPill(),
                      _avatarWidget(),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Searching nearby",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.60),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
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

  Widget _locationPill() => Container(
    padding: const EdgeInsets.fromLTRB(8, 5, 12, 5),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.14),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: Colors.white.withOpacity(0.24), width: 1),
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
        Text(
          "Lonavala",
          style: TextStyle(
            color: Colors.white.withOpacity(0.88),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );

  Widget _avatarWidget() => Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(0.16),
      border: Border.all(color: Colors.white.withOpacity(0.28), width: 1.5),
    ),
    child: const Icon(Icons.person_rounded, color: Colors.white, size: 17),
  );

  // ── Empty ───────────────────────────────────────────────
  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: _blueSoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.search_off_rounded, color: _blue, size: 32),
        ),
        const SizedBox(height: 12),
        Text(
          isHospital ? "No hospitals found" : "No ambulances found",
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _slate,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Check your connection and try again",
          style: TextStyle(
            fontSize: 12,
            color: _muted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );

  // ── Content (stats + list) ──────────────────────────────
  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats strip
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
          child: Row(
            children: [
              _StatCard(
                icon: isHospital
                    ? Icons.local_hospital_rounded
                    : Icons.airport_shuttle_rounded,
                iconBg: _blueSoft,
                iconColor: _blue,
                value: "$_totalCount",
                label: "Total Found",
              ),
              const SizedBox(width: 10),
              _StatCard(
                icon: isHospital ? Icons.bed_rounded : Icons.verified_rounded,
                iconBg: _tealSoft,
                iconColor: _teal,
                value: "$_availableCount",
                label: isHospital ? "Beds Available" : "Available Now",
              ),
            ],
          ),
        ),

        // Section label
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
          child: Text(
            isHospital ? "HOSPITALS NEAR YOU" : "AMBULANCES NEAR YOU",
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: _muted,
              letterSpacing: 1.3,
            ),
          ),
        ),

        // List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
            itemCount: _totalCount,
            itemBuilder: (ctx, i) => isHospital
                ? _HospitalCard(hospital: hospitals[i])
                : _AmbulanceCard(ambulance: ambulances[i]),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
//  Stat Card
// ═══════════════════════════════════════════════
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String value, label;
  const _StatCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: _slate,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: _muted,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ═══════════════════════════════════════════════
//  Hospital Card
// ═══════════════════════════════════════════════
class _HospitalCard extends StatelessWidget {
  final Hospital hospital;
  const _HospitalCard({required this.hospital});

  @override
  Widget build(BuildContext context) {
    final res = hospital.resources;
    final hasBeds = res != null && res.bedAvailable > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _blueBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: icon + name + status badge ──
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _blueSoft,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: _blue,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _slate,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hospital.contactNumber,
                      style: const TextStyle(
                        fontSize: 11,
                        color: _muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hasBeds ? _greenSoft : _redSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hasBeds ? "Available" : "Full",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: hasBeds ? _green : _red,
                  ),
                ),
              ),
            ],
          ),

          // ── Resource chips ──
          if (res != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _ResourceChip(
                  label: "ICU",
                  available: res.icuAvailable,
                  total: res.icuTotal,
                ),
                _ResourceChip(
                  label: "Beds",
                  available: res.bedAvailable,
                  total: res.bedTotal,
                ),
                _ResourceChip(
                  label: "Ventilators",
                  available: res.ventilatorAvailable,
                  total: res.ventilatorTotal,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Resource Chip  (e.g. "ICU  3/10")
// ═══════════════════════════════════════════════
class _ResourceChip extends StatelessWidget {
  final String label;
  final int available;
  final int total;
  const _ResourceChip({
    required this.label,
    required this.available,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final isLow = available <= 2 && total > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isLow ? _redSoft : _blueSoft,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label  ",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isLow ? _red : _slate,
            ),
          ),
          Text(
            "$available/$total",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: isLow ? _red : _blue,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Ambulance Card
// ═══════════════════════════════════════════════
class _AmbulanceCard extends StatelessWidget {
  final Ambulance ambulance;
  const _AmbulanceCard({required this.ambulance});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _blueBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _blueSoft,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.airport_shuttle_rounded,
              color: _blue,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          // info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ambulance.ambulanceNo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _slate,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Driver: ${ambulance.driverName}",
                  style: const TextStyle(
                    fontSize: 11,
                    color: _muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ambulance.isAvailable ? _greenSoft : _redSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: ambulance.isAvailable ? _green : _red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  ambulance.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: ambulance.isAvailable ? _green : _red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
