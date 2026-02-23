import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import '../data/profile_service.dart';
import '../data/profile_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _service = ProfileService();

  bool isLoading = true;
  bool isEditing = false;

  UserModel? user;

  File? _imageFile;
  String? _imageUrl;

  String phoneNumber = "";
  String gender = "Male";
  String bloodGroup = "O+";
  String additionalNotes = "";

  final List<String> genders = ["Male", "Female", "Other"];
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

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final data = await _service.fetchUserProfile();
    if (!mounted) return;

    user = data;
    phoneNumber = user?.phone ?? "";
    gender = genders.contains(user?.gender) ? user!.gender : "Male";
    bloodGroup = bloodGroups.contains(user?.bloodGroup)
        ? user!.bloodGroup
        : "O+";
    additionalNotes = user?.medicalConditions?.join(", ") ?? "";
    _imageUrl = user?.profileImageUrl;

    setState(() => isLoading = false);
  }

  Future<void> pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

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
                      aspectRatio: 1,
                      withCircleUi: true,
                      maskColor: Colors.black38,
                      baseColor: Colors.black,
                      onCropped: (croppedBytes) async {
                        final tempDir = await getTemporaryDirectory();
                        final file = File(
                          "${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg",
                        );
                        await file.writeAsBytes(croppedBytes);

                        if (!mounted) return;

                        setState(() => _imageFile = file);
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
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to pick/crop image: $e"),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> saveProfile() async {
    try {
      String? imageUrl = _imageUrl; // Photo is optional - can be null

      // Upload image if selected (only if user picked a new image)
      if (_imageFile != null) {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        final ref = FirebaseStorage.instance.ref().child(
          "profile_images/$uid.jpg",
        );
        await ref.putFile(_imageFile!);
        imageUrl = await ref.getDownloadURL();
      }

      // Convert comma-separated notes to list
      final notesList = additionalNotes
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      // Update profile
      await _service.updateProfile({
        "phone": phoneNumber,
        "gender": gender,
        "bloodGroup": bloodGroup,
        "medicalConditions": notesList,
        "profileImageUrl": imageUrl,
      });

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _imageUrl = imageUrl;
        isEditing = false;
      });
    } catch (e) {
      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating profile: $e"),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void exitEditMode() {
    setState(() => isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: isEditing
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: exitEditMode,
              )
            : null,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.check_circle, size: 28),
              onPressed: saveProfile,
            )
          else
            IconButton(
              icon: const Icon(Icons.edit_rounded, size: 24),
              onPressed: () => setState(() => isEditing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 🔹 PROFILE HERO SECTION
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  /// Profile Image
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.white,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : (_imageUrl != null
                                        ? NetworkImage(_imageUrl!)
                                        : null)
                                    as ImageProvider?,
                          child: (_imageFile == null && _imageUrl == null)
                              ? const Icon(
                                  Icons.person,
                                  size: 70,
                                  color: AppColors.primary,
                                )
                              : null,
                        ),
                      ),
                      if (isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Row(
                            children: [
                              /// Remove/Clear image button
                              if (_imageFile != null)
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _imageFile = null),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    margin: const EdgeInsets.only(right: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade600,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.2,
                                          ),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),

                              /// Pick/Crop image button
                              GestureDetector(
                                onTap: pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 22,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  /// Name
                  Text(
                    user!.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            /// 🔹 FORM SECTION
            Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: isDarkMode ? 0.3 : 0.08,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Email
                  Text(
                    "Email",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.grey.shade700
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.grey.shade600
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    child: Text(
                      user!.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// Phone Number
                  Text(
                    "Contact Information",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 14),

                  IntlPhoneField(
                    initialCountryCode: 'IN',
                    enabled: isEditing,
                    initialValue: phoneNumber,
                    decoration: InputDecoration(
                      hintText: "Enter phone number",
                      filled: true,
                      fillColor: isDarkMode
                          ? Colors.grey.shade700
                          : Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (phone) {
                      phoneNumber = phone.completeNumber;
                    },
                  ),

                  const SizedBox(height: 24),

                  /// Gender & Blood Group
                  Text(
                    "Health Metrics",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      /// Gender
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.grey.shade600
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: genders.contains(gender) ? gender : "Male",
                              isExpanded: true,
                              icon: const Icon(
                                Icons.expand_more,
                                color: AppColors.primary,
                              ),
                              items: genders
                                  .map(
                                    (e) => DropdownMenuItem<String>(
                                      value: e,
                                      child: Text(
                                        e,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: isEditing
                                  ? (String? val) {
                                      if (val != null) {
                                        setState(() => gender = val);
                                      }
                                    }
                                  : null,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      /// Blood Group
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.grey.shade600
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: bloodGroups.contains(bloodGroup)
                                  ? bloodGroup
                                  : "O+",
                              isExpanded: true,
                              icon: const Icon(
                                Icons.expand_more,
                                color: AppColors.primary,
                              ),
                              items: bloodGroups
                                  .map(
                                    (e) => DropdownMenuItem<String>(
                                      value: e,
                                      child: Text(
                                        e,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: isEditing
                                  ? (String? val) {
                                      if (val != null) {
                                        setState(() => bloodGroup = val);
                                      }
                                    }
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// Additional Notes
                  Text(
                    "Medical Notes",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.grey.shade700
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.grey.shade600
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      maxLines: 4,
                      enabled: isEditing,
                      controller: TextEditingController(text: additionalNotes),
                      onChanged: (val) => additionalNotes = val,
                      decoration: InputDecoration(
                        hintText:
                            "Add any medical conditions or health notes...",
                        hintStyle: TextStyle(
                          color: isDarkMode
                              ? Colors.grey.shade500
                              : Colors.grey.shade500,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(14),
                      ),
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),

            /// 🔹 LOGOUT BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  onPressed: showLogoutDialog,
                  child: const Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await _service.logout();
              if (mounted) context.go('/welcome');
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
