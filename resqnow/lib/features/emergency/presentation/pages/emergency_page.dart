import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:resqnow/features/emergency/presentation/widgets/emergency_button.dart';
import 'package:resqnow/features/emergency/presentation/controllers/emergency_controller.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();

  bool _isListening = false;
  bool _speechAvailable = false;
  bool _micPermissionGranted = false;
  bool _showListeningPrompt = false;

  @override
  void initState() {
    super.initState();
    _tts.awaitSpeakCompletion(true);
    _initVoiceSystem();
  }

  Future<void> _initVoiceSystem() async {
    await Future.delayed(const Duration(milliseconds: 200));

    var micStatus = PermissionStatus.granted;
    if (Platform.isAndroid || Platform.isIOS) {
      micStatus = await Permission.microphone.request();
    }

    if (!micStatus.isGranted) {
      if (mounted) {
        setState(() {
          _micPermissionGranted = false;
          _showListeningPrompt = false;
        });
      }
      return;
    }

    if (mounted) setState(() => _micPermissionGranted = true);

    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') _restartListening();
      },
    );

    if (_speechAvailable) {
      _startListeningLoop();
    }
  }

  Future<void> _playBeep() async {
    await _audioPlayer.play(AssetSource('sounds/beep.wav'));
  }

  Future<void> _startListeningLoop() async {
    if (mounted) {
      setState(() => _showListeningPrompt = true);
    }

    await _playBeep();
    await _tts.speak("Say 'Rescue me now' to trigger emergency call");
    await _tts.awaitSpeakCompletion(true);
    _startListening();
  }

  Future<void> _startListening() async {
    if (_isListening || !_speechAvailable || !_micPermissionGranted) return;

    setState(() => _isListening = true);

    await _speech.listen(
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 10),
      onResult: (result) {
        if (!result.finalResult) return;

        final command = result.recognizedWords.trim().toLowerCase();
        if (command == "rescue me now") {
          _triggerEmergencyCall();
        }
      },
    );
  }

  Future<void> _restartListening() async {
    if (!_isListening) return;
    _isListening = false;
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) _startListening();
  }

  Future<void> _triggerEmergencyCall() async {
    await _speech.stop();
    await _tts.speak("Calling emergency services...");

    EmergencyController.handleEmergencyCall();

    setState(() {
      _isListening = false;
      _showListeningPrompt = false;
    });
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
            // 🔴 YOUR ORIGINAL UI — UNCHANGED
            const Center(child: EmergencyButton()),

            // Close button
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

            // 🔵 Voice command banner + animation
            if (_micPermissionGranted && _showListeningPrompt)
              Positioned(
                bottom: 180,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Lottie.asset(
                        'assets/animation/Audio&Voice-A-002.json',
                        repeat: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '🎙️ Listening for “Rescue me now”...',
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ],
                ),
              ),

            if (!_micPermissionGranted)
              Positioned(
                bottom: 170,
                left: 0,
                right: 0,
                child: const Center(
                  child: Text(
                    '🎤 Microphone permission denied.\nEnable it in settings to use voice rescue.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.redAccent, fontSize: 14),
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
