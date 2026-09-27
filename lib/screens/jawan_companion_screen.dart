import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/rakshak_state.dart';
import '../theme/tactical_theme.dart';

/// Screen 1: Jawan / Personnel Companion View (Android Field UI).
/// Fuses Sehat Setu (Status Halo, 2x2 Vitals Grid, Audio Narration, Emoji Mood Check-in)
/// with PathWise (Bento 28-Day Resilience Heatmap, Inline "Why This?" Explainability, Re-Adapt Moment).
class JawanCompanionScreen extends StatefulWidget {
  final RakshakState appState;

  const JawanCompanionScreen({
    super.key,
    required this.appState,
  });

  @override
  State<JawanCompanionScreen> createState() => _JawanCompanionScreenState();
}

class _JawanCompanionScreenState extends State<JawanCompanionScreen> {
  static const List<String> _breathPhases = [
    'INHALE',
    'HOLD',
    'EXHALE',
    'HOLD',
  ];
  static const List<String> _breathInstructions = [
    'Breathe in slowly through your nose (4s)',
    'Hold breath steady — stabilize heart rate (4s)',
    'Exhale controlled through your mouth (4s)',
    'Hold empty — reset vagus nerve tone (4s)',
  ];

  Timer? _breathingTimer;
  bool _isBreathingActive = false;
  int _currentPhaseIndex = 0;
  double _phaseElapsedSeconds = 0.0;
  int _completedCycles = 0;

  @override
  void dispose() {
    _breathingTimer?.cancel();
    super.dispose();
  }

  void _toggleBreathingDrill() {
    if (_isBreathingActive) {
      _breathingTimer?.cancel();
      setState(() {
        _isBreathingActive = false;
      });
    } else {
      setState(() {
        _isBreathingActive = true;
        _currentPhaseIndex = 0;
        _phaseElapsedSeconds = 0.0;
      });
      _breathingTimer =
          Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!mounted) return;
        setState(() {
          _phaseElapsedSeconds += 0.1;
          if (_phaseElapsedSeconds >= 4.0) {
            _phaseElapsedSeconds = 0.0;
            _currentPhaseIndex = (_currentPhaseIndex + 1) % 4;
            if (_currentPhaseIndex == 0) {
              _completedCycles++;
            }
          }
        });
      });
    }
  }

  void _resetBreathingDrill() {
    _breathingTimer?.cancel();
    setState(() {
      _isBreathingActive = false;
      _currentPhaseIndex = 0;
      _phaseElapsedSeconds = 0.0;
      _completedCycles = 0;
    });
  }

  double _calculateBreathingScale() {
    if (!_isBreathingActive) return 0.72;
    final progress = (_phaseElapsedSeconds / 4.0).clamp(0.0, 1.0);
    switch (_currentPhaseIndex) {
      case 0:
        return 0.62 + (0.38 * progress);
      case 1:
        return 1.0;
      case 2:
        return 1.0 - (0.38 * progress);
      case 3:
      default:
        return 0.62;
    }
  }

  void _showConfidentialSupportModal(BuildContext context) {
    widget.appState.submitConfidentialMoRequest();
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: TacticalColors.bgSlateCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(
              color: TacticalColors.emeraldPrimary,
              width: 1.5,
            ),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: TacticalColors.emeraldPrimary.withAlpha(35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: TacticalColors.emeraldPrimary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Encrypted Medical Request Sent',
                  style: TextStyle(
                    color: TacticalColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: TacticalColors.bgDeepNavy,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: TacticalColors.emeraldPrimary.withAlpha(110),
                  ),
                ),
                child: const Text(
                  'Request submitted privately. No officer or peer is notified.',
                  style: TextStyle(
                    color: TacticalColors.emeraldPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                '• Routed directly to Battalion Regimental Medical Officer (RMO) via end-to-end encrypted channel.\n'
                '• Zero logging in Coy Commander Roster, Service Book, or ACR.\n'
                '• Private tele-consultation callback scheduled within 30 mins.',
                style: TextStyle(
                  color: TacticalColors.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 15,
                    color: TacticalColors.cyberTeal,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Token ID: ${widget.appState.confidentialTicketId ?? "MHA-MED-4821"}',
                    style: const TextStyle(
                      color: TacticalColors.cyberTeal,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: TacticalColors.emeraldPrimary,
                foregroundColor: const Color(0xFF042F2E),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
              icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: const Text(
                'Acknowledged',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    final sunlight = state.isSunlightMode;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 740),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. PRIVACY & ANTI-STIGMA GUARDRAIL BANNER (Crucial SIH Criteria)
              _buildPrivacyGuardrailBanner(sunlight),
              const SizedBox(height: 14),

              // Sehat Setu Greeting Bar + Audio Voice Readout Pill
              _buildSehatSetuGreetingBar(state, sunlight),
              const SizedBox(height: 14),

              // Audio Narration Readout Banner (Sehat Setu Voice-First UX)
              if (state.isAudioNarrationActive) ...[
                _buildAudioNarrationBanner(state, sunlight),
                const SizedBox(height: 14),
              ],

              // 2. FORCE RESILIENCE & STRESS INDEX (FRSI) STATUS HALO & 2x2 VITAL TILES
              _buildFrsiStatusHaloCard(state, sunlight),
              const SizedBox(height: 16),

              // 3. DAILY 30-SECOND RAPID WELLNESS CHECK-IN (Sehat Setu Emojis + PathWise Chips)
              _buildRapidWellnessCheckInCard(context, state, sunlight),
              const SizedBox(height: 16),

              // PathWise Bento Card: 28-Day Patrol Resilience & Recovery Heatmap
              _buildPathWiseHeatmapBentoCard(state, sunlight),
              const SizedBox(height: 16),

              // 4. TACTICAL DE-ESCALATION BOX BREATHING DRILL
              _buildBoxBreathingDrillCard(sunlight),
              const SizedBox(height: 16),

              // 5. CONFIDENTIAL WELFARE SUPPORT BUTTON
              _buildConfidentialSupportSection(context, state, sunlight),
            ],
          ),
        ),
      ),
    );
  }

  /// 1. Privacy & Anti-Stigma Guardrail Banner
  Widget _buildPrivacyGuardrailBanner(bool sunlight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: sunlight
              ? [
                  const Color(0xFFE1F3E7),
                  const Color(0xFFDCEEF5),
                ]
              : [
                  TacticalColors.emeraldPrimary.withAlpha(38),
                  TacticalColors.cyberTeal.withAlpha(22),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: TacticalColors.emeraldPrimary.withAlpha(150),
          width: 1.3,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TacticalColors.emeraldPrimary.withAlpha(45),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: TacticalColors.emeraldPrimary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ANTI-STIGMA MEDICAL FIREWALL ACTIVE',
                  style: TextStyle(
                    color: TacticalColors.emeraldPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.9,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '🔒 MHA Medical Confidentiality: Data is strictly accessible to Unit Medical Officers. Fully excluded from Service Records, Conduct Sheets, and Annual Performance Appraisals (ACR).',
                  style: TextStyle(
                    color: TacticalColors.textMain(sunlight),
                    fontSize: 12.8,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Sehat Setu Greeting Bar (`नमस्ते, जवान 🙏` + `🔊 सुनें / Listen` Pill)
  Widget _buildSehatSetuGreetingBar(RakshakState state, bool sunlight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: TacticalColors.cardBg(sunlight),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TacticalColors.borderCol(sunlight)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.isHindiLanguage
                    ? 'नमस्ते, कांस्टेबल प्रदीप जी 🙏'
                    : 'Jai Hind, CT Pradeep Meena 👋',
                style: TextStyle(
                  color: TacticalColors.textMain(sunlight),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '84 Bn CRPF • Delta Coy (Forward Post) • Wearable Band Synced ☁️✓',
                style: TextStyle(
                  color: TacticalColors.textDim(sunlight),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: state.toggleAudioNarration,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: state.isAudioNarrationActive
                    ? TacticalColors.cyberTeal.withAlpha(38)
                    : TacticalColors.innerWellBg(sunlight),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: state.isAudioNarrationActive
                      ? TacticalColors.cyberTeal
                      : TacticalColors.borderCol(sunlight),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    state.isAudioNarrationActive
                        ? Icons.volume_up_rounded
                        : Icons.volume_mute_rounded,
                    size: 16,
                    color: TacticalColors.cyberTeal,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    state.isHindiLanguage
                        ? '🔊 सुनें (Listen)'
                        : '🔊 Listen Readout',
                    style: TextStyle(
                      color: TacticalColors.textMain(sunlight),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioNarrationBanner(RakshakState state, bool sunlight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: TacticalColors.cyberTeal.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TacticalColors.cyberTeal.withAlpha(130)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.graphic_eq_rounded,
            color: TacticalColors.cyberTeal,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              state.jawanAudioNarrationText,
              style: TextStyle(
                color: TacticalColors.textMain(sunlight),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Force Resilience & Stress Index (FRSI) Dial + Sehat Setu Status Halo & 2x2 Vitals Grid
  Widget _buildFrsiStatusHaloCard(RakshakState state, bool sunlight) {
    final statusColor = state.jawanStatusColor;

    return TacticalCard(
      isSunlightMode: sunlight,
      borderColor: statusColor.withAlpha(140),
      leftAccentColor: statusColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TacticalSectionHeader(
            icon: Icons.radar_rounded,
            bentoTag: '⚡ Sehat Setu Status Halo × PathWise AI Telemetry',
            title: 'Force Resilience & Stress Index (FRSI)',
            subtitle: '3-second glanceable readiness halo + multimodal biometrics',
            accentColor: statusColor,
            isSunlightMode: sunlight,
            trailing: TacticalStatusChip(
              label: state.jawanStatusChipLabel,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 18),

          // Hero Halo + Score Details Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 450;

              // Sehat Setu Status Halo + Animated Radial FRSI Gauge
              final haloDialWidget = TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 78.0,
                  end: state.jawanFrsiScore.toDouble(),
                ),
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeOutCubic,
                builder: (context, animatedScore, _) {
                  return Container(
                    width: 168,
                    height: 168,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor.withAlpha(22),
                    ),
                    child: CustomPaint(
                      painter: _FrsiRadialGaugePainter(
                        score: animatedScore,
                        activeColor: statusColor,
                        trackColor: TacticalColors.innerWellBg(sunlight),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.jawanFrsiScore >= 70
                                  ? '🟢'
                                  : state.jawanFrsiScore >= 50
                                      ? '🟡'
                                      : '🔴',
                              style: const TextStyle(fontSize: 15),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${animatedScore.round()}',
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 34,
                                      fontWeight: FontWeight.w900,
                                      height: 1.05,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '/100',
                                    style: TextStyle(
                                      color: TacticalColors.textDim(sunlight),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              state.jawanHaloVerdictWord,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );

              final summaryRightColumn = Column(
                crossAxisAlignment: isCompact
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current FRSI: ${state.jawanFrsiScore}/100 (${state.jawanStatusSubtext})',
                    textAlign: isCompact ? TextAlign.center : TextAlign.left,
                    style: TextStyle(
                      color: TacticalColors.textMain(sunlight),
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: TacticalColors.innerWellBg(sunlight),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: TacticalColors.borderCol(sunlight),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.psychology_alt_rounded,
                          color: statusColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.aiInsightSummary,
                            style: TextStyle(
                              color: TacticalColors.textSub(sunlight),
                              fontSize: 12.5,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // PathWise "Why this?" Inline Explainability Trigger + Tier Legend
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      InkWell(
                        onTap: state.toggleJawanWhyThis,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: TacticalColors.pathwiseIndigo.withAlpha(32),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  TacticalColors.pathwiseIndigo.withAlpha(120),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.auto_awesome_rounded,
                                size: 13,
                                color: Color(0xFF818CF8),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                state.showJawanWhyThis
                                    ? 'Hide AI Breakdown'
                                    : 'Why this FRSI? (AI Explainability)',
                                style: const TextStyle(
                                  color: Color(0xFF818CF8),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _buildMiniTierLegend(
                        'Combat Ready',
                        TacticalColors.emeraldPrimary,
                        state.jawanStatusTier == FrsiStatusTier.combatReady,
                        sunlight,
                      ),
                      _buildMiniTierLegend(
                        'Operational Fatigue',
                        TacticalColors.warningAmber,
                        state.jawanStatusTier ==
                            FrsiStatusTier.operationalFatigue,
                        sunlight,
                      ),
                      _buildMiniTierLegend(
                        'High Stress Alert',
                        TacticalColors.criticalRed,
                        state.jawanStatusTier == FrsiStatusTier.highStressAlert,
                        sunlight,
                      ),
                    ],
                  ),
                ],
              );

              if (isCompact) {
                return Column(
                  children: [
                    haloDialWidget,
                    const SizedBox(height: 14),
                    summaryRightColumn,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  haloDialWidget,
                  const SizedBox(width: 20),
                  Expanded(child: summaryRightColumn),
                ],
              );
            },
          ),

          // PathWise Inline "Why this?" Expanding Explainability Drawer
          if (state.showJawanWhyThis) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TacticalColors.pathwiseIndigo.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: TacticalColors.pathwiseIndigo.withAlpha(100),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✨ PATHWISE TRANSPARENT AI FEATURE ATTRIBUTION (NO BLACK-BOX):',
                    style: TextStyle(
                      color: Color(0xFF818CF8),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '• Sleep Architecture (38% weight): Selected "${state.selectedSleep}" → Deficit +${state.jawanSleepDeficit.toStringAsFixed(1)}h\n'
                    '• Wearable Autonomic Telemetry (34% weight): Resting Pulse ${state.jawanRestingPulse} bpm, SpO2 ${state.jawanSpo2}%, HRV ${state.jawanHrvMs} ms\n'
                    '• Field Self-Report (28% weight): Fatigue "${state.selectedFatigue}", Mental State "${state.selectedDistress}"',
                    style: TextStyle(
                      color: TacticalColors.textSub(sunlight),
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          Divider(color: TacticalColors.borderCol(sunlight), height: 1),
          const SizedBox(height: 14),

          // Sehat Setu Vitals Grid (Responsive: 3 columns on wide, stacked cleanly inside each tile)
          LayoutBuilder(
            builder: (context, vitalConstraints) {
              final pulseTile = _buildVitalTelemetryTile(
                emoji: '❤️',
                label: 'Resting Pulse',
                value: '${state.jawanRestingPulse} bpm',
                statusWord: state.jawanRestingPulse > 88 ? 'Elevated' : 'Normal',
                accentColor: state.jawanRestingPulse > 88
                    ? TacticalColors.criticalRed
                    : state.jawanRestingPulse > 78
                        ? TacticalColors.warningAmber
                        : TacticalColors.emeraldPrimary,
                sunlight: sunlight,
              );
              final spo2Tile = _buildVitalTelemetryTile(
                emoji: '🫁',
                label: 'SpO2 Level',
                value: '${state.jawanSpo2}%',
                statusWord: state.jawanSpo2 < 95 ? 'Monitor' : 'Normal',
                accentColor: state.jawanSpo2 < 95
                    ? TacticalColors.warningAmber
                    : TacticalColors.cyberTeal,
                sunlight: sunlight,
              );
              final sleepTile = _buildVitalTelemetryTile(
                emoji: '🌙',
                label: 'Sleep Deficit',
                value: '+${state.jawanSleepDeficit.toStringAsFixed(1)}h',
                statusWord:
                    state.jawanSleepDeficit >= 4.0 ? 'High Debt' : 'Nominal',
                accentColor: state.jawanSleepDeficit >= 4.0
                    ? TacticalColors.criticalRed
                    : state.jawanSleepDeficit >= 2.5
                        ? TacticalColors.warningAmber
                        : TacticalColors.emeraldPrimary,
                sunlight: sunlight,
              );

              if (vitalConstraints.maxWidth < 380) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: pulseTile),
                        const SizedBox(width: 8),
                        Expanded(child: spo2Tile),
                      ],
                    ),
                    const SizedBox(height: 8),
                    sleepTile,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: pulseTile),
                  const SizedBox(width: 10),
                  Expanded(child: spo2Tile),
                  const SizedBox(width: 10),
                  Expanded(child: sleepTile),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMiniTierLegend(
    String text,
    Color color,
    bool isActive,
    bool sunlight,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? color.withAlpha(38)
            : TacticalColors.innerWellBg(sunlight),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isActive ? color : TacticalColors.borderCol(sunlight),
          width: isActive ? 1.2 : 0.8,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? color : TacticalColors.textSub(sunlight),
          fontSize: 11,
          fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildVitalTelemetryTile({
    required String emoji,
    required String label,
    required String value,
    required String statusWord,
    required Color accentColor,
    required bool sunlight,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: TacticalColors.innerWellBg(sunlight),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TacticalColors.borderCol(sunlight)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: TacticalColors.textSub(sunlight),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: accentColor,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            statusWord,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: TacticalColors.textDim(sunlight),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Daily 30-Second Rapid Wellness Check-in
  Widget _buildRapidWellnessCheckInCard(
    BuildContext context,
    RakshakState state,
    bool sunlight,
  ) {
    return TacticalCard(
      isSunlightMode: sunlight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TacticalSectionHeader(
            icon: Icons.fact_check_rounded,
            bentoTag: '🩺 Sehat Setu Mood Check-In × PathWise Quick-Reply Chips',
            title: 'Daily 30-Second Rapid Wellness Check-in',
            subtitle:
                'Tap 3 rapid parameters below to dynamically recalculate live FRSI',
            accentColor: TacticalColors.cyberTeal,
            isSunlightMode: sunlight,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: TacticalColors.innerWellBg(sunlight),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: TacticalColors.borderCol(sunlight)),
              ),
              child: const Text(
                '⏱ ~30 SEC',
                style: TextStyle(
                  color: TacticalColors.cyberTeal,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Parameter 1: Sleep Duration [<4 hrs, 4-6 hrs, 6-8 hrs, 8+ hrs]
          _buildCheckInSelectorGroup(
            indexLabel: '01',
            title: 'Sleep Duration',
            icon: Icons.nights_stay_rounded,
            options: RakshakState.sleepOptions,
            selectedValue: state.selectedSleep,
            onSelect: state.selectSleep,
            sunlight: sunlight,
            colorForOption: (opt) {
              if (opt == '<4 hrs') return TacticalColors.criticalRed;
              if (opt == '4-6 hrs') return TacticalColors.warningAmber;
              return TacticalColors.emeraldPrimary;
            },
          ),
          const SizedBox(height: 15),

          // Parameter 2: Operational Fatigue [Nominal, Moderate, High, Severe]
          _buildCheckInSelectorGroup(
            indexLabel: '02',
            title: 'Operational Fatigue',
            icon: Icons.bolt_rounded,
            options: RakshakState.fatigueOptions,
            selectedValue: state.selectedFatigue,
            onSelect: state.selectFatigue,
            sunlight: sunlight,
            colorForOption: (opt) {
              if (opt == 'Severe' || opt == 'High') {
                return TacticalColors.criticalRed;
              }
              if (opt == 'Moderate') return TacticalColors.warningAmber;
              return TacticalColors.emeraldPrimary;
            },
          ),
          const SizedBox(height: 15),

          // Parameter 3: Mental Distress / Anxiety [Calm, Focused, Stressed, Overwhelmed]
          _buildCheckInSelectorGroup(
            indexLabel: '03',
            title: 'Mental Distress / Anxiety',
            icon: Icons.psychology_rounded,
            options: RakshakState.distressOptions,
            selectedValue: state.selectedDistress,
            onSelect: state.selectDistress,
            sunlight: sunlight,
            emojiMap: RakshakState.distressEmojis,
            colorForOption: (opt) {
              if (opt == 'Overwhelmed') return TacticalColors.criticalRed;
              if (opt == 'Stressed') return TacticalColors.warningAmber;
              return TacticalColors.emeraldPrimary;
            },
          ),
          const SizedBox(height: 18),

          // Submit Check-in Button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: TacticalColors.emeraldPrimary,
                foregroundColor: const Color(0xFF042F2E),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                state.submitWellnessCheckIn();
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          color: state.jawanStatusColor,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Check-in Recalculated: FRSI ${state.jawanFrsiScore}/100 • Status: ${state.jawanStatusChipLabel}',
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              icon: const Icon(Icons.sync_rounded, size: 20),
              label: const Text(
                'Submit Check-in',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),

          // PathWise Signature "Re-Adapt Moment" Inline Explanation Banner
          if (state.reAdaptCaption != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: state.jawanStatusColor.withAlpha(24),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: state.jawanStatusColor.withAlpha(120),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_graph_rounded,
                    size: 18,
                    color: state.jawanStatusColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.reAdaptCaption!,
                      style: TextStyle(
                        color: TacticalColors.textMain(sunlight),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          // Quick Jury Demo Presets
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: TacticalColors.innerWellBg(sunlight),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: TacticalColors.borderCol(sunlight)),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Text(
                  'One-Tap Jury Demo Presets:',
                  style: TextStyle(
                    color: TacticalColors.textDim(sunlight),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildQuickPresetButton(
                      label: '🟢 Combat Ready (94)',
                      color: TacticalColors.emeraldPrimary,
                      onTap: () => state.applyDemoPreset(
                        sleep: '8+ hrs',
                        fatigue: 'Nominal',
                        distress: 'Calm',
                      ),
                    ),
                    _buildQuickPresetButton(
                      label: '🟡 Fatigue (56)',
                      color: TacticalColors.warningAmber,
                      onTap: () => state.applyDemoPreset(
                        sleep: '4-6 hrs',
                        fatigue: 'Moderate',
                        distress: 'Focused',
                      ),
                    ),
                    _buildQuickPresetButton(
                      label: '🔴 High Stress (28)',
                      color: TacticalColors.criticalRed,
                      onTap: () => state.applyDemoPreset(
                        sleep: '<4 hrs',
                        fatigue: 'Severe',
                        distress: 'Overwhelmed',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPresetButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withAlpha(28),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withAlpha(120)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckInSelectorGroup({
    required String indexLabel,
    required String title,
    required IconData icon,
    required List<String> options,
    required String selectedValue,
    required ValueChanged<String> onSelect,
    required bool sunlight,
    required Color Function(String) colorForOption,
    Map<String, String>? emojiMap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: TacticalColors.cyberTeal.withAlpha(30),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                indexLabel,
                style: const TextStyle(
                  color: TacticalColors.cyberTeal,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, size: 15, color: TacticalColors.textSub(sunlight)),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: TacticalColors.textMain(sunlight),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        LayoutBuilder(
          builder: (context, constraints) {
            final useTwoByTwo = constraints.maxWidth < 460 && options.length == 4;
            Widget buildOptionButton(String option) {
              final isSelected = option == selectedValue;
              final activeColor = colorForOption(option);
              final emoji = emojiMap != null ? '${emojiMap[option] ?? ""} ' : '';
              return InkWell(
                onTap: () => onSelect(option),
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeColor.withAlpha(42)
                        : TacticalColors.innerWellBg(sunlight),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? activeColor
                          : TacticalColors.borderCol(sunlight),
                      width: isSelected ? 1.6 : 1.0,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$emoji$option',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected
                          ? activeColor
                          : TacticalColors.textMain(sunlight),
                      fontSize: 12.5,
                      fontWeight:
                          isSelected ? FontWeight.w900 : FontWeight.w600,
                    ),
                  ),
                ),
              );
            }

            if (useTwoByTwo) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: buildOptionButton(options[0])),
                      const SizedBox(width: 8),
                      Expanded(child: buildOptionButton(options[1])),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: buildOptionButton(options[2])),
                      const SizedBox(width: 8),
                      Expanded(child: buildOptionButton(options[3])),
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: options.map((option) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: option == options.last ? 0 : 8,
                    ),
                    child: buildOptionButton(option),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  /// PathWise Bento Card: 28-Day Patrol Resilience & Recovery Heatmap (`PathWiseBentoGrid.tsx`)
  Widget _buildPathWiseHeatmapBentoCard(RakshakState state, bool sunlight) {
    final days = state.resilienceHeatmap28Days;

    return TacticalCard(
      isSunlightMode: sunlight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TacticalSectionHeader(
            icon: Icons.local_fire_department_rounded,
            bentoTag: '⚡ PathWise Bento Grid Architecture',
            title: '28-Day Patrol Resilience & Recovery Heatmap',
            subtitle:
                'Duolingo/PathWise-style circadian stability & check-in streak',
            accentColor: TacticalColors.emeraldPrimary,
            isSunlightMode: sunlight,
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    TacticalColors.emeraldPrimary.withAlpha(45),
                    TacticalColors.cyberTeal.withAlpha(25),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: TacticalColors.emeraldPrimary.withAlpha(120),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🔥 ${state.resilienceStreakDays} Days Active',
                    style: const TextStyle(
                      color: TacticalColors.emeraldPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 7x4 Heatmap Grid (7 days per week x 4 weeks — spacious & legible)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 1.6,
            ),
            itemBuilder: (context, index) {
              final intensity = days[index];
              final isToday = index == days.length - 1;
              Color cellColor;
              if (intensity == 3) {
                cellColor = TacticalColors.emeraldPrimary;
              } else if (intensity == 2) {
                cellColor = TacticalColors.cyberTeal;
              } else if (intensity == 1) {
                cellColor = TacticalColors.warningAmber;
              } else {
                cellColor = TacticalColors.criticalRed;
              }

              return Container(
                decoration: BoxDecoration(
                  color: cellColor,
                  borderRadius: BorderRadius.circular(6),
                  border: isToday
                      ? Border.all(color: Colors.white, width: 1.8)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  isToday ? '★ D${index + 1}' : 'D${index + 1}',
                  style: const TextStyle(
                    color: Color(0xFF042F2E),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 6,
            children: [
              const Text(
                '✓ Resilience Shield ON • Zero ACR Impact',
                style: TextStyle(
                  color: TacticalColors.emeraldPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '★ Today (${state.jawanStatusChipLabel})',
                style: TextStyle(
                  color: TacticalColors.textSub(sunlight),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 4. Tactical De-escalation Box Breathing Drill
  Widget _buildBoxBreathingDrillCard(bool sunlight) {
    final secondsRemaining = (4.0 - _phaseElapsedSeconds).ceil().clamp(1, 4);
    final currentPhaseName = _breathPhases[_currentPhaseIndex];
    final currentInstruction = _breathInstructions[_currentPhaseIndex];
    final scale = _calculateBreathingScale();

    return TacticalCard(
      isSunlightMode: sunlight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TacticalSectionHeader(
            icon: Icons.air_rounded,
            bentoTag: '🧘 Sehat Setu Guided Breathing × Tactical Vagus Reset',
            title: 'Tactical De-Escalation Box Breathing Drill',
            subtitle:
                '4s Inhale • 4s Hold • 4s Exhale • 4s Hold (Field De-Stressing)',
            accentColor: TacticalColors.cyberTeal,
            isSunlightMode: sunlight,
            trailing: _completedCycles > 0
                ? TacticalStatusChip(
                    label: '$_completedCycles Cycles Done',
                    color: TacticalColors.emeraldPrimary,
                    compact: true,
                  )
                : null,
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
            decoration: BoxDecoration(
              color: TacticalColors.innerWellBg(sunlight),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: TacticalColors.borderCol(sunlight)),
            ),
            child: Column(
              children: [
                // 4-Phase Step Strip
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: List.generate(4, (index) {
                    final isCurrent =
                        _isBreathingActive && _currentPhaseIndex == index;
                    final labels = [
                      '4s Inhale',
                      '4s Hold',
                      '4s Exhale',
                      '4s Hold',
                    ];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? TacticalColors.cyberTeal.withAlpha(45)
                            : TacticalColors.cardBg(sunlight),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCurrent
                              ? TacticalColors.cyberTeal
                              : TacticalColors.borderCol(sunlight),
                        ),
                      ),
                      child: Text(
                        labels[index],
                        style: TextStyle(
                          color: isCurrent
                              ? TacticalColors.cyberTeal
                              : TacticalColors.textDim(sunlight),
                          fontSize: 11,
                          fontWeight:
                              isCurrent ? FontWeight.w900 : FontWeight.w600,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),

                // Smooth Animated Countdown Circle
                SizedBox(
                  height: 160,
                  width: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 156,
                        height: 156,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: TacticalColors.borderCol(sunlight),
                            width: 1.5,
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        width: 150 * scale,
                        height: 150 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              TacticalColors.cyberTeal.withAlpha(95),
                              TacticalColors.emeraldPrimary.withAlpha(35),
                            ],
                          ),
                          border: Border.all(
                            color: _isBreathingActive
                                ? TacticalColors.cyberTeal
                                : TacticalColors.borderHighlight,
                            width: 2.5,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isBreathingActive ? currentPhaseName : 'READY',
                            style: const TextStyle(
                              color: TacticalColors.cyberTeal,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isBreathingActive
                                ? '${secondsRemaining}s'
                                : '4-4-4-4',
                            style: TextStyle(
                              color: TacticalColors.textMain(sunlight),
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  _isBreathingActive
                      ? currentInstruction
                      : 'Tap Start to initiate guided 16-second tactical box breathing cycle.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: TacticalColors.textSub(sunlight),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: _isBreathingActive
                            ? TacticalColors.warningAmber
                            : TacticalColors.cyberTeal,
                        foregroundColor: const Color(0xFF042F2E),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 11,
                        ),
                      ),
                      onPressed: _toggleBreathingDrill,
                      icon: Icon(
                        _isBreathingActive
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_fill_rounded,
                        size: 19,
                      ),
                      label: Text(
                        _isBreathingActive
                            ? 'Pause Drill'
                            : 'Start Box Breathing',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (_isBreathingActive || _completedCycles > 0) ...[
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: TacticalColors.textSub(sunlight),
                          side: BorderSide(
                            color: TacticalColors.borderCol(sunlight),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 11,
                          ),
                        ),
                        onPressed: _resetBreathingDrill,
                        icon: const Icon(Icons.replay_rounded, size: 17),
                        label: const Text('Reset'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 5. Confidential Welfare Support Button
  Widget _buildConfidentialSupportSection(
    BuildContext context,
    RakshakState state,
    bool sunlight,
  ) {
    return TacticalCard(
      isSunlightMode: sunlight,
      borderColor: TacticalColors.emeraldPrimary.withAlpha(120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.health_and_safety_rounded,
                color: TacticalColors.emeraldPrimary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'DIRECT MEDICAL OFFICER HOTLINE (ZERO CHAIN-OF-COMMAND LOG)',
                  style: TextStyle(
                    color: TacticalColors.textMain(sunlight),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (state.confidentialTalkRequested)
                const TacticalStatusChip(
                  label: 'Request Sent Privately',
                  color: TacticalColors.emeraldPrimary,
                  compact: true,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Speak directly with your Battalion Medical Officer or Force Psychologist over an encrypted channel. Protected under MHA Welfare Confidentiality Directive.',
            style: TextStyle(
              color: TacticalColors.textDim(sunlight),
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: TacticalColors.innerWellBg(sunlight),
                foregroundColor: TacticalColors.emeraldPrimary,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: TacticalColors.emeraldPrimary,
                    width: 1.6,
                  ),
                ),
              ),
              onPressed: () => _showConfidentialSupportModal(context),
              icon: const Icon(Icons.lock_person_rounded, size: 20),
              label: const Text(
                'Request Confidential Talk with Unit Medical Officer',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter for the animated circular FRSI Radial Gauge + Sehat Setu Halo.
class _FrsiRadialGaugePainter extends CustomPainter {
  final double score;
  final Color activeColor;
  final Color trackColor;

  _FrsiRadialGaugePainter({
    required this.score,
    required this.activeColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - 10;

    const startAngle = 135 * (math.pi / 180);
    const sweepTotal = 270 * (math.pi / 180);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotal,
      false,
      trackPaint,
    );

    final normalized = (score / 100.0).clamp(0.0, 1.0);
    final activeSweep = sweepTotal * normalized;

    final glowPaint = Paint()
      ..color = activeColor.withAlpha(65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      activeSweep,
      false,
      glowPaint,
    );

    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      activeSweep,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FrsiRadialGaugePainter oldDelegate) {
    return oldDelegate.score != score ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.trackColor != trackColor;
  }
}
