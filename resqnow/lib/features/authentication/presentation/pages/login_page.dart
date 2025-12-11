import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Email & Password login
  Future<void> _loginWithEmail() async {
    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) context.go('/home');
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Login failed');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Google Sign-In
  Future<void> _loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      if (mounted) context.go('/home');
    } catch (e) {
      _showError('Google sign-in failed');
    }
  }

  // Phone login
  Future<void> _loginWithPhone() async {
    String phoneNumber = '';
    final parentContext = context;

    await showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Phone Login'),
        content: TextField(
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: '+91 9876543210'),
          onChanged: (value) => phoneNumber = value,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              if (!mounted) return;

              final enteredNumber = phoneNumber.trim();
              if (enteredNumber.isEmpty) {
                _showError('Enter a valid phone number.');
                return;
              }

              await _auth.verifyPhoneNumber(
                phoneNumber: enteredNumber,
                verificationCompleted: (credential) async {
                  await _auth.signInWithCredential(credential);
                  if (!mounted) return;
                  context.go('/home');
                },
                verificationFailed: (error) =>
                    _showError(error.message ?? 'Phone verification failed'),
                codeSent: (verificationId, _) {
                  if (!mounted) return;
                  _showOtpDialog(parentContext, verificationId);
                },
                codeAutoRetrievalTimeout: (_) {},
              );
            },
            child: const Text('Send OTP'),
          ),
        ],
      ),
    );
  }

  // OTP Dialog
  Future<void> _showOtpDialog(
    BuildContext parentContext,
    String verificationId,
  ) async {
    final otpController = TextEditingController();

    await showDialog<void>(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Enter OTP'),
        content: TextField(
          controller: otpController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '6-digit code'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final smsCode = otpController.text.trim();
              if (smsCode.length != 6) {
                _showError('Enter the 6-digit OTP.');
                return;
              }

              try {
                final credential = PhoneAuthProvider.credential(
                  verificationId: verificationId,
                  smsCode: smsCode,
                );
                await _auth.signInWithCredential(credential);

                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                if (!parentContext.mounted) return;
                parentContext.go('/home');
              } catch (_) {
                _showError('Invalid OTP, please try again.');
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );

    otpController.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Image.asset('lib/assets/images/logo.png', height: 160),
              const SizedBox(height: 16),

              // Heading
              const Text(
                "ResQnow",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 12),

              // Welcome Text
              const Text(
                "Welcome Back!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 32),

              _buildTextField(_emailController, "Email", Icons.email),
              const SizedBox(height: 16),
              _buildTextField(
                _passwordController,
                "Password",
                Icons.lock,
                isPassword: true,
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _loginWithEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Login",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "Or sign in with",
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _socialButton(
                    icon: FontAwesomeIcons.google,
                    label: "Google",
                    color: Colors.white,
                    textColor: Colors.black87,
                    onPressed: _loginWithGoogle,
                  ),
                  _socialButton(
                    icon: FontAwesomeIcons.phone,
                    label: "Phone",
                    color: Colors.teal.shade50,
                    textColor: Colors.teal,
                    onPressed: _loginWithPhone,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(color: Colors.black87),
                  ),
                  TextButton(
                    onPressed: () => context.go('/signup'),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.w600,
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black87),
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  Widget _socialButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: FaIcon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }
}
