import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive_layout.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? ResponsiveLayout.getButtonHeight(context);
    final effectiveBackgroundColor = backgroundColor ?? AppColors.primary;
    final effectiveTextColor =
        textColor ?? (isOutlined ? AppColors.primary : Colors.white);

    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
            ),
          ),
          const SizedBox(width: 12),
        ] else if (icon != null) ...[
          Icon(
            icon,
            size: ResponsiveLayout.getIconSize(context, base: 20),
            color: effectiveTextColor,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          isLoading ? 'Loading...' : text,
          style: GoogleFonts.inter(
            fontSize: ResponsiveLayout.getFontSize(context, base: 16),
            fontWeight: FontWeight.w600,
            color: effectiveTextColor,
          ),
        ),
      ],
    );

    if (isOutlined) {
      return Container(
        width: width,
        height: effectiveHeight,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: effectiveBackgroundColor, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding:
                padding ??
                EdgeInsets.symmetric(
                  horizontal: ResponsiveLayout.getSpacing(context),
                  vertical: ResponsiveLayout.getSpacing(context) / 2,
                ),
          ),
          child: buttonChild,
        ),
      );
    }

    return Container(
      width: width,
      height: effectiveHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isLoading || onPressed == null
                  ? [AppColors.textHint, AppColors.textHint]
                  : [effectiveBackgroundColor, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow:
            onPressed != null && !isLoading
                ? [
                  BoxShadow(
                    color: effectiveBackgroundColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ]
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding:
                padding ??
                EdgeInsets.symmetric(
                  horizontal: ResponsiveLayout.getSpacing(context),
                  vertical: ResponsiveLayout.getSpacing(context) / 2,
                ),
            child: buttonChild,
          ),
        ),
      ),
    );
  }
}
