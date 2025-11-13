import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isListening = false;
  bool _speechAvailable = false;
  bool _micPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _initVoiceSystem();
  }

  Future<void> _initVoiceSystem() async {
    // 1️⃣ Request mic permission
    final status = await Permission.microphone.request();

    if (status.isGranted) {
      setState(() => _micPermissionGranted = true);
      await _initializeSpeech();
      _startListeningLoop();
    } else {
      setState(() => _micPermissionGranted = false);
    }
  }

  Future<void> _initializeSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        debugPrint('Speech status: $status');
        if (status == 'done' || status == 'notListening') {
          _restartListening();
        }
      },
      onError: (error) => debugPrint('Speech error: $error'),
    );
  }

  Future<void> _playBeepSound() async {
    await _audioPlayer.play(
      AssetSource('sounds/beep.wav'),
    ); // 🔔 Add this file in assets
  }

  Future<void> _startListeningLoop() async {
    if (!_speechAvailable) return;

    await _playBeepSound(); // alert sound
    await _tts.speak("Say 'Rescue me now' to trigger emergency call");
    _startListening();
  }

  Future<void> _startListening() async {
    if (_isListening) return;
    setState(() => _isListening = true);

    await _speech.listen(
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      onResult: (result) {
        final spoken = result.recognizedWords.toLowerCase();
        debugPrint("🗣️ Heard: $spoken");

        if (spoken.contains("rescue me now")) {
          _triggerEmergencyCall();
        }
      },
    );
  }

  Future<void> _restartListening() async {
    if (!_isListening) return;
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) _startListening();
  }

  Future<void> _triggerEmergencyCall() async {
    await _speech.stop();
    await _tts.speak("Calling emergency services...");

    const emergencyNumber = '108'; // or your stored number
    final Uri callUri = Uri(scheme: 'tel', path: emergencyNumber);
    await launchUrl(callUri);

    setState(() => _isListening = false);
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Centered Emergency Button (already present)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🔴 Replace with your EmergencyButton widget
                  GestureDetector(
                    onTap: _triggerEmergencyCall,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.6),
                            blurRadius: 25,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'SOS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  if (_micPermissionGranted)
                    Column(
                      children: [
                        if (_isListening)
                          Column(
                            children: [
                              // 🎵 Lottie animation for listening
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: Lottie.asset(
                                  'assets/animations/voice_wave.json',
                                  repeat: true,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "🎙️ Listening for 'Rescue me now'...",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        else
                          const Text(
                            "Voice system inactive",
                            style: TextStyle(color: Colors.white38),
                          ),
                      ],
                    )
                  else
                    const Text(
                      "🎙️ Microphone permission denied.\nPlease enable it in settings to use voice rescue.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.redAccent),
                    ),
                ],
              ),
            ),

            // Title and close icon
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => context.go('/categories'),
                child: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),

            const Positioned(
              top: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'EMERGENCY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

            const Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'If you need help, say “Rescue me now”',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ),

            Positioned(
              bottom: 40,
              left: 32,
              right: 32,
              child: ElevatedButton(
                onPressed: () => context.go('/categories'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withAlpha(40),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.white30),
                  ),
                ),
                child: const Text(
                  'Get First Aid Help',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
