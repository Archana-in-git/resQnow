// lib/features/blood_donor/presentation/pages/donor/donor_registration_page.dart

import 'dart:convert';
import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:resqnow/features/blood_donor/presentation/controllers/donor_registration_controller.dart';

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
  final localityCtrl = TextEditingController();

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
    localityCtrl.dispose();

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
      final cityValue = selectedCity ?? cityManualCtrl.text.trim();
      final locality = localityCtrl.text.trim();
      final pin = pincodeCtrl.text.trim();

      assembledAddress = [
        locality,
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
        "locality": locality,
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
      Navigator.of(context).pop(true);
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
    return base.copyWith(color: Colors.black);
  }

  TextStyle _labelTextStyle(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    return base.copyWith(color: Colors.grey.shade700);
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
          return AlertDialog(
            backgroundColor: Colors.white,
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
        final colorScheme = theme.colorScheme;
        final primaryColor = AppColors.primary;

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
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top bar
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
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
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
                                  color:
                                      theme.textTheme.bodyMedium?.color ??
                                      colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Profile picture row (NEW)
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 48,
                                backgroundColor: theme.colorScheme.surface,
                                backgroundImage: _pickedImageFile != null
                                    ? FileImage(_pickedImageFile!)
                                          as ImageProvider
                                    : null,
                                child: _pickedImageFile == null
                                    ? Icon(
                                        Icons.person,
                                        size: 48,
                                        color: theme.disabledColor,
                                      )
                                    : null,
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: _showImageSourceSheet,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.12,
                                          ),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _pickedImageFile == null
                                          ? Icons.add_a_photo
                                          : Icons.edit,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Profile picture (optional, recommended)",
                            style: theme.textTheme.bodySmall,
                          ),
                          if (_isUploadingImage) ...[
                            const SizedBox(height: 8),
                            const SizedBox(
                              height: 14,
                              width: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(height: 6),
                            const Text("Uploading image..."),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // PERSONAL DETAILS
                    _sectionHeader("Your Details"),
                    const SizedBox(height: 12),

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
                        initialCountryCode: selectedCountryIsoCode,
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
                          setState(() {});
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // -----------------------------
                    // PERMANENT ADDRESS SECTION
                    // -----------------------------
                    _sectionHeader("Permanent Address"),
                    const SizedBox(height: 12),

                    // COUNTRY SELECTOR (NEW)
                    _countrySelector(),

                    const SizedBox(height: 12),

                    // If India -> show state/district/city UI
                    if (selectedCountryName == "India") ...[
                      _stateDropdown(),
                      const SizedBox(height: 12),
                      _districtDropdown(),
                      const SizedBox(height: 12),
                      _citySelector(),
                      const SizedBox(height: 12),

                      // Locality
                      _modernInput(
                        "Locality (optional)",
                        Icons.location_city,
                        localityCtrl,
                      ),
                      const SizedBox(height: 12),

                      // PIN code (India)
                      _modernInput(
                        "PIN Code",
                        Icons.pin_drop,
                        pincodeCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ] else ...[
                      // Non-India minimal fields (Option A)
                      _nonIndiaAddressSection(),
                    ],

                    const SizedBox(height: 12),

                    const SizedBox(height: 20),

                    // MEDICAL CONDITIONS
                    Text(
                      "Medical Conditions",
                      style: _labelTextStyle(
                        context,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 64),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 18,
                      ),
                      decoration: _boxDecoration(),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: conditions.map((c) {
                          final selected = selectedConditions.contains(c);
                          final disabled = noneSelected && c != "None";
                          final chipBackground = selected
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : disabled
                              ? theme.disabledColor.withValues(alpha: 0.10)
                              : theme.colorScheme.surfaceContainerHighest;
                          final chipBorderColor = selected
                              ? AppColors.primary.withValues(alpha: 0.80)
                              : disabled
                              ? theme.disabledColor.withValues(alpha: 0.30)
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

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: _boxDecoration(dimmed: !notesEnabled),
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

  // -------------------------
  // NEW: Country selector widget
  // -------------------------
  Widget _countrySelector() {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        showCountryPicker(
          context: context,
          showPhoneCode:
              true, // show phone code to let user know dialing code (helps sync with phone input)
          onSelect: (Country country) {
            setState(() {
              selectedCountryName = country.name;
              selectedCountryIsoCode = country.countryCode;
              selectedCountryDialCode = '+${country.phoneCode}';
              selectedCountryCode = '+${country.phoneCode}';
              // For simplicity, don't auto-change phone field value here; IntlPhoneField handles its own picker.
              // Reset address fields when country changes
              selectedState = null;
              selectedDistrict = null;
              selectedCity = null;
              cityManualCtrl.clear();
              pincodeCtrl.clear();
              localityCtrl.clear();

              nonIndiaAddressCtrl.clear();
              nonIndiaCityCtrl.clear();
              nonIndiaProvinceCtrl.clear();
              nonIndiaPincodeCtrl.clear();
            });
          },
          countryListTheme: CountryListThemeData(
            flagSize: 20,
            backgroundColor: theme.colorScheme.surface,
            textStyle: theme.textTheme.bodyMedium,
            bottomSheetHeight: 520,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: _boxDecoration(),
        child: Row(
          children: [
            Icon(Icons.public, color: AppColors.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                selectedCountryName ?? "Select Country",
                style: _inputTextStyle(context),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_drop_down, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  // -------------------------
  // NON-INDIA minimal address section (Option A)
  // -------------------------
  Widget _nonIndiaAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _modernInput("Address line", Icons.home, nonIndiaAddressCtrl),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _modernInput(
                "City",
                Icons.location_city,
                nonIndiaCityCtrl,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _modernInput(
                "Province / State",
                Icons.map,
                nonIndiaProvinceCtrl,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _modernInput(
          "Postal Code",
          Icons.pin_drop,
          nonIndiaPincodeCtrl,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  // -------------------------
  // ADDRESS WIDGET HELPERS (India)
  // -------------------------
  Widget _stateDropdown() {
    // If statesList is not loaded yet, show a placeholder or small spinner
    final items = _addressDataLoaded && statesList.isNotEmpty
        ? statesList
        : ['Kerala'];

    return DropdownSearch<String>(
      popupProps: PopupProps.modalBottomSheet(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(hintText: "Search state"),
        ),
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
          border: InputBorder.none,
          prefixIcon: Icon(Icons.map, color: AppColors.primary),
        ),
      ),
      validator: (s) => s == null || s.isEmpty ? "Please select a state" : null,
    );
  }

  Widget _districtDropdown() {
    // Only show districts when Kerala is selected and data loaded
    final districts =
        (selectedState != null &&
            selectedState!.toLowerCase() == 'kerala' &&
            keralaDistricts.isNotEmpty)
        ? keralaDistricts
        : <String>[];

    return DropdownSearch<String>(
      popupProps: PopupProps.modalBottomSheet(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(hintText: "Search district"),
        ),
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
          hintText: selectedState == null
              ? "Select State first"
              : (selectedState!.toLowerCase() == 'kerala'
                    ? "Select District"
                    : "Districts (Kerala only)"),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.location_city, color: AppColors.primary),
        ),
      ),
      validator: (s) =>
          (selectedState != null &&
              selectedState!.toLowerCase() == 'kerala' &&
              (s == null || s.isEmpty))
          ? "Please select a district"
          : null,
    );
  }

  Widget _citySelector() {
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
        DropdownSearch<String>(
          popupProps: PopupProps.modalBottomSheet(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: const InputDecoration(hintText: "Search city/town"),
            ),
          ),
          items: cities,
          selectedItem: selectedCity,
          onChanged: (v) {
            setState(() {
              selectedCity = v;
              cityManualCtrl.clear(); // clear manual entry
            });
          },
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              hintText: selectedDistrict == null
                  ? "Select district first"
                  : (cities.isEmpty
                        ? "No city data for this district"
                        : "Select City/Town (or enter manually below)"),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.location_city, color: AppColors.primary),
            ),
          ),

          // Validator: Always returns null (optional field)
          validator: (value) {
            return null;
          },
        ),

        const SizedBox(height: 8),

        // Manual entry fallback
        _modernInput(
          "If your town isn't listed, enter it here",
          Icons.edit_location,
          cityManualCtrl,
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
              onChanged: (_) =>
                  setState(() {}), // reflect in canSubmit / validation
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
                title: Text(g, style: Theme.of(context).textTheme.bodyMedium),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _bloodGroupSelector() {
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
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
                        ? primaryColor.withValues(alpha: 0.40)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: selected
                          ? primaryColor
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                  child: Text(
                    b,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                      color: selected
                          ? primaryColor
                          : Theme.of(context).textTheme.bodyMedium?.color,
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

  Widget _sectionHeader(String text) {
    final base =
        Theme.of(context).textTheme.titleMedium ??
        const TextStyle(fontSize: 20);
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
}
