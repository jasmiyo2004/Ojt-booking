import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'user_management_page.dart';
import 'landing_page.dart';
import '../services/user_session.dart';
import '../services/api_service.dart';
import '../widgets/success_dialog.dart';
import '../widgets/error_dialog.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final UserSession _userSession = UserSession();
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _currentUserData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    setState(() => _isLoading = true);
    try {
      // Get user data from session
      final sessionData = _userSession.currentUser;

      if (sessionData != null) {
        // Fetch complete user data from API to get profile picture
        try {
          final userId = sessionData['userId'];
          final usersData = await _apiService.getUsers();
          final currentUserFromApi = usersData.firstWhere(
            (user) => user['userId'] == userId,
            orElse: () => {},
          );

          // Merge API data with session data to include profile picture
          if (currentUserFromApi.isNotEmpty) {
            final updatedUserData = Map<String, dynamic>.from(sessionData);
            updatedUserData['profilePicture'] =
                currentUserFromApi['profilePicture'];

            // Update session with profile picture
            _userSession.setUser(updatedUserData);

            setState(() {
              _currentUserData = updatedUserData;
              _isLoading = false;
            });
          } else {
            setState(() {
              _currentUserData = sessionData;
              _isLoading = false;
            });
          }
        } catch (e) {
          print('Error fetching user profile picture: $e');
          setState(() {
            _currentUserData = sessionData;
            _isLoading = false;
          });
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading current user: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFFD4AF37)),
              const SizedBox(height: 16),
              Text(
                'Loading settings...',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Yellow header section
          Container(
            decoration: const BoxDecoration(color: Color(0xFFFFEB3B)),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company branding
                    Row(
                      children: [
                        Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gothong Southern',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B5E20),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Transport & Logistics',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF424242),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // White content area with rounded top
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Settings Title
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your account and preferences',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Profile Section
                    _buildSectionTitle('Profile', Icons.person_rounded),
                    const SizedBox(height: 16),
                    _buildProfileCard(),
                    const SizedBox(height: 32),

                    // Management Section (only show for non-Local users)
                    if (_currentUserData != null &&
                        _currentUserData!['userType']
                                ?.toString()
                                .toUpperCase() !=
                            'LOCAL') ...[
                      _buildSectionTitle(
                        'Management',
                        Icons.admin_panel_settings_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildUserManagementCard(),
                      const SizedBox(height: 32),
                    ],

                    // Session Section
                    _buildSectionTitle('Session', Icons.logout_rounded),
                    const SizedBox(height: 16),
                    _buildLogoutCard(),
                    const SizedBox(height: 32),

                    // Version Info
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Gothong Southern Booking System',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Version 1.0.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEB3B).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF1B5E20), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    if (_currentUserData == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(
          child: Text(
            'No user logged in',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final fullName = _currentUserData!['fullName'] ?? 'Unknown User';
    final userType = _currentUserData!['userType'] ?? 'Unknown';
    final initials = _userSession.getInitials();

    // Decode profile picture if available
    Uint8List? imgBytes;
    if (_currentUserData!['profilePicture'] != null &&
        _currentUserData!['profilePicture']!.isNotEmpty) {
      try {
        imgBytes = base64Decode(_currentUserData!['profilePicture']!);
      } catch (_) {}
    }

    return InkWell(
      onTap: () => _showViewProfileDialog(),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B5E20).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: imgBytes != null
                    ? Colors.transparent
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
                image: imgBytes != null
                    ? DecorationImage(
                        image: MemoryImage(imgBytes),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imgBytes == null
                  ? Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEB3B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          userType,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1B5E20),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[300],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserManagementCard() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserManagementPage()),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEB3B).withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.people_rounded,
                color: Color(0xFF1B5E20),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'User Management',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage users and permissions',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey[400],
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutCard() {
    return InkWell(
      onTap: () => _showLogoutDialog(),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: Colors.red[700],
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sign out of your account',
                    style: TextStyle(fontSize: 13, color: Colors.red[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.red[400], size: 28),
          ],
        ),
      ),
    );
  }

  void _showViewProfileDialog() {
    if (_currentUserData == null) return;

    final fullName = _currentUserData!['fullName'] ?? 'Unknown User';
    final firstName = _currentUserData!['firstName'] ?? '';
    final middleName = _currentUserData!['middleName'] ?? '';
    final lastName = _currentUserData!['lastName'] ?? '';
    final email = _currentUserData!['email'] ?? 'N/A';
    final number = _currentUserData!['number'] ?? 'N/A';
    final userCode = _currentUserData!['userCode'] ?? 'N/A';
    final userType = _currentUserData!['userType'] ?? 'Unknown';
    final initials = _userSession.getInitials();

    // Decode profile picture if available
    Uint8List? imgBytes;
    if (_currentUserData!['profilePicture'] != null &&
        _currentUserData!['profilePicture']!.isNotEmpty) {
      try {
        imgBytes = base64Decode(_currentUserData!['profilePicture']!);
      } catch (_) {}
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.person, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 8),
                  const Text(
                    'Profile',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Profile Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: imgBytes != null
                            ? Colors.transparent
                            : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        image: imgBytes != null
                            ? DecorationImage(
                                image: MemoryImage(imgBytes),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: imgBytes == null
                          ? Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4AF37),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  userType,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green[300],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Active',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // User Information
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.badge, color: Colors.grey[700], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoField(
                        'First Name',
                        firstName.isEmpty ? 'N/A' : firstName,
                        Icons.person_outline,
                      ),
                      _buildInfoField(
                        'Middle Name',
                        middleName.isEmpty ? 'N/A' : middleName,
                        Icons.person_outline,
                      ),
                      _buildInfoField(
                        'Last Name',
                        lastName.isEmpty ? 'N/A' : lastName,
                        Icons.person_outline,
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Icon(
                            Icons.contact_mail,
                            color: Colors.grey[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Contact Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoField('Email', email, Icons.email),
                      _buildInfoField('Number', number, Icons.phone),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Icon(Icons.shield, color: Colors.grey[700], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Account Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoField(
                        'User Type',
                        userType,
                        Icons.admin_panel_settings,
                      ),
                      _buildInfoField('User Code', userCode, Icons.qr_code),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Edit Profile Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showEditProfileDialog();
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('EDIT PROFILE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    if (_currentUserData == null) return;

    // Store parent context
    final parentContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => _EditProfileDialog(
        userData: _currentUserData!,
        onSave: (updatedData) async {
          try {
            print('Settings: Updating user profile...');
            final userId = _currentUserData!['userId'];
            await _apiService.updateUser(userId, updatedData);
            print('Settings: Profile updated successfully');

            // Update session with new data
            final updatedUserData = Map<String, dynamic>.from(
              _currentUserData!,
            );
            updatedUserData['firstName'] = updatedData['firstName'];
            updatedUserData['middleName'] = updatedData['middleName'];
            updatedUserData['lastName'] = updatedData['lastName'];
            updatedUserData['email'] = updatedData['email'];
            updatedUserData['number'] = updatedData['number'];
            updatedUserData['fullName'] =
                '${updatedData['firstName']} ${updatedData['middleName'] ?? ''} ${updatedData['lastName']}'
                    .trim();

            _userSession.setUser(updatedUserData);
            await _loadCurrentUser();

            print('Settings: Showing success dialog');
            // Use parent context and ensure it's still mounted
            if (mounted && parentContext.mounted) {
              showDialog(
                context: parentContext,
                barrierDismissible: false,
                builder: (context) => const SuccessDialog(
                  title: 'SUCCESS',
                  message: 'Profile Successfully Updated',
                ),
              );
            }
          } catch (e) {
            print('Settings: Error updating profile: $e');
            // Use parent context for error dialog too
            if (mounted && parentContext.mounted) {
              ErrorDialog.show(
                context: parentContext,
                title: 'Error',
                message:
                    'Failed to update profile: ${e.toString().replaceAll('Exception: ', '')}',
              );
            }
          }
        },
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Clear user session
              _userSession.clearUser();

              // Close the dialog
              Navigator.pop(context);

              // Navigate back to landing page and remove all previous routes
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LandingPage()),
                (route) => false, // Remove all previous routes
              );

              // Show success message on the landing page
              Future.delayed(const Duration(milliseconds: 500), () {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logged out successfully!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// Edit Profile Dialog
class _EditProfileDialog extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function(Map<String, dynamic>) onSave;

  const _EditProfileDialog({required this.userData, required this.onSave});

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _numberController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Profile picture
  Uint8List? _imageBytes;
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.userData['firstName'] ?? '',
    );
    _middleNameController = TextEditingController(
      text: widget.userData['middleName'] ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.userData['lastName'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.userData['email'] ?? '',
    );
    _numberController = TextEditingController(
      text: widget.userData['number'] ?? '',
    );
    _passwordController = TextEditingController();

    // Load existing profile picture
    if (widget.userData['profilePicture'] != null &&
        widget.userData['profilePicture']!.isNotEmpty) {
      try {
        _imageBytes = base64Decode(widget.userData['profilePicture']!);
        _base64Image = widget.userData['profilePicture'];
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _numberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 512,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _base64Image = base64Encode(bytes);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
    if (mounted) {
      Navigator.pop(context); // close bottom sheet
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose how to add a photo',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
              const SizedBox(height: 20),
              _sheetOption(
                icon: Icons.camera_alt_rounded,
                label: 'Take Photo',
                color: const Color(0xFF2196F3),
                onTap: () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(height: 12),
              _sheetOption(
                icon: Icons.photo_library_rounded,
                label: 'Choose from Gallery',
                color: const Color(0xFFD4AF37),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              if (_imageBytes != null) ...[
                const SizedBox(height: 12),
                _sheetOption(
                  icon: Icons.delete_outline_rounded,
                  label: 'Remove Photo',
                  color: const Color(0xFFEF5350),
                  onTap: () {
                    setState(() {
                      _imageBytes = null;
                      _base64Image = null;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    String initials = '';
    if (firstName.isNotEmpty) initials += firstName[0].toUpperCase();
    if (lastName.isNotEmpty) initials += lastName[0].toUpperCase();
    return initials.isEmpty ? '?' : initials;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 450,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.edit, color: Color(0xFFD4AF37)),
                  const SizedBox(width: 8),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Form Fields
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile picture picker
                      Center(
                        child: GestureDetector(
                          onTap: _showImagePickerSheet,
                          child: Stack(
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: _imageBytes != null
                                      ? Colors.transparent
                                      : const Color(0xFF2E7D32),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.12,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  image: _imageBytes != null
                                      ? DecorationImage(
                                          image: MemoryImage(_imageBytes!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: _imageBytes == null
                                    ? Center(
                                        child: Text(
                                          _getInitials(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFD4AF37),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Tap to change photo',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(
                        'First Name',
                        _firstNameController,
                        Icons.person_outline,
                        required: true,
                      ),
                      _buildTextField(
                        'Middle Name',
                        _middleNameController,
                        Icons.person_outline,
                      ),
                      _buildTextField(
                        'Last Name',
                        _lastNameController,
                        Icons.person_outline,
                        required: true,
                      ),
                      _buildTextField(
                        'Email',
                        _emailController,
                        Icons.email,
                        required: true,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _buildTextField(
                        'Number',
                        _numberController,
                        Icons.phone,
                        required: true,
                        keyboardType: TextInputType.phone,
                        maxLength: 11,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter Number';
                          }
                          if (value.trim().length != 11) {
                            return 'Phone number must be exactly 11 digits';
                          }
                          if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                            return 'Phone number must contain only digits';
                          }
                          return null;
                        },
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password (leave blank to keep current)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: const Icon(Icons.lock, size: 20),
                                hintText: 'Enter new password',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('CANCEL'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveProfile,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isLoading ? 'SAVING...' : 'SAVE CHANGES'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool required = false,
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              maxLength: maxLength,
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(icon, size: 20),
                counterText: maxLength != null ? '' : null,
              ),
              validator:
                  validator ??
                  (required
                      ? (value) => value == null || value.trim().isEmpty
                            ? 'Please enter $label'
                            : null
                      : null),
            ),
          ),
        ],
      ),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final updatedData = {
        'firstName': _firstNameController.text.trim(),
        'middleName': _middleNameController.text.trim().isEmpty
            ? null
            : _middleNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'number': _numberController.text.trim(),
        'profilePicture':
            _base64Image ?? '', // Send empty string if null (photo removed)
        'updateUserId': 'SYSTEM',
      };

      if (_passwordController.text.isNotEmpty) {
        updatedData['password'] = _passwordController.text;
      }

      widget.onSave(updatedData);
      Navigator.pop(context);
    }
  }
}
