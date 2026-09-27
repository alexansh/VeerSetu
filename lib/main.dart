import 'package:flutter/material.dart';
import 'models/rakshak_state.dart';
import 'screens/jawan_companion_screen.dart';
import 'screens/mo_commander_console_screen.dart';
import 'theme/tactical_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RakshakSenseApp());
}

/// Root widget for RakshakSense (SIH26186 - MHA / CRPF).
/// "AI-Based Predictive Personnel Stress and Welfare Monitoring System for Uniformed Forces"
/// Designed as a fusion of PathWise (Bento Grid & Transparent AI) + Sehat Setu (Floating Island Header, Status Halo & Offline-First UX).
class RakshakSenseApp extends StatefulWidget {
  const RakshakSenseApp({super.key});

  @override
  State<RakshakSenseApp> createState() => _RakshakSenseAppState();
}

class _RakshakSenseAppState extends State<RakshakSenseApp> {
  final RakshakState _appState = RakshakState();
  bool _showSplash = true;

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appState,
      builder: (context, _) {
        return MaterialApp(
          title: 'VeerSetu • RakshakSense (CRPF / MHA)',
          debugShowCheckedModeBanner: false,
          theme: TacticalColors.buildTheme(
            isSunlightMode: _appState.isSunlightMode,
          ),
          home: AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            child: _showSplash
                ? VeerSetuSplashScreen(
                    key: const ValueKey('veersetu_splash'),
                    onFinished: () {
                      if (mounted) {
                        setState(() => _showSplash = false);
                      }
                    },
                  )
                : RakshakShell(
                    key: const ValueKey('veersetu_shell'),
                    appState: _appState,
                    onReplaySplash: () => setState(() => _showSplash = true),
                  ),
          ),
        );
      },
    );
  }
}

/// Main Android shell combining Sehat Setu's Floating Top Island Header + Floating Bottom Pill Dock
/// with PathWise's Bento Workspace Container.
class RakshakShell extends StatelessWidget {
  final RakshakState appState;
  final VoidCallback onReplaySplash;

  const RakshakShell({
    super.key,
    required this.appState,
    required this.onReplaySplash,
  });

  @override
  Widget build(BuildContext context) {
    final isJawanView = appState.viewMode == AppViewMode.jawanCompanion;
    final sunlight = appState.isSunlightMode;

    return Scaffold(
      backgroundColor: TacticalColors.canvasBg(sunlight),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: _buildFloatingBottomNavBar(sunlight),
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sehat Setu Floating Top Island Header + Dual-View Switcher
            _buildFloatingTopIslandHeader(context, sunlight),

            // Sehat Setu Animated Offline-First Room/SQLite Edge Banner
            if (appState.isOfflineEdgeMode)
              _buildOfflineFirstEdgeBanner(sunlight),

            // Active View Body
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: isJawanView
                    ? JawanCompanionScreen(
                        key: const ValueKey('jawan_companion_view'),
                        appState: appState,
                      )
                    : MoCommanderConsoleScreen(
                        key: const ValueKey('mo_commander_console_view'),
                        appState: appState,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sehat Setu `TopRoleSwitcherBar` Floating Island Header + View Switcher
  Widget _buildFloatingTopIslandHeader(BuildContext context, bool sunlight) {
    final isJawan = appState.viewMode == AppViewMode.jawanCompanion;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: TacticalColors.cardBg(sunlight),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: TacticalColors.borderCol(sunlight),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(sunlight ? 18 : 60),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Row: Role Avatar + RAKSHAK SENSE Brand + Sehat Setu Utility Pills
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: onReplaySplash,
                          customBorder: const CircleBorder(),
                          child: const VeerSetuLogoBadge(size: 42),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'VEER SETU • RAKSHAK SENSE',
                                    style: TextStyle(
                                      color: TacticalColors.textMain(sunlight),
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: TacticalColors.emeraldPrimary
                                          .withAlpha(30),
                                      borderRadius: BorderRadius.circular(99),
                                      border: Border.all(
                                        color: TacticalColors.emeraldPrimary
                                            .withAlpha(110),
                                      ),
                                    ),
                                    child: const Text(
                                      'SIH26186',
                                      style: TextStyle(
                                        color: TacticalColors.emeraldPrimary,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                isJawan
                                    ? 'CRPF / MHA • Jawan Field Companion Portal'
                                    : 'CRPF / MHA • Unit Medical Officer & Commander Console',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: TacticalColors.textDim(sunlight),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Right Pills: Language Pill, Offline-First Pill, Sunlight/Dark Theme Toggle
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Language Switcher Pill (Sehat Setu)
                        _buildTopUtilityPill(
                          onTap: appState.toggleLanguage,
                          sunlight: sunlight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🌐', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 5),
                              Text(
                                appState.isHindiLanguage ? 'हिन्दी' : 'EN',
                                style: TextStyle(
                                  color: TacticalColors.textMain(sunlight),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Offline-First Connectivity Pill (Sehat Setu)
                        _buildTopUtilityPill(
                          onTap: appState.toggleOfflineEdgeMode,
                          sunlight: sunlight,
                          bgColor: appState.isOfflineEdgeMode
                              ? TacticalColors.warningAmber.withAlpha(32)
                              : TacticalColors.emeraldPrimary.withAlpha(28),
                          borderColor: appState.isOfflineEdgeMode
                              ? TacticalColors.warningAmber
                              : TacticalColors.emeraldPrimary.withAlpha(120),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: appState.isOfflineEdgeMode
                                      ? TacticalColors.warningAmber
                                      : TacticalColors.emeraldPrimary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                appState.isOfflineEdgeMode
                                    ? 'Offline Edge'
                                    : 'Online',
                                style: TextStyle(
                                  color: appState.isOfflineEdgeMode
                                      ? TacticalColors.warningAmber
                                      : TacticalColors.emeraldPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // PathWise / Sehat Setu Theme Toggle (Sunlight Light vs Tactical Dark)
                        _buildTopUtilityPill(
                          onTap: appState.toggleSunlightMode,
                          sunlight: sunlight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                sunlight ? '☀️' : '🌙',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                sunlight ? 'Sunlight' : 'Dark',
                                style: TextStyle(
                                  color: TacticalColors.textMain(sunlight),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Segmented View Toggle Bar (Required Top Bar View Switcher)
                Container(
                  padding: const EdgeInsets.all(3.5),
                  decoration: BoxDecoration(
                    color: TacticalColors.innerWellBg(sunlight),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TacticalColors.borderCol(sunlight)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildViewSwitchButton(
                          icon: Icons.phone_android_rounded,
                          label: 'Jawan / Personnel Companion',
                          isSelected: isJawan,
                          sunlight: sunlight,
                          onTap: () =>
                              appState.setViewMode(AppViewMode.jawanCompanion),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _buildViewSwitchButton(
                          icon: Icons.dashboard_customize_rounded,
                          label: 'Unit Medical Officer & Commander Console',
                          isSelected: !isJawan,
                          sunlight: sunlight,
                          badgeCount: appState.scheduledInterventionsCount,
                          onTap: () => appState
                              .setViewMode(AppViewMode.moCommanderConsole),
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
    );
  }

  Widget _buildTopUtilityPill({
    required VoidCallback onTap,
    required bool sunlight,
    required Widget child,
    Color? bgColor,
    Color? borderColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bgColor ?? TacticalColors.innerWellBg(sunlight),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: borderColor ?? TacticalColors.borderCol(sunlight),
          ),
        ),
        child: child,
      ),
    );
  }

  /// Sehat Setu Offline-First Room/SQLite Engine Banner (`TopRoleSwitcherBar.kt`)
  Widget _buildOfflineFirstEdgeBanner(bool sunlight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: TacticalColors.warningAmber.withAlpha(28),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: TacticalColors.warningAmber),
            ),
            child: Row(
              children: [
                const Text('⚡', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'OFFLINE-FIRST BUNKER / HIGH-ALTITUDE ENGINE ACTIVE',
                        style: TextStyle(
                          color: TacticalColors.warningAmber,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Local encrypted Room/SQLite instant writes (0ms) · Auto-syncs to Battalion MO Server when patrol signal returns',
                        style: TextStyle(
                          color: TacticalColors.textSub(sunlight),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: TacticalColors.warningAmber,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '${appState.checkInCount + 1} queued',
                    style: const TextStyle(
                      color: Color(0xFF0B1120),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Sehat Setu `FloatingBottomNavBar.kt` Rounded 28dp Floating Pill Dock
  Widget _buildFloatingBottomNavBar(bool sunlight) {
    final isJawan = appState.viewMode == AppViewMode.jawanCompanion;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: TacticalColors.cardBg(sunlight),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: TacticalColors.borderCol(sunlight),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(sunlight ? 30 : 110),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildFloatingDockItem(
              emoji: '🪖',
              label: 'Jawan Companion',
              isSelected: isJawan,
              sunlight: sunlight,
              onTap: () => appState.setViewMode(AppViewMode.jawanCompanion),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildFloatingDockItem(
              emoji: '👨‍⚕️',
              label: 'MO & Commander',
              isSelected: !isJawan,
              sunlight: sunlight,
              badgeCount: appState.scheduledInterventionsCount,
              onTap: () => appState.setViewMode(AppViewMode.moCommanderConsole),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingDockItem({
    required String emoji,
    required String label,
    required bool isSelected,
    required bool sunlight,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? TacticalColors.emeraldPrimary.withAlpha(35)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: isSelected
              ? Border.all(
                  color: TacticalColors.emeraldPrimary.withAlpha(140),
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected
                      ? TacticalColors.emeraldPrimary
                      : TacticalColors.textSub(sunlight),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ),
            if (badgeCount > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: TacticalColors.emeraldPrimary,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Color(0xFF042F2E),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildViewSwitchButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required bool sunlight,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? TacticalColors.emeraldPrimary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? const Color(0xFF042F2E)
                  : TacticalColors.textSub(sunlight),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF042F2E)
                      : TacticalColors.textSub(sunlight),
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ),
            if (badgeCount > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF042F2E)
                      : TacticalColors.emeraldPrimary.withAlpha(45),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: TacticalColors.emeraldPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Custom vector-drawn VeerSetu / RakshakSense Shield + Valor Star + ECG Pulse Logo
class VeerSetuLogoBadge extends StatelessWidget {
  final double size;

  const VeerSetuLogoBadge({
    super.key,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _VeerSetuLogoPainter(),
      ),
    );
  }
}

class _VeerSetuLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.5);

    // 1. Background Circle
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0A192F), Color(0xFF063B3A)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawCircle(center, w * 0.48, bgPaint);

    // Outer Border Ring
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..shader = const LinearGradient(
        colors: [TacticalColors.emeraldPrimary, TacticalColors.cyberTeal],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawCircle(center, w * 0.47, ringPaint);

    // 2. Outer Tactical Shield
    final outerShield = Path()
      ..moveTo(w * 0.50, h * 0.13)
      ..lineTo(w * 0.81, h * 0.25)
      ..lineTo(w * 0.81, h * 0.49)
      ..cubicTo(w * 0.81, h * 0.69, w * 0.67, h * 0.83, w * 0.50, h * 0.89)
      ..cubicTo(w * 0.33, h * 0.83, w * 0.19, h * 0.69, w * 0.19, h * 0.49)
      ..lineTo(w * 0.19, h * 0.25)
      ..close();
    final shieldPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [TacticalColors.emeraldPrimary, TacticalColors.cyberTeal],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(outerShield, shieldPaint);

    // 3. Inner Dark Core Shield
    final innerShield = Path()
      ..moveTo(w * 0.50, h * 0.18)
      ..lineTo(w * 0.76, h * 0.29)
      ..lineTo(w * 0.76, h * 0.48)
      ..cubicTo(w * 0.76, h * 0.65, w * 0.64, h * 0.77, w * 0.50, h * 0.83)
      ..cubicTo(w * 0.36, h * 0.77, w * 0.24, h * 0.65, w * 0.24, h * 0.48)
      ..lineTo(w * 0.24, h * 0.29)
      ..close();
    final innerPaint = Paint()..color = const Color(0xFF0A192C);
    canvas.drawPath(innerShield, innerPaint);

    // 4. Valor Diamond Crest
    final crest = Path()
      ..moveTo(w * 0.50, h * 0.23)
      ..lineTo(w * 0.545, h * 0.285)
      ..lineTo(w * 0.50, h * 0.34)
      ..lineTo(w * 0.455, h * 0.285)
      ..close();
    canvas.drawPath(crest, Paint()..color = const Color(0xFFF59E0B));

    // 5. ECG Biometric Heartbeat Pulse
    final ecg = Path()
      ..moveTo(w * 0.27, h * 0.51)
      ..lineTo(w * 0.38, h * 0.51)
      ..lineTo(w * 0.42, h * 0.41)
      ..lineTo(w * 0.48, h * 0.63)
      ..lineTo(w * 0.54, h * 0.35)
      ..lineTo(w * 0.59, h * 0.55)
      ..lineTo(w * 0.63, h * 0.51)
      ..lineTo(w * 0.73, h * 0.51);
    final ecgPaint = Paint()
      ..color = const Color(0xFF34D399)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.042
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(ecg, ecgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Animated Splash Screen Intro for VeerSetu / RakshakSense
class VeerSetuSplashScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const VeerSetuSplashScreen({
    super.key,
    required this.onFinished,
  });

  @override
  State<VeerSetuSplashScreen> createState() => _VeerSetuSplashScreenState();
}

class _VeerSetuSplashScreenState extends State<VeerSetuSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) {
        widget.onFinished();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060E1A),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF050B14),
              Color(0xFF0A1628),
              Color(0xFF072227),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: TacticalColors.emeraldPrimary.withAlpha(35),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: TacticalColors.emeraldPrimary.withAlpha(115),
                        ),
                      ),
                      child: const Text(
                        '🇮🇳 MINISTRY OF HOME AFFAIRS • CRPF • SIH26186',
                        style: TextStyle(
                          color: Color(0xFF6EE7B7),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: 172,
                      height: 172,
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final scale = 0.94 + (_pulseController.value * 0.14);
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: 156,
                                  height: 156,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: TacticalColors.emeraldPrimary
                                        .withAlpha(20),
                                    border: Border.all(
                                      color: TacticalColors.emeraldPrimary
                                          .withAlpha(75),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              child!,
                            ],
                          );
                        },
                        child: const VeerSetuLogoBadge(size: 116),
                      ),
                    ),
                    const SizedBox(height: 18),
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                        children: [
                          TextSpan(
                            text: 'VEER',
                            style: TextStyle(color: Color(0xFFF8FAFC)),
                          ),
                          TextSpan(
                            text: 'SETU',
                            style: TextStyle(
                              color: TacticalColors.emeraldPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'RAKSHAK SENSE • वीर सेतु सुरक्षा कवच',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: TacticalColors.cyberTeal,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'हर जवान के स्वास्थ्य, मनोबल और कल्याण का स्मार्ट साथी',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFF1F5F9),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'AI-Based Predictive Stress & Welfare Monitoring System for Uniformed Forces',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: widget.onFinished,
                      style: FilledButton.styleFrom(
                        backgroundColor: TacticalColors.emeraldPrimary,
                        foregroundColor: const Color(0xFF042F2E),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text(
                        'Launch Tactical Console',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
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

