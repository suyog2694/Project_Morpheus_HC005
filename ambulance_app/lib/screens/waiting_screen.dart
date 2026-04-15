// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../services/mission_controller.dart';
// import 'mission_screen.dart';

// class WaitingScreen extends StatelessWidget {
//   const WaitingScreen({super.key});

//   @override
//   Widget build(BuildContext context) {

//     return Consumer<MissionController>(
//       builder: (context, controller, _) {

//         // If backend assigns emergency -> auto navigate
//         if (controller.currentEmergency != null) {
//           Future.microtask(() {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => const MissionScreen()),
//             );
//           });
//         }

//         return Scaffold(
//           backgroundColor: Colors.black,
//           body: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: const [

//                 Icon(Icons.local_hospital, color: Colors.red, size: 120),
//                 SizedBox(height: 20),

//                 Text(
//                   "AMBULANCE ONLINE",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),

//                 SizedBox(height: 10),

//                 Text(
//                   "Waiting for dispatch from coordination server...",
//                   style: TextStyle(color: Colors.white70),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mission_controller.dart';
import '../services/auth_service.dart';
import 'dispatch_screen.dart';

class WaitingScreen extends StatefulWidget {
  const WaitingScreen({super.key});

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _spinCtrl;

  static const _red = Color(0xFFC0392B);
  static const _bgBody = Color(0xFFFDF5F5);

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    // Start polling for emergencies after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthService>();
      if (auth.isLoggedIn && auth.user != null) {
        context.read<MissionController>().startPolling(auth.user!.ambulanceId);
      }
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _spinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MissionController>(
      builder: (context, controller, _) {
        // Auto-navigate when backend assigns emergency
        if (controller.currentEmergency != null) {
          final emergency = controller.currentEmergency!;
          Future.microtask(() {
            controller.stopPolling();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DispatchScreen(emergency: emergency),
              ),
            ).then((_) {
              // Resume polling when returning from dispatch (rejected)
              final auth = context.read<AuthService>();
              if (auth.isLoggedIn &&
                  auth.user != null &&
                  controller.currentEmergency == null) {
                controller.startPolling(auth.user!.ambulanceId);
              }
            });
          });
        }

        return Scaffold(
          backgroundColor: _bgBody,
          body: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPulseIcon(),
                      const SizedBox(height: 28),
                      _buildOnlineChip(),
                      const SizedBox(height: 16),
                      const Text(
                        'Ready for\nNext Dispatch',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1A1A1A),
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Waiting for dispatch from\ncoordination server…',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade400,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildWaitingCard(),
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

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8362A), Color(0xFFC0392B), Color(0xFFA93226)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Row(
                children: [
                  const SizedBox(width: 36),
                  const Expanded(
                    child: Text(
                      'CareLink',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.18),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Pulsing ambulance icon ─────────────────────────────────────────────────
  Widget _buildPulseIcon() {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 3 expanding rings
          ...List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) {
                final progress = ((_pulseCtrl.value - i * 0.25) % 1.0).clamp(
                  0.0,
                  1.0,
                );
                final scale = 0.55 + progress * 0.55;
                final opacity = (1.0 - progress) * 0.35;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _red.withOpacity(opacity),
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          // Icon circle
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: _red.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: _red.withOpacity(0.12), width: 1.5),
            ),
            child: const Center(
              child: Text('🚑', style: TextStyle(fontSize: 44)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Online chip ────────────────────────────────────────────────────────────
  Widget _buildOnlineChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF27AE60).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF27AE60).withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BlinkDot(),
          const SizedBox(width: 7),
          const Text(
            'AMBULANCE ONLINE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF27AE60),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // ── Waiting card ───────────────────────────────────────────────────────────
  Widget _buildWaitingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _red.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: _red.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _spinCtrl,
            builder: (_, __) => Transform.rotate(
              angle: _spinCtrl.value * 6.28318,
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: const AlwaysStoppedAnimation(_red),
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF888888),
                fontFamily: 'Nunito',
              ),
              children: [
                TextSpan(text: 'Listening for '),
                TextSpan(
                  text: 'incoming emergencies',
                  style: TextStyle(color: _red),
                ),
                TextSpan(text: '…'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Blinking green dot ────────────────────────────────────────────────────

class _BlinkDot extends StatefulWidget {
  @override
  State<_BlinkDot> createState() => _BlinkDotState();
}

class _BlinkDotState extends State<_BlinkDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _a = Tween(
      begin: 1.0,
      end: 0.35,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _a,
    child: Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF27AE60),
      ),
    ),
  );
}
