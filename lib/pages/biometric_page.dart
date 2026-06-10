import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/biometric_service.dart';
import 'login_page.dart';
import 'main_page.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final BiometricService _biometricService = BiometricService();
  bool biometricAvailable = false;
  bool isLoading = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkBiometricAvailability();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkBiometricAvailability();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      bool supported = await _biometricService.isDeviceSupported();
      List available = await _biometricService.getAvailableBiometrics();
      setState(() {
        biometricAvailable = supported && available.isNotEmpty;
      });
      if (supported && available.isEmpty) _showBiometricNotEnrolledDialog();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _showBiometricNotEnrolledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Biometric Not Set Up", style: TextStyle(color: Colors.white)),
        content: const Text(
          "No fingerprint is configured on this device. Go to settings to set it up.",
          style: TextStyle(color: Color(0xFF9E9E9E)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF757575))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openSettings();
            },
            child: const Text("Settings", style: TextStyle(color: Color(0xFF00C853))),
          ),
        ],
      ),
    );
  }

  void _openSettings() {
    final intent = AndroidIntent(
      action: 'android.settings.SETTINGS',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    intent.launch();
  }

  Future<void> _biometricAuthentification() async {
    if (!biometricAvailable) return;
    setState(() => isLoading = true);

    try {
      bool authenticated = await _biometricService.authenticate();
      if (authenticated) {
        final user = FirebaseAuth.instance.currentUser;
        await _playSuccessSound();
        if (!mounted) return;
        await _showSuccessDialog();
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => user != null ? const MainScreen() : const LoginPage(),
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _showSuccessDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF00C853).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Color(0xFF00C853), size: 38),
            ),
            const SizedBox(height: 16),
            const Text(
              "Authenticated!",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _playSuccessSound() async {
    await player.play(AssetSource('success.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo area
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFF00C853).withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: const Icon(Icons.mosque_rounded, color: Color(0xFF00C853), size: 34),
              ),

              const SizedBox(height: 24),

              const Text(
                "Quran App",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Verify your identity to continue",
                style: TextStyle(color: Color(0xFF616161), fontSize: 14),
              ),

              const SizedBox(height: 56),

              if (biometricAvailable) ...[
                // Pulsing fingerprint button
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isLoading ? 1.0 : _pulseAnimation.value,
                      child: child,
                    );
                  },
                  child: GestureDetector(
                    onTap: isLoading ? null : _biometricAuthentification,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00C853).withOpacity(0.1),
                        border: Border.all(
                          color: const Color(0xFF00C853).withOpacity(0.4),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00C853).withOpacity(0.15),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(30),
                              child: CircularProgressIndicator(
                                color: Color(0xFF00C853),
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Icon(
                              Icons.fingerprint_rounded,
                              size: 50,
                              color: Color(0xFF00C853),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  isLoading ? "Verifying..." : "Tap to authenticate",
                  style: const TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 14,
                    letterSpacing: 0.3,
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.fingerprint_rounded, color: Color(0xFF424242), size: 48),
                      const SizedBox(height: 12),
                      const Text(
                        "Biometric unavailable",
                        style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
