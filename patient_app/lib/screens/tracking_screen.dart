import 'dart:async';
import 'package:flutter/material.dart';
import '../models/emergency_model.dart';
import '../services/socket_service.dart';
import '../services/api_service.dart';

class TrackingScreen extends StatefulWidget {
  final EmergencyModel emergency;

  const TrackingScreen({super.key, required this.emergency});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  final SocketService _socketService = SocketService();
  Timer? _statusPollTimer;
  String? _lastStatus;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _lastStatus = widget.emergency.status;
    final requestId = widget.emergency.id;
    if (requestId != null && requestId.isNotEmpty && requestId != 'PENDING') {
      _initSocketConnection(requestId);
      _startStatusPolling(requestId);
    }
  }

  void _initSocketConnection(String requestId) {
    _socketService.connect(requestId, onStatusUpdate: (data) {
      if (!mounted) return;
      _handleStatusUpdate(data);
    });
  }

  void _startStatusPolling(String requestId) {
    _statusPollTimer?.cancel();
    _statusPollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted) return;
      final statusData = await ApiService.getEmergencyStatus(requestId);
      if (statusData != null && mounted) {
        _handleStatusUpdate(statusData);
      }
    });
  }

  void _handleStatusUpdate(Map<String, dynamic> data) {
    final newStatus = data['status']?.toString();
    if (newStatus == null || newStatus == _lastStatus) return;
    _lastStatus = newStatus;

    setState(() {
      final ambulance = data['ambulance'] as Map<String, dynamic>?;
      if (ambulance != null) {
        widget.emergency.ambulanceNumber =
            ambulance['ambulance_no']?.toString();
        widget.emergency.driverName = ambulance['driver_name']?.toString();
        widget.emergency.driverPhone = ambulance['driver_phone']?.toString();
      }

      final hospital = data['hospital'] as Map<String, dynamic>?;
      if (hospital != null) {
        widget.emergency.hospitalName = hospital['name']?.toString();
        widget.emergency.hospitalDepartment = 'Emergency Unit';
      }

      _mapBackendStatus(newStatus);
    });
  }

  void _mapBackendStatus(String status) {
    switch (status) {
      case 'searching_ambulance':
        widget.emergency.status = 'SEARCHING_AMBULANCE';
        break;
      case 'ambulance_assigned':
        widget.emergency.status = 'AMBULANCE_ASSIGNED';
        break;
      case 'searching_hospital':
      case 'hospital_approved':
      case 'routed_to_stabilization':
        widget.emergency.status = 'HOSPITAL_CONFIRMED';
        break;
      case 'completed':
        widget.emergency.status = 'COMPLETED';
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _statusPollTimer?.cancel();
    _socketService.disconnect();
    super.dispose();
  }

  // ── STATUS STEP INDEX ────────────────────────────────────
  int get _statusStep {
    switch (widget.emergency.status) {
      case "REPORTED":
      case "SEARCHING_AMBULANCE":
        return 0;
      case "AMBULANCE_ASSIGNED":
        return 1;
      case "HOSPITAL_CONFIRMED":
        return 2;
      case "COMPLETED":
        return 3;
      default:
        return 0;
    }
  }

  // ── HEADER ───────────────────────────────────────────────
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
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7, height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4ADE80),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Flexible(
                            child: Text(
                              "Lonavala",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_outline,
                        color: Colors.white, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Emergency Tracking",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
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
                  // Live pulse indicator
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (context, child) => Transform.scale(
                      scale: _pulseAnim.value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7, height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4ADE80),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text("LIVE",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1)),
                          ],
                        ),
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

  // ── STATUS STEPPER ───────────────────────────────────────
  Widget _buildStepper() {
    final steps = [
      {"label": "Reported", "icon": Icons.warning_amber_rounded},
      {"label": "Ambulance\nAssigned", "icon": Icons.local_shipping},
      {"label": "Hospital\nConfirmed", "icon": Icons.local_hospital},
      {"label": "Completed", "icon": Icons.check_circle},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10, offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
            final lineIndex = i ~/ 2;
            final isCompleted = _statusStep > lineIndex;
            return Expanded(
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFFD11A2A)
                      : const Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }
          // Step dot
          final stepIndex = i ~/ 2;
          final isCompleted = _statusStep >= stepIndex;
          final isCurrent = _statusStep == stepIndex;
          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isCurrent ? 40 : 32,
                height: isCurrent ? 40 : 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? const Color(0xFFD11A2A)
                      : const Color(0xFFEEEEEE),
                  boxShadow: isCurrent
                      ? [BoxShadow(
                          color: const Color(0xFFD11A2A).withOpacity(0.35),
                          blurRadius: 10, spreadRadius: 2)]
                      : [],
                ),
                child: Icon(
                  steps[stepIndex]["icon"] as IconData,
                  color: isCompleted ? Colors.white : Colors.grey,
                  size: isCurrent ? 20 : 16,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                steps[stepIndex]["label"] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                  color: isCompleted
                      ? const Color(0xFFD11A2A)
                      : const Color(0xFFAAAAAA),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ── AMBULANCE CARD ───────────────────────────────────────
  Widget _buildAmbulanceCard() {
    final bool searching = widget.emergency.status == "SEARCHING_AMBULANCE" ||
        widget.emergency.status == "REPORTED";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFCDD2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD11A2A).withOpacity(0.06),
            blurRadius: 10, offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD11A2A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_shipping,
                    color: Color(0xFFD11A2A), size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                searching ? "Finding Ambulance..." : "Ambulance Assigned",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF222222),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (searching) ...[
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD11A2A),
                strokeWidth: 2.5,
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                "Locating nearest available ambulance",
                style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
              ),
            ),
          ] else ...[
            _infoRow(Icons.badge_outlined,
                "Ambulance No", widget.emergency.ambulanceNumber ?? "--"),
            const SizedBox(height: 8),
            _infoRow(Icons.person_outline,
                "Driver", widget.emergency.driverName ?? "Awaiting details"),
            const SizedBox(height: 8),
            _infoRow(Icons.phone_outlined,
                "Driver Phone", widget.emergency.driverPhone ?? "--"),
            const SizedBox(height: 8),
            _infoRow(Icons.timer_outlined,
                "ETA to You",
                "${widget.emergency.ambulanceEta ?? '--'} minutes"),

            const SizedBox(height: 14),

            // Map placeholder
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.grey.shade200,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined,
                      size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 6),
                  Text("Live Ambulance Location",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                          fontSize: 13)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── HOSPITAL CARD ────────────────────────────────────────
  Widget _buildHospitalCard() {
    final bool searching = widget.emergency.status != "HOSPITAL_CONFIRMED" &&
        widget.emergency.status != "COMPLETED";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3FFF5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFC8E6C9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.06),
            blurRadius: 10, offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.local_hospital,
                    color: Colors.green.shade700, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                searching ? "Finding Hospital..." : "Hospital Confirmed",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF222222),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (searching) ...[
            Center(
              child: CircularProgressIndicator(
                color: Colors.green.shade600,
                strokeWidth: 2.5,
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                "Coordinating with nearby hospitals",
                style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
              ),
            ),
          ] else ...[
            // Hospital ready banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "HOSPITAL READY — GO DIRECTLY",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            _infoRow(Icons.business_outlined,
                "Hospital", widget.emergency.hospitalName ?? "--"),
            const SizedBox(height: 8),
            _infoRow(Icons.medical_services_outlined,
                "Department", widget.emergency.hospitalDepartment ?? "--"),
            const SizedBox(height: 8),
            _infoRow(Icons.straighten_outlined,
                "Distance", "${widget.emergency.hospitalDistance ?? '--'} km"),
            const SizedBox(height: 8),
            _infoRow(Icons.timer_outlined,
                "ETA to Hospital",
                "${widget.emergency.hospitalEta ?? '--'} minutes"),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.green.shade700, size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Emergency team is prepared. No admission wait.",
                      style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── CALM MESSAGE ─────────────────────────────────────────
  Widget _buildCalmBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3F3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.favorite,
                color: Color(0xFFD11A2A), size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Please stay calm. Help is being coordinated for you.",
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF555555)),
            ),
          ),
        ],
      ),
    );
  }

  // ── INFO ROW HELPER ──────────────────────────────────────
  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF999999)),
        const SizedBox(width: 8),
        Text("$label: ",
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF888888))),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF222222)),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  // ── DEV TEST CONTROLS ────────────────────────────────────
  Widget _buildDevControls() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("🛠 Developer Test Controls",
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: Colors.black54)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _devButton("Assign Ambulance", () {
                setState(() {
                  widget.emergency.status = "AMBULANCE_ASSIGNED";
                  widget.emergency.driverName = "Test Driver";
                  widget.emergency.driverPhone = "9999999999";
                  widget.emergency.ambulanceNumber = "MH12XY1234";
                  widget.emergency.ambulanceEta = 5;
                });
              }),
              _devButton("Confirm Hospital", () {
                setState(() {
                  widget.emergency.status = "HOSPITAL_CONFIRMED";
                  widget.emergency.hospitalName = "AISSMS Hospital";
                  widget.emergency.hospitalDepartment = "Emergency Unit";
                  widget.emergency.hospitalEta = 8;
                  widget.emergency.hospitalDistance = 2.1;
                });
              }),
              _devButton("Complete Case", () {
                setState(() {
                  widget.emergency.status = "COMPLETED";
                });
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _devButton(String label, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade800,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      onPressed: onTap,
      child: Text(label),
    );
  }

  // ── BUILD ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F0F0),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                children: [
                  _buildStepper(),
                  const SizedBox(height: 16),
                  _buildAmbulanceCard(),
                  const SizedBox(height: 16),
                  _buildHospitalCard(),
                  const SizedBox(height: 16),
                  _buildCalmBanner(),
                  const SizedBox(height: 16),
                  _buildDevControls(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}