import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive_layout.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/custom_button.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxWidth = ResponsiveLayout.getMaxWidth(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: ResponsiveLayout.getPadding(context),
              child: Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo and Title
                    Container(
                      padding: EdgeInsets.all(
                        ResponsiveLayout.getSpacing(context) * 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.school,
                        size: ResponsiveLayout.getIconSize(context, base: 60),
                        color: AppColors.primary,
                      ),
                    ).animate().scale(
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    ),

                    SizedBox(height: ResponsiveLayout.getSpacing(context) * 2),

                    Text(
                      'CECOS Hub',
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveLayout.getFontSize(
                          context,
                          base: 32,
                        ),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

                    SizedBox(height: ResponsiveLayout.getSpacing(context) / 2),

                    Text(
                      'Stay connected with your university',
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveLayout.getFontSize(
                          context,
                          base: 16,
                        ),
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

                    SizedBox(height: ResponsiveLayout.getSpacing(context) * 3),

                    // Login Form
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
                                  'Welcome Back',
                                  style: GoogleFonts.inter(
                                    fontSize: ResponsiveLayout.getFontSize(
                                      context,
                                      base: 24,
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

                                // Email Field
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    hintText: 'Enter your email',
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    ).hasMatch(value)) {
                                      return 'Please enter a valid email';
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
                                  height:
                                      ResponsiveLayout.getSpacing(context) * 2,
                                ),

                                // Login Button
                                CustomButton(
                                  text: 'Login',
                                  onPressed: _handleLogin,
                                  isLoading: _isLoading,
                                  height: ResponsiveLayout.getButtonHeight(
                                    context,
                                  ),
                                ),

                                SizedBox(
                                  height: ResponsiveLayout.getSpacing(context),
                                ),

                                // Sign Up Link
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const SignUpScreen(),
                                      ),
                                    );
                                  },
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
                                          text: "Don't have an account? ",
                                        ),
                                        TextSpan(
                                          text: 'Sign Up',
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
                          delay: 600.ms,
                        )
                        .fadeIn(duration: 600.ms, delay: 600.ms),
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
