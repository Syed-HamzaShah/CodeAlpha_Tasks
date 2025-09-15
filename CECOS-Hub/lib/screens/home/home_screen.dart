import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../utils/app_colors.dart';
import '../../utils/responsive_layout.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_posts_service.dart';
import '../../widgets/common/post_card.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);

    // Initialize posts stream using the provider
    final postsService = Provider.of<SupabasePostsService>(
      context,
      listen: false,
    );
    postsService.initializePostsStream();

    // Register posts service with auth service for cleanup
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.setPostsService(postsService);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Top App Bar container
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
                    Container(
                      padding: EdgeInsets.all(
                        ResponsiveLayout.getSpacing(context),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.school,
                        color: AppColors.primary,
                        size: ResponsiveLayout.getIconSize(context, base: 28),
                      ),
                    ),
                    SizedBox(width: ResponsiveLayout.getSpacing(context)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CECOS Hub',
                            style: GoogleFonts.inter(
                              fontSize: ResponsiveLayout.getFontSize(
                                context,
                                base: 22,
                              ),
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Welcome ${currentUser?.name ?? 'Student'}',
                            style: GoogleFonts.inter(
                              fontSize: ResponsiveLayout.getFontSize(
                                context,
                                base: 14,
                              ),
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: ResponsiveLayout.getIconSize(context, base: 24),
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

              // Feed Section
              Expanded(child: _buildFeedTab()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedTab() {
    return Consumer<SupabasePostsService>(
      builder: (context, postsService, child) {
        if (postsService.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
                SizedBox(height: ResponsiveLayout.getSpacing(context)),
                Text(
                  'Loading posts...',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: ResponsiveLayout.getFontSize(context, base: 16),
                  ),
                ),
              ],
            ),
          );
        }

        if (postsService.posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(
                    ResponsiveLayout.getSpacing(context) * 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.post_add,
                    size: ResponsiveLayout.getIconSize(context, base: 64),
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: ResponsiveLayout.getSpacing(context) * 2),
                Text(
                  'No Posts Yet',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveLayout.getFontSize(context, base: 24),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: ResponsiveLayout.getSpacing(context)),
                Text(
                  'Be the first to share university updates!',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveLayout.getFontSize(context, base: 16),
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await postsService.initializePostsStream();
          },
          color: AppColors.primary,
          child: ListView.builder(
            padding: ResponsiveLayout.getPadding(context),
            itemCount: postsService.posts.length,
            itemBuilder: (context, index) {
              final post = postsService.posts[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: ResponsiveLayout.getSpacing(context),
                ),
                child: PostCard(post: post)
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: index * 100),
                      duration: 600.ms,
                    )
                    .slideX(begin: 0.3, end: 0),
              );
            },
          ),
        );
      },
    );
  }
}
