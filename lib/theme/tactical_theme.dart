import 'package:flutter/material.dart';

/// Unified Design System combining:
/// 1. Tactical Defense Dark Mode & PathWise Bento Architecture
///    (`#0B1120` Deep Navy, `#1E293B` Slate Cards, `#334155` Borders, `#10B981` Emerald, `#14B8A6` Teal)
/// 2. Sehat Setu (VitalSense / NagarSeva) High-Contrast Outdoor Sunlight Palette & Pill Surfaces
class TacticalColors {
  TacticalColors._();

  // Core Tactical Defense Dark Palette (Default)
  static const Color bgDeepNavy = Color(0xFF0B1120);
  static const Color bgSlateCard = Color(0xFF1E293B);
  static const Color bgElevated = Color(0xFF0F172A);
  static const Color borderSubtle = Color(0xFF334155);
  static const Color borderHighlight = Color(0xFF475569);

  // Sehat Setu Sunlight High-Contrast Palette (Optional Field Daylight Toggle)
  static const Color vsBackground = Color(0xFFF4F6FB);
  static const Color vsSurface = Color(0xFFFFFFFF);
  static const Color vsSurfaceVariant = Color(0xFFEEF1F4);
  static const Color vsOutline = Color(0xFFC7CDD4);
  static const Color vsPrimaryTeal = Color(0xFF2E6F8E);
  static const Color vsOnBackground = Color(0xFF0F172A);
  static const Color vsOnSurfaceVariant = Color(0xFF334155);

  // Accents & Status Semantic Colors
  static const Color emeraldPrimary = Color(0xFF10B981);
  static const Color cyberTeal = Color(0xFF14B8A6);
  static const Color pathwiseIndigo = Color(0xFF818CF8);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color criticalRed = Color(0xFFEF4444);
  static const Color infoCyan = Color(0xFF38BDF8);

  // High-Contrast Typography Colors (Dark Mode)
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFFE2E8F0);
  static const Color textMuted = Color(0xFFCBD5E1);

  /// Dynamic surface helpers based on Sunlight Mode vs Tactical Dark Mode.
  static Color canvasBg(bool sunlight) =>
      sunlight ? vsBackground : bgDeepNavy;
  static Color cardBg(bool sunlight) =>
      sunlight ? vsSurface : bgSlateCard;
  static Color innerWellBg(bool sunlight) =>
      sunlight ? vsSurfaceVariant : bgElevated;
  static Color borderCol(bool sunlight) =>
      sunlight ? vsOutline : borderSubtle;
  static Color textMain(bool sunlight) =>
      sunlight ? vsOnBackground : textPrimary;
  static Color textSub(bool sunlight) =>
      sunlight ? const Color(0xFF1E293B) : textSecondary;
  static Color textDim(bool sunlight) =>
      sunlight ? vsOnSurfaceVariant : textMuted;

  /// Builds the Material 3 Theme for RakshakSense.
  static ThemeData buildTheme({bool isSunlightMode = false}) {
    if (isSunlightMode) {
      const lightScheme = ColorScheme.light(
        primary: Color(0xFF0D9488),
        onPrimary: Colors.white,
        secondary: vsPrimaryTeal,
        onSecondary: Colors.white,
        error: Color(0xFFB3261E),
        onError: Colors.white,
        surface: vsSurface,
        onSurface: vsOnBackground,
      );
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: vsBackground,
        colorScheme: lightScheme,
        cardColor: vsSurface,
        dividerColor: vsOutline,
      );
    }

    const darkScheme = ColorScheme.dark(
      primary: emeraldPrimary,
      onPrimary: Color(0xFF042F2E),
      secondary: cyberTeal,
      onSecondary: Color(0xFF042F2E),
      error: criticalRed,
      onError: Colors.white,
      surface: bgSlateCard,
      onSurface: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDeepNavy,
      colorScheme: darkScheme,
      cardColor: bgSlateCard,
      dividerColor: borderSubtle,
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDeepNavy,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: bgSlateCard,
        contentTextStyle: const TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: emeraldPrimary, width: 1.2),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: bgSlateCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: borderSubtle, width: 1.2),
        ),
      ),
    );
  }
}

/// Reusable PathWise Spotlight + Sehat Setu Surface Card (`#1E293B` in dark mode).
class TacticalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final Color? leftAccentColor;
  final bool isSunlightMode;

  const TacticalCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderColor,
    this.backgroundColor,
    this.onTap,
    this.leftAccentColor,
    this.isSunlightMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorder =
        borderColor ?? TacticalColors.borderCol(isSunlightMode);
    final effectiveBg =
        backgroundColor ?? TacticalColors.cardBg(isSunlightMode);

    Widget content = Padding(
      padding: padding,
      child: child,
    );

    if (leftAccentColor != null) {
      content = DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: leftAccentColor!,
              width: 4.5,
            ),
          ),
        ),
        child: content,
      );
    }

    return Material(
      color: effectiveBg,
      elevation: isSunlightMode ? 1.5 : 0,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: effectiveBorder, width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              splashColor: TacticalColors.emeraldPrimary.withAlpha(28),
              highlightColor: TacticalColors.cyberTeal.withAlpha(18),
              child: content,
            )
          : content,
    );
  }
}

/// Tactical & Bento section header with icon badge, PathWise micro-tag, and trailing widget.
class TacticalSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? bentoTag;
  final Widget? trailing;
  final Color accentColor;
  final bool isSunlightMode;

  const TacticalSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.bentoTag,
    this.trailing,
    this.accentColor = TacticalColors.emeraldPrimary,
    this.isSunlightMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 460 && trailing != null;
        final headerRow = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(35),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accentColor.withAlpha(110)),
              ),
              child: Icon(icon, size: 19, color: accentColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (bentoTag != null) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withAlpha(28),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: accentColor.withAlpha(95)),
                      ),
                      child: Text(
                        bentoTag!.toUpperCase(),
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                  Text(
                    title,
                    style: TextStyle(
                      color: TacticalColors.textMain(isSunlightMode),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: TacticalColors.textSub(isSunlightMode),
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!isNarrow && trailing != null) ...[
              const SizedBox(width: 10),
              trailing!,
            ],
          ],
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              headerRow,
              const SizedBox(height: 10),
              trailing!,
            ],
          );
        }
        return headerRow;
      },
    );
  }
}

/// Quiet single-tone status pill inspired by Sehat Setu `VSStatusPill` + Tactical glow dot.
class TacticalStatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool compact;

  const TacticalStatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(32),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(140), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 12 : 14, color: color),
            const SizedBox(width: 5),
          ] else ...[
            Container(
              width: compact ? 7 : 8,
              height: compact ? 7 : 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(140),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: compact ? 11 : 12.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
