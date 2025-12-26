// lib/features/blood_donor/presentation/pages/donor/donor_registration_page.dart

import 'dart:convert';
import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:resqnow/features/blood_donor/presentation/controllers/donor_registration_controller.dart';
import 'package:resqnow/features/blood_donor/presentation/controllers/donor_profile_controller.dart';
import 'package:go_router/go_router.dart';

// New imports for image & firebase
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crop_your_image/crop_your_image.dart';

class DonorRegistrationPage extends StatefulWidget {
  const DonorRegistrationPage({super.key});

  @override
  State<DonorRegistrationPage> createState() => _DonorRegistrationPageState();
}

class _DonorRegistrationPageState extends State<DonorRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  // basic personal controllers
  final nameCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  final dobCtrl = TextEditingController();

  // new permanent address controllers
  String? selectedCountryName = "India"; // default
  String selectedCountryIsoCode = "IN"; // default iso
  String selectedCountryDialCode =
      "+91"; // default dial code used for phone submit

  String? selectedState;
  String? selectedDistrict;
  String? selectedCity; // selected from dropdown
  final cityManualCtrl = TextEditingController(); // manual fallback
  final pincodeCtrl = TextEditingController();

  // NON-INDIA minimal fields (Option A)
  final nonIndiaAddressCtrl = TextEditingController();
  final nonIndiaCityCtrl = TextEditingController();
  final nonIndiaProvinceCtrl = TextEditingController();
  final nonIndiaPincodeCtrl = TextEditingController();

  // consent to share realtime last_seen (timestamp-only)
  bool shareLastSeen = false;

  String gender = "Male";
  String bloodGroup = "A+";
  List<String> selectedConditions = [];
  String selectedCountryCode =
      '+91'; // used with phone number (keeps compatibility)

  bool noneSelected = false;

  DateTime? selectedDob;

  // Image state
  File? _pickedImageFile;
  bool _isUploadingImage = false;
  String? _uploadedImageUrl; // final download url (optional)

  // Lists
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

  // -------------------------
  // JSON-loaded address data
  // -------------------------
  List<String> statesList = []; // loaded from states_india.json (names)
  Map<String, dynamic>? keralaCities; // loaded from cities_kerala.json
  List<String> keralaDistricts = []; // loaded from districts_kerala.json
  bool _addressDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAddressData();
    _checkIfAlreadyDonor();
  }

  /// Check if user is already registered as a donor
  Future<void> _checkIfAlreadyDonor() async {
    if (!mounted) return;

    try {
      final profileController = context.read<DonorProfileController>();
      final isDonor = await profileController.isDonor();

      if (isDonor && mounted) {
        // User is already a donor, show dialog and redirect
        _showAlreadyDonorDialog();
      }
    } catch (e) {
      debugPrint("Error checking donor status: $e");
    }
  }

  /// Dialog shown when user is already a registered donor
  void _showAlreadyDonorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.white,
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green.shade600),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Already Registered',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          'You are already registered as a blood donor! View your donor profile to see your details and manage your availability.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              context.go('/donor-profile');
            },
            child: const Text('View Profile'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    ageCtrl.dispose();
    phoneCtrl.dispose();
    notesCtrl.dispose();
    dobCtrl.dispose();
    cityManualCtrl.dispose();
    pincodeCtrl.dispose();

    nonIndiaAddressCtrl.dispose();
    nonIndiaCityCtrl.dispose();
    nonIndiaProvinceCtrl.dispose();
    nonIndiaPincodeCtrl.dispose();

    super.dispose();
  }

  // Updated validation: support India and non-India minimal fields
  bool get hasValidLocationPermanent {
    if (selectedCountryName == "India") {
      // permanent address mandatory for India
      return (selectedState != null && selectedDistrict != null) &&
          (selectedCity != null || cityManualCtrl.text.trim().isNotEmpty);
    } else {
      // non-India: require minimal fields (address line + city)
      final addr = nonIndiaAddressCtrl.text.trim();
      final city = nonIndiaCityCtrl.text.trim();
      return addr.isNotEmpty && city.isNotEmpty;
    }
  }

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

  // === Register donor ===
  Future<void> _onRegisterPressed(
    DonorRegistrationController controller,
  ) async {
    // --------------------------
    // Validate all form fields
    // --------------------------
    if (!_formKey.currentState!.validate()) return;

    if (!mounted) return;

    // Get messenger while mounted to avoid context async gap warnings
    // ignore: use_build_context_synchronously
    final messenger = ScaffoldMessenger.of(context);

    if (selectedDob == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Please choose Date of Birth.")),
      );
      return;
    }

    // AGE AUTO-CALCULATED FROM DOB
    final computedAge = _calculateAge(selectedDob!);
    if (computedAge <= 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Invalid age calculated.")),
      );
      return;
    }
    ageCtrl.text = computedAge.toString();

    if (!hasValidLocationPermanent) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Please enter your permanent address.")),
      );
      return;
    }

    if (!hasValidCondition) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Select a medical condition or choose 'None'."),
        ),
      );
      return;
    }

    // --------------------------
    // Assemble Permanent Address
    // --------------------------
    String assembledAddress = "";
    Map<String, String> components = {};

    if (selectedCountryName == "India") {
      final cityValue = selectedCity ?? "";
      final pin = pincodeCtrl.text.trim();

      assembledAddress = [
        cityValue,
        selectedDistrict ?? "",
        selectedState ?? "",
        pin,
      ].where((x) => x.isNotEmpty).join(", ");

      components = {
        "country": "India",
        "state": selectedState ?? "",
        "district": selectedDistrict ?? "",
        "city": cityValue,
        "pincode": pin,
      };
    } else {
      final addr = nonIndiaAddressCtrl.text.trim();
      final city = nonIndiaCityCtrl.text.trim();
      final prov = nonIndiaProvinceCtrl.text.trim();
      final pin = nonIndiaPincodeCtrl.text.trim();

      assembledAddress = [
        addr,
        city,
        prov,
        pin,
      ].where((x) => x.isNotEmpty).join(", ");

      components = {
        "country": selectedCountryName ?? "",
        "address_line": addr,
        "city": city,
        "province": prov,
        "pincode": pin,
      };
    }

    // --------------------------
    // If user picked image but not yet uploaded -> upload now
    // --------------------------
    if (_pickedImageFile != null && _uploadedImageUrl == null) {
      setState(() => _isUploadingImage = true);
      try {
        final url = await _uploadImageToFirebase(_pickedImageFile!);
        _uploadedImageUrl = url;
      } catch (e) {
        debugPrint("Image upload failed: $e");
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(
            content: Text("Profile image upload failed. Try again."),
          ),
        );
        setState(() => _isUploadingImage = false);
        return;
      }
      setState(() => _isUploadingImage = false);
    }

    // --------------------------
    // Create lastSeen timestamp ONLY (no GPS)
    // --------------------------
    final lastSeenData = shareLastSeen
        ? {"timestamp": DateTime.now().toUtc().toIso8601String()}
        : null;

    // --------------------------
    // CALL register()
    // --------------------------
    final registrationData = {
      "name": nameCtrl.text.trim(),
      "age": computedAge,
      "gender": gender,
      "bloodGroup": bloodGroup,
      "phone": "$selectedCountryCode${phoneCtrl.text.trim()}",
      "conditions": selectedConditions,
      "notes": notesCtrl.text.trim(),
      "addressInput": assembledAddress,
      "permanentAddressComponents": components,
      "lastSeen": lastSeenData,
      "profileImageUrl": _uploadedImageUrl,
    };

    print("🩸🩸🩸 DONOR REGISTRATION PAYLOAD START");
    print(registrationData);
    print("🩸🩸🩸 DONOR REGISTRATION PAYLOAD END");

    final success = await controller.register(
      name: nameCtrl.text.trim(),
      age: computedAge,
      gender: gender,
      bloodGroup: bloodGroup,
      phone: "$selectedCountryCode${phoneCtrl.text.trim()}",
      conditions: selectedConditions,
      notes: notesCtrl.text.trim(),
      addressInput: assembledAddress,
      permanentAddressComponents: components,
      lastSeen: lastSeenData,
      profileImageUrl: _uploadedImageUrl,
    );

    if (!mounted) return;

    // --------------------------
    // SUCCESS DIALOG
    // --------------------------
    if (success) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: SizedBox(
            height: 160,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.check_circle, size: 64, color: Colors.green),
                SizedBox(height: 10),
                Text(
                  "Registration Successful!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text("Your donor profile has been created."),
              ],
            ),
          ),
        ),
      );

      if (!mounted) return;
      context.go('/donor-profile');
    } else {
      if (!mounted) return;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return base.copyWith(color: isDark ? Colors.white : Colors.black);
  }

  TextStyle _labelTextStyle(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return base.copyWith(
      color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
    );
  }

  Future<void> _loadAddressData() async {
    try {
      // load states file (expects format: { "states": [ { "code": "AP", "name": "Andhra Pradesh" }, ... ] })
      final statesStr = await rootBundle.loadString(
        'assets/data/states_india.json',
      );
      final statesJson = json.decode(statesStr) as Map<String, dynamic>?;
      final rawStates = (statesJson ?? {})['states'] as List<dynamic>?;

      if (rawStates != null && rawStates.isNotEmpty) {
        statesList =
            rawStates
                .map(
                  (e) => (e is Map && e.containsKey('name'))
                      ? e['name'].toString()
                      : e.toString(),
                )
                .toList()
              ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      }

      // load kerala districts
      final districtsStr = await rootBundle.loadString(
        'assets/data/districts_kerala.json',
      );
      final districtsJson = json.decode(districtsStr) as Map<String, dynamic>?;
      final rawDistricts = (districtsJson ?? {})['districts'] as List<dynamic>?;
      if (rawDistricts != null && rawDistricts.isNotEmpty) {
        keralaDistricts = rawDistricts.map((e) => e.toString()).toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      }

      // load kerala cities
      final citiesStr = await rootBundle.loadString(
        'assets/data/cities_kerala.json',
      );
      final citiesJson = json.decode(citiesStr) as Map<String, dynamic>?;
      // Expecting: { "Kerala": { "Alappuzha": [...], "Ernakulam": [...] } }
      if (citiesJson != null && citiesJson.containsKey('Kerala')) {
        keralaCities =
            (citiesJson['Kerala'] as Map?)?.map(
              (k, v) => MapEntry(
                k.toString(),
                List<String>.from(v as List<dynamic>? ?? []),
              ),
            ) ??
            {};
        // Sort each district's city list
        keralaCities?.forEach((k, v) {
          final list = List<String>.from(v);
          list.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
          keralaCities![k] = list;
        });
      }

      setState(() {
        _addressDataLoaded = true;
      });
    } catch (e) {
      debugPrint('Failed to load address JSON: $e');
      setState(() {
        _addressDataLoaded = true;
      });
    }
  }

  // ---------- IMAGE PICK & UPLOAD LOGIC ----------
  Future<void> _showImageSourceSheet() async {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_pickedImageFile != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Remove photo'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _pickedImageFile = null;
                      _uploadedImageUrl = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (picked == null) return;

      final imageBytes = await picked.readAsBytes();
      final cropController = CropController();

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          final isDarkDialog = Theme.of(context).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: isDarkDialog
                ? const Color(0xFF1E1E1E)
                : Colors.white,
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 420,
              child: Column(
                children: [
                  Expanded(
                    child: Crop(
                      controller: cropController,
                      image: imageBytes,
                      aspectRatio: 1, // force square crop
                      withCircleUi: false, // square frame
                      maskColor: Colors.black38,
                      baseColor: Colors.black,
                      onCropped: (croppedBytes) async {
                        final tempDir = await getTemporaryDirectory();
                        final file = File(
                          "${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg",
                        );
                        await file.writeAsBytes(croppedBytes);

                        setState(() {
                          _pickedImageFile = file;
                          _uploadedImageUrl = null;
                        });

                        if (!mounted) return;
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      onPressed: () {
                        cropController.crop();
                      },
                      child: const Text(
                        "Done",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint("Image pick/crop failed: $e");
    }
  }

  Future<String> _uploadImageToFirebase(File file) async {
    final storage = FirebaseStorage.instance;
    final phoneForName = phoneCtrl.text.trim().isNotEmpty
        ? phoneCtrl.text.trim()
        : 'unknown';
    final fileName =
        "${selectedCountryCode.replaceAll('+', '')}_${phoneForName}_${DateTime.now().millisecondsSinceEpoch}.jpg";
    final ref = storage.ref().child('donor_profile_pics').child(fileName);

    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DonorRegistrationController>(
      builder: (context, controller, _) {
        final notesEnabled = !noneSelected;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final scaffoldBg = isDark
            ? const Color(0xFF121212)
            : const Color(0xFFFAFAFA);

        // Compute button enabled state
        final canSubmit =
            !controller.isLoading &&
            nameCtrl.text.trim().isNotEmpty &&
            selectedDob != null &&
            hasValidLocationPermanent &&
            hasValidCondition &&
            phoneCtrl.text.trim().isNotEmpty &&
            !_isUploadingImage; // disable submit while uploading image

        return Scaffold(
          backgroundColor: scaffoldBg,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Enhanced Header Section
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  AppColors.primary.withValues(alpha: 0.12),
                                  AppColors.primary.withValues(alpha: 0.05),
                                ]
                              : [
                                  AppColors.primary.withValues(alpha: 0.08),
                                  AppColors.primary.withValues(alpha: 0.03),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withValues(
                            alpha: isDark ? 0.15 : 0.1,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.favorite,
                                      size: 14,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Save Lives",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Become a Donor",
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 32,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade500,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Join our community and help save lives",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Profile picture section - Elegant card matching section width
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.3 : 0.06,
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 28,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.primary.withValues(
                                          alpha: 0.12,
                                        ),
                                        AppColors.primary.withValues(
                                          alpha: 0.06,
                                        ),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.12,
                                        ),
                                        blurRadius: 20,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.white,
                                    backgroundImage: _pickedImageFile != null
                                        ? FileImage(_pickedImageFile!)
                                              as ImageProvider
                                        : null,
                                    child: _pickedImageFile == null
                                        ? Icon(
                                            Icons.person_outline,
                                            size: 52,
                                            color: AppColors.primary.withValues(
                                              alpha: 0.25,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: GestureDetector(
                                    onTap: _showImageSourceSheet,
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(
                                              alpha: 0.35,
                                            ),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        _pickedImageFile == null
                                            ? Icons.add
                                            : Icons.edit,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              "Profile Photo",
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: 15,
                                  ),
                            ),
                          ),
                          if (_isUploadingImage) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Uploading...",
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // PERSONAL DETAILS SECTION
                    _buildSectionCard(
                      title: "Your Details",
                      children: [
                        _modernInput(
                          "Full Name",
                          Icons.person_outline,
                          nameCtrl,
                        ),
                        const SizedBox(height: 14),
                        _modernInput(
                          "Date of Birth",
                          Icons.calendar_today_outlined,
                          dobCtrl,
                          readOnly: true,
                          onTap: _onSelectDob,
                        ),
                        const SizedBox(height: 14),
                        _modernInput(
                          "Age",
                          Icons.cake_outlined,
                          ageCtrl,
                          keyboardType: TextInputType.number,
                          readOnly: true,
                        ),
                        const SizedBox(height: 18),
                        _genderSelector(),
                        const SizedBox(height: 18),
                        _bloodGroupSelector(),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // CONTACT INFORMATION
                    _buildSectionCard(
                      title: "Contact Information",
                      children: [
                        Container(
                          decoration: _modernBoxDecoration(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          child: IntlPhoneField(
                            controller: phoneCtrl,
                            initialCountryCode: selectedCountryIsoCode,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.phone_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              labelStyle: _labelTextStyle(context),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 2,
                              ),
                            ),
                            dropdownIcon: Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.primary,
                              size: 24,
                            ),
                            onChanged: (phone) {
                              selectedCountryCode = phone.countryCode;
                              phoneCtrl.text = phone.number;
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),

                    // PERMANENT ADDRESS SECTION
                    _buildSectionCard(
                      title: "Permanent Address",
                      children: [
                        _countrySelector(),
                        const SizedBox(height: 14),
                        if (selectedCountryName == "India") ...[
                          _stateDropdown(),
                          const SizedBox(height: 14),
                          _districtDropdown(),
                          const SizedBox(height: 14),
                          _citySelector(),
                          const SizedBox(height: 14),
                          _modernInput(
                            "PIN Code",
                            Icons.pin_drop_outlined,
                            pincodeCtrl,
                            keyboardType: TextInputType.number,
                          ),
                        ] else ...[
                          _nonIndiaAddressSection(),
                        ],
                      ],
                    ),

                    // MEDICAL CONDITIONS SECTION
                    _buildSectionCard(
                      title: "Medical Conditions",
                      children: [
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(minHeight: 72),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: conditions.map((c) {
                              final selected = selectedConditions.contains(c);
                              final disabled = noneSelected && c != "None";

                              return GestureDetector(
                                onTap: disabled
                                    ? null
                                    : () => _onConditionTap(c),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOutCubic,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.primary.withValues(
                                            alpha: 0.15,
                                          )
                                        : disabled
                                        ? (isDark
                                              ? Colors.grey.shade800
                                              : Colors.grey.shade200)
                                        : (isDark
                                              ? Colors.grey.shade900
                                              : Colors.white),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.primary.withValues(
                                              alpha: 0.5,
                                            )
                                          : disabled
                                          ? (isDark
                                                ? Colors.grey.shade700
                                                : Colors.grey.shade300)
                                          : (isDark
                                                ? Colors.grey.shade800
                                                : Colors.grey.shade300),
                                      width: selected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Text(
                                    c,
                                    style: TextStyle(
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: selected
                                          ? AppColors.primary
                                          : disabled
                                          ? (isDark
                                                ? Colors.grey.shade600
                                                : Colors.grey.shade500)
                                          : (isDark
                                                ? Colors.grey.shade300
                                                : Colors.grey.shade700),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: _modernBoxDecoration(
                            dimmed: !notesEnabled,
                          ),
                          child: TextField(
                            controller: notesCtrl,
                            enabled: notesEnabled,
                            maxLines: 2,
                            style: _inputTextStyle(context),
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: noneSelected
                                  ? "Other (disabled)"
                                  : "Other conditions (optional)",
                              hintStyle: _labelTextStyle(context),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 2,
                              ),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Icon(
                                  Icons.note_outlined,
                                  size: 18,
                                  color: notesEnabled
                                      ? AppColors.primary
                                      : Colors.grey.shade400,
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 0,
                                minHeight: 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // SUBMIT BUTTON - ELEGANT DESIGN
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: canSubmit
                              ? () => _onRegisterPressed(controller)
                              : null,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: controller.isLoading
                                  ? SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                            ),
                                      ),
                                    )
                                  : Text(
                                      "Register as Donor",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            letterSpacing: 0.3,
                                          ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ===== NEW SECTION CARD WIDGET =====
  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // ===== MODERN BOX DECORATION =====
  BoxDecoration _modernBoxDecoration({bool dimmed = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
          ? (dimmed ? Colors.grey.shade900 : Colors.grey.shade800)
          : (dimmed ? Colors.grey.shade100 : Colors.grey.shade50),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark
            ? (dimmed ? Colors.grey.shade700 : Colors.grey.shade800)
            : (dimmed ? Colors.grey.shade300 : Colors.grey.shade200),
      ),
    );
  }

  // ===== COUNTRY SELECTOR =====
  Widget _countrySelector() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        showCountryPicker(
          context: context,
          showPhoneCode: true,
          onSelect: (Country country) {
            setState(() {
              selectedCountryName = country.name;
              selectedCountryIsoCode = country.countryCode;
              selectedCountryDialCode = '+${country.phoneCode}';
              selectedCountryCode = '+${country.phoneCode}';
              // Reset address fields when country changes
              selectedState = null;
              selectedDistrict = null;
              selectedCity = null;
              cityManualCtrl.clear();
              pincodeCtrl.clear();

              nonIndiaAddressCtrl.clear();
              nonIndiaCityCtrl.clear();
              nonIndiaProvinceCtrl.clear();
              nonIndiaPincodeCtrl.clear();
            });
          },
          countryListTheme: CountryListThemeData(
            flagSize: 20,
            backgroundColor: isDark
                ? const Color(0xFF1E1E1E)
                : theme.colorScheme.surface,
            textStyle: theme.textTheme.bodyMedium,
            bottomSheetHeight: 520,
            searchTextStyle: theme.textTheme.bodyMedium,
            inputDecoration: InputDecoration(
              labelText: 'Search country',
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: _modernBoxDecoration(),
        child: Row(
          children: [
            Icon(Icons.public, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedCountryName ?? "Select Country",
                style: _inputTextStyle(context),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_drop_down, color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }

  // ===== NON-INDIA MINIMAL ADDRESS SECTION =====
  Widget _nonIndiaAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _modernInput("Address line", Icons.home_outlined, nonIndiaAddressCtrl),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _modernInput(
                "City",
                Icons.location_city_outlined,
                nonIndiaCityCtrl,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _modernInput(
                "Province / State",
                Icons.map_outlined,
                nonIndiaProvinceCtrl,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _modernInput(
          "Postal Code",
          Icons.pin_drop_outlined,
          nonIndiaPincodeCtrl,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  // ===== STATE DROPDOWN =====
  Widget _stateDropdown() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = _addressDataLoaded && statesList.isNotEmpty
        ? statesList
        : ['Kerala'];

    return Container(
      decoration: _modernBoxDecoration(),
      child: DropdownSearch<String>(
        popupProps: PopupProps.modalBottomSheet(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              hintText: "Search state",
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
              ),
            ),
          ),
          containerBuilder: (ctx, popupWidget) {
            return Container(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              child: popupWidget,
            );
          },
          itemBuilder: (context, item, isSelected) {
            return Container(
              color: isSelected
                  ? (isDark
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : AppColors.primary.withValues(alpha: 0.1))
                  : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                item,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            );
          },
        ),
        items: items,
        selectedItem: selectedState,
        onChanged: (v) {
          setState(() {
            selectedState = v;
            // reset dependent selections
            selectedDistrict = null;
            selectedCity = null;
            cityManualCtrl.clear();
          });
        },
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            hintText: "Select State",
            hintStyle: TextStyle(
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            ),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.map, color: AppColors.primary),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            isDense: true,
          ),
        ),
        dropdownBuilder: (context, selectedItem) {
          return Text(
            selectedItem ?? "Select State",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 14,
            ),
          );
        },
        validator: (s) =>
            s == null || s.isEmpty ? "Please select a state" : null,
      ),
    );
  }

  Widget _districtDropdown() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Only show districts when Kerala is selected and data loaded
    final districts =
        (selectedState != null &&
            selectedState!.toLowerCase() == 'kerala' &&
            keralaDistricts.isNotEmpty)
        ? keralaDistricts
        : <String>[];

    return Container(
      decoration: _modernBoxDecoration(),
      child: DropdownSearch<String>(
        popupProps: PopupProps.modalBottomSheet(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              hintText: "Search district",
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
              ),
            ),
          ),
          containerBuilder: (ctx, popupWidget) {
            return Container(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              child: popupWidget,
            );
          },
          itemBuilder: (context, item, isSelected) {
            return Container(
              color: isSelected
                  ? (isDark
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : AppColors.primary.withValues(alpha: 0.1))
                  : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                item,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            );
          },
        ),
        items: districts,
        selectedItem: selectedDistrict,
        onChanged: (v) {
          setState(() {
            selectedDistrict = v;
            selectedCity = null;
            cityManualCtrl.clear();
          });
        },
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            hintText: "Select District",
            hintStyle: TextStyle(
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            ),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.location_city, color: AppColors.primary),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            isDense: true,
          ),
        ),
        dropdownBuilder: (context, selectedItem) {
          return Text(
            selectedItem ?? "Select District",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 14,
            ),
          );
        },
        validator: (s) =>
            (selectedState != null &&
                selectedState!.toLowerCase() == 'kerala' &&
                (s == null || s.isEmpty))
            ? "Please select a district"
            : null,
      ),
    );
  }

  Widget _citySelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cities =
        (selectedState != null &&
            selectedState!.toLowerCase() == 'kerala' &&
            selectedDistrict != null &&
            selectedDistrict!.isNotEmpty &&
            keralaCities != null)
        ? List<String>.from(keralaCities![selectedDistrict] ?? <String>[])
        : <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown for known cities
        Container(
          decoration: _modernBoxDecoration(),
          child: DropdownSearch<String>(
            popupProps: PopupProps.modalBottomSheet(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: "Search city/town",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
              containerBuilder: (ctx, popupWidget) {
                return Container(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  child: popupWidget,
                );
              },
              itemBuilder: (context, item, isSelected) {
                return Container(
                  color: isSelected
                      ? (isDark
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : AppColors.primary.withValues(alpha: 0.1))
                      : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
            items: cities,
            selectedItem: selectedCity,
            onChanged: (v) {
              setState(() {
                selectedCity = v;
                cityManualCtrl
                    .clear(); // clear manual entry when selecting from dropdown
              });
            },
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                hintText: "Select City/Town",
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                ),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.location_city, color: AppColors.primary),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                isDense: true,
              ),
            ),
            dropdownBuilder: (context, selectedItem) {
              return Text(
                selectedItem ?? "Select City/Town",
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 14,
                ),
              );
            },

            // Validator: Always returns null (optional field)
            validator: (value) {
              return null;
            },
          ),
        ),

        const SizedBox(height: 8),

        // Manual entry fallback - updates selectedCity when typing
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: _modernBoxDecoration(),
          child: Row(
            children: [
              Icon(Icons.edit_location, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: cityManualCtrl,
                  onChanged: (value) {
                    // Update selectedCity as user types
                    setState(() {
                      selectedCity = value.trim().isEmpty ? null : value.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "If your town isn't listed, enter it here",
                    border: InputBorder.none,
                    hintStyle: _labelTextStyle(context),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 2),
                  ),
                  style: _inputTextStyle(context).copyWith(fontSize: 14),
                ),
              ),
            ],
          ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: _modernBoxDecoration(),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: ctrl,
              keyboardType: keyboardType,
              readOnly: readOnly,
              onTap: onTap,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: label,
                border: InputBorder.none,
                hintStyle: _labelTextStyle(context),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 2),
              ),
              style: _inputTextStyle(context).copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _genderSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
          ),
          child: Column(
            children: genderList.map((g) {
              final selected = gender == g;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: GestureDetector(
                  onTap: () {
                    setState(() => gender = g);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : (isDark
                                        ? Colors.grey.shade600
                                        : Colors.grey.shade400),
                              width: selected ? 2 : 1.5,
                            ),
                          ),
                          child: selected
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          g,
                          style: TextStyle(
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: selected
                                ? (isDark ? AppColors.primary : Colors.black87)
                                : (isDark
                                      ? Colors.grey.shade300
                                      : Colors.grey.shade700),
                            fontSize: 14,
                          ),
                        ),
                      ],
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

  Widget _bloodGroupSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: bloodGroups.map((b) {
              final selected = bloodGroup == b;

              return GestureDetector(
                onTap: () => setState(() => bloodGroup = b),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : (isDark ? Colors.grey.shade900 : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : (isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade300),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    b,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected
                          ? AppColors.primary
                          : (isDark
                                ? Colors.grey.shade300
                                : Colors.grey.shade700),
                      fontSize: 13,
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
