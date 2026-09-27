# RakshakSense (`SIH26186` — MHA / CRPF)

**AI-Based Predictive Personnel Stress and Welfare Monitoring System for Uniformed Forces**

A high-impact, zero-external-dependency Flutter demonstration prototype built with Material 3 and a **Modern Tactical Defense Dark UI** (`#0B1120` Deep Navy, `#1E293B` Slate Cards, `#10B981` Tactical Emerald, `#F59E0B` Amber Warning, `#EF4444` Critical Alert).

---

## Quick Start

```bash
# If platform directories (windows/android/ios) are not yet generated on your machine:
flutter create . --project-name rakshak_sense

# Launch the prototype (Chrome, Windows, or Android/iOS emulator):
flutter run
```

---

## Prototype Architecture & SIH Demo Walkthrough

### Top Navigation Bar
- Displays **RAKSHAK SENSE** (`SIH26186`) with **CRPF / Ministry of Home Affairs (MHA)** subtitle.
- Live Segmented Switcher to toggle seamlessly between:
  1. **`[Jawan / Personnel Companion]`** (Mobile Field View)
  2. **`[Unit Medical Officer & Commander Console]`** (Dashboard View)

### Screen 1: Jawan / Personnel Companion View (`lib/screens/jawan_companion_screen.dart`)
1. **Privacy & Anti-Stigma Guardrail Banner**:
   - Prominent top assurance: *"🔒 MHA Medical Confidentiality: Data is strictly accessible to Unit Medical Officers. Fully excluded from Service Records, Conduct Sheets, and Annual Performance Appraisals (ACR)."*
2. **Force Resilience & Stress Index (FRSI) Dial / Status Card**:
   - Custom-painted animated circular radial gauge starting at **78/100 (Nominal / Low Fatigue)**.
   - Dynamic status badge: **Combat Ready** (Green), **Operational Fatigue** (Amber), or **High Stress Alert** (Red).
   - Quick vitals telemetry bar: **Resting Pulse (72 bpm)**, **SpO2 (98%)**, **Sleep Deficit (+1.5h)**.
3. **Daily 30-Second Rapid Wellness Check-in**:
   - Interactive rapid chip selectors for **Sleep Duration** (`[<4 hrs, 4-6 hrs, 6-8 hrs, 8+ hrs]`), **Operational Fatigue** (`[Nominal, Moderate, High, Severe]`), and **Mental Distress / Anxiety** (`[Calm, Focused, Stressed, Overwhelmed]`).
   - **Submit Check-in** button (plus 1-click jury demo presets) that dynamically recalculates the FRSI score, animates the radial dial, and updates telemetry in real time.
4. **Tactical De-escalation Box Breathing Drill**:
   - Interactive **4s Inhale – 4s Hold – 4s Exhale – 4s Hold** animated breathing guide with expanding/contracting tactical ring and countdown timer.
5. **Confidential Welfare Support Button**:
   - Prominent button *"Request Confidential Talk with Unit Medical Officer"* that triggers a private confirmation modal: *"Request submitted privately. No officer or peer is notified."*

### Screen 2: Unit Medical Officer (MO) & Commander Console (`lib/screens/mo_commander_console_screen.dart`)
1. **Battalion Readiness & Welfare Overview**:
   - 4 KPI cards: **Total Personnel Monitored: 120**, **Mission Ready (Green): 104 (86%)**, **Moderate Fatigue (Amber): 12 (10%)**, **Critical Burnout Risk (Red): 4 (4%)**.
2. **Actionable Personnel Triage Roster**:
   - Flagged battalion personnel including **Constable Rajesh Kumar (B Co.)** (`FRSI: 42 Critical`), **Havildar Surender Singh (Post 3)** (`FRSI: 58 Amber`), and **Constable Amit Verma (A Co.)** (`FRSI: 88 Normal`).
3. **One-Click Welfare Intervention Actions**:
   - Tapping any personnel card opens a tactical intervention sheet with:
     - `[Schedule Tele-Counseling with MO]`
     - `[Recommend 72h Duty Rotation & Rest]`
     - `[Fast-Track Welfare Leave Request]`
   - Selecting any intervention updates the personnel's status tag to **"Intervention Scheduled"** in real time.
