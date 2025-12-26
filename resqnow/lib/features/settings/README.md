# Settings Module

The Settings module provides users with comprehensive app configuration options including theme preferences, notification settings, permission management, and app information.

## Features

### 1. **Theme Settings**

- **Dark Mode Toggle**: Switch between light and dark themes
- **Text Size**: Adjust text size (Small, Normal, Large)
- Settings are persisted using SharedPreferences

### 2. **Notification Settings**

- **Push Notifications**: Enable/disable general push notifications
- **Emergency Alerts**: Enable/disable high-priority emergency notifications
- All preferences are saved locally

### 3. **Permissions Management**

- **Location**: For finding nearby hospitals and services
- **Camera**: For image analysis and medical imaging features
- **Microphone**: For voice-based features and voice input
- **Photo Library**: For selecting images from device storage
- Each permission can be individually requested and managed

### 4. **About Section**

- **App Version**: Displays current app version
- **Privacy Policy**: Link to privacy policy (extensible)
- **Terms & Conditions**: Link to terms and conditions (extensible)

## Architecture

The Settings module follows Clean Architecture principles:

```
settings/
├── presentation/
│   ├── controllers/
│   │   └── settings_controller.dart      # State management with ChangeNotifier
│   └── pages/
│       └── settings_page.dart             # Main settings UI page
└── (data & domain layers can be extended for remote sync)
```

## Components

### SettingsPage (`settings_page.dart`)

The main UI page that displays all settings options organized into sections:

- Theme Section
- Notifications Section
- Permissions Section
- About Section

Uses `ListenableBuilder` to reactively update the UI when settings change.

### SettingsController (`settings_controller.dart`)

ChangeNotifier-based controller that handles:

- Loading settings from SharedPreferences on initialization
- Saving user preferences to local storage
- Notifying listeners when settings change
- Providing getter methods for accessing current settings

**Preference Keys**:

- `dark_mode`: Boolean indicating dark mode status
- `text_size`: String for text size preference (small/normal/large)
- `notifications_enabled`: Boolean for push notifications
- `emergency_alerts_enabled`: Boolean for emergency alerts

## Usage

### Accessing Settings

```dart
// In any widget with access to context
final settingsController = SettingsController();
await settingsController.loadSettings();

// Access settings
final isDarkMode = settingsController.isDarkMode;
final textSize = settingsController.textSize;
```

### Navigating to Settings

```dart
// From navbar or anywhere in the app
context.push('/settings');
```

### Toggling Dark Mode

```dart
// This automatically updates the ThemeManager and saves preference
themeManager.toggleTheme(true); // Enable dark mode
```

### Requesting Permissions

The settings page handles permission requests when user taps on a permission tile:

```dart
await Permission.location.request();
```

## Integration Points

### With ThemeManager

The Settings page integrates with the existing `ThemeManager` (from `core/theme/theme_manager.dart`):

- Dark mode toggle updates `ThemeManager.themeMode`
- Changes are reflected app-wide through `context.watch<ThemeManager>()`

### With SharedPreferences

All settings except theme (which uses ThemeManager) are persisted using SharedPreferences:

- Automatic loading on app startup via `SettingsController.loadSettings()`
- Automatic saving when user changes any setting
- No manual persistence needed

### With PermissionHandler

Permission requests use the `permission_handler` package:

- Location, Camera, Microphone, Photos permissions
- Shows user-friendly status messages via SnackBar
- Links to app settings for permanently denied permissions

## Extending the Settings

### Adding New Setting

1. Add property to `SettingsController`:

```dart
bool _newSetting = false;
bool get newSetting => _newSetting;
```

2. Add preference key:

```dart
static const String _newSettingKey = 'new_setting';
```

3. Add save/load logic:

```dart
Future<void> saveNewSetting(bool value) async {
  _newSetting = value;
  await _prefs.setBool(_newSettingKey, value);
  notifyListeners();
}
```

4. Add UI tile in `SettingsPage`:

```dart
_buildSettingsTile(
  icon: Icons.your_icon,
  iconColor: AppColors.primary,
  title: 'Your Setting',
  subtitle: 'Description',
  trailing: Switch(
    value: settingsController.newSetting,
    onChanged: (value) => settingsController.saveNewSetting(value),
  ),
)
```

### Adding New Permission

1. Add permission tile in `_buildPermissionsSection()`:

```dart
_buildPermissionTile(
  icon: Icons.your_icon,
  iconColor: AppColors.primary,
  title: 'Your Permission',
  subtitle: 'Description',
  onTap: () => _requestPermission(Permission.yourPermission),
)
```

2. Ensure the permission is declared in:
   - Android: `android/app/src/main/AndroidManifest.xml`
   - iOS: `ios/Runner/Info.plist`

## Future Enhancements

- [ ] Remote settings sync across devices
- [ ] Backup/restore settings to cloud storage
- [ ] Language/localization preferences
- [ ] Accessibility settings (font scaling, colors)
- [ ] Data privacy controls
- [ ] App usage analytics opt-in/opt-out
- [ ] Cache management and storage control
