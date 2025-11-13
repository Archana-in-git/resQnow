import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/auth_controller.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();
  final dobController = TextEditingController();

  String? selectedGender;
  String selectedCountryCode = '+91';
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset('lib/assets/images/logo.png', height: 160),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    "ResQNow",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _buildTextField(nameController, "Full Name", Icons.person),
                const SizedBox(height: 16),

                _buildTextField(
                  emailController,
                  "Email",
                  Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                IntlPhoneField(
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: const TextStyle(color: Colors.black87),
                    prefixIcon: const Icon(Icons.phone, color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  initialCountryCode: 'IN',
                  dropdownIcon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.teal,
                  ),
                  onChanged: (phone) {
                    phoneController.text = phone.number;
                    selectedCountryCode = phone.countryCode;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  addressController,
                  "Address",
                  Icons.location_on,
                ),

                TextFormField(
                  controller: dobController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Date of Birth (DD/MM/YYYY)",
                    prefixIcon: const Icon(
                      Icons.calendar_today,
                      color: Colors.teal,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      dobController.text = DateFormat(
                        'dd/MM/yyyy',
                      ).format(pickedDate);
                    }
                  },
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Gender",
                    prefixIcon: const Icon(
                      Icons.transgender,
                      color: Colors.teal,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  value: selectedGender,
                  items: const [
                    DropdownMenuItem(value: "Male", child: Text("Male")),
                    DropdownMenuItem(value: "Female", child: Text("Female")),
                    DropdownMenuItem(value: "Other", child: Text("Other")),
                  ],
                  onChanged: (value) => setState(() => selectedGender = value),
                  validator: (value) =>
                      value == null ? 'Please select gender' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock, color: Colors.teal),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.teal,
                      ),
                      onPressed: () => setState(
                        () => isPasswordVisible = !isPasswordVisible,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authController.isLoading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;

                            final user = await authController.signUpWithEmail(
                              name: nameController.text.trim(),
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                            );

                            if (user != null) {
                              // ✅ Add extended user details
                              final firestore = FirebaseFirestore.instance;
                              await firestore
                                  .collection('users')
                                  .doc(user.uid)
                                  .set({
                                    'phone':
                                        '$selectedCountryCode${phoneController.text.trim()}',
                                    'dob': dobController.text.trim(),
                                    'gender': selectedGender,
                                    'address': addressController.text.trim(),
                                  }, SetOptions(merge: true));

                              final role = await authController
                                  .getCurrentUserRole();
                              if (role == 'admin') {
                                context.go('/adminDashboard');
                              } else {
                                context.go('/home');
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    authController.errorMessage ??
                                        "Signup failed",
                                  ),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: authController.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Sign Up",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.black87),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: const Text(
                        "Login",
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
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Required field' : null,
    );
  }
}
