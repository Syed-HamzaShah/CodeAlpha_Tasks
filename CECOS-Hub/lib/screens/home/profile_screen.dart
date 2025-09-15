import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive_layout.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String? _selectedDepartment;
  String? _selectedSemester;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _selectedDepartment = user?.department;
    _selectedSemester = user?.semester;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showImageUploadDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Update Profile Picture',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            content: Container(
              color: AppColors.cardBackground,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.photo_camera,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Photo Upload',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Image upload functionality will be available when Firebase Storage is configured. Profile pictures are currently generated automatically.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.updateProfile(
      name: _nameController.text.trim(),
      department: _selectedDepartment,
      semester: _selectedSemester,
    );

    if (success) {
      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Container(
                padding: ResponsiveLayout.getPadding(context),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
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
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Profile',
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveLayout.getFontSize(
                            context,
                            base: 20,
                          ),
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (_isEditing) {
                          _saveProfile();
                        } else {
                          setState(() => _isEditing = true);
                        }
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              _isEditing
                                  ? AppColors.success
                                  : AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _isEditing ? Icons.check : Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().slideY(
                begin: -1,
                duration: 600.ms,
                curve: Curves.easeOut,
              ),

              // Profile Content
              Expanded(
                child: SingleChildScrollView(
                  padding: ResponsiveLayout.getPadding(context),
                  child: Column(
                    children: [
                      SizedBox(height: ResponsiveLayout.getSpacing(context)),

                      // Profile Picture Section
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.primaryGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child:
                                  user?.profileImageUrl != null
                                      ? ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: user!.profileImageUrl!,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          placeholder:
                                              (context, url) => Container(
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      AppColors.primaryGradient,
                                                ),
                                                child: const Icon(
                                                  Icons.person,
                                                  size: 60,
                                                  color: Colors.white,
                                                ),
                                              ),
                                          errorWidget:
                                              (context, url, error) =>
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      gradient:
                                                          AppColors
                                                              .primaryGradient,
                                                    ),
                                                    child: const Icon(
                                                      Icons.person,
                                                      size: 60,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                        ),
                                      )
                                      : const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.white,
                                      ),
                            ),
                            if (_isEditing)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _showImageUploadDialog,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ).animate().scale(
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      ),

                      SizedBox(
                        height: ResponsiveLayout.getSpacing(context) * 2,
                      ),

                      // Profile Information Card
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
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child:
                            _isEditing
                                ? _buildEditForm()
                                : _buildProfileInfo(user),
                      ).animate().slideY(
                        begin: 0.3,
                        duration: 600.ms,
                        curve: Curves.easeOut,
                        delay: 200.ms,
                      ),

                      SizedBox(
                        height: ResponsiveLayout.getSpacing(context) * 2,
                      ),

                      // Action Buttons
                      if (!_isEditing) ...[
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
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildActionButton(
                                icon: Icons.notifications,
                                title: 'Notifications',
                                subtitle:
                                    'Manage your notification preferences',
                                onTap:
                                    () =>
                                        _showComingSoonDialog('Notifications'),
                              ),
                              const Divider(height: 32),
                              _buildActionButton(
                                icon: Icons.security,
                                title: 'Privacy & Security',
                                subtitle: 'Control your account security',
                                onTap:
                                    () => _showComingSoonDialog(
                                      'Privacy & Security',
                                    ),
                              ),
                              const Divider(height: 32),
                              _buildActionButton(
                                icon: Icons.help,
                                title: 'Help & Support',
                                subtitle: 'Get help and contact support',
                                onTap:
                                    () =>
                                        _showComingSoonDialog('Help & Support'),
                              ),
                              const Divider(height: 32),
                              _buildActionButton(
                                icon: Icons.logout,
                                title: 'Sign Out',
                                subtitle: 'Sign out of your account',
                                onTap: () => _showSignOutDialog(),
                                isDestructive: true,
                              ),
                            ],
                          ),
                        ).animate().slideY(
                          begin: 0.3,
                          duration: 600.ms,
                          curve: Curves.easeOut,
                          delay: 400.ms,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo(user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Information',
          style: GoogleFonts.inter(
            fontSize: ResponsiveLayout.getFontSize(context, base: 20),
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: ResponsiveLayout.getSpacing(context) * 2),
        _buildInfoRow(Icons.person, 'Name', user?.name ?? 'N/A'),
        _buildInfoRow(Icons.email, 'Email', user?.email ?? 'N/A'),
        _buildInfoRow(Icons.business, 'Department', user?.department ?? 'N/A'),
        _buildInfoRow(Icons.school, 'Semester', user?.semester ?? 'N/A'),
        _buildInfoRow(
          Icons.date_range,
          'Joined',
          user?.createdAt != null
              ? '${user!.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'
              : 'N/A',
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit Profile',
            style: GoogleFonts.inter(
              fontSize: ResponsiveLayout.getFontSize(context, base: 20),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveLayout.getSpacing(context) * 2),

          // Name Field
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),

          SizedBox(height: ResponsiveLayout.getSpacing(context)),

          // Department Dropdown
          DropdownButtonFormField<String>(
            value: _selectedDepartment,
            decoration: const InputDecoration(
              labelText: 'Department',
              prefixIcon: Icon(Icons.business),
            ),
            items:
                UserModel.getDepartments().map((department) {
                  return DropdownMenuItem(
                    value: department,
                    child: Text(department, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() => _selectedDepartment = value);
            },
          ),

          SizedBox(height: ResponsiveLayout.getSpacing(context)),

          // Semester Dropdown
          DropdownButtonFormField<String>(
            value: _selectedSemester,
            decoration: const InputDecoration(
              labelText: 'Semester',
              prefixIcon: Icon(Icons.school),
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
          ),

          SizedBox(height: ResponsiveLayout.getSpacing(context) * 2),

          // Cancel Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                final authService = Provider.of<AuthService>(
                  context,
                  listen: false,
                );
                final user = authService.currentUser;
                _nameController.text = user?.name ?? '';
                _selectedDepartment = user?.department;
                _selectedSemester = user?.semester;
                setState(() => _isEditing = false);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveLayout.getSpacing(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveLayout.getFontSize(context, base: 16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveLayout.getSpacing(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          SizedBox(width: ResponsiveLayout.getSpacing(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveLayout.getFontSize(context, base: 12),
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveLayout.getFontSize(context, base: 16),
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isDestructive
                      ? AppColors.error.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isDestructive ? AppColors.error : AppColors.primary,
              size: 24,
            ),
          ),
          SizedBox(width: ResponsiveLayout.getSpacing(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveLayout.getFontSize(context, base: 16),
                    fontWeight: FontWeight.w600,
                    color:
                        isDestructive ? AppColors.error : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveLayout.getFontSize(context, base: 14),
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              feature,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            content: Container(
              color: AppColors.cardBackground,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.construction,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$feature Coming Soon',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This feature is currently under development and will be available in a future update.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Sign Out',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            content: Text(
              'Are you sure you want to sign out of your account?',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  final authService = Provider.of<AuthService>(
                    context,
                    listen: false,
                  );
                  authService.signOut();
                  Navigator.pop(context);
                },
                child: const Text(
                  'Sign Out',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );
  }
}
