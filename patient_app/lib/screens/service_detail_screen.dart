import 'package:flutter/material.dart';
import '../models/service_unit.dart';

// ── Palette ─────────────────────────────────────────────────
const _blueDark   = Color(0xFF1E3A8A);
const _blueMid    = Color(0xFF1D4ED8);
const _blue       = Color(0xFF2563EB);
const _blueSoft   = Color(0xFFEFF6FF);
const _blueBorder = Color(0xFFDBEAFE);
const _bg         = Color(0xFFF0F7FF);
const _slate      = Color(0xFF1E293B);
const _muted      = Color(0xFF64748B);
const _green      = Color(0xFF16A34A);
const _greenSoft  = Color(0xFFDCFCE7);
const _red        = Color(0xFFE8334A);
const _redDark    = Color(0xFFB91C2E);
const _redSoft    = Color(0xFFFEE2E2);
const _divider    = Color(0xFFF0F5FF);

class ServiceDetailScreen extends StatelessWidget {
  final ServiceUnit service;
  final bool isHospital;
  const ServiceDetailScreen({super.key, required this.service, required this.isHospital});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(children: [
        _buildHeader(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
            child: Column(children: [
              _buildUnifiedCard(),
              const SizedBox(height: 18),
              _buildCallButton(context),
            ]),
          ),
        ),
      ]),
    );
  }

  // ── Header ──────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [_blueDark, _blueMid, _blue, Color(0xFF60A5FA)],
        ),
      ),
      child: Stack(children: [
        Positioned(top: -55, right: -55,
          child: Container(width: 200, height: 200,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), shape: BoxShape.circle))),
        Positioned(bottom: -30, left: -40,
          child: Container(width: 140, height: 140,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), shape: BoxShape.circle))),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.16),
                      border: Border.all(color: Colors.white.withOpacity(0.26), width: 1.5)),
                    child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18)),
                ),
                _locationPill(),
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.16),
                    border: Border.all(color: Colors.white.withOpacity(0.28), width: 1.5)),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 17)),
              ]),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(isHospital ? "Hospital Details" : "Ambulance Details",
                      style: TextStyle(color: Colors.white.withOpacity(0.60), fontSize: 11,
                          fontWeight: FontWeight.w700, letterSpacing: 1.0)),
                  const SizedBox(height: 3),
                  Text(service.name,
                      style: const TextStyle(color: Colors.white, fontSize: 20,
                          fontWeight: FontWeight.w900, letterSpacing: -0.2)),
                ]),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _locationPill() => Container(
    padding: const EdgeInsets.fromLTRB(8, 5, 12, 5),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.14), borderRadius: BorderRadius.circular(30),
      border: Border.all(color: Colors.white.withOpacity(0.24), width: 1)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 7, height: 7,
          decoration: const BoxDecoration(color: Color(0xFF4ADE80), shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text("HSR Layout, Bengaluru",
          style: TextStyle(color: Colors.white.withOpacity(0.88), fontSize: 11, fontWeight: FontWeight.w700)),
    ]),
  );

  // ── Single unified card ─────────────────────────────────
  Widget _buildUnifiedCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _blueBorder, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, 5))
        ],
      ),
      child: Column(children: [
        // ── Hospital identity section ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: _blueSoft, borderRadius: BorderRadius.circular(16)),
                child: Icon(
                  isHospital ? Icons.local_hospital_rounded : Icons.airport_shuttle_rounded,
                  color: _blue, size: 28)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(service.name,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _slate)),
                const SizedBox(height: 3),
                // address placeholder (backend will supply)
                Text("${service.distance.toStringAsFixed(1)} km · Bengaluru",
                    style: const TextStyle(fontSize: 12, color: _muted, fontWeight: FontWeight.w600)),
                const SizedBox(height: 7),
                // availability badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: service.available ? _greenSoft : _redSoft,
                    borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: service.available ? _green : _red, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text(service.available ? "Available" : "Busy",
                        style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w800,
                          color: service.available ? const Color(0xFF15803D) : _redDark)),
                  ]),
                ),
              ])),
            ]),

            const SizedBox(height: 14),

            // Info chips
            Wrap(spacing: 8, runSpacing: 6, children: [
              _InfoChip(icon: Icons.location_on_rounded,
                  label: "${service.distance.toStringAsFixed(1)} km away"),
              _InfoChip(icon: Icons.access_time_rounded, label: "Open 24/7"),
              if (!isHospital && service.eta != null)
                _InfoChip(icon: Icons.timer_rounded, label: "~${service.eta} min ETA"),
            ]),
          ]),
        ),

        // ── Divider ──
        Container(height: 1.5, color: _divider),

        // ── Resources section ──
        if (isHospital)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("RESOURCES",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                      color: _muted, letterSpacing: 1.3)),
              const SizedBox(height: 12),
              // 2×2 minimal grid — separated by fine lines
              _buildResourceGrid(),
            ]),
          ),

        if (!isHospital)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("INFO",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                      color: _muted, letterSpacing: 1.3)),
              const SizedBox(height: 12),
              _buildAmbulanceGrid(),
            ]),
          ),
      ]),
    );
  }

  // ── 2×2 resource grid ───────────────────────────────────
  Widget _buildResourceGrid() {
    final items = [
      _ResData(label: "ICU Beds",      value: service.icu?.toString() ?? "—",      unit: "available"),
      _ResData(label: "General Beds",  value: service.beds?.toString() ?? "—",     unit: "available"),
      _ResData(label: "Ventilators",   value: service.ventilator?.toString() ?? "—", unit: "available"),
      _ResData(label: "Oxygen",
          value: (service.oxygen != null && service.oxygen! > 0) ? "Yes" : "No",
          unit: "24/7 support"),
    ];

    return Column(children: [
      // row 1
      IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: _ResCell(data: items[0])),
          Container(width: 1.5, color: _blueBorder),
          Expanded(child: _ResCell(data: items[1])),
        ]),
      ),
      Container(height: 1.5, color: _blueBorder),
      // row 2
      IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: _ResCell(data: items[2])),
          Container(width: 1.5, color: _blueBorder),
          Expanded(child: _ResCell(data: items[3])),
        ]),
      ),
    ]);
  }

  // ── Ambulance info grid ─────────────────────────────────
  Widget _buildAmbulanceGrid() {
    final items = [
      _ResData(label: "Distance",  value: "${service.distance.toStringAsFixed(1)} km", unit: "from you"),
      _ResData(label: "ETA",       value: service.eta != null ? "${service.eta} min" : "—", unit: "est. arrival"),
      _ResData(label: "Status",    value: service.available ? "Ready" : "Busy", unit: "current status"),
      _ResData(label: "Type",      value: "ALS",  unit: "ambulance class"),
    ];

    return Column(children: [
      IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: _ResCell(data: items[0])),
          Container(width: 1.5, color: _blueBorder),
          Expanded(child: _ResCell(data: items[1])),
        ]),
      ),
      Container(height: 1.5, color: _blueBorder),
      IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: _ResCell(data: items[2])),
          Container(width: 1.5, color: _blueBorder),
          Expanded(child: _ResCell(data: items[3])),
        ]),
      ),
    ]);
  }

  // ── Call button ─────────────────────────────────────────
  Widget _buildCallButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [_blueDark, _blueMid, _blue],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [
          BoxShadow(color: _blue.withOpacity(0.38), blurRadius: 22, offset: const Offset(0, 8))
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Call feature will connect via backend"),
                behavior: SnackBarBehavior.floating));
        },
        icon: const Icon(Icons.call_rounded, color: Colors.white, size: 22),
        label: Text("Call ${service.name}",
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Resource data model
// ═══════════════════════════════════════════════
class _ResData {
  final String label, value, unit;
  _ResData({required this.label, required this.value, required this.unit});
}

// ═══════════════════════════════════════════════
//  Resource cell — just label + big count + unit
// ═══════════════════════════════════════════════
class _ResCell extends StatelessWidget {
  final _ResData data;
  const _ResCell({required this.data});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(data.label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _muted)),
      const SizedBox(height: 5),
      Text(data.value,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: _slate, height: 1)),
      const SizedBox(height: 2),
      Text(data.unit,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _muted)),
    ]),
  );
}

// ═══════════════════════════════════════════════
//  Info Chip
// ═══════════════════════════════════════════════
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(9)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: _muted),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _slate)),
    ]),
  );
}