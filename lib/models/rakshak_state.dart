import 'package:flutter/material.dart';
import '../theme/tactical_theme.dart';

/// Active application view mode in the Top Island Header & Floating Bottom Nav.
enum AppViewMode {
  jawanCompanion,
  moCommanderConsole,
}

/// Risk tier derived from the Force Resilience & Stress Index (FRSI) score.
enum FrsiStatusTier {
  combatReady, // >= 70 (Green)
  operationalFatigue, // 50 - 69 (Amber)
  highStressAlert, // < 50 (Red)
}

/// Personnel record for the Unit Medical Officer & Commander Triage Roster.
class PersonnelTriageItem {
  final String id;
  final String forceId;
  final String nameWithCoy;
  final String rank;
  final String dutyDescription;
  int frsiScore;
  String primarySignal;
  int restingPulse;
  int spo2;
  double sleepDeficitHours;
  int hrvMs;
  final List<String> aiExplainabilityFactors;
  String? scheduledIntervention;
  String? interventionTime;
  bool hasConfidentialRequest;
  bool isWhyThisExpanded;

  PersonnelTriageItem({
    required this.id,
    required this.forceId,
    required this.nameWithCoy,
    required this.rank,
    required this.dutyDescription,
    required this.frsiScore,
    required this.primarySignal,
    required this.restingPulse,
    required this.spo2,
    required this.sleepDeficitHours,
    this.hrvMs = 52,
    this.aiExplainabilityFactors = const [],
    this.scheduledIntervention,
    this.interventionTime,
    this.hasConfidentialRequest = false,
    this.isWhyThisExpanded = false,
  });

  bool get isInterventionScheduled => scheduledIntervention != null;

  FrsiStatusTier get statusTier {
    if (frsiScore >= 70) return FrsiStatusTier.combatReady;
    if (frsiScore >= 50) return FrsiStatusTier.operationalFatigue;
    return FrsiStatusTier.highStressAlert;
  }

  String get frsiBandLabel {
    if (frsiScore >= 70) return 'Normal';
    if (frsiScore >= 50) return 'Amber';
    return 'Critical';
  }

  Color get statusColor {
    switch (statusTier) {
      case FrsiStatusTier.combatReady:
        return TacticalColors.emeraldPrimary;
      case FrsiStatusTier.operationalFatigue:
        return TacticalColors.warningAmber;
      case FrsiStatusTier.highStressAlert:
        return TacticalColors.criticalRed;
    }
  }
}

/// Central state controller for the RakshakSense SIH26186 Android prototype.
/// Blends Sehat Setu (NagarSeva Status Halo, Offline-First Engine, Bilingual Voice Readout)
/// with PathWise (Bento 28-Day Heatmap, Inline "Why This?" AI Explainability, Re-Adapt Feedback).
class RakshakState extends ChangeNotifier {
  AppViewMode _viewMode = AppViewMode.jawanCompanion;
  AppViewMode get viewMode => _viewMode;

  // Sehat Setu + PathWise Global Shell States
  bool _isSunlightMode = false;
  bool _isOfflineEdgeMode = false;
  bool _isHindiLanguage = false;
  bool _isAudioNarrationActive = false;

  bool get isSunlightMode => _isSunlightMode;
  bool get isOfflineEdgeMode => _isOfflineEdgeMode;
  bool get isHindiLanguage => _isHindiLanguage;
  bool get isAudioNarrationActive => _isAudioNarrationActive;

  void setViewMode(AppViewMode mode) {
    if (_viewMode != mode) {
      _viewMode = mode;
      notifyListeners();
    }
  }

  void toggleSunlightMode() {
    _isSunlightMode = !_isSunlightMode;
    notifyListeners();
  }

  void toggleOfflineEdgeMode() {
    _isOfflineEdgeMode = !_isOfflineEdgeMode;
    notifyListeners();
  }

  void toggleLanguage() {
    _isHindiLanguage = !_isHindiLanguage;
    notifyListeners();
  }

  void toggleAudioNarration() {
    _isAudioNarrationActive = !_isAudioNarrationActive;
    notifyListeners();
  }

  // ===========================================================================
  // SCREEN 1: JAWAN / PERSONNEL COMPANION STATE
  // ===========================================================================

  static const List<String> sleepOptions = [
    '<4 hrs',
    '4-6 hrs',
    '6-8 hrs',
    '8+ hrs',
  ];

  static const List<String> fatigueOptions = [
    'Nominal',
    'Moderate',
    'High',
    'Severe',
  ];

  static const List<String> distressOptions = [
    'Calm',
    'Focused',
    'Stressed',
    'Overwhelmed',
  ];

  static const Map<String, String> distressEmojis = {
    'Calm': '😊',
    'Focused': '🎯',
    'Stressed': '😟',
    'Overwhelmed': '😫',
  };

  // Current Jawan FRSI & Telemetry (Starts at 78/100 as specified)
  int _jawanFrsiScore = 78;
  int _jawanRestingPulse = 72;
  int _jawanSpo2 = 98;
  double _jawanSleepDeficit = 1.5;
  int _jawanHrvMs = 64;

  String _selectedSleep = '6-8 hrs';
  String _selectedFatigue = 'Nominal';
  String _selectedDistress = 'Focused';

  bool _checkInSubmitted = false;
  int _checkInCount = 0;
  bool _showJawanWhyThis = false;
  String _aiInsightSummary =
      'AI Predictive Model: Vitals & circadian recovery within nominal operational envelope.';
  String? _reAdaptCaption;

  // PathWise 28-Day Resilience & Recovery Heatmap (0: high stress, 1: moderate, 2: good, 3: optimal)
  final List<int> _resilienceHeatmap28Days = [
    3, 3, 2, 3, 2, 3, 3,
    2, 3, 3, 2, 1, 2, 3,
    3, 2, 3, 3, 2, 3, 2,
    3, 3, 2, 2, 3, 3, 3,
  ];
  int _resilienceStreakDays = 14;

  bool _confidentialTalkRequested = false;
  String? _confidentialTicketId;

  int get jawanFrsiScore => _jawanFrsiScore;
  int get jawanRestingPulse => _jawanRestingPulse;
  int get jawanSpo2 => _jawanSpo2;
  double get jawanSleepDeficit => _jawanSleepDeficit;
  int get jawanHrvMs => _jawanHrvMs;

  String get selectedSleep => _selectedSleep;
  String get selectedFatigue => _selectedFatigue;
  String get selectedDistress => _selectedDistress;
  bool get checkInSubmitted => _checkInSubmitted;
  int get checkInCount => _checkInCount;
  bool get showJawanWhyThis => _showJawanWhyThis;
  String get aiInsightSummary => _aiInsightSummary;
  String? get reAdaptCaption => _reAdaptCaption;
  List<int> get resilienceHeatmap28Days =>
      List.unmodifiable(_resilienceHeatmap28Days);
  int get resilienceStreakDays => _resilienceStreakDays;

  bool get confidentialTalkRequested => _confidentialTalkRequested;
  String? get confidentialTicketId => _confidentialTicketId;

  void toggleJawanWhyThis() {
    _showJawanWhyThis = !_showJawanWhyThis;
    notifyListeners();
  }

  FrsiStatusTier get jawanStatusTier {
    if (_jawanFrsiScore >= 70) return FrsiStatusTier.combatReady;
    if (_jawanFrsiScore >= 50) return FrsiStatusTier.operationalFatigue;
    return FrsiStatusTier.highStressAlert;
  }

  String get jawanStatusChipLabel {
    switch (jawanStatusTier) {
      case FrsiStatusTier.combatReady:
        return 'Combat Ready';
      case FrsiStatusTier.operationalFatigue:
        return 'Operational Fatigue';
      case FrsiStatusTier.highStressAlert:
        return 'High Stress Alert';
    }
  }

  /// Sehat Setu Status Halo Verdict Word (Bilingual Hindi + English support)
  String get jawanHaloVerdictWord {
    switch (jawanStatusTier) {
      case FrsiStatusTier.combatReady:
        return _isHindiLanguage ? 'ठीक हैं • Ready' : 'Combat Ready';
      case FrsiStatusTier.operationalFatigue:
        return _isHindiLanguage ? 'ध्यान दें • Fatigue' : 'Pay Attention';
      case FrsiStatusTier.highStressAlert:
        return _isHindiLanguage ? 'मदद लें • High Stress' : 'High Stress Alert';
    }
  }

  String get jawanStatusSubtext {
    switch (jawanStatusTier) {
      case FrsiStatusTier.combatReady:
        return 'Nominal / Low Fatigue';
      case FrsiStatusTier.operationalFatigue:
        return 'Moderate Strain • Rest Advised';
      case FrsiStatusTier.highStressAlert:
        return 'Critical Burnout Risk • Priority Care';
    }
  }

  String get jawanAudioNarrationText {
    if (_isHindiLanguage) {
      return 'नमस्ते जवान। आपका फोर्स रेजिलिएंस स्कोर $_jawanFrsiScore प्रति सौ ($jawanStatusChipLabel) है। हृदय गति $_jawanRestingPulse प्रति मिनट और ऑक्सीजन $_jawanSpo2 प्रतिशत सामान्य है। यह डेटा पूर्णतः गोपनीय है।';
    }
    return 'Voice Readout: Your Force Resilience Score is $_jawanFrsiScore out of 100 ($jawanStatusChipLabel). Resting pulse is $_jawanRestingPulse bpm, SpO2 is $_jawanSpo2%, and sleep deficit is +${_jawanSleepDeficit.toStringAsFixed(1)} hours.';
  }

  Color get jawanStatusColor {
    switch (jawanStatusTier) {
      case FrsiStatusTier.combatReady:
        return TacticalColors.emeraldPrimary;
      case FrsiStatusTier.operationalFatigue:
        return TacticalColors.warningAmber;
      case FrsiStatusTier.highStressAlert:
        return TacticalColors.criticalRed;
    }
  }

  void selectSleep(String value) {
    _selectedSleep = value;
    notifyListeners();
  }

  void selectFatigue(String value) {
    _selectedFatigue = value;
    notifyListeners();
  }

  void selectDistress(String value) {
    _selectedDistress = value;
    notifyListeners();
  }

  /// Dynamically recalculates the Jawan's FRSI score, vitals telemetry,
  /// PathWise 28-day heatmap cell, and AI Re-Adapt explanation banner.
  void submitWellnessCheckIn() {
    final previousScore = _jawanFrsiScore;
    int score = 92;

    // 1. Sleep contribution
    switch (_selectedSleep) {
      case '8+ hrs':
        score += 4;
        _jawanSleepDeficit = 0.0;
        break;
      case '6-8 hrs':
        score -= 6;
        _jawanSleepDeficit = 1.5;
        break;
      case '4-6 hrs':
        score -= 20;
        _jawanSleepDeficit = 3.8;
        break;
      case '<4 hrs':
        score -= 34;
        _jawanSleepDeficit = 6.2;
        break;
    }

    // 2. Operational Fatigue contribution
    switch (_selectedFatigue) {
      case 'Nominal':
        score -= 2;
        break;
      case 'Moderate':
        score -= 12;
        break;
      case 'High':
        score -= 22;
        break;
      case 'Severe':
        score -= 30;
        break;
    }

    // 3. Mental Distress / Anxiety contribution
    switch (_selectedDistress) {
      case 'Calm':
        score += 2;
        break;
      case 'Focused':
        score -= 4;
        break;
      case 'Stressed':
        score -= 16;
        break;
      case 'Overwhelmed':
        score -= 26;
        break;
    }

    _jawanFrsiScore = score.clamp(18, 98);

    // Adjust simulated wearable biometric telemetry to correlate with FRSI
    if (_jawanFrsiScore >= 70) {
      _jawanRestingPulse = 72;
      _jawanSpo2 = 98;
      _jawanHrvMs = 64;
      _resilienceHeatmap28Days[_resilienceHeatmap28Days.length - 1] = 3;
      _aiInsightSummary =
          'AI Telemetry Nominal: Parasympathetic recovery stable. Cleared for standard patrol roster.';
      _reAdaptCaption =
          'PathWise AI Re-Adapt ($previousScore → $_jawanFrsiScore): Since you logged $_selectedSleep sleep & $_selectedDistress state, your status is locked at Combat Ready.';
    } else if (_jawanFrsiScore >= 50) {
      _jawanRestingPulse = 84;
      _jawanSpo2 = 96;
      _jawanHrvMs = 44;
      _resilienceHeatmap28Days[_resilienceHeatmap28Days.length - 1] = 1;
      _aiInsightSummary =
          'AI Early Warning: Elevated sympathetic strain ($_selectedSleep sleep, $_selectedFatigue fatigue). 4-4-4-4 Tactical Box Breathing & hydration advised.';
      _reAdaptCaption =
          'PathWise AI Re-Adapt ($previousScore → $_jawanFrsiScore): Detected $_selectedFatigue fatigue with +${_jawanSleepDeficit.toStringAsFixed(1)}h sleep debt. Queued 4-4-4-4 Autonomic Breathing Drill.';
    } else {
      _jawanRestingPulse = 96;
      _jawanSpo2 = 94;
      _jawanHrvMs = 28;
      _resilienceHeatmap28Days[_resilienceHeatmap28Days.length - 1] = 0;
      _aiInsightSummary =
          'AI Critical Alert: Acute fatigue & distress signature detected. Confidential Medical Officer check-in & 72h light-duty rotation recommended.';
      _reAdaptCaption =
          'PathWise AI Re-Adapt ($previousScore → $_jawanFrsiScore): High stress signature ($_selectedSleep sleep, $_selectedDistress). Flagged non-punitive 72h rest advisory for Unit MO.';
    }

    _checkInSubmitted = true;
    _checkInCount++;
    _resilienceStreakDays = 14 + (_checkInCount > 0 ? 1 : 0);
    notifyListeners();
  }

  /// Apply a one-tap demo preset for fast live jury demonstration on Screen 1.
  void applyDemoPreset({
    required String sleep,
    required String fatigue,
    required String distress,
  }) {
    _selectedSleep = sleep;
    _selectedFatigue = fatigue;
    _selectedDistress = distress;
    submitWellnessCheckIn();
  }

  /// Marks confidential welfare talk requested and generates an encrypted token.
  void submitConfidentialMoRequest() {
    _confidentialTalkRequested = true;
    _confidentialTicketId = 'MHA-MED-${4820 + _checkInCount}';
    notifyListeners();
  }

  // ===========================================================================
  // SCREEN 2: UNIT MEDICAL OFFICER (MO) & COMMANDER CONSOLE STATE
  // ===========================================================================

  static const int totalPersonnelMonitored = 120;
  static const int baseMissionReadyCount = 104; // 86%
  static const int baseModerateFatigueCount = 12; // 10%
  static const int baseCriticalRiskCount = 4; // 4%

  static const List<String> welfareInterventions = [
    'Schedule Tele-Counseling with MO',
    'Recommend 72h Duty Rotation & Rest',
    'Fast-Track Welfare Leave Request',
  ];

  final List<PersonnelTriageItem> _triageRoster = [
    PersonnelTriageItem(
      id: 'crpf-101',
      forceId: 'CRPF-88412',
      nameWithCoy: 'Constable Rajesh Kumar (B Co.)',
      rank: 'Constable (GD)',
      dutyDescription: '28 Days High-Altitude Patrol',
      frsiScore: 42,
      primarySignal: 'Chronic Sleep Deficit & Heart Rate Spike',
      restingPulse: 96,
      spo2: 93,
      sleepDeficitHours: 6.5,
      hrvMs: 26,
      aiExplainabilityFactors: const [
        'Sleep Debt Impact (-28 pts): <4.5h avg sleep across last 6 high-altitude night pickets.',
        'Autonomic HRV Drop (-18 pts): HRV fell from 58ms baseline to 26ms with 96 bpm resting pulse.',
        'Continuous Deployment (-12 pts): 28 consecutive days above 11,000 ft without rotation.',
      ],
    ),
    PersonnelTriageItem(
      id: 'crpf-102',
      forceId: 'CRPF-64209',
      nameWithCoy: 'Havildar Surender Singh (Post 3)',
      rank: 'Havildar',
      dutyDescription: '19 Days Active Deployment',
      frsiScore: 58,
      primarySignal: 'Elevated Fatigue & Family Stress',
      restingPulse: 84,
      spo2: 96,
      sleepDeficitHours: 3.5,
      hrvMs: 41,
      aiExplainabilityFactors: const [
        'Self-Reported Stress (-16 pts): Logged Moderate fatigue & Stressed mental state for 3 days.',
        'Sleep Deficit (-14 pts): +3.5h cumulative deficit on Post 3 perimeter shift.',
        'Pending Welfare Leave (-12 pts): 64 days since last home leave approval.',
      ],
    ),
    PersonnelTriageItem(
      id: 'crpf-103',
      forceId: 'CRPF-91534',
      nameWithCoy: 'Constable Amit Verma (A Co.)',
      rank: 'Constable (GD)',
      dutyDescription: '7 Days Patrol',
      frsiScore: 88,
      primarySignal: 'Baseline Vitals Nominal • Rested',
      restingPulse: 68,
      spo2: 99,
      sleepDeficitHours: 0.5,
      hrvMs: 68,
      aiExplainabilityFactors: const [
        'Circadian Recovery (+14 pts): 7.5h average sleep over last 7 days.',
        'Cardio-Autonomic Stability (+12 pts): 68 bpm resting pulse, 68ms HRV.',
      ],
    ),
    PersonnelTriageItem(
      id: 'crpf-104',
      forceId: 'CRPF-51908',
      nameWithCoy: 'SI Vikram Rathore (QRT Platoon)',
      rank: 'Sub-Inspector',
      dutyDescription: '31 Days Night Area Domination',
      frsiScore: 39,
      primarySignal: 'Severe HRV Drop (-34%) & Consecutive Night Shifts',
      restingPulse: 99,
      spo2: 94,
      sleepDeficitHours: 7.0,
      hrvMs: 24,
      aiExplainabilityFactors: const [
        'Circadian Inversion (-30 pts): 11 consecutive night QRT sorties.',
        'Sympathetic Overdrive (-21 pts): Resting pulse 99 bpm, HRV 24ms.',
      ],
    ),
    PersonnelTriageItem(
      id: 'crpf-105',
      forceId: 'CRPF-77321',
      nameWithCoy: 'HC Manoj Tiwari (Signal Sec.)',
      rank: 'Head Constable (RO)',
      dutyDescription: '16 Days Forward Comms Relay',
      frsiScore: 61,
      primarySignal: 'Circadian Disruption & Mild Operational Fatigue',
      restingPulse: 81,
      spo2: 97,
      sleepDeficitHours: 3.0,
      hrvMs: 46,
      aiExplainabilityFactors: const [
        'Split Radio Watch (-15 pts): 4h-on / 4h-off relay schedule.',
        'Mild Cognitive Fatigue (-12 pts): Self-reported Moderate fatigue.',
      ],
    ),
  ];

  List<PersonnelTriageItem> get triageRoster => List.unmodifiable(_triageRoster);

  int get scheduledInterventionsCount =>
      _triageRoster.where((p) => p.isInterventionScheduled).length;

  void toggleWhyThisForPersonnel(String personnelId) {
    final index = _triageRoster.indexWhere((item) => item.id == personnelId);
    if (index != -1) {
      _triageRoster[index].isWhyThisExpanded =
          !_triageRoster[index].isWhyThisExpanded;
      notifyListeners();
    }
  }

  /// Assigns a defense-specific welfare intervention to a personnel member
  /// and updates their status tag to "Intervention Scheduled".
  void assignWelfareIntervention({
    required String personnelId,
    required String interventionAction,
  }) {
    final index = _triageRoster.indexWhere((item) => item.id == personnelId);
    if (index != -1) {
      _triageRoster[index].scheduledIntervention = interventionAction;
      _triageRoster[index].interventionTime = 'Just now • Logged by Unit MO';
      notifyListeners();
    }
  }

  /// Clears a scheduled intervention (useful if resetting during a demo).
  void clearWelfareIntervention(String personnelId) {
    final index = _triageRoster.indexWhere((item) => item.id == personnelId);
    if (index != -1) {
      _triageRoster[index].scheduledIntervention = null;
      _triageRoster[index].interventionTime = null;
      notifyListeners();
    }
  }
}
