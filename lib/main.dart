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
          title: 'RakshakSense • CRPF / MHA',
          debugShowCheckedModeBanner: false,
          theme: TacticalColors.buildTheme(
            isSunlightMode: _appState.isSunlightMode,
          ),
          home: RakshakShell(appState: _appState),
        );
      },
    );
  }
}

/// Main Android shell combining Sehat Setu's Floating Top Island Header + Floating Bottom Pill Dock
/// with PathWise's Bento Workspace Container.
class RakshakShell extends StatelessWidget {
  final RakshakState appState;

  const RakshakShell({
    super.key,
    required this.appState,
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
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: TacticalColors.emeraldPrimary.withAlpha(35),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  TacticalColors.emeraldPrimary.withAlpha(140),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isJawan ? '🪖' : '👨‍⚕️',
                            style: const TextStyle(fontSize: 18),
                          ),
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
                                    'RAKSHAK SENSE',
                                    style: TextStyle(
                                      color: TacticalColors.textMain(sunlight),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
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
