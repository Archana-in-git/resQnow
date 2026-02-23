import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_controller.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late FocusNode nameFocus;
  late FocusNode emailFocus;
  late FocusNode passwordFocus;

  bool isPasswordVisible = false;
  bool isDrawerOpen = false;
  late AnimationController _drawerController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _shakeController;
  late Animation<Offset> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    nameFocus = FocusNode();
    emailFocus = FocusNode();
    passwordFocus = FocusNode();
    _drawerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(parent: _drawerController, curve: Curves.easeOut),
        );
    // Auto-start the animation
    _drawerController.forward();

    // Initialize shake animation
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(1, 0))
        .animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
        );
  }

  void _triggerShakeAnimation() {
    _shakeController.forward().then((_) {
      _shakeController.reset();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    _drawerController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Collapsible Header Drawer
                    SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.teal.shade600,
                              Colors.teal.shade500,
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            // Logo
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Image.asset(
                                'assets/images/logo.png',
                                height: 100,
                                width: 100,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Title
                            const Text(
                              'Join ResQnow',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Subtitle
                            Text(
                              'Create an account to get started',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Form Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Full Name
                          _buildModernField(
                            controller: nameController,
                            label: 'Full Name',
                            icon: Icons.person,
                            hint: 'Enter your full name',
                            focusNode: nameFocus,
                          ),
                          const SizedBox(height: 22),

                          // Email
                          _buildModernField(
                            controller: emailController,
                            label: 'Email Address',
                            icon: Icons.email,
                            hint: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                            focusNode: emailFocus,
                          ),
                          const SizedBox(height: 22),

                          // Password
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 4,
                                  bottom: 10,
                                ),
                                child: Text(
                                  'Password',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              TextFormField(
                                controller: passwordController,
                                focusNode: passwordFocus,
                                obscureText: !isPasswordVisible,
                                onChanged: (_) => setState(() {}),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Enter a strong password',
                                  labelStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                    color: Colors.teal,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.teal,
                                    ),
                                    onPressed: () => setState(
                                      () => isPasswordVisible =
                                          !isPasswordVisible,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                ),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Password is required'
                                    : null,
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Sign Up Button
                          AnimatedBuilder(
                            animation: _shakeAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: _shakeAnimation.value * 10,
                                child: child,
                              );
                            },
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed:
                                    context.watch<AuthController>().isLoading
                                    ? null
                                    : () async {
                                        if (!_formKey.currentState!
                                            .validate()) {
                                          _triggerShakeAnimation();
                                          return;
                                        }

                                        final scaffoldMessenger =
                                            ScaffoldMessenger.of(context);
                                        final auth = context
                                            .read<AuthController>();
                                        final user = await auth.signUpWithEmail(
                                          name: nameController.text.trim(),
                                          email: emailController.text.trim(),
                                          password: passwordController.text
                                              .trim(),
                                        );

                                        if (!mounted) return;

                                        if (user == null &&
                                            auth.errorMessage != null) {
                                          scaffoldMessenger.showSnackBar(
                                            SnackBar(
                                              content: Text(auth.errorMessage!),
                                            ),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  disabledBackgroundColor: Colors.teal
                                      .withValues(alpha: 0.6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                                child: context.watch<AuthController>().isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      )
                                    : const Text(
                                        'Create Account',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Login Link
                          Center(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Already have an account? ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: () => context.go('/login'),
                                      child: const Text(
                                        'Login here',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.teal,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    required FocusNode focusNode,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              letterSpacing: 0.2,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: hint,
            labelStyle: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(icon, color: Colors.teal),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          validator: (value) =>
              value == null || value.isEmpty ? '$label is required' : null,
        ),
      ],
    );
  }
}
