package `in`.gov.mha.crpf.rakshaksense.model

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import kotlin.math.roundToInt

enum class RiskTier {
    OPTIMAL,
    MODERATE,
    CRITICAL
}

data class AttributionFactor(
    val label: String,
    val weight: String,
    val detail: String,
    val isAlert: Boolean = false
)

data class PersonnelRecord(
    val id: String,
    val name: String,
    val unit: String,
    val frsiScore: Int,
    val riskDriver: String,
    val telemetryDetail: String,
    val aiAttributionFactors: List<AttributionFactor>,
    val status: String = "Pending Review",
    val activeIntervention: String? = null
) {
    val tier: RiskTier
        get() = when {
            frsiScore >= 70 -> RiskTier.OPTIMAL
            frsiScore >= 50 -> RiskTier.MODERATE
            else -> RiskTier.CRITICAL
        }

    val closedLoopStep: Int
        get() = if (status == "Intervention Scheduled") 3 else 2
}

class RakshakState {
    // 0 = Jawan Companion, 1 = MO / Commander Console
    var activeTab by mutableIntStateOf(0)

    // Sehat Setu (VitalSense / NagarSeva) Top Island Toggles
    var isSunlightMode by mutableStateOf(false)
    var isOfflineEdgeMode by mutableStateOf(false)
    var isHindi by mutableStateOf(false)
    var isAudioReadoutActive by mutableStateOf(false)

    // Phone vs Tablet layout preview (0 = Auto by screen width, 1 = Phone, 2 = Tablet Split-Pane)
    var layoutModeOverride by mutableIntStateOf(0)

    // Jawan Check-in & FRSI state
    var sleepHours by mutableFloatStateOf(6.5f)
    var fatigueLevel by mutableIntStateOf(2) // 1..5
    var stressLevel by mutableIntStateOf(2)  // 1..5
    var frsiScore by mutableIntStateOf(78)
    var checkInCount by mutableIntStateOf(1)
    var showFrsiExplainability by mutableStateOf(false)
    var reAdaptSummary by mutableStateOf(
        "Baseline calibrated from 06:00 HRS wearable sync + morning check-in."
    )

    // PathWise 28-Day Patrol Resilience & Recovery Heatmap (0..3 intensity)
    val resilienceHeatmap28Days = mutableStateListOf(
        3, 3, 2, 3, 3, 2, 3,
        3, 2, 1, 2, 3, 3, 3,
        2, 3, 3, 2, 1, 2, 3,
        3, 3, 2, 3, 3, 2, 3
    )

    val currentTier: RiskTier
        get() = when {
            frsiScore >= 70 -> RiskTier.OPTIMAL
            frsiScore >= 50 -> RiskTier.MODERATE
            else -> RiskTier.CRITICAL
        }

    val restingPulseBpm: Int
        get() = when (currentTier) {
            RiskTier.OPTIMAL -> 72
            RiskTier.MODERATE -> 84
            RiskTier.CRITICAL -> 96
        }

    val spO2Percent: Int
        get() = when (currentTier) {
            RiskTier.OPTIMAL -> 98
            RiskTier.MODERATE -> 97
            RiskTier.CRITICAL -> 95
        }

    val sleepDeficitText: String
        get() {
            val diff = sleepHours - 7.0f
            return if (diff >= 0f) {
                "+%.1fh".format(diff)
            } else {
                "%.1fh".format(diff)
            }
        }

    val jawanFrsiFactors: List<AttributionFactor>
        get() {
            val sleepImpact = ((sleepHours - 6.5f) * 6f).roundToInt()
            val fatigueImpact = -((fatigueLevel - 1) * 6)
            val stressImpact = -((stressLevel - 1) * 7)
            return listOf(
                AttributionFactor(
                    label = "Sleep Recovery (${"%.1f".format(sleepHours)}h / 8h target)",
                    weight = if (sleepImpact >= 0) "+$sleepImpact pts" else "$sleepImpact pts",
                    detail = if (sleepHours < 6.0f) {
                        "REM debt detected across consecutive night shifts"
                    } else {
                        "Circadian recovery within operational threshold"
                    },
                    isAlert = sleepHours < 6.0f
                ),
                AttributionFactor(
                    label = "Post-Patrol Physical Strain (Level $fatigueLevel/5)",
                    weight = "$fatigueImpact pts",
                    detail = if (fatigueLevel >= 4) {
                        "Elevated musculoskeletal load from long-range patrol"
                    } else {
                        "Standard cardiovascular recovery curve"
                    },
                    isAlert = fatigueLevel >= 4
                ),
                AttributionFactor(
                    label = "Cognitive & Emotional Load (Level $stressLevel/5)",
                    weight = "$stressImpact pts",
                    detail = if (stressLevel >= 4) {
                        "Sympathetic nervous system arousal flagged by Edge-AI"
                    } else {
                        "Autonomic HRV balance stable"
                    },
                    isAlert = stressLevel >= 4
                ),
                AttributionFactor(
                    label = "Wearable HRV & Resting Pulse ($restingPulseBpm bpm)",
                    weight = if (currentTier == RiskTier.OPTIMAL) "+6 pts" else "-8 pts",
                    detail = "Passive optical PPG telemetry via rugged wrist strap",
                    isAlert = currentTier == RiskTier.CRITICAL
                )
            )
        }

    val roster = mutableStateListOf(
        PersonnelRecord(
            id = "CRPF-84920",
            name = "Constable Rajesh Kumar (B Co.)",
            unit = "B Company • Bastar Sector",
            frsiScore = 42,
            riskDriver = "3-Day Severe Sleep Deficit + High Post-Patrol Fatigue",
            telemetryDetail = "Avg Sleep: 4.1h/night • Resting HR: 94 bpm (+18 bpm over baseline) • Consecutive Night Patrols: 4",
            aiAttributionFactors = listOf(
                AttributionFactor("72h Cumulative Sleep Debt", "-24 pts", "4.1h/night across 3 consecutive LRP operations", true),
                AttributionFactor("Resting HR Baseline Drift", "-14 pts", "94 bpm (+18 bpm above 30-day personal baseline)", true),
                AttributionFactor("Post-Patrol Fatigue Check-in", "-12 pts", "Self-reported Level 5/5 exhaustion at 05:30 HRS", true)
            )
        ),
        PersonnelRecord(
            id = "CRPF-73104",
            name = "Havildar Surender Singh (Post 3)",
            unit = "Forward Post 3 • High Altitude",
            frsiScore = 58,
            riskDriver = "Elevated Resting HR + 14 Days Since Last Rotation",
            telemetryDetail = "Avg Sleep: 5.6h/night • Resting HR: 86 bpm • Days on Forward Post: 14 days",
            aiAttributionFactors = listOf(
                AttributionFactor("Forward Post Rotation Overdue", "-15 pts", "14 continuous days at Forward Post 3 without relief", true),
                AttributionFactor("Sub-Optimal Sleep Architecture", "-11 pts", "5.6h/night fragmented by guard duty shift change", false),
                AttributionFactor("Mild Sympathetic Elevation", "-8 pts", "Resting HR 86 bpm (+9 bpm over baseline)", false)
            )
        ),
        PersonnelRecord(
            id = "CRPF-66419",
            name = "Naik Vikram Rathore (C Co.)",
            unit = "C Company • QRT Platoon",
            frsiScore = 63,
            riskDriver = "Back-to-Back QRT Standbys + Mild Sleep Fragmentation",
            telemetryDetail = "Avg Sleep: 6.0h/night • Resting HR: 79 bpm • QRT Alerts (48h): 3",
            aiAttributionFactors = listOf(
                AttributionFactor("High QRT Standby Frequency", "-14 pts", "3 rapid-response nocturnal turnouts in 48 hours", false),
                AttributionFactor("Recovery Window Compression", "-10 pts", "6.0h total sleep with 2 awakenings", false)
            )
        ),
        PersonnelRecord(
            id = "CRPF-91205",
            name = "Constable Amit Verma (A Co.)",
            unit = "A Company • Reserve Lines",
            frsiScore = 88,
            riskDriver = "Optimal Recovery & Stable HRV Baseline",
            telemetryDetail = "Avg Sleep: 7.6h/night • Resting HR: 68 bpm • SpO2: 99% • Full Duty Readiness",
            aiAttributionFactors = listOf(
                AttributionFactor("Restorative Sleep Cycle", "+12 pts", "7.6h continuous sleep in Reserve Lines", false),
                AttributionFactor("Optimal Vagal Tone (HRV)", "+10 pts", "68 bpm resting pulse, 99% SpO2", false)
            )
        ),
        PersonnelRecord(
            id = "CRPF-95811",
            name = "Constable Pradeep Meena (HQ)",
            unit = "Signal Platoon • Sector HQ",
            frsiScore = 91,
            riskDriver = "Consistent 7.8h Sleep + Completed Rest Rotation",
            telemetryDetail = "Avg Sleep: 7.8h/night • Resting HR: 66 bpm • SpO2: 99% • Optimal Welfare State",
            aiAttributionFactors = listOf(
                AttributionFactor("Completed 72h Rest Rotation", "+15 pts", "Returned from scheduled rotation with full recovery", false),
                AttributionFactor("Steady Circadian Alignment", "+9 pts", "7.8h average sleep over 7-day window", false)
            )
        )
    )

    var selectedPersonnelId by mutableStateOf("CRPF-84920")

    fun submitCheckIn(): Int {
        val sleepScore = ((sleepHours / 8.5f).coerceIn(0f, 1f) * 42f)
        val fatigueScore = ((5 - fatigueLevel) / 4.0f) * 29f
        val stressScore = ((5 - stressLevel) / 4.0f) * 29f

        val rawScore = (sleepScore + fatigueScore + stressScore).roundToInt().coerceIn(18, 98)
        val previousScore = frsiScore
        frsiScore = rawScore
        checkInCount += 1

        val delta = frsiScore - previousScore
        val deltaLabel = if (delta >= 0) "+$delta" else "$delta"
        reAdaptSummary = "Edge-AI Recalibrated ($deltaLabel pts): Sleep ${"%.1f".format(sleepHours)}h, Fatigue $fatigueLevel/5, Distress $stressLevel/5."

        val heatVal = when {
            frsiScore >= 80 -> 3
            frsiScore >= 65 -> 2
            frsiScore >= 50 -> 1
            else -> 0
        }
        resilienceHeatmap28Days[resilienceHeatmap28Days.lastIndex] = heatVal
        return frsiScore
    }

    fun applyPreset(sleep: Float, fatigue: Int, stress: Int): Int {
        sleepHours = sleep
        fatigueLevel = fatigue
        stressLevel = stress
        return submitCheckIn()
    }

    fun scheduleIntervention(personnelId: String, interventionLabel: String) {
        val idx = roster.indexOfFirst { it.id == personnelId }
        if (idx != -1) {
            roster[idx] = roster[idx].copy(
                status = "Intervention Scheduled",
                activeIntervention = interventionLabel
            )
        }
    }
}
