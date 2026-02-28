// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../services/mission_controller.dart';
// import 'waiting_screen.dart';

// class MissionScreen extends StatelessWidget {
//   const MissionScreen({super.key});

//   @override
//   Widget build(BuildContext context) {

//     return Consumer<MissionController>(
//       builder: (context, controller, _) {

//         final emergency = controller.currentEmergency;

//         if (emergency == null) {
//           return const WaitingScreen();
//         }

//         return Scaffold(
//           appBar: AppBar(
//             title: const Text("Active Mission"),
//             backgroundColor: Colors.red,
//           ),

//           body: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [

//                 const Text("🚑 Proceed to Patient",
//                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

//                 const SizedBox(height: 20),

//                 Text("Pickup Location: ${emergency.pickupLocation}",
//                     style: const TextStyle(fontSize: 18)),

//                 const SizedBox(height: 30),
//                 const Divider(),
//                 const SizedBox(height: 20),

//                 const Text("Mission Status",
//                     style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

//                 const SizedBox(height: 20),

//                 if (controller.missionStage == 0)
//                   const Text("Navigating to patient location"),

//                 if (controller.missionStage == 1)
//                   const Text("Patient picked up"),

//                 if (controller.missionStage == 2)
//                   const Text("Transporting patient to hospital"),

//                 if (controller.missionStage == 3)
//                   const Text("Mission completed", style: TextStyle(color: Colors.green)),

//                 const SizedBox(height: 25),

//                 if (controller.assignedHospital == null)
//                   const Text(
//                     "Waiting for hospital confirmation...",
//                     style: TextStyle(color: Colors.orange),
//                   )
//                 else
//                   Container(
//                     padding: const EdgeInsets.all(15),
//                     decoration: BoxDecoration(
//                       color: Colors.green.shade100,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       "🏥 ${controller.assignedHospital} confirmed. Proceed immediately.",
//                       style: const TextStyle(fontSize: 18),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/mission_controller.dart';
import 'waiting_screen.dart';

class MissionScreen extends StatelessWidget {
  const MissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MissionController>(
      builder: (context, controller, _) {
        final emergency = controller.currentEmergency;

        if (emergency == null) {
          return const WaitingScreen();
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF7F0F0),
          body: Column(
            children: [
              _buildHeader(context, controller),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    children: [
                      _buildStageIndicator(controller.missionStage),
                      const SizedBox(height: 16),
                      _buildCallerCard(context, emergency),
                      const SizedBox(height: 14),
                      _buildPickupCard(emergency),
                      const SizedBox(height: 14),
                      _buildHospitalCard(controller),
                      const SizedBox(height: 14),
                      if (controller.missionStage == 3)
                        _buildCompletedBanner(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── HEADER ───────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, MissionController controller) {
    final stages = [
      "Navigating to Patient",
      "Patient Picked Up",
      "En Route to Hospital",
      "Mission Completed",
    ];
    final stage = controller.missionStage.clamp(0, 3);

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
                          Flexible(
                            child: Text(
                              stages[stage],
                              style: const TextStyle(
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
              const Text(
                "Active Mission",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Respond quickly · Every second counts",
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

  // ── STAGE INDICATOR ──────────────────────────────────────
  Widget _buildStageIndicator(int stage) {
    final steps = [
      {"icon": Icons.navigation_rounded, "label": "Navigate"},
      {"icon": Icons.person_pin_circle, "label": "Pickup"},
      {"icon": Icons.local_hospital, "label": "Transport"},
      {"icon": Icons.check_circle, "label": "Done"},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
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
            final lineIndex = i ~/ 2;
            return Expanded(
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: stage > lineIndex
                      ? const Color(0xFFD11A2A)
                      : const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }
          final s = i ~/ 2;
          final isDone = stage > s;
          final isCurrent = stage == s;
          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isCurrent ? 42 : 32,
                height: isCurrent ? 42 : 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone || isCurrent
                      ? const Color(0xFFD11A2A)
                      : const Color(0xFFEEEEEE),
                  boxShadow: isCurrent
                      ? [BoxShadow(
                          color: const Color(0xFFD11A2A).withOpacity(0.4),
                          blurRadius: 12, spreadRadius: 2)]
                      : [],
                ),
                child: Icon(
                  steps[s]["icon"] as IconData,
                  color: isDone || isCurrent ? Colors.white : Colors.grey,
                  size: isCurrent ? 20 : 15,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                steps[s]["label"] as String,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                  color: isDone || isCurrent
                      ? const Color(0xFFD11A2A)
                      : const Color(0xFFBBBBBB),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ── CALLER CARD ──────────────────────────────────────────
  Widget _buildCallerCard(BuildContext context, dynamic emergency) {
    // Uses emergency.callerName and emergency.callerPhone from EmergencyModel
    final String callerName = emergency.callerName ?? "Unknown Caller";
    final String callerPhone = emergency.callerPhone ?? "--";

    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          // Avatar
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFD11A2A).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person,
                color: Color(0xFFD11A2A), size: 26),
          ),
          const SizedBox(width: 14),
          // Name + phone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  callerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  callerPhone,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          // Call button
          GestureDetector(
            onTap: () {
              // Launch phone call
              // url_launcher: launchUrl(Uri.parse('tel:$callerPhone'));
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Calling $callerName..."),
                  backgroundColor: const Color(0xFFD11A2A),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD11A2A), Color(0xFFFF4D5E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD11A2A).withOpacity(0.4),
                    blurRadius: 12, offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const Icon(Icons.call, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  // ── PICKUP CARD ──────────────────────────────────────────
  Widget _buildPickupCard(dynamic emergency) {
    return Container(
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD11A2A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_on,
                    color: Color(0xFFD11A2A), size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                "Pickup Location",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF222222),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            emergency.pickupLocation ?? "--",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          // Map placeholder
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined,
                    size: 36, color: Colors.grey.shade400),
                const SizedBox(height: 6),
                Text(
                  "Navigate to Patient",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── HOSPITAL CARD ────────────────────────────────────────
  Widget _buildHospitalCard(MissionController controller) {
    final bool waiting = controller.assignedHospital == null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: waiting
            ? const Color(0xFFFFFBF0)
            : const Color(0xFFF3FFF5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: waiting
              ? const Color(0xFFFFE082)
              : const Color(0xFFC8E6C9),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (waiting ? Colors.orange : Colors.green).withOpacity(0.06),
            blurRadius: 10, offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (waiting ? Colors.orange : Colors.green)
                  .withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              waiting
                  ? Icons.hourglass_top_rounded
                  : Icons.local_hospital,
              color: waiting
                  ? Colors.orange.shade700
                  : Colors.green.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: waiting
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Awaiting Hospital",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF222222),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "Waiting for hospital confirmation...",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hospital Confirmed",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF222222),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "${controller.assignedHospital} · Proceed immediately",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
          ),
          if (!waiting)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "GO",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── COMPLETED BANNER ─────────────────────────────────────
  Widget _buildCompletedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 16, offset: const Offset(0, 4),
          )
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 28),
          SizedBox(width: 12),
          Text(
            "Mission Completed",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}