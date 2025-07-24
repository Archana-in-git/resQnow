import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

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
                const Center(
                  child: Text(
                    "ResQnow",
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

                _buildTextField(emailController, "Email", Icons.email,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),

IntlPhoneField(
  controller: phoneController,
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
  dropdownIcon: const Icon(Icons.arrow_drop_down, color: Colors.teal),
  style: const TextStyle(color: Colors.black87),
  flagsButtonMargin: const EdgeInsets.only(left: 8),
  dropdownTextStyle: const TextStyle(color: Colors.black87),
  onChanged: (phone) {
    phoneController.text = phone.completeNumber;
    selectedCountryCode = phone.countryCode;
  },
),

                TextFormField(
                  controller: dobController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Date of Birth (DD/MM/YYYY)",
                    labelStyle: const TextStyle(color: Colors.black87),
                    prefixIcon: const Icon(Icons.calendar_today, color: Colors.teal),
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
                      dobController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                    }
                  },
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Gender",
                    labelStyle: const TextStyle(color: Colors.black87),
                    prefixIcon: const Icon(Icons.transgender, color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  dropdownColor: Colors.grey[100],
                  value: selectedGender,
                  items: const [
                    DropdownMenuItem(value: "Male", child: Text("Male")),
                    DropdownMenuItem(value: "Female", child: Text("Female")),
                    DropdownMenuItem(value: "Other", child: Text("Other")),
                  ],
                  onChanged: (value) => setState(() => selectedGender = value),
                  validator: (value) =>
                      value == null ? 'Please select gender' : null,
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 16),

                _buildTextField(addressController, "Address", Icons.home,
                    maxLines: 2),
                const SizedBox(height: 16),

                TextFormField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: const TextStyle(color: Colors.black87),
                    prefixIcon: const Icon(Icons.lock, color: Colors.teal),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        color: Colors.teal,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required field' : null,
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Handle signup
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
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
                      onTap: () => Navigator.pushNamed(context, '/login'),
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
    bool isPassword = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black87),
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Required field' : null,
    );
  }
}
