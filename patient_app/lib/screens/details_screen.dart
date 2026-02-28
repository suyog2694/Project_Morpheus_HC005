import 'package:flutter/material.dart';
import 'tracking_screen.dart';
import 'assignment_screen.dart';
import 'package:geolocator/geolocator.dart';
import '../models/emergency_model.dart';
import '../services/speech_service.dart';
import '../services/language_locale.dart';
import '../services/api_service.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen>
    with SingleTickerProviderStateMixin {
  String selectedLanguage = "English"; // default stays English
  final TextEditingController descriptionController = TextEditingController();

  final SpeechService speechService = SpeechService();
  bool isListening = false;

  final List<String> languages = ["English", "हिंदी", "मराठी", "తెలుగు"];

  final List<String> quickOptions = [
    "Heart Attack",
    "Bleeding",
    "Fracture",
    "Breathless",
    "Head Injury",
    "Burns",
  ];
  String? selectedQuick;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  Future<void> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please turn ON GPS location")),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Location detected:\nLat: ${position.latitude}, Lng: ${position.longitude}",
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    speechService.init();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void startListening() async {
    String locale = LanguageLocale.getLocale(selectedLanguage);

    if (!isListening) {
      setState(() => isListening = true);
      await speechService.startListening(
        localeId: locale,
        onResult: (text) {
          setState(() {
            descriptionController.text = text;
          });
        },
      );
    } else {
      speechService.stopListening();
      setState(() => isListening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F0F0),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel("What happened?"),
                  const SizedBox(height: 8),
                  _buildDescriptionField(),
                  const SizedBox(height: 14),
                  _sectionLabel("Quick Select"),
                  const SizedBox(height: 8),
                  _buildQuickOptions(),
                  const SizedBox(height: 14),
                  _buildVoiceCard(),
                  const SizedBox(height: 16),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                              "HSR Layout, Bengaluru",
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
                  const SizedBox(width: 10),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "Describe Condition",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Help us understand what happened",
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

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: Color(0xFF999999),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0E0E0), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD11A2A).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: descriptionController,
        maxLines: 4,
        style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
        onChanged: (value) {
          if (selectedQuick != null && value != selectedQuick) {
            setState(() => selectedQuick = null);
          }
        },
        decoration: const InputDecoration(
          hintText: "e.g. chest pain, severe accident occured...",
          hintStyle: TextStyle(color: Color(0xFFCCCCCC), fontSize: 13),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(14),
        ),
      ),
    );
  }

  Widget _buildQuickOptions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: quickOptions.map((label) {
        final isSelected = selectedQuick == label;
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedQuick = null;
                descriptionController.clear();
              } else {
                selectedQuick = label;
                descriptionController.text = label;
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFF0F0) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFD11A2A)
                    : const Color(0xFFE8E8E8),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? const Color(0xFFD11A2A)
                    : const Color(0xFF555555),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVoiceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        // ── Transparent red background ──
        color: const Color(0xFFD11A2A).withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD11A2A).withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD11A2A).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isListening ? "Listening..." : "Tap to describe by voice",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isListening
                  ? const Color(0xFFD11A2A)
                  : const Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: startListening,
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isListening)
                      Transform.scale(
                        scale: _pulseAnim.value,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFD11A2A).withOpacity(0.15),
                          ),
                        ),
                      ),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD11A2A), Color(0xFFFF4D5E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD11A2A).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isListening ? "Tap again to stop" : "Tap mic to speak",
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFFAAAAAA),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: languages.map((lang) {
              final isActive = selectedLanguage == lang;
              return GestureDetector(
                onTap: () => setState(() => selectedLanguage = lang),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFD11A2A).withOpacity(0.12)
                        : Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFFD11A2A)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    lang,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? const Color(0xFFD11A2A)
                          : const Color(0xFF777777),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD11A2A),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          shadowColor: const Color(0xFFD11A2A).withOpacity(0.4),
        ),
        icon: const Icon(Icons.local_hospital_rounded, size: 22),
        label: const Text(
          "SUBMIT EMERGENCY",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        onPressed: () async {
          // 1. Get real GPS position
          Position? position;
          try {
            bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
            if (!serviceEnabled) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please turn ON GPS location')),
              );
              return;
            }
            LocationPermission perm = await Geolocator.checkPermission();
            if (perm == LocationPermission.denied) {
              perm = await Geolocator.requestPermission();
            }
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
            );
          } catch (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Location error: $e')));
            return;
          }

          // 2. Call server API
          final desc = descriptionController.text.trim();
          final data = await ApiService.createEmergency(
            patientLat: position.latitude,
            patientLng: position.longitude,
            description: desc.isEmpty ? null : desc,
          );

          if (data == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to submit emergency. Please retry.'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          // 3. Build model from server response
          final emergency = EmergencyModel(
            id: data['request_id'] ?? 'UNKNOWN',
            status: data['status'] ?? 'SEARCHING_AMBULANCE',
            patientLat: position.latitude,
            patientLng: position.longitude,
            description: desc,
            language: selectedLanguage,
            ambulanceNumber: data['ambulance']?['ambulance_no'],
            driverName: data['ambulance']?['driver_name'],
            driverPhone: data['ambulance']?['driver_phone'],
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AssignmentScreen(emergency: emergency),
            ),
          );
        },
      ),
    );
  }
}
