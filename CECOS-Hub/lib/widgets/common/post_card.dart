import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive_layout.dart';
import '../../models/post_model.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final VoidCallback? onShare;

  const PostCard({
    super.key,
    required this.post,
    this.onShare,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveLayout.getSpacing(context) / 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(ResponsiveLayout.getSpacing(context)),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child:
                      widget.post.createdByAvatar != null
                          ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: widget.post.createdByAvatar!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Container(
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                            ),
                          )
                          : const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          ),
                ),
                SizedBox(width: ResponsiveLayout.getSpacing(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.createdByName,
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveLayout.getFontSize(
                            context,
                            base: 16,
                          ),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getTimeAgo(widget.post.createdAt),
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveLayout.getFontSize(
                            context,
                            base: 12,
                          ),
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    // Handle menu actions
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$value feature coming soon!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'Report',
                          child: Row(
                            children: [
                              Icon(Icons.flag_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Report Post'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'Hide',
                          child: Row(
                            children: [
                              Icon(Icons.visibility_off_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Hide Post'),
                            ],
                          ),
                        ),
                      ],
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.more_vert,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveLayout.getSpacing(context),
            ),
            child: Text(
              widget.post.description,
              style: GoogleFonts.inter(
                fontSize: ResponsiveLayout.getFontSize(context, base: 14),
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),

          // Media
          if (widget.post.mediaUrl != null) ...[
            SizedBox(height: ResponsiveLayout.getSpacing(context)),
            Container(
              width: double.infinity,
              height: 200,
              margin: EdgeInsets.symmetric(
                horizontal: ResponsiveLayout.getSpacing(context),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: widget.post.mediaUrl!,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        color: AppColors.background,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        color: AppColors.background,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                ),
              ),
            ),
          ],

          SizedBox(height: ResponsiveLayout.getSpacing(context)),

          // Action Buttons
          Padding(
            padding: EdgeInsets.all(ResponsiveLayout.getSpacing(context)),
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    color: AppColors.textSecondary,
                    onTap: widget.onShare ?? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Share feature coming soon!'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: ResponsiveLayout.getSpacing(context) / 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: ResponsiveLayout.getIconSize(context, base: 20),
                  color: color,
                ),
                SizedBox(width: ResponsiveLayout.getSpacing(context) / 2),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveLayout.getFontSize(context, base: 14),
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(target: onTap != null ? 1 : 0)
        .scale(
          duration: 150.ms,
          begin: const Offset(1, 1),
          end: const Offset(0.95, 0.95),
        );
  }
}
