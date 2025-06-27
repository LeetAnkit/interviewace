import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/profile_header_widget.dart';
import './widgets/settings_item_widget.dart';
import './widgets/settings_section_widget.dart';

class UserProfileSettings extends StatefulWidget {
  const UserProfileSettings({super.key});

  @override
  State<UserProfileSettings> createState() => _UserProfileSettingsState();
}

class _UserProfileSettingsState extends State<UserProfileSettings> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;
  bool practiceReminders = true;
  bool achievementAlerts = true;
  bool weeklyProgress = false;
  bool autoSaveRecordings = true;
  bool biometricAuth = false;
  String selectedLanguage = 'English';
  String feedbackDetailLevel = 'Detailed';
  String defaultSessionLength = '15 minutes';

  final List<Map<String, dynamic>> mockUserData = [
    {
      "id": "user_001",
      "name": "Sarah Johnson",
      "email": "sarah.johnson@email.com",
      "avatar":
          "https://images.unsplash.com/photo-1494790108755-2616b612b786?fm=jpg&q=60&w=400&ixlib=rb-4.0.3",
      "joinDate": "2024-01-15",
      "totalSessions": 47,
      "averageScore": 8.2,
    }
  ];

  @override
  Widget build(BuildContext context) {
    final user = mockUserData.first;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Profile Settings',
          style: theme.textTheme.titleLarge,
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              ProfileHeaderWidget(
                user: user,
                onEditProfile: _handleEditProfile,
                onChangeAvatar: _handleChangeAvatar,
              ),

              SizedBox(height: 3.h),

              // Account Section
              SettingsSectionWidget(
                title: 'Account',
                children: [
                  SettingsItemWidget(
                    icon: 'email',
                    title: 'Email',
                    subtitle: user['email'] as String,
                    onTap: () => _handleEmailChange(),
                  ),
                  SettingsItemWidget(
                    icon: 'lock',
                    title: 'Password',
                    subtitle: 'Change password',
                    onTap: () => _handlePasswordChange(),
                  ),
                  SettingsItemWidget(
                    icon: 'delete_forever',
                    title: 'Delete Account',
                    subtitle: 'Permanently delete your account',
                    textColor: AppTheme.errorLight,
                    onTap: () => _handleDeleteAccount(),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // Preferences Section
              SettingsSectionWidget(
                title: 'Preferences',
                children: [
                  SettingsItemWidget(
                    icon: 'notifications',
                    title: 'Notifications',
                    subtitle: notificationsEnabled ? 'Enabled' : 'Disabled',
                    trailing: Switch(
                      value: notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          notificationsEnabled = value;
                        });
                      },
                    ),
                  ),
                  SettingsItemWidget(
                    icon: 'dark_mode',
                    title: 'Dark Mode',
                    subtitle: isDarkMode ? 'Enabled' : 'Disabled',
                    trailing: Switch(
                      value: isDarkMode,
                      onChanged: (value) {
                        setState(() {
                          isDarkMode = value;
                        });
                      },
                    ),
                  ),
                  SettingsItemWidget(
                    icon: 'language',
                    title: 'Language',
                    subtitle: selectedLanguage,
                    onTap: () => _handleLanguageSelection(),
                  ),
                  SettingsItemWidget(
                    icon: 'fingerprint',
                    title: 'Biometric Authentication',
                    subtitle: biometricAuth ? 'Enabled' : 'Disabled',
                    trailing: Switch(
                      value: biometricAuth,
                      onChanged: (value) {
                        setState(() {
                          biometricAuth = value;
                        });
                        _handleBiometricToggle(value);
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // Practice Settings Section
              SettingsSectionWidget(
                title: 'Practice Settings',
                children: [
                  SettingsItemWidget(
                    icon: 'timer',
                    title: 'Default Session Length',
                    subtitle: defaultSessionLength,
                    onTap: () => _handleSessionLengthChange(),
                  ),
                  SettingsItemWidget(
                    icon: 'save',
                    title: 'Auto-save Recordings',
                    subtitle: autoSaveRecordings ? 'Enabled' : 'Disabled',
                    trailing: Switch(
                      value: autoSaveRecordings,
                      onChanged: (value) {
                        setState(() {
                          autoSaveRecordings = value;
                        });
                      },
                    ),
                  ),
                  SettingsItemWidget(
                    icon: 'feedback',
                    title: 'Feedback Detail Level',
                    subtitle: feedbackDetailLevel,
                    onTap: () => _handleFeedbackLevelChange(),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // Notification Settings Section
              SettingsSectionWidget(
                title: 'Notification Settings',
                children: [
                  SettingsItemWidget(
                    icon: 'alarm',
                    title: 'Practice Reminders',
                    subtitle: practiceReminders ? 'Enabled' : 'Disabled',
                    trailing: Switch(
                      value: practiceReminders,
                      onChanged: (value) {
                        setState(() {
                          practiceReminders = value;
                        });
                      },
                    ),
                  ),
                  SettingsItemWidget(
                    icon: 'star',
                    title: 'Achievement Alerts',
                    subtitle: achievementAlerts ? 'Enabled' : 'Disabled',
                    trailing: Switch(
                      value: achievementAlerts,
                      onChanged: (value) {
                        setState(() {
                          achievementAlerts = value;
                        });
                      },
                    ),
                  ),
                  SettingsItemWidget(
                    icon: 'analytics',
                    title: 'Weekly Progress Summary',
                    subtitle: weeklyProgress ? 'Enabled' : 'Disabled',
                    trailing: Switch(
                      value: weeklyProgress,
                      onChanged: (value) {
                        setState(() {
                          weeklyProgress = value;
                        });
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // Data Export Section
              SettingsSectionWidget(
                title: 'Data Export',
                children: [
                  SettingsItemWidget(
                    icon: 'download',
                    title: 'Download My Data',
                    subtitle: 'Export practice history as PDF',
                    onTap: () => _handleDataExport(),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // About Section
              SettingsSectionWidget(
                title: 'About',
                children: [
                  SettingsItemWidget(
                    icon: 'info',
                    title: 'App Version',
                    subtitle: '1.0.0 (Build 1)',
                  ),
                  SettingsItemWidget(
                    icon: 'privacy_tip',
                    title: 'Privacy Policy',
                    subtitle: 'View privacy policy',
                    onTap: () => _handlePrivacyPolicy(),
                  ),
                  SettingsItemWidget(
                    icon: 'description',
                    title: 'Terms of Service',
                    subtitle: 'View terms and conditions',
                    onTap: () => _handleTermsOfService(),
                  ),
                ],
              ),

              SizedBox(height: 4.h),

              // Sign Out Button
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: ElevatedButton(
                  onPressed: () => _handleSignOut(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorLight,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Sign Out',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: 'home',
                label: 'Home',
                isSelected: false,
                onTap: () => Navigator.pushNamed(context, '/home-dashboard'),
              ),
              _buildNavItem(
                context,
                icon: 'play_circle',
                label: 'Practice',
                isSelected: false,
                onTap: () =>
                    Navigator.pushNamed(context, '/practice-session-setup'),
              ),
              _buildNavItem(
                context,
                icon: 'analytics',
                label: 'Feedback',
                isSelected: false,
                onTap: () =>
                    Navigator.pushNamed(context, '/ai-feedback-results'),
              ),
              _buildNavItem(
                context,
                icon: 'history',
                label: 'History',
                isSelected: false,
                onTap: () => Navigator.pushNamed(context, '/practice-history'),
              ),
              _buildNavItem(
                context,
                icon: 'person',
                label: 'Profile',
                isSelected: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required String icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: isSelected
                  ? theme.bottomNavigationBarTheme.selectedItemColor
                  : theme.bottomNavigationBarTheme.unselectedItemColor,
              size: 24,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? theme.bottomNavigationBarTheme.selectedItemColor
                    : theme.bottomNavigationBarTheme.unselectedItemColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleEditProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: const Text(
            'Profile editing functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleChangeAvatar() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'camera_alt',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                // Implement camera functionality
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'photo_library',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                // Implement gallery functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleEmailChange() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Email'),
        content:
            const Text('Email change functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _handlePasswordChange() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text(
            'Password change functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _handleDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement account deletion
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorLight,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleLanguageSelection() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: selectedLanguage,
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Spanish'),
              value: 'Spanish',
              groupValue: selectedLanguage,
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('French'),
              value: 'French',
              groupValue: selectedLanguage,
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleBiometricToggle(bool value) {
    if (value) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enable Biometric Authentication'),
          content: const Text(
              'This will enable Face ID/Touch ID or fingerprint login for enhanced security.'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  biometricAuth = false;
                });
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Enable'),
            ),
          ],
        ),
      );
    }
  }

  void _handleSessionLengthChange() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Session Length'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('10 minutes'),
              value: '10 minutes',
              groupValue: defaultSessionLength,
              onChanged: (value) {
                setState(() {
                  defaultSessionLength = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('15 minutes'),
              value: '15 minutes',
              groupValue: defaultSessionLength,
              onChanged: (value) {
                setState(() {
                  defaultSessionLength = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('30 minutes'),
              value: '30 minutes',
              groupValue: defaultSessionLength,
              onChanged: (value) {
                setState(() {
                  defaultSessionLength = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleFeedbackLevelChange() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Feedback Detail Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Basic'),
              value: 'Basic',
              groupValue: feedbackDetailLevel,
              onChanged: (value) {
                setState(() {
                  feedbackDetailLevel = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Detailed'),
              value: 'Detailed',
              groupValue: feedbackDetailLevel,
              onChanged: (value) {
                setState(() {
                  feedbackDetailLevel = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Comprehensive'),
              value: 'Comprehensive',
              groupValue: feedbackDetailLevel,
              onChanged: (value) {
                setState(() {
                  feedbackDetailLevel = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleDataExport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text(
            'Your practice history will be exported as a PDF file. This may take a few moments.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement PDF export functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Data export started. You will be notified when complete.'),
                ),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _handlePrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text('Privacy policy content will be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const Text('Terms of service content will be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleSignOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement sign out functionality
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home-dashboard',
                (route) => false,
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorLight,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
