import 'package:flutter/material.dart';
import '../models/rakshak_state.dart';
import '../theme/tactical_theme.dart';

/// Screen 2: Unit Medical Officer (MO) & Commander Console (Dashboard View).
/// Fuses PathWise (Bento KPI Grid, Inline "Why This?" AI Explainability)
/// with Sehat Setu (Closed-Loop VSTimeline Referral/Intervention Lifecycle & Glume Stat Cards).
class MoCommanderConsoleScreen extends StatefulWidget {
  final RakshakState appState;

  const MoCommanderConsoleScreen({
    super.key,
    required this.appState,
  });

  @override
  State<MoCommanderConsoleScreen> createState() =>
      _MoCommanderConsoleScreenState();
}

class _MoCommanderConsoleScreenState extends State<MoCommanderConsoleScreen> {
  String _selectedFilter = 'ALL'; // ALL, CRITICAL, AMBER, NORMAL, SCHEDULED

  List<PersonnelTriageItem> _filteredRoster(List<PersonnelTriageItem> items) {
    switch (_selectedFilter) {
      case 'CRITICAL':
        return items
            .where((p) => p.statusTier == FrsiStatusTier.highStressAlert)
            .toList();
      case 'AMBER':
        return items
            .where((p) => p.statusTier == FrsiStatusTier.operationalFatigue)
            .toList();
      case 'NORMAL':
        return items
            .where((p) => p.statusTier == FrsiStatusTier.combatReady)
            .toList();
      case 'SCHEDULED':
        return items.where((p) => p.isInterventionScheduled).toList();
      case 'ALL':
      default:
        return items;
    }
  }

  void _openInterventionActionSheet(
    BuildContext context,
    PersonnelTriageItem person,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: TacticalColors.bgSlateCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        side: BorderSide(color: TacticalColors.borderHighlight, width: 1.2),
      ),
      builder: (sheetContext) {
        final statusColor = person.statusColor;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: TacticalColors.borderHighlight,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: statusColor.withAlpha(35),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: statusColor.withAlpha(120),
                              ),
                            ),
                            child: Icon(
                              Icons.medical_services_rounded,
                              color: statusColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ONE-CLICK WELFARE INTERVENTION PROTOCOL',
                                  style: TextStyle(
                                    color: TacticalColors.cyberTeal,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.9,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  person.nameWithCoy,
                                  style: const TextStyle(
                                    color: TacticalColors.textPrimary,
                                    fontSize: 17.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Force ID: ${person.forceId} • Duty: ${person.dutyDescription}',
                                  style: const TextStyle(
                                    color: TacticalColors.textSecondary,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      TacticalStatusChip(
                        label:
                            'FRSI: ${person.frsiScore} (${person.frsiBandLabel})',
                        color: statusColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: TacticalColors.bgDeepNavy,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: TacticalColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 16,
                              color: statusColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Primary Signal: ${person.primarySignal}',
                                style: const TextStyle(
                                  color: TacticalColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 16,
                          runSpacing: 6,
                          children: [
                            _buildMiniMetric(
                              'Resting Pulse',
                              '${person.restingPulse} bpm',
                            ),
                            _buildMiniMetric('SpO2', '${person.spo2}%'),
                            _buildMiniMetric(
                              'Sleep Deficit',
                              '+${person.sleepDeficitHours.toStringAsFixed(1)}h',
                            ),
                            _buildMiniMetric('HRV', '${person.hrvMs} ms'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    'SELECT DEFENSE WELFARE INTERVENTION ACTION:',
                    style: TextStyle(
                      color: TacticalColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 10),

                  _buildInterventionOptionTile(
                    sheetContext: sheetContext,
                    person: person,
                    icon: Icons.video_call_rounded,
                    actionTitle: 'Schedule Tele-Counseling with MO',
                    subtitle:
                        'Encrypted 1-on-1 video session with Unit Medical Officer / Psychologist.',
                    accentColor: TacticalColors.emeraldPrimary,
                  ),
                  const SizedBox(height: 10),

                  _buildInterventionOptionTile(
                    sheetContext: sheetContext,
                    person: person,
                    icon: Icons.published_with_changes_rounded,
                    actionTitle: 'Recommend 72h Duty Rotation & Rest',
                    subtitle:
                        'Issue non-punitive medical advisory to Coy Commander for temporary post rotation.',
                    accentColor: TacticalColors.warningAmber,
                  ),
                  const SizedBox(height: 10),

                  _buildInterventionOptionTile(
                    sheetContext: sheetContext,
                    person: person,
                    icon: Icons.flight_takeoff_rounded,
                    actionTitle: 'Fast-Track Welfare Leave Request',
                    subtitle:
                        'Priority endorsement to Battalion HQ for compassionate / family welfare leave.',
                    accentColor: TacticalColors.cyberTeal,
                  ),

                  if (person.isInterventionScheduled) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          widget.appState.clearWelfareIntervention(person.id);
                          Navigator.of(sheetContext).pop();
                        },
                        icon: const Icon(
                          Icons.restart_alt_rounded,
                          size: 16,
                          color: TacticalColors.textMuted,
                        ),
                        label: const Text(
                          'Reset Status Tag (Demo)',
                          style: TextStyle(
                            color: TacticalColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniMetric(String label, String val) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              color: TacticalColors.textMuted,
              fontSize: 12,
            ),
          ),
          TextSpan(
            text: val,
            style: const TextStyle(
              color: TacticalColors.cyberTeal,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterventionOptionTile({
    required BuildContext sheetContext,
    required PersonnelTriageItem person,
    required IconData icon,
    required String actionTitle,
    required String subtitle,
    required Color accentColor,
  }) {
    final isSelected = person.scheduledIntervention == actionTitle;

    return InkWell(
      onTap: () {
        widget.appState.assignWelfareIntervention(
          personnelId: person.id,
          interventionAction: actionTitle,
        );
        Navigator.of(sheetContext).pop();
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.task_alt_rounded,
                  color: TacticalColors.emeraldPrimary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Intervention Scheduled for ${person.nameWithCoy}: [$actionTitle]',
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withAlpha(35)
              : TacticalColors.bgDeepNavy,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accentColor : TacticalColors.borderSubtle,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '[$actionTitle]',
                    style: TextStyle(
                      color: isSelected
                          ? accentColor
                          : TacticalColors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: TacticalColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.arrow_forward_ios_rounded,
              size: isSelected ? 20 : 15,
              color: isSelected ? accentColor : TacticalColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    final sunlight = state.isSunlightMode;
    final roster = _filteredRoster(state.triageRoster);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Command Console Header Banner
              _buildCommandConsoleHeader(state, sunlight),
              const SizedBox(height: 16),

              // 1. BATTALION READINESS & WELFARE OVERVIEW (4 Key KPI Metric Cards)
              _buildBattalionReadinessKpiSection(state, sunlight),
              const SizedBox(height: 18),

              // Live Companion Sync Notification
              if (state.checkInSubmitted || state.confidentialTalkRequested) ...[
                _buildLiveFieldTelemetryBanner(state, sunlight),
                const SizedBox(height: 18),
              ],

              // 2. ACTIONABLE PERSONNEL TRIAGE ROSTER & 3. ONE-CLICK INTERVENTIONS
              _buildPersonnelTriageRosterCard(
                context,
                state,
                roster,
                sunlight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommandConsoleHeader(RakshakState state, bool sunlight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: TacticalColors.cardBg(sunlight),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TacticalColors.borderCol(sunlight)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 14,
        runSpacing: 10,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: TacticalColors.cyberTeal.withAlpha(32),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: TacticalColors.cyberTeal.withAlpha(110),
                  ),
                ),
                child: const Icon(
                  Icons.monitor_heart_rounded,
                  color: TacticalColors.cyberTeal,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '84 BATTALION CRPF • MEDICAL OFFICER & COMMANDER CONSOLE',
                      style: TextStyle(
                        color: TacticalColors.textMain(sunlight),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Role-Scoped Firewall: MO sees clinical telemetry • Commander sees anonymized duty readiness',
                      style: TextStyle(
                        color: TacticalColors.textDim(sunlight),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          TacticalStatusChip(
            label:
                '${state.scheduledInterventionsCount} Interventions Scheduled',
            color: state.scheduledInterventionsCount > 0
                ? TacticalColors.emeraldPrimary
                : TacticalColors.cyberTeal,
            icon: Icons.medical_information_rounded,
          ),
        ],
      ),
    );
  }

  /// 1. Battalion Readiness & Welfare Overview (4 Key KPI Metric Cards)
  Widget _buildBattalionReadinessKpiSection(
    RakshakState state,
    bool sunlight,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TacticalSectionHeader(
          icon: Icons.grid_view_rounded,
          bentoTag: '⚡ PathWise Bento KPI Grid × Sehat Setu Glume Stat Cards',
          title: 'Battalion Readiness & Welfare Overview',
          subtitle:
              'Real-time aggregated force wellness telemetry across 4 Companies (120 Personnel)',
          accentColor: TacticalColors.emeraldPrimary,
          isSunlightMode: sunlight,
        ),
        const SizedBox(height: 14),

        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 760;
            final isMedium = constraints.maxWidth >= 420;

            final cards = [
              _buildKpiCard(
                title: 'Total Personnel Monitored',
                primaryValue: '${RakshakState.totalPersonnelMonitored}',
                subValue: '100% Active Telemetry',
                icon: Icons.groups_rounded,
                accentColor: TacticalColors.cyberTeal,
                sunlight: sunlight,
              ),
              _buildKpiCard(
                title: 'Mission Ready (Green)',
                primaryValue: '${RakshakState.baseMissionReadyCount} (86%)',
                subValue: 'FRSI ≥ 70 • Cleared for Ops',
                icon: Icons.verified_rounded,
                accentColor: TacticalColors.emeraldPrimary,
                sunlight: sunlight,
              ),
              _buildKpiCard(
                title: 'Moderate Fatigue (Amber)',
                primaryValue: '${RakshakState.baseModerateFatigueCount} (10%)',
                subValue: 'FRSI 50–69 • Rest Rotation',
                icon: Icons.timelapse_rounded,
                accentColor: TacticalColors.warningAmber,
                sunlight: sunlight,
              ),
              _buildKpiCard(
                title: 'Critical Burnout Risk (Red)',
                primaryValue: '${RakshakState.baseCriticalRiskCount} (4%)',
                subValue: 'FRSI < 50 • Immediate MO Care',
                icon: Icons.gpp_maybe_rounded,
                accentColor: TacticalColors.criticalRed,
                sunlight: sunlight,
              ),
            ];

            if (isWide) {
              return Row(
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 12),
                  Expanded(child: cards[1]),
                  const SizedBox(width: 12),
                  Expanded(child: cards[2]),
                  const SizedBox(width: 12),
                  Expanded(child: cards[3]),
                ],
              );
            } else if (isMedium) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 10),
                      Expanded(child: cards[1]),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: cards[2]),
                      const SizedBox(width: 10),
                      Expanded(child: cards[3]),
                    ],
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  cards[0],
                  const SizedBox(height: 10),
                  cards[1],
                  const SizedBox(height: 10),
                  cards[2],
                  const SizedBox(height: 10),
                  cards[3],
                ],
              );
            }
          },
        ),
        const SizedBox(height: 12),

        // Proportion Readiness Bar (86% Green | 10% Amber | 4% Red)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: TacticalColors.cardBg(sunlight),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TacticalColors.borderCol(sunlight)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'BATTALION FORCE RESILIENCE DISTRIBUTION',
                    style: TextStyle(
                      color: TacticalColors.textDim(sunlight),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.7,
                    ),
                  ),
                  Text(
                    '86% Ready  •  10% Fatigue  •  4% Critical',
                    style: TextStyle(
                      color: TacticalColors.textSub(sunlight),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: SizedBox(
                  height: 9,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 86,
                        child: Container(color: TacticalColors.emeraldPrimary),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        flex: 10,
                        child: Container(color: TacticalColors.warningAmber),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        flex: 4,
                        child: Container(color: TacticalColors.criticalRed),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String primaryValue,
    required String subValue,
    required IconData icon,
    required Color accentColor,
    required bool sunlight,
  }) {
    return TacticalCard(
      isSunlightMode: sunlight,
      padding: const EdgeInsets.all(15),
      leftAccentColor: accentColor,
      borderColor: accentColor.withAlpha(110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: TacticalColors.textSub(sunlight),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(32),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 17, color: accentColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            primaryValue,
            style: TextStyle(
              color: accentColor,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subValue,
            style: TextStyle(
              color: TacticalColors.textDim(sunlight),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveFieldTelemetryBanner(RakshakState state, bool sunlight) {
    final color = state.jawanStatusColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(130)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sensors_rounded, color: color, size: 20),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  'LIVE COMPANION TELEMETRY SYNC: Field Check-in FRSI ${state.jawanFrsiScore}/100 (${state.jawanStatusChipLabel})'
                  '${state.confidentialTalkRequested ? " • 🔒 Confidential MO Talk Requested (${state.confidentialTicketId})" : ""}',
                  style: TextStyle(
                    color: TacticalColors.textMain(sunlight),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          TacticalStatusChip(
            label: 'Real-Time Sync Active',
            color: color,
            compact: true,
          ),
        ],
      ),
    );
  }

  /// 2. Actionable Personnel Triage Roster & 3. One-Click Welfare Intervention Actions
  Widget _buildPersonnelTriageRosterCard(
    BuildContext context,
    RakshakState state,
    List<PersonnelTriageItem> roster,
    bool sunlight,
  ) {
    return TacticalCard(
      isSunlightMode: sunlight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TacticalSectionHeader(
            icon: Icons.assignment_ind_rounded,
            bentoTag:
                '🩺 Sehat Setu Closed-Loop Triage × PathWise Inline Explainability',
            title: 'Actionable Personnel Triage Roster',
            subtitle:
                'Tap any personnel card to trigger One-Click Defense Welfare Interventions',
            accentColor: TacticalColors.warningAmber,
            isSunlightMode: sunlight,
            trailing: const TacticalStatusChip(
              label: 'Tap Card for Interventions',
              color: TacticalColors.cyberTeal,
              icon: Icons.touch_app_rounded,
              compact: true,
            ),
          ),
          const SizedBox(height: 14),

          // Filter Chips Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildRosterFilterChip(
                  'ALL',
                  'All Flagged (${state.triageRoster.length})',
                  sunlight,
                ),
                const SizedBox(width: 8),
                _buildRosterFilterChip(
                  'CRITICAL',
                  'Critical Risk (Red)',
                  sunlight,
                ),
                const SizedBox(width: 8),
                _buildRosterFilterChip(
                  'AMBER',
                  'Moderate Fatigue (Amber)',
                  sunlight,
                ),
                const SizedBox(width: 8),
                _buildRosterFilterChip(
                  'NORMAL',
                  'Mission Ready (Normal)',
                  sunlight,
                ),
                const SizedBox(width: 8),
                _buildRosterFilterChip(
                  'SCHEDULED',
                  'Intervention Scheduled (${state.scheduledInterventionsCount})',
                  sunlight,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (roster.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: TacticalColors.innerWellBg(sunlight),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TacticalColors.borderCol(sunlight)),
              ),
              child: Center(
                child: Text(
                  'No personnel match the selected triage filter.',
                  style: TextStyle(color: TacticalColors.textDim(sunlight)),
                ),
              ),
            )
          else
            ...roster.map((person) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildPersonnelRosterTile(
                  context,
                  state,
                  person,
                  sunlight,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildRosterFilterChip(
    String filterKey,
    String label,
    bool sunlight,
  ) {
    final isSelected = _selectedFilter == filterKey;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = filterKey;
        });
      },
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? TacticalColors.emeraldPrimary.withAlpha(38)
              : TacticalColors.innerWellBg(sunlight),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? TacticalColors.emeraldPrimary
                : TacticalColors.borderCol(sunlight),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? TacticalColors.emeraldPrimary
                : TacticalColors.textSub(sunlight),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPersonnelRosterTile(
    BuildContext context,
    RakshakState state,
    PersonnelTriageItem person,
    bool sunlight,
  ) {
    final statusColor = person.statusColor;
    final hasIntervention = person.isInterventionScheduled;

    return TacticalCard(
      isSunlightMode: sunlight,
      padding: const EdgeInsets.all(15),
      backgroundColor: TacticalColors.innerWellBg(sunlight),
      leftAccentColor:
          hasIntervention ? TacticalColors.emeraldPrimary : statusColor,
      borderColor: hasIntervention
          ? TacticalColors.emeraldPrimary.withAlpha(150)
          : statusColor.withAlpha(110),
      onTap: () => _openInterventionActionSheet(context, person),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Name + Duty + FRSI Badge + Status Tag
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
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(32),
                      shape: BoxShape.circle,
                      border: Border.all(color: statusColor.withAlpha(140)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${person.frsiScore}',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          person.nameWithCoy,
                          style: TextStyle(
                            color: TacticalColors.textMain(sunlight),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Duty: ${person.dutyDescription}  •  ID: ${person.forceId}',
                          style: TextStyle(
                            color: TacticalColors.textSub(sunlight),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TacticalStatusChip(
                    label:
                        'FRSI: ${person.frsiScore} (${person.frsiBandLabel})',
                    color: statusColor,
                    compact: true,
                  ),
                  if (hasIntervention)
                    const TacticalStatusChip(
                      label: 'Intervention Scheduled',
                      color: TacticalColors.emeraldPrimary,
                      icon: Icons.verified_rounded,
                      compact: true,
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: TacticalColors.borderCol(sunlight), height: 1),
          const SizedBox(height: 10),

          // Bottom Row: Primary Signal + PathWise "Why this?" + Intervene Button
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.troubleshoot_rounded,
                    size: 16,
                    color: statusColor,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Primary Signal: ',
                            style: TextStyle(
                              color: TacticalColors.textDim(sunlight),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: person.primarySignal,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // PathWise "Why this?" inline explainability toggle
                  InkWell(
                    onTap: () => state.toggleWhyThisForPersonnel(person.id),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: TacticalColors.pathwiseIndigo.withAlpha(28),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: TacticalColors.pathwiseIndigo.withAlpha(110),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 12,
                            color: Color(0xFF818CF8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            person.isWhyThisExpanded
                                ? 'Hide Why'
                                : 'Why this?',
                            style: const TextStyle(
                              color: Color(0xFF818CF8),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildInlinePill(
                    Icons.favorite_border_rounded,
                    '${person.restingPulse} bpm',
                    sunlight,
                  ),
                  _buildInlinePill(
                    Icons.bedtime_outlined,
                    '+${person.sleepDeficitHours.toStringAsFixed(1)}h deficit',
                    sunlight,
                  ),
                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      backgroundColor: hasIntervention
                          ? TacticalColors.emeraldPrimary.withAlpha(35)
                          : TacticalColors.cardBg(sunlight),
                      foregroundColor: hasIntervention
                          ? TacticalColors.emeraldPrimary
                          : TacticalColors.cyberTeal,
                      side: BorderSide(
                        color: hasIntervention
                            ? TacticalColors.emeraldPrimary
                            : TacticalColors.cyberTeal.withAlpha(120),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () =>
                        _openInterventionActionSheet(context, person),
                    icon: Icon(
                      hasIntervention
                          ? Icons.edit_calendar_rounded
                          : Icons.medical_services_outlined,
                      size: 15,
                    ),
                    label: Text(
                      hasIntervention ? 'Update Action' : 'Intervene',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // PathWise Inline "Why this?" Explainability Panel
          if (person.isWhyThisExpanded &&
              person.aiExplainabilityFactors.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: TacticalColors.pathwiseIndigo.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: TacticalColors.pathwiseIndigo.withAlpha(100),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✨ PATHWISE AI SIGNAL ATTRIBUTION (WHY THIS SOLDIER WAS FLAGGED):',
                    style: TextStyle(
                      color: Color(0xFF818CF8),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  ...person.aiExplainabilityFactors.map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        '• $f',
                        style: TextStyle(
                          color: TacticalColors.textSub(sunlight),
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Sehat Setu `VSTimeline` Closed-Loop Intervention Status when Scheduled
          if (hasIntervention) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: TacticalColors.emeraldPrimary.withAlpha(24),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: TacticalColors.emeraldPrimary.withAlpha(120),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: TacticalColors.emeraldPrimary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Closed-Loop Status: Intervention Scheduled — [${person.scheduledIntervention}] (${person.interventionTime})',
                          style: const TextStyle(
                            color: TacticalColors.emeraldPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      Text(
                        '① AI Triage Flagged ✓',
                        style: TextStyle(
                          color: TacticalColors.emeraldPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '→  ② MO Action Logged ✓',
                        style: TextStyle(
                          color: TacticalColors.emeraldPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '→  ③ ACR-Exempt Welfare Dispatch Active ✓',
                        style: TextStyle(
                          color: TacticalColors.cyberTeal,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInlinePill(IconData icon, String text, bool sunlight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: TacticalColors.cardBg(sunlight),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: TacticalColors.borderCol(sunlight)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: TacticalColors.textDim(sunlight)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: TacticalColors.textSub(sunlight),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
