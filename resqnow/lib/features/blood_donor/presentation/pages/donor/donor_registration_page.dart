// lib/features/blood_donor/presentation/pages/donor/donor_registration_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:resqnow/features/blood_donor/presentation/controllers/donor_registration_controller.dart';
import 'package:lottie/lottie.dart';

class DonorRegistrationPage extends StatefulWidget {
  const DonorRegistrationPage({super.key});

  @override
  State<DonorRegistrationPage> createState() => _DonorRegistrationPageState();
}

class _DonorRegistrationPageState extends State<DonorRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final dobCtrl = TextEditingController();

  String gender = "Male";
  String bloodGroup = "A+";
  List<String> selectedConditions = [];
  String selectedCountryCode = '+91';

  bool noneSelected = false;

  DateTime? selectedDob;

  final List<String> genderList = ["Male", "Female", "Other"];
  final List<String> bloodGroups = [
    "A+",
    "A-",
    "B+",
    "B-",
    "O+",
    "O-",
    "AB+",
    "AB-",
  ];

  final List<String> conditions = [
    "Diabetes",
    "Blood Pressure",
    "Thyroid",
    "Asthma",
    "None",
  ];

  @override
  void dispose() {
    nameCtrl.dispose();
    ageCtrl.dispose();
    phoneCtrl.dispose();
    notesCtrl.dispose();
    addressCtrl.dispose();
    dobCtrl.dispose();
    super.dispose();
  }

  bool get hasValidLocation =>
      addressCtrl.text.trim().isNotEmpty; // address required

  bool get hasValidCondition {
    final hasOther = selectedConditions.any((c) => c != "None");
    final hasNone = selectedConditions.contains("None");
    final hasNotes = notesCtrl.text.trim().isNotEmpty;
    return hasNone || hasOther || hasNotes;
  }

  void _onConditionTap(String c) {
    setState(() {
      if (c == "None") {
        final already = selectedConditions.contains("None");
        if (already) {
          selectedConditions.remove("None");
          noneSelected = false;
        } else {
          selectedConditions = ["None"];
          noneSelected = true;
          notesCtrl.clear();
        }
      } else {
        final selected = selectedConditions.contains(c);
        if (selected) {
          selectedConditions.remove(c);
        } else {
          if (selectedConditions.contains("None")) {
            selectedConditions.remove("None");
            noneSelected = false;
          }
          selectedConditions.add(c);
        }
      }
    });
  }

  Future<void> _handleDetectLocation(
    DonorRegistrationController controller,
  ) async {
    try {
      await controller.fetchLocation();

      if (controller.address.isNotEmpty) {
        setState(() => addressCtrl.text = controller.address);
      } else {
        _showLocationErrorCard();
      }
    } catch (_) {
      _showLocationErrorCard();
    }
  }

  void _showLocationErrorCard() {
    showModalBottomSheet(
      context: context,
      builder: (c) {
        return Container(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off, size: 50, color: Colors.orange),
              const SizedBox(height: 12),
              const Text(
                "We couldn't detect your location",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Location is required so nearby hospitals and recipients can find you quickly. You can try again or enable permission.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        final controller = context
                            .read<DonorRegistrationController>();
                        _handleDetectLocation(controller);
                      },
                      child: const Text("Try Again"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Enable Permissions"),
                            content: const Text(
                              "Open device settings and enable location permission for this app.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text("Open Settings"),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Register donor ---
  Future<void> _onRegisterPressed(
    DonorRegistrationController controller,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (!_formKey.currentState!.validate()) return;

    if (selectedDob == null) return; // guarded by canSubmit

    final computedAge = _calculateAge(selectedDob!);
    if (computedAge <= 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Invalid age calculated from DOB.")),
      );
      return;
    }
    ageCtrl.text = computedAge.toString();

    if (!hasValidLocation) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Please detect or enter address.")),
      );
      return;
    }

    if (!hasValidCondition) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            "Select at least one medical condition, choose 'None', or add notes.",
          ),
        ),
      );
      return;
    }

    final success = await controller.register(
      name: nameCtrl.text.trim(),
      age: computedAge,
      gender: gender,
      bloodGroup: bloodGroup,
      phone: '$selectedCountryCode${phoneCtrl.text.trim()}',
      conditions: selectedConditions,
      notes: notesCtrl.text.trim(),
      addressInput: addressCtrl.text.trim(),
      latitudeInput: controller.latitude,
      longitudeInput: controller.longitude,
    );

    if (!mounted) return;

    if (success) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: SizedBox(
            height: 170,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.check_circle, size: 64, color: Colors.green),
                SizedBox(height: 12),
                Text(
                  "Registration Successful!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  "Thank you — your details have been recorded.",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );

      if (!mounted) return;
      navigator.pop(true);
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            controller.errorMessage ?? "Registration failed. Try again.",
          ),
        ),
      );
    }
  }

  Future<void> _onSelectDob() async {
    final now = DateTime.now();
    final initialDate =
        selectedDob ?? DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        selectedDob = picked;
        dobCtrl.text = DateFormat('dd MMM yyyy').format(picked);
        ageCtrl.text = _calculateAge(picked).toString();
      });
    }
  }

  int _calculateAge(DateTime dob) {
    final today = DateTime.now();
    var age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  TextStyle _inputTextStyle(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    return base.copyWith(color: Colors.black);
  }

  TextStyle _labelTextStyle(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    return base.copyWith(color: Colors.grey.shade700);
  }

  // =====================================================================
  // BUILD METHOD — MODERN ONBOARDING UI
  // =====================================================================
  @override
  Widget build(BuildContext context) {
    return Consumer<DonorRegistrationController>(
      builder: (context, controller, _) {
        if (controller.address.isNotEmpty &&
            addressCtrl.text.trim().isEmpty &&
            controller.latitude != null) {
          addressCtrl.text = controller.address;
        }

        final notesEnabled = !noneSelected;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final primaryColor = AppColors.primary;

        // Compute button enabled state
        final canSubmit = !controller.isLoading &&
            nameCtrl.text.trim().isNotEmpty &&
            selectedDob != null &&
            hasValidLocation &&
            hasValidCondition &&
            phoneCtrl.text.trim().isNotEmpty;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top bar (replaced)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: theme.iconTheme.color,
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Become a Donor",
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: colorScheme.onSurface,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  SizedBox(
                                    height: 34,
                                    width: 34,
                                    child: Lottie.asset(
                                      'assets/animation/giving-hand.json',
                                      animate: true,
                                      repeat: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Your contribution can save lives.",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodyMedium?.color ??
                                      colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // LOCATION CARD
                    GestureDetector(
                      onTap: controller.isLoading
                          ? null
                          : () => _handleDetectLocation(controller),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: primaryColor.withAlpha(28),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromRGBO(0, 0, 0, 0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.my_location,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Your Location",
                                    style: _labelTextStyle(context).copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    controller.latitude == null
                                        ? "Tap to detect your current location"
                                        : controller.address,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 15.5,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: controller.latitude == null
                                          ? AppColors.warning.withAlpha(40)
                                          : AppColors.success.withAlpha(40),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      controller.latitude == null
                                          ? "Required"
                                          : "Detected",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: controller.latitude == null
                                            ? AppColors.warning
                                            : AppColors.success,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (controller.isLoading)
                              const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // PERSONAL DETAILS
                    _sectionHeader("Your Details"),
                    const SizedBox(height: 12),

                    // Enable field change tracking for live button state
                    _modernInput("Full Name", Icons.person, nameCtrl),
                    const SizedBox(height: 12),
                    _modernInput(
                      "Date of Birth",
                      Icons.calendar_month,
                      dobCtrl,
                      readOnly: true,
                      onTap: _onSelectDob,
                    ),
                    const SizedBox(height: 12),
                    _modernInput(
                      "Age",
                      Icons.cake_outlined,
                      ageCtrl,
                      keyboardType: TextInputType.number,
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),

                    _genderSelector(),
                    const SizedBox(height: 20),

                    _bloodGroupSelector(),
                    const SizedBox(height: 20),

                    Container(
                      decoration: _boxDecoration(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: IntlPhoneField(
                        controller: phoneCtrl,
                        initialCountryCode: 'IN',
                        style: _inputTextStyle(context),
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.phone, color: primaryColor),
                          labelStyle: _labelTextStyle(context),
                        ),
                        dropdownIcon: Icon(
                          Icons.arrow_drop_down,
                          color: primaryColor,
                        ),
                        onChanged: (phone) {
                          selectedCountryCode = phone.countryCode;
                          phoneCtrl.text = phone.number;
                          setState(() {}); // reflect in canSubmit
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 12),

                    // LOCATION
                  
                    Text(
                      "Location",
                      style: _labelTextStyle(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      decoration: _boxDecoration(),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: primaryColor),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextField(
                              controller: addressCtrl,
                              minLines: 1,
                              maxLines: 2,
                              readOnly: true,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Your current location",
                                hintStyle: _labelTextStyle(context),
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: _inputTextStyle(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // MEDICAL CONDITIONS
                    Text(
                      "Medical Conditions",
                      style: _labelTextStyle(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 64),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 18, // increased from 14
                      ),
                      decoration: _boxDecoration(),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: conditions.map((c) {
                          final selected = selectedConditions.contains(c);
                          final disabled = noneSelected && c != "None";
                          final chipBackground = selected
                              ? AppColors.primary.withOpacity(0.12)
                              : disabled
                                  ? theme.disabledColor.withOpacity(0.10)
                                  : theme.colorScheme.surfaceContainerHighest;
                          final chipBorderColor = selected
                              ? AppColors.primary.withOpacity(0.80)
                              : disabled
                                  ? theme.disabledColor.withOpacity(0.30)
                                  : theme.dividerColor;
                          final chipTextColor = selected
                              ? AppColors.primary
                              : disabled
                                  ? theme.disabledColor
                                  : theme.textTheme.bodyMedium?.color;

                          return GestureDetector(
                            onTap: disabled ? null : () => _onConditionTap(c),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 240),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: chipBackground,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: chipBorderColor),
                              ),
                              child: Text(
                                c,
                                style: TextStyle(
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: chipTextColor,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Notes
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, // reduced from 18
                        vertical: 8,   // reduced from 14
                      ),
                      decoration: _boxDecoration(dimmed: !notesEnabled),
                      child: TextField(
                        controller: notesCtrl,
                        enabled: notesEnabled,
                        maxLines: 2,
                        style: _inputTextStyle(context),
                        onChanged: (_) => setState(() {}), // reflect in canSubmit
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: noneSelected
                              ? "Other (disabled)"
                              : "Other (optional)",
                          hintStyle: _labelTextStyle(context),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // SUBMIT BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: canSubmit
                            ? () => _onRegisterPressed(controller)
                            : null,
                        child: controller.isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: colorScheme.onPrimary,
                                ),
                              )
                            : const Text(
                                "Register as Donor",
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ======================================================
  // HELPER WIDGETS
  // ======================================================

  Widget _sectionHeader(String text) {
    final base =
        Theme.of(context).textTheme.titleMedium ?? const TextStyle(fontSize: 20);
    return Text(
      text,
      style: base.copyWith(
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade700,
      ),
    );
  }

  BoxDecoration _boxDecoration({bool dimmed = false}) {
    final theme = Theme.of(context);
    return BoxDecoration(
      color: dimmed
          ? theme.colorScheme.surfaceContainerHighest
          : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: const Color.fromRGBO(0, 0, 0, 0.05),
          blurRadius: 10,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  Widget _modernInput(
    String label,
    IconData icon,
    TextEditingController ctrl, {
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final primaryColor = AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: _boxDecoration(),
      child: Row(
        children: [
          Icon(icon, color: primaryColor),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: ctrl,
              keyboardType: keyboardType,
              readOnly: readOnly,
              onTap: onTap,
              onChanged: (_) => setState(() {}), // reflect in canSubmit
              decoration: InputDecoration(
                hintText: label,
                border: InputBorder.none,
                hintStyle: _labelTextStyle(context),
              ),
              style: _inputTextStyle(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _genderSelector() {
    final theme = Theme.of(context);
    final primaryColor = AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Gender",
          style: _labelTextStyle(context).copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: _boxDecoration(),
          child: Column(
            children: genderList.map((g) {
              return RadioListTile<String>(
                value: g,
                groupValue: gender,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => gender = value);
                  }
                },
                activeColor: primaryColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 2,
                ),
                dense: true,
                title: Text(g, style: theme.textTheme.bodyMedium),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _bloodGroupSelector() {
    final theme = Theme.of(context);
    final primaryColor = AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Blood Group",
          style: _labelTextStyle(context).copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18, // increased from 14
          ),
          decoration: _boxDecoration(),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: bloodGroups.map((b) {
              final selected = bloodGroup == b;

              return GestureDetector(
                onTap: () => setState(() => bloodGroup = b),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? primaryColor.withAlpha(40)
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: selected ? primaryColor : theme.dividerColor,
                    ),
                  ),
                  child: Text(
                    b,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                      color: selected
                          ? primaryColor
                          : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
