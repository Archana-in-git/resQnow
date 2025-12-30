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

class _EmergencyPageState extends State<EmergencyPage>
    with TickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();

  bool _isListening = false;
  bool _speechAvailable = false;
  bool _micPermissionGranted = false;
  bool _showListeningPrompt = false;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _tts.awaitSpeakCompletion(true);

    // Pulse animation for SOS button
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

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
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.black87,
                    Colors.red.shade900.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),

            // Close button with enhanced styling
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => context.go('/home'),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),

            // Header section
            Positioned(
              top: 24,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const Text(
                    'EMERGENCY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'One Tap to Save',
                    style: TextStyle(
                      color: Colors.red.shade300,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Main SOS button with pulse animation
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pulse ring animation
                      ScaleTransition(
                        scale: Tween(
                          begin: 0.8,
                          end: 1.2,
                        ).animate(_pulseController),
                        child: Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.red.withAlpha(100),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      // Inner pulse ring
                      ScaleTransition(
                        scale: Tween(begin: 0.9, end: 1.1).animate(
                          CurvedAnimation(
                            parent: _pulseController,
                            curve: const Interval(0.2, 1.0),
                          ),
                        ),
                        child: Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.red.withAlpha(150),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      // Main SOS button
                      const SizedBox(
                        width: 200,
                        height: 200,
                        child: EmergencyButton(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Instruction text - unified section
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withAlpha(30),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'TAP THE BUTTON',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'OR SAY',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withAlpha(180),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'RESCUE ME NOW',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Voice recording animation
            if (_micPermissionGranted && _showListeningPrompt)
              Positioned(
                bottom: 160,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: Lottie.asset(
                      'assets/animation/Audio&Voice-A-002.json',
                      repeat: true,
                    ),
                  ),
                ),
              ),

            // Microphone permission denied message
            if (!_micPermissionGranted)
              Positioned(
                bottom: 160,
                left: 0,
                right: 0,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade900.withAlpha(100),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade400, width: 1),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.mic_off_rounded,
                        color: Colors.orange.shade300,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Microphone Permission Denied',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enable microphone in settings to use voice rescue',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.orange.shade200,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom section with First Aid button
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  const Text(
                    'Need guidance on first aid?',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => context.go('/home'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade600, Colors.red.shade800],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.shade600.withAlpha(100),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_hospital,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Get First Aid Help',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
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
}
