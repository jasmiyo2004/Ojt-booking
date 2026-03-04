import 'package:flutter/material.dart';
import 'main_screen.dart';
import '../services/api_service.dart';
import '../services/user_session.dart';
import '../widgets/validation_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  int _selectedRole = 1; // 1 = Admin, 2 = Local

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Check if form is valid
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if username is empty
    if (_usernameController.text.trim().isEmpty) {
      await ValidationDialog.show(
        context,
        'Please enter your username, email, or user code.',
        icon: Icons.person_off_rounded,
      );
      return;
    }

    // Check if password is empty
    if (_passwordController.text.isEmpty) {
      await ValidationDialog.show(
        context,
        'Please enter your password.',
        icon: Icons.lock_outline_rounded,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        selectedRole: _selectedRole,
      );

      if (mounted) {
        // Store user session
        if (response['user'] != null) {
          UserSession().setUser(response['user']);
        }

        // Login successful - navigate to main screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Login successful!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show error dialog instead of snackbar
        String errorMessage = e.toString().replaceAll('Exception: ', '');

        // Customize icon based on error type
        IconData errorIcon = Icons.error_outline_rounded;
        if (errorMessage.toLowerCase().contains('password')) {
          errorIcon = Icons.lock_outline_rounded;
        } else if (errorMessage.toLowerCase().contains('username') ||
            errorMessage.toLowerCase().contains('user')) {
          errorIcon = Icons.person_off_rounded;
        } else if (errorMessage.toLowerCase().contains('inactive')) {
          errorIcon = Icons.block_rounded;
        } else if (errorMessage.toLowerCase().contains('authorized') ||
            errorMessage.toLowerCase().contains('role')) {
          errorIcon = Icons.admin_panel_settings_outlined;
        }

        await ValidationDialog.show(context, errorMessage, icon: errorIcon);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Branded Header
            _buildHeader(context),

            const SizedBox(height: 40),

            // Login Form Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please sign in to continue',
                        style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 40),

                      // Role Selection Dropdown
                      _buildLabel('Login As'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedRole,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            _selectedRole == 1
                                ? Icons.admin_panel_settings
                                : Icons.person,
                            color: Colors.grey[400],
                            size: 22,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFAFAFA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.grey[200]!,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.grey[200]!,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFD4AF37),
                              width: 1.5,
                            ),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('Admin')),
                          DropdownMenuItem(value: 2, child: Text('Local')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value ?? 1;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Email / User Code Field
                      _buildLabel('Email / User Code'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _usernameController,
                        hintText: 'Enter your user code or email',
                        icon: Icons.person_outline_rounded,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email or user code';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Password Field
                      _buildLabel('Password'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _passwordController,
                        hintText: 'Enter your password',
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B5E20),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                            disabledBackgroundColor: Colors.grey[400],
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFFEB3B),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
      child: Column(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 60,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.directions_boat_rounded,
                color: Color(0xFF1B5E20),
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF424242),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey[400], size: 22),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: Colors.grey[400],
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
    );
  }
}
