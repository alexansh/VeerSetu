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

data class CompanyRiskUnit(
    val companyName: String,
    val deploymentRole: String,
    val personnelCount: Int,
    val avgFrsi: Int,
    val fourWeekTrend: String,
    val highRiskCount: Int
) {
    val tier: RiskTier
        get() = when {
            avgFrsi >= 70 -> RiskTier.OPTIMAL
            avgFrsi >= 55 -> RiskTier.MODERATE
            else -> RiskTier.CRITICAL
        }
}

data class WelfareAlertItem(
    val alertId: String,
    val timestamp: String,
    val unitName: String,
    val maskedToken: String,
    val fullPersonnelName: String,
    val triggerReason: String,
    val recommendedAction: String,
    val acknowledged: Boolean = false
)

data class ChatMessage(
    val sender: String, // "bot" or "user"
    val text: String,
    val timestamp: String
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

    // Anonymized fields for Commander (Aggregate-Only) Role (#6 & #8)
    val maskedId: String
        get() = "ANON-SHA256-${id.takeLast(4)}"

    val maskedName: String
        get() = "Personnel Token #${id.takeLast(4)} [Identity Masked]"

    val maskedTelemetry: String
        get() = "🔒 Raw biometric & clinical telemetry encrypted under MHA Zero-Stigma Firewall (Accessible to Welfare/Medical Officer only)."
}

class RakshakState {
    // Splash screen intro visibility (true on initial launch, can be replayed by tapping logo)
    var showSplash by mutableStateOf(true)

    // 0 = Personnel (Self-Only Jawan Companion), 1 = Welfare Officer / Commander Console
    var activeTab by mutableIntStateOf(0)

    // 3-Tier RBAC Role inside Console (#6 & #8):
    // 0 = Welfare / Medical Officer (Unit-Level Authorized, Unmasked Clinical Triage + Alerts)
    // 1 = Unit Commander (Aggregate-Only, Masked IDs, Unit Heatmap & PDF Export)
    var consoleSubRole by mutableIntStateOf(0)

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

    // Feature #1: Unit-Wise Company Risk Heatmap & 4-Week Trends for Commander/Welfare Dashboard
    val unitHeatmap = mutableStateListOf(
        CompanyRiskUnit(
            companyName = "Bravo Coy",
            deploymentRole = "72h LRP • Bastar Core",
            personnelCount = 24,
            avgFrsi = 48,
            fourWeekTrend = "-9% (High Fatigue)",
            highRiskCount = 2
        ),
        CompanyRiskUnit(
            companyName = "Fwd Post 3",
            deploymentRole = "High-Altitude Overwatch",
            personnelCount = 18,
            avgFrsi = 58,
            fourWeekTrend = "-5% (Rotation Due)",
            highRiskCount = 1
        ),
        CompanyRiskUnit(
            companyName = "Charlie Coy",
            deploymentRole = "Night QRT Platoon",
            personnelCount = 22,
            avgFrsi = 64,
            fourWeekTrend = "-3% (Watch)",
            highRiskCount = 1
        ),
        CompanyRiskUnit(
            companyName = "Alpha Coy",
            deploymentRole = "Perimeter Security",
            personnelCount = 20,
            avgFrsi = 79,
            fourWeekTrend = "+4% (Stable)",
            highRiskCount = 0
        ),
        CompanyRiskUnit(
            companyName = "Delta Coy",
            deploymentRole = "Reserve Lines",
            personnelCount = 20,
            avgFrsi = 88,
            fourWeekTrend = "+7% (Recovered)",
            highRiskCount = 0
        ),
        CompanyRiskUnit(
            companyName = "HQ & Signals",
            deploymentRole = "Command & Comms",
            personnelCount = 16,
            avgFrsi = 91,
            fourWeekTrend = "+5% (Optimal)",
            highRiskCount = 0
        )
    )

    // Feature #7: Automated Alerts for Welfare Personnel ONLY (Never Disciplinary Chain)
    val welfareAlerts = mutableStateListOf(
        WelfareAlertItem(
            alertId = "WLF-ALERT-901",
            timestamp = "06:15 HRS",
            unitName = "B Company • Bastar Sector",
            maskedToken = "ANON-SHA256-4920",
            fullPersonnelName = "Constable Rajesh Kumar (CRPF-84920)",
            triggerReason = "FRSI dropped to 42/100 (72h sleep debt + +18 bpm resting HR drift)",
            recommendedAction = "Mandatory 48h Rest Rotation + Confidential MO Check-in"
        ),
        WelfareAlertItem(
            alertId = "WLF-ALERT-884",
            timestamp = "05:40 HRS",
            unitName = "Forward Post 3 • High Altitude",
            maskedToken = "ANON-SHA256-3104",
            fullPersonnelName = "Havildar Surender Singh (CRPF-73104)",
            triggerReason = "14 continuous days at Forward Post + fragmented REM recovery",
            recommendedAction = "Schedule Platoon Relief Rotation & Family Welfare Call"
        )
    )

    // Feature #11: Anonymous Peer-Support Chatbot ("VeerMitra / वीर-मित्र") — No Login Required
    val chatMessages = mutableStateListOf(
        ChatMessage(
            sender = "bot",
            text = "Jai Hind! I am VeerMitra (वीर-मित्र), your 100% anonymous peer-support companion. No login or Service ID is recorded. Tap a topic below or type how you are feeling.",
            timestamp = "Encrypted Ephemeral Session"
        )
    )

    fun sendPeerSupportMessage(userPrompt: String) {
        val trimmed = userPrompt.trim()
        if (trimmed.isEmpty()) return
        chatMessages.add(
            ChatMessage(
                sender = "user",
                text = trimmed,
                timestamp = "Just now"
            )
        )
        val lower = trimmed.lowercase()
        val reply = when {
            lower.contains("sleep") || lower.contains("night") || lower.contains("नींद") -> {
                if (isHindi) {
                    "रात्रि गश्त के बाद नींद न आना सामान्य है। सुझाव: (1) सोने से 30 मिनट पहले कैफीन से बचें, (2) ऊपर दिए गए 4-4-4-4 बॉक्स ब्रीदिंग अभ्यास को 60 सेकंड चलाएं, और (3) अपने शरीर का तापमान सामान्य करने के लिए पैरों को गुनगुने पानी से धोएं।"
                } else {
                    "Post-night-shift insomnia is caused by elevated cortisol after high-alert sentry duty. Try: (1) Run the 60s 4-4-4-4 Box Breathing drill above to trigger a vagal heart-rate drop, (2) Avoid tea/caffeine 3 hours before rest, and (3) Request a 20-minute dark-room power recovery window."
                }
            }
            lower.contains("home") || lower.contains("family") || lower.contains("परिवार") || lower.contains("घर") -> {
                if (isHindi) {
                    "परिवार से दूर रहना कठिन है। आप अकेले नहीं हैं—आपकी बटालियन में 'कल्याण कॉल प्राथमिकता' उपलब्ध है। आप बिना किसी झिझक के यूनिट वेलफेयर ऑफिसर से 15 मिनट के सैटेलाइट/कल्याण कॉल या प्राथमिकता अवकाश की मांग कर सकते हैं।"
                } else {
                    "Missing family during extended deployment is completely natural. You can request a Priority Satellite Welfare Call or Leave Counselling through the Welfare Officer—this is 100% confidential and never affects your promotion or service record."
                }
            }
            lower.contains("patrol") || lower.contains("anx") || lower.contains("stress") || lower.contains("तनाव") || lower.contains("घबराहट") -> {
                if (isHindi) {
                    "लंबी गश्त (LRP) के बाद शरीर 'हाइपर-विजिलेंस' मोड में रहता है। अभी 5 गहरी सांसें लें, अपने कंधों को ढीला छोड़ें, और पर्याप्त इलेक्ट्रोलाइट पानी पिएं। यदि थकान बनी रहती है, तो गोपनीय एमओ परामर्श बटन दबाएं।"
                } else {
                    "After a long-range patrol (LRP), your nervous system stays in combat hypervigilance. Ground yourself: name 3 things you see, drink 500ml water with electrolytes, and do 4 cycles of Box Breathing. You can also tap 'Request Confidential Talk with Unit MO' anytime."
                }
            }
            lower.contains("privacy") || lower.contains("acr") || lower.contains("record") || lower.contains("गोपनीय") -> {
                if (isHindi) {
                    "100% गोपनीयता गारंटी: वीर-मित्र चैट में कोई लॉगिन या सर्विस आईडी सेव नहीं होती। आपके स्वास्थ्य और तनाव के आंकड़े कमांडर या अनुशासनात्मक चेन से पूरी तरह छिपे रहते हैं।"
                } else {
                    "Strict MHA Privacy Firewall: VeerMitra does not log your Service ID, name, or IP. Furthermore, Unit Commanders only see anonymized aggregate stats—never your individual check-ins or chat messages."
                }
            }
            else -> {
                if (isHindi) {
                    "मैं आपकी बात समझता हूँ, जवान। आपका मानसिक और शारीरिक स्वास्थ्य देश के लिए अमूल्य है। कृपया 60-सेकंड का ब्रीदिंग ड्रिल आज़माएं या बिना किसी संकोच के यूनिट मेडिकल ऑफिसर से गोपनीय चर्चा करें।"
                } else {
                    "I hear you, Jawan. Staying resilient in tough terrain takes recovery, not just endurance. Consider taking a 60-second Box Breathing reset right now, or tap 'Request Confidential Talk with Unit MO' for a private, zero-stigma welfare check."
                }
            }
        }
        chatMessages.add(
            ChatMessage(
                sender = "bot",
                text = reply,
                timestamp = "VeerMitra Edge-AI • Anonymous"
            )
        )
    }

    fun clearChatHistory() {
        chatMessages.clear()
        chatMessages.add(
            ChatMessage(
                sender = "bot",
                text = if (isHindi)
                    "चैट इतिहास साफ़ कर दिया गया है। यह सत्र 100% गुमनाम है।"
                else
                    "Session wiped cleanly. Zero logs retained. How can I support you today?",
                timestamp = "Encrypted Ephemeral Session"
            )
        )
    }

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

        // Feature #7: Automatically notify Welfare Officer ONLY (never disciplinary chain) if FRSI < 50
        if (frsiScore < 50 && welfareAlerts.none { it.alertId == "WLF-LIVE-772" }) {
            welfareAlerts.add(
                0,
                WelfareAlertItem(
                    alertId = "WLF-LIVE-772",
                    timestamp = "LIVE NOW",
                    unitName = "204 CoBRA Bn • Bastar South",
                    maskedToken = "ANON-SHA256-7721",
                    fullPersonnelName = "Constable Vikram Singh (Self Check-in Alert)",
                    triggerReason = "FRSI dropped to $frsiScore/100 during field check-in (${"%.1f".format(sleepHours)}h sleep, Fatigue $fatigueLevel/5)",
                    recommendedAction = "Immediate Welfare Officer Outreach • Non-Disciplinary Support"
                )
            )
        }
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
