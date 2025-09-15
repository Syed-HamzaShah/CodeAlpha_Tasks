import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive_layout.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../widgets/common/custom_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedDepartment;
  String? _selectedSemester;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDepartment == null || _selectedSemester == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select department and semester'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.signUp(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      department: _selectedDepartment!,
      semester: _selectedSemester!,
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign up failed. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveLayout.getMaxWidth(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: ResponsiveLayout.getPadding(context),
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    SizedBox(height: ResponsiveLayout.getSpacing(context)),

                    // Header
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Create Account',
                            style: GoogleFonts.inter(
                              fontSize: ResponsiveLayout.getFontSize(
                                context,
                                base: 24,
                              ),
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ).animate().fadeIn(duration: 600.ms),

                    SizedBox(height: ResponsiveLayout.getSpacing(context) * 2),

                    // Sign Up Form
                    Container(
                          padding: EdgeInsets.all(
                            ResponsiveLayout.getSpacing(context) * 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 0,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Join CECOS Hub',
                                  style: GoogleFonts.inter(
                                    fontSize: ResponsiveLayout.getFontSize(
                                      context,
                                      base: 22,
                                    ),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                SizedBox(
                                  height:
                                      ResponsiveLayout.getSpacing(context) * 2,
                                ),

                                // Name Field
                                TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Full Name',
                                    hintText: 'Enter your full name',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your full name';
                                    }
                                    if (value.length < 2) {
                                      return 'Name must be at least 2 characters';
                                    }
                                    return null;
                                  },
                                ),

                                SizedBox(
                                  height: ResponsiveLayout.getSpacing(context),
                                ),

                                // Email Field
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'Email / University ID',
                                    hintText:
                                        'Enter your email or university ID',
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email or university ID';
                                    }
                                    if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                        ).hasMatch(value) &&
                                        !RegExp(
                                          r'^[a-zA-Z0-9]+$',
                                        ).hasMatch(value)) {
                                      return 'Please enter a valid email or university ID';
                                    }
                                    return null;
                                  },
                                ),

                                SizedBox(
                                  height: ResponsiveLayout.getSpacing(context),
                                ),

                                // Department Dropdown
                                DropdownButtonFormField<String>(
                                  value: _selectedDepartment,
                                  decoration: const InputDecoration(
                                    labelText: 'Department',
                                    hintText: 'Select your department',
                                    prefixIcon: Icon(Icons.business_outlined),
                                  ),
                                  items:
                                      UserModel.getDepartments().map((
                                        department,
                                      ) {
                                        return DropdownMenuItem(
                                          value: department,
                                          child: Text(
                                            department,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    setState(() => _selectedDepartment = value);
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Please select your department';
                                    }
                                    return null;
                                  },
                                ),

                                SizedBox(
                                  height: ResponsiveLayout.getSpacing(context),
                                ),

                                // Semester Dropdown
                                DropdownButtonFormField<String>(
                                  value: _selectedSemester,
                                  decoration: const InputDecoration(
                                    labelText: 'Semester',
                                    hintText: 'Select your semester',
                                    prefixIcon: Icon(Icons.school_outlined),
                                  ),
                                  items:
                                      UserModel.getSemesters().map((semester) {
                                        return DropdownMenuItem(
                                          value: semester,
                                          child: Text(semester),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    setState(() => _selectedSemester = value);
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Please select your semester';
                                    }
                                    return null;
                                  },
                                ),

                                SizedBox(
                                  height: ResponsiveLayout.getSpacing(context),
                                ),

                                // Password Field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    hintText: 'Enter your password',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(
                                          () =>
                                              _obscurePassword =
                                                  !_obscurePassword,
                                        );
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),

                                SizedBox(
                                  height: ResponsiveLayout.getSpacing(context),
                                ),

                                // Confirm Password Field
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  decoration: InputDecoration(
                                    labelText: 'Confirm Password',
                                    hintText: 'Confirm your password',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(
                                          () =>
                                              _obscureConfirmPassword =
                                                  !_obscureConfirmPassword,
                                        );
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your password';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),

                                SizedBox(
                                  height:
                                      ResponsiveLayout.getSpacing(context) * 2,
                                ),

                                // Sign Up Button
                                CustomButton(
                                  text: 'Create Account',
                                  onPressed: _handleSignUp,
                                  isLoading: _isLoading,
                                  height: ResponsiveLayout.getButtonHeight(
                                    context,
                                  ),
                                ),

                                SizedBox(
                                  height: ResponsiveLayout.getSpacing(context),
                                ),

                                // Login Link
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.inter(
                                        fontSize: ResponsiveLayout.getFontSize(
                                          context,
                                          base: 14,
                                        ),
                                        color: AppColors.textSecondary,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: "Already have an account? ",
                                        ),
                                        TextSpan(
                                          text: 'Login',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate()
                        .slideY(
                          begin: 0.3,
                          duration: 600.ms,
                          curve: Curves.easeOut,
                          delay: 200.ms,
                        )
                        .fadeIn(duration: 600.ms, delay: 200.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
