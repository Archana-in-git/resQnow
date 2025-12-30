import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:resqnow/core/theme/theme_manager.dart';
import '../controllers/settings_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SettingsController _settingsController;

  @override
  void initState() {
    super.initState();
    _settingsController = SettingsController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _settingsController.loadSettings();
    });
  }

  @override
  void dispose() {
    _settingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDarkMode ? Colors.grey.shade800 : AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListenableBuilder(
        listenable: _settingsController,
        builder: (context, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // 🎨 THEME SECTION
                _buildSectionHeader('Theme', Icons.palette_rounded),
                _buildThemeSection(context),

                // 🔔 NOTIFICATIONS SECTION
                _buildSectionHeader(
                  'Notifications',
                  Icons.notifications_rounded,
                ),
                _buildNotificationSection(context),

                // 📍 PERMISSIONS SECTION
                _buildSectionHeader('Permissions', Icons.security_rounded),
                _buildPermissionsSection(context),

                // 🔧 ABOUT SECTION
                _buildSectionHeader('About', Icons.info_rounded),
                _buildAboutSection(context),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context) {
    final themeManager = context.watch<ThemeManager>();
    final isDarkMode = themeManager.themeMode == ThemeMode.dark;
    final isAppDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        color: isAppDarkMode ? Colors.grey.shade800 : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            _buildSettingsTile(
              icon: Icons.dark_mode_rounded,
              iconColor: const Color(0xFF455A64),
              title: 'Dark Mode',
              subtitle: isDarkMode ? 'Enabled' : 'Disabled',
              trailing: Switch(
                value: isDarkMode,
                activeColor: AppColors.primary,
                onChanged: (value) async {
                  // Update theme via ThemeManager (handles both state and SharedPreferences persistence)
                  await themeManager.toggleTheme(value);

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value
                            ? '🌙 Dark mode enabled'
                            : '☀️ Light mode enabled',
                      ),
                      duration: const Duration(milliseconds: 800),
                    ),
                  );
                },
              ),
            ),
            Divider(
              color: isAppDarkMode
                  ? Colors.grey.shade700
                  : Colors.grey.shade200,
              height: 1,
              indent: 16,
              endIndent: 16,
            ),
            _buildSettingsTile(
              icon: Icons.text_fields_rounded,
              iconColor: const Color(0xFF1976D2),
              title: 'Text Size',
              subtitle: 'Normal',
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  _settingsController.saveTextSizePreference(value);
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(value: 'small', child: Text('Small')),
                  const PopupMenuItem(value: 'normal', child: Text('Normal')),
                  const PopupMenuItem(value: 'large', child: Text('Large')),
                ],
                child: Icon(
                  Icons.arrow_drop_down_rounded,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection(BuildContext context) {
    final isAppDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        color: isAppDarkMode ? Colors.grey.shade800 : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            _buildSettingsTile(
              icon: Icons.notifications_active_rounded,
              iconColor: const Color(0xFFFFA000),
              title: 'Push Notifications',
              subtitle: 'Stay updated with alerts',
              trailing: Switch(
                value: _settingsController.notificationsEnabled,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  _settingsController.saveNotificationsPreference(value);
                },
              ),
            ),
            Divider(
              color: isAppDarkMode
                  ? Colors.grey.shade700
                  : Colors.grey.shade200,
              height: 1,
              indent: 16,
              endIndent: 16,
            ),
            _buildSettingsTile(
              icon: Icons.emergency_rounded,
              iconColor: AppColors.accent,
              title: 'Emergency Alerts',
              subtitle: 'High priority notifications',
              trailing: Switch(
                value: _settingsController.emergencyAlertsEnabled,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  _settingsController.saveEmergencyAlertsPreference(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsSection(BuildContext context) {
    final isAppDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        color: isAppDarkMode ? Colors.grey.shade800 : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            _buildPermissionTile(
              icon: Icons.location_on_rounded,
              iconColor: AppColors.accent,
              title: 'Location',
              subtitle: '',
              onTap: () => _requestPermission(Permission.location),
            ),
            Divider(
              color: isAppDarkMode
                  ? Colors.grey.shade700
                  : Colors.grey.shade200,
              height: 1,
              indent: 16,
              endIndent: 16,
            ),
            _buildPermissionTile(
              icon: Icons.camera_alt_rounded,
              iconColor: const Color(0xFF1976D2),
              title: 'Camera',
              subtitle: '',
              onTap: () => _requestPermission(Permission.camera),
            ),
            Divider(
              color: isAppDarkMode
                  ? Colors.grey.shade700
                  : Colors.grey.shade200,
              height: 1,
              indent: 16,
              endIndent: 16,
            ),
            _buildPermissionTile(
              icon: Icons.mic_rounded,
              iconColor: const Color(0xFF6A4C93),
              title: 'Microphone',
              subtitle: '',
              onTap: () => _requestPermission(Permission.microphone),
            ),
            Divider(
              color: isAppDarkMode
                  ? Colors.grey.shade700
                  : Colors.grey.shade200,
              height: 1,
              indent: 16,
              endIndent: 16,
            ),
            _buildPermissionTile(
              icon: Icons.photo_library_rounded,
              iconColor: const Color(0xFFFFA000),
              title: 'Photo Library',
              subtitle: '',
              onTap: () => _requestPermission(Permission.photos),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final isAppDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        color: isAppDarkMode ? Colors.grey.shade800 : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            _buildSettingsTile(
              icon: Icons.app_shortcut_rounded,
              iconColor: AppColors.primary,
              title: 'App Version',
              subtitle: 'Version 1.0.0',
              trailing: null,
            ),
            Divider(
              color: isAppDarkMode
                  ? Colors.grey.shade700
                  : Colors.grey.shade200,
              height: 1,
              indent: 16,
              endIndent: 16,
            ),
            _buildSettingsTile(
              icon: Icons.privacy_tip_rounded,
              iconColor: const Color(0xFF455A64),
              title: 'Privacy Policy',
              subtitle: 'View our privacy policy',
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacy policy coming soon')),
                );
              },
            ),
            Divider(
              color: isAppDarkMode
                  ? Colors.grey.shade700
                  : Colors.grey.shade200,
              height: 1,
              indent: 16,
              endIndent: 16,
            ),
            _buildSettingsTile(
              icon: Icons.description_rounded,
              iconColor: const Color(0xFF1976D2),
              title: 'Terms & Conditions',
              subtitle: 'View our terms',
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Terms & conditions coming soon'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final isAppDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isAppDarkMode
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isAppDarkMode
                          ? Colors.grey.shade400
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isAppDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: isAppDarkMode ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();

    if (!mounted) return;

    final message = switch (status) {
      PermissionStatus.granted =>
        '✅ ${permission.toString().split('.').last} permission granted',
      PermissionStatus.denied =>
        '❌ ${permission.toString().split('.').last} permission denied',
      PermissionStatus.restricted =>
        '⚠️ ${permission.toString().split('.').last} permission restricted',
      PermissionStatus.limited =>
        '⚠️ ${permission.toString().split('.').last} permission limited',
      PermissionStatus.provisional =>
        '⚠️ ${permission.toString().split('.').last} permission provisional',
      PermissionStatus.permanentlyDenied =>
        '🔒 ${permission.toString().split('.').last} permission permanently denied. Go to settings to enable it.',
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }
}
