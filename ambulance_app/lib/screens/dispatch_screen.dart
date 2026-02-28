// import 'package:flutter/material.dart';
// import '../models/emergency.dart';
// import 'mission_screen.dart';

// class DispatchScreen extends StatelessWidget {
//   final Emergency emergency;
//   const DispatchScreen({super.key, required this.emergency});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.red.shade50,
//       appBar: AppBar(
//         title: const Text("Incoming Emergency"),
//         backgroundColor: Colors.red,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [

//             const Text(
//               "🚨 NEW EMERGENCY",
//               style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 25),

//             Text("Patient: ${emergency.patientName}", style: const TextStyle(fontSize: 18)),
//             const SizedBox(height: 10),

//             Text("Care Required: ${emergency.careType}", style: const TextStyle(fontSize: 18)),
//             const SizedBox(height: 10),

//             Text("Pickup Location: ${emergency.pickupLocation}", style: const TextStyle(fontSize: 18)),
//             const SizedBox(height: 10),

//             Text("Notes: ${emergency.description}", style: const TextStyle(fontSize: 16)),

//             const Spacer(),

//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                     onPressed: () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => const MissionScreen(),
//                         ),
//                       );
//                     },
//                     child: const Text("ACCEPT", style: TextStyle(fontSize: 18)),
//                   ),
//                 ),
//                 const SizedBox(width: 20),
//                 Expanded(
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     child: const Text("REJECT", style: TextStyle(fontSize: 18)),
//                   ),
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import '../models/emergency.dart';
// import 'mission_screen.dart';
// import 'profile_sheet.dart'; // adjust path to match yours

// class DispatchScreen extends StatelessWidget {
//   final Emergency emergency;
//   const DispatchScreen({super.key, required this.emergency});

//   static const _redDark = Color(0xFFC0392B);
//   static const _bgBody  = Color(0xFFFDF5F5);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _bgBody,
//       body: Column(
//         children: [
//           _buildHeader(context),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
//               child: Column(
//                 children: [
//                   _PatientCard(name: emergency.patientName),
//                   const SizedBox(height: 11),
//                   _InfoTile(
//                     iconWidget: const _AlertIcon(),
//                     iconBg: const Color(0xFFFDECEA),
//                     label: 'CONDITION',
//                     value: emergency.description, // swap with emergency.condition if available
//                   ),
//                   const SizedBox(height: 11),
//                   _InfoTile(
//                     iconWidget: const _LocationIcon(),
//                     iconBg: const Color(0xFFE8F1FD),
//                     label: 'PICKUP LOCATION',
//                     value: emergency.pickupLocation,
//                   ),
//                   const SizedBox(height: 18),
//                 ],
//               ),
//             ),
//           ),
//           _buildActions(context),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [Color(0xFFE8362A), Color(0xFFC0392B), Color(0xFFA93226)],
//         ),
//       ),
//       child: SafeArea(
//         bottom: false,
//         child: Stack(
//           children: [

//             Positioned(
//   top: -30, right: -30,
//   child: IgnorePointer(  // ← add this
//     child: Container(
//       width: 150, height: 150,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: Colors.white.withOpacity(0.07),
//       ),
//     ),
//   ),
// ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       _HeaderCircleBtn(
//                         onTap: () => Navigator.pop(context),
//                         child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 17),
//                       ),
//                       const Expanded(child: _PulsingTitle()),
//                       _HeaderCircleBtn(
//                         onTap: () => ProfileSheet.show(context), // ← was () {}
//                         child: const Icon(Icons.person_rounded, color: Colors.white, size: 19),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 14),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const _PulseDot(),
//                       const SizedBox(width: 9),
//                       const Text(
//                         'New Dispatch',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 22,
//                           fontWeight: FontWeight.w900,
//                           letterSpacing: 0.3,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActions(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
//       decoration: BoxDecoration(
//         color: _bgBody,
//         border: Border(top: BorderSide(color: Colors.red.withOpacity(0.08))),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: OutlinedButton.icon(
//               icon: const Icon(Icons.close_rounded, size: 18),
//               label: const Text('REJECT'),
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: Colors.grey.shade500,
//                 side: BorderSide(color: Colors.grey.shade300),
//                 padding: const EdgeInsets.symmetric(vertical: 15),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                 textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.8),
//               ),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ),
//           const SizedBox(width: 11),
//           Expanded(
//             flex: 2,
//             child: DecoratedBox(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(16),
//                 gradient: const LinearGradient(colors: [Color(0xFFE8362A), Color(0xFFC0392B)]),
//                 boxShadow: [BoxShadow(color: _redDark.withOpacity(0.32), blurRadius: 16, offset: const Offset(0, 6))],
//               ),
//               child: ElevatedButton.icon(
//                 icon: const Icon(Icons.check_rounded, size: 20),
//                 label: const Text('ACCEPT MISSION'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.transparent,
//                   shadowColor: Colors.transparent,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                   textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.8),
//                 ),
//                 onPressed: () {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (_) => const MissionScreen()),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─── Header Widgets ──────────────────────────────────────────────────────────

// class _HeaderCircleBtn extends StatelessWidget {
//   final Widget child;
//   final VoidCallback onTap;
//   const _HeaderCircleBtn({required this.child, required this.onTap});

//   @override
//   Widget build(BuildContext context) => GestureDetector(
//     onTap: onTap,
//     child: Container(
//       width: 36, height: 36,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: Colors.white.withOpacity(0.18),
//       ),
//       child: Center(child: child),
//     ),
//   );
// }

// class _PulsingTitle extends StatefulWidget {
//   const _PulsingTitle();
//   @override State<_PulsingTitle> createState() => _PulsingTitleState();
// }
// class _PulsingTitleState extends State<_PulsingTitle> with SingleTickerProviderStateMixin {
//   late final AnimationController _ctrl;
//   late final Animation<double> _opacity;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
//     _opacity = Tween(begin: 1.0, end: 0.55).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
//   }
//   @override void dispose() { _ctrl.dispose(); super.dispose(); }

//   @override
//   Widget build(BuildContext context) => FadeTransition(
//     opacity: _opacity,
//     child: const Text(
//       '🚨 INCOMING EMERGENCY',
//       textAlign: TextAlign.center,
//       style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5),
//     ),
//   );
// }

// class _PulseDot extends StatefulWidget {
//   const _PulseDot();
//   @override State<_PulseDot> createState() => _PulseDotState();
// }
// class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
//   late final AnimationController _ctrl;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
//   }
//   @override void dispose() { _ctrl.dispose(); super.dispose(); }

//   @override
//   Widget build(BuildContext context) => AnimatedBuilder(
//     animation: _ctrl,
//     builder: (_, __) => Container(
//       width: 10, height: 10,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: Colors.white,
//         boxShadow: [BoxShadow(
//           color: Colors.white.withOpacity((1 - _ctrl.value) * 0.7),
//           blurRadius: _ctrl.value * 12,
//           spreadRadius: _ctrl.value * 3,
//         )],
//       ),
//     ),
//   );
// }

// // ─── Body Widgets ─────────────────────────────────────────────────────────────

// class _PatientCard extends StatelessWidget {
//   final String name;
//   const _PatientCard({required this.name});

//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(18),
//       boxShadow: [BoxShadow(color: const Color(0xFFC0392B).withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 2))],
//       border: Border.all(color: const Color(0xFFC0392B).withOpacity(0.08)),
//     ),
//     child: Row(
//       children: [
//         // Universal medical cross icon in a circle
//         Container(
//           width: 54, height: 54,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: const Color(0xFFFDECEA),
//             border: Border.all(color: const Color(0xFFC0392B).withOpacity(0.15), width: 1.5),
//           ),
//           child: Center(
//             child: CustomPaint(size: const Size(24, 24), painter: _CrossPainter()),
//           ),
//         ),
//         const SizedBox(width: 14),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('PATIENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFBBBBBB), letterSpacing: 1.6)),
//               const SizedBox(height: 2),
//               Text(name, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }

// class _CrossPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..color = const Color(0xFFC0392B)..style = PaintingStyle.fill;
//     final r = 2.5;
//     // Vertical bar
//     canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.375, 0, size.width * 0.25, size.height), Radius.circular(r)), paint);
//     // Horizontal bar
//     canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, size.height * 0.375, size.width, size.height * 0.25), Radius.circular(r)), paint);
//   }
//   @override bool shouldRepaint(_) => false;
// }

// class _InfoTile extends StatelessWidget {
//   final Widget iconWidget;
//   final Color iconBg;
//   final String label;
//   final String value;

//   const _InfoTile({
//     required this.iconWidget,
//     required this.iconBg,
//     required this.label,
//     required this.value,
//   });

//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.all(14),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       boxShadow: [BoxShadow(color: const Color(0xFFC0392B).withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2))],
//       border: Border.all(color: const Color(0xFFC0392B).withOpacity(0.07)),
//     ),
//     child: Row(
//       children: [
//         Container(
//           width: 42, height: 42,
//           decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
//           child: Center(child: iconWidget),
//         ),
//         const SizedBox(width: 14),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFBBBBBB), letterSpacing: 1.5)),
//               const SizedBox(height: 2),
//               Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)), maxLines: 2, overflow: TextOverflow.ellipsis),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }

// // ─── Icon Widgets (no external packages needed) ───────────────────────────────

// class _AlertIcon extends StatelessWidget {
//   const _AlertIcon();
//   @override
//   Widget build(BuildContext context) => CustomPaint(size: const Size(22, 22), painter: _AlertPainter());
// }

// class _AlertPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..color = const Color(0xFFC0392B)..style = PaintingStyle.fill;
//     final cx = size.width / 2;
//     final cy = size.height / 2;
//     // Circle
//     canvas.drawCircle(Offset(cx, cy), size.width / 2, paint);
//     // Exclamation — white
//     final white = Paint()..color = Colors.white..style = PaintingStyle.fill;
//     // Stem
//     canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy - 2), width: 3, height: 8), const Radius.circular(1.5)), white);
//     // Dot
//     canvas.drawCircle(Offset(cx, cy + 6), 1.8, white);
//   }
//   @override bool shouldRepaint(_) => false;
// }

// class _LocationIcon extends StatelessWidget {
//   const _LocationIcon();
//   @override
//   Widget build(BuildContext context) => CustomPaint(size: const Size(22, 22), painter: _LocationPainter());
// }

// class _LocationPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..color = const Color(0xFF2471D9)..style = PaintingStyle.fill;
//     final cx = size.width / 2;
//     final path = Path();
//     // Pin body
//     path.addOval(Rect.fromCenter(center: Offset(cx, size.height * 0.38), width: size.width * 0.7, height: size.height * 0.7));
//     // Tail
//     path.moveTo(cx - size.width * 0.18, size.height * 0.6);
//     path.lineTo(cx, size.height * 0.95);
//     path.lineTo(cx + size.width * 0.18, size.height * 0.6);
//     canvas.drawPath(path, paint);
//     // Inner white circle
//     canvas.drawCircle(Offset(cx, size.height * 0.38), size.width * 0.18, Paint()..color = Colors.white);
//   }
//   @override bool shouldRepaint(_) => false;
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/emergency.dart';
import '../services/mission_controller.dart';
import 'mission_screen.dart';
import 'profile_sheet.dart';

class DispatchScreen extends StatelessWidget {
  final Emergency emergency;
  const DispatchScreen({super.key, required this.emergency});

  static const _redDark = Color(0xFFC0392B);
  static const _bgBody = Color(0xFFFDF5F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBody,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: Column(
                children: [
                  _PatientCard(name: emergency.patientName),
                  const SizedBox(height: 11),
                  _InfoTile(
                    iconWidget: const _AlertIcon(),
                    iconBg: const Color(0xFFFDECEA),
                    label: 'CONDITION',
                    value: emergency.description,
                  ),
                  const SizedBox(height: 11),
                  _InfoTile(
                    iconWidget: const _LocationIcon(),
                    iconBg: const Color(0xFFE8F1FD),
                    label: 'PICKUP LOCATION',
                    value: emergency.pickupLocation,
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: Column(
            children: [
              Row(
                children: [
                  _HeaderCircleBtn(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 17,
                    ),
                  ),
                  const Expanded(child: _PulsingTitle()),
                  _HeaderCircleBtn(
                    onTap: () => ProfileSheet.show(context),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _PulseDot(),
                  const SizedBox(width: 9),
                  const Text(
                    'New Dispatch',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
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

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: _bgBody,
        border: Border(top: BorderSide(color: Colors.red.withOpacity(0.08))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.close_rounded, size: 18),
              label: const Text('REJECT'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade500,
                side: BorderSide(color: Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              onPressed: () {
                // Clear mission so WaitingScreen resumes polling
                context.read<MissionController>().clearMission();
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            flex: 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8362A), Color(0xFFC0392B)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _redDark.withOpacity(0.32),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_rounded, size: 20),
                label: const Text('ACCEPT MISSION'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                onPressed: () {
                  // Keep the emergency in the controller and go to MissionScreen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MissionScreen()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header Widgets ──────────────────────────────────────────────────────────

class _HeaderCircleBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _HeaderCircleBtn({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.18),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _PulsingTitle extends StatefulWidget {
  const _PulsingTitle();
  @override
  State<_PulsingTitle> createState() => _PulsingTitleState();
}

class _PulsingTitleState extends State<_PulsingTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _opacity = Tween(
      begin: 1.0,
      end: 0.55,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _opacity,
    child: const Text(
      '🚨 INCOMING EMERGENCY',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    ),
  );
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) => Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity((1 - _ctrl.value) * 0.7),
            blurRadius: _ctrl.value * 12,
            spreadRadius: _ctrl.value * 3,
          ),
        ],
      ),
    ),
  );
}

// ─── Body Widgets ─────────────────────────────────────────────────────────────

class _PatientCard extends StatelessWidget {
  final String name;
  const _PatientCard({required this.name});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFC0392B).withOpacity(0.07),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ],
      border: Border.all(color: const Color(0xFFC0392B).withOpacity(0.08)),
    ),
    child: Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFDECEA),
            border: Border.all(
              color: const Color(0xFFC0392B).withOpacity(0.15),
              width: 1.5,
            ),
          ),
          child: Center(
            child: CustomPaint(
              size: const Size(24, 24),
              painter: _CrossPainter(),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PATIENT',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFBBBBBB),
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC0392B)
      ..style = PaintingStyle.fill;
    const r = 2.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.375, 0, size.width * 0.25, size.height),
        const Radius.circular(r),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height * 0.375, size.width, size.height * 0.25),
        const Radius.circular(r),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _InfoTile extends StatelessWidget {
  final Widget iconWidget;
  final Color iconBg;
  final String label;
  final String value;

  const _InfoTile({
    required this.iconWidget,
    required this.iconBg,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFC0392B).withOpacity(0.06),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
      border: Border.all(color: const Color(0xFFC0392B).withOpacity(0.07)),
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: iconWidget),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFBBBBBB),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ─── Icon Widgets ─────────────────────────────────────────────────────────────

class _AlertIcon extends StatelessWidget {
  const _AlertIcon();
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(22, 22), painter: _AlertPainter());
}

class _AlertPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC0392B)
      ..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawCircle(Offset(cx, cy), size.width / 2, paint);
    final white = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 2), width: 3, height: 8),
        const Radius.circular(1.5),
      ),
      white,
    );
    canvas.drawCircle(Offset(cx, cy + 6), 1.8, white);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _LocationIcon extends StatelessWidget {
  const _LocationIcon();
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(22, 22), painter: _LocationPainter());
}

class _LocationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2471D9)
      ..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final path = Path();
    path.addOval(
      Rect.fromCenter(
        center: Offset(cx, size.height * 0.38),
        width: size.width * 0.7,
        height: size.height * 0.7,
      ),
    );
    path.moveTo(cx - size.width * 0.18, size.height * 0.6);
    path.lineTo(cx, size.height * 0.95);
    path.lineTo(cx + size.width * 0.18, size.height * 0.6);
    canvas.drawPath(path, paint);
    canvas.drawCircle(
      Offset(cx, size.height * 0.38),
      size.width * 0.18,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
