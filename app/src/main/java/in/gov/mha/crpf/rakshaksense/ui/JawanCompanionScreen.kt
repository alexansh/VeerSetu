package `in`.gov.mha.crpf.rakshaksense.ui

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.VolumeUp
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.Bolt
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.ExpandLess
import androidx.compose.material.icons.filled.ExpandMore
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.MedicalServices
import androidx.compose.material.icons.filled.NightlightRound
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Stop
import androidx.compose.material.icons.filled.VerifiedUser
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import `in`.gov.mha.crpf.rakshaksense.model.RakshakState
import kotlinx.coroutines.delay

@Composable
fun JawanCompanionScreen(
    state: RakshakState,
    isTabletLayout: Boolean,
    onShowSnackbar: (String) -> Unit
) {
    val sunlight = state.isSunlightMode
    val hindi = state.isHindi
    var showConfidentialDialog by remember { mutableStateOf(false) }

    var isBreathingActive by remember { mutableStateOf(false) }
    var breathingPhase by remember { mutableIntStateOf(0) }
    var secondsLeft by remember { mutableIntStateOf(4) }

    LaunchedEffect(isBreathingActive) {
        while (isBreathingActive) {
            delay(1000L)
            if (secondsLeft > 1) {
                secondsLeft -= 1
            } else {
                secondsLeft = 4
                breathingPhase = (breathingPhase + 1) % 4
            }
        }
    }

    if (showConfidentialDialog) {
        AlertDialog(
            onDismissRequest = { showConfidentialDialog = false },
            containerColor = TacticalPalette.bgCard(sunlight),
            title = {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.VerifiedUser,
                        contentDescription = null,
                        tint = TacticalPalette.Emerald
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = if (hindi) "गोपनीय चिकित्सा परामर्श अनुरोध" else "Confidential MO Request Dispatched",
                        color = TacticalPalette.textPrimary(sunlight),
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            },
            text = {
                Column {
                    Text(
                        text = if (hindi)
                            "यूनिट मेडिकल ऑफिसर (डॉ. ए.के. शर्मा, 204 कोबरा बटालियन) को आपका गोपनीय अनुरोध प्राप्त हो गया है। यह अनुरोध आपकी सेवा पंजिका (ACR) में दर्ज नहीं किया जाएगा।"
                        else
                            "Your private consultation request has been encrypted and sent directly to the Unit Medical Officer (Dr. A.K. Sharma, 204 CoBRA Bn). Zero visibility in service promotion / ACR records.",
                        color = TacticalPalette.textSecondary(sunlight),
                        fontSize = 13.sp,
                        lineHeight = 19.sp
                    )
                    Spacer(modifier = Modifier.height(10.dp))
                    StatusPillBadge(
                        label = "TOKEN #MHA-CONF-904 • TODAY 17:30 HRS",
                        color = TacticalPalette.Emerald
                    )
                }
            },
            confirmButton = {
                Button(
                    onClick = { showConfidentialDialog = false },
                    colors = ButtonDefaults.buttonColors(
                        containerColor = TacticalPalette.Emerald,
                        contentColor = Color(0xFF042F2E)
                    )
                ) {
                    Text("Acknowledged", fontWeight = FontWeight.Bold)
                }
            }
        )
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = if (isTabletLayout) 24.dp else 16.dp, vertical = 12.dp),
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        // 1. MHA Medical Confidentiality & Anti-Stigma Guardrail Banner
        Surface(
            shape = RoundedCornerShape(14.dp),
            color = TacticalPalette.Emerald.copy(alpha = 0.14f),
            border = BorderStroke(1.2.dp, TacticalPalette.Emerald.copy(alpha = 0.55f)),
            modifier = Modifier.fillMaxWidth()
        ) {
            Row(
                modifier = Modifier.padding(horizontal = 14.dp, vertical = 12.dp),
                verticalAlignment = Alignment.Top
            ) {
                Icon(
                    imageVector = Icons.Default.Lock,
                    contentDescription = null,
                    tint = TacticalPalette.Emerald,
                    modifier = Modifier
                        .padding(top = 2.dp)
                        .size(20.dp)
                )
                Spacer(modifier = Modifier.width(10.dp))
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = if (hindi)
                            "गोपनीयता गारंटी (MHA गोपनीयता प्रोटोकॉल)"
                        else
                            "MHA MEDICAL CONFIDENTIALITY & ANTI-STIGMA GUARDRAIL",
                        color = TacticalPalette.Emerald,
                        fontSize = 11.5.sp,
                        fontWeight = FontWeight.ExtraBold,
                        letterSpacing = 0.5.sp
                    )
                    Spacer(modifier = Modifier.height(3.dp))
                    Text(
                        text = if (hindi)
                            "सभी स्वास्थ्य डेटा एन्क्रिप्टेड हैं और केवल यूनिट मेडिकल ऑफिसर द्वारा देखे जा सकते हैं। ACR/पदोन्नति से पूर्णतः अलग।"
                        else
                            "Zero-Stigma Guarantee: Stress & sleep telemetry is strictly medical-privileged and never linked to ACR or disciplinary files.",
                        color = TacticalPalette.textPrimary(sunlight),
                        fontSize = 12.5.sp,
                        lineHeight = 18.sp
                    )
                }
            }
        }

        // 2. Sehat Setu Greeting + Voice Readout Bar
        TacticalBentoCard(
            sunlight = sunlight,
            padding = 14.dp
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = if (hindi) "जय हिन्द, सिपाही विक्रम सिंह • 204 कोबरा बटालियन" else "JAI HIND, CONSTABLE VIKRAM SINGH • 204 CoBRA BN",
                        color = TacticalPalette.CyberTeal,
                        fontSize = 11.5.sp,
                        fontWeight = FontWeight.ExtraBold,
                        letterSpacing = 0.4.sp
                    )
                    Spacer(modifier = Modifier.height(3.dp))
                    Text(
                        text = if (hindi)
                            "आपका वर्तमान बल लचीलापन और तनाव सूचकांक (FRSI): ${state.frsiScore}/100"
                        else
                            "Personal Welfare & Force Resilience Companion • Sector: Bastar South",
                        color = TacticalPalette.textPrimary(sunlight),
                        fontSize = 13.5.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
                Spacer(modifier = Modifier.width(10.dp))
                Surface(
                    shape = RoundedCornerShape(999.dp),
                    color = if (state.isAudioReadoutActive) TacticalPalette.Emerald else TacticalPalette.CyberTeal.copy(alpha = 0.18f),
                    border = BorderStroke(1.2.dp, TacticalPalette.CyberTeal),
                    modifier = Modifier.clickable {
                        state.isAudioReadoutActive = !state.isAudioReadoutActive
                    }
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.VolumeUp,
                            contentDescription = null,
                            tint = if (state.isAudioReadoutActive) Color(0xFF042F2E) else TacticalPalette.CyberTeal,
                            modifier = Modifier.size(16.dp)
                        )
                        Spacer(modifier = Modifier.width(5.dp))
                        Text(
                            text = if (hindi) "सुनें" else "Listen",
                            color = if (state.isAudioReadoutActive) Color(0xFF042F2E) else TacticalPalette.textPrimary(sunlight),
                            fontSize = 12.sp,
                            fontWeight = FontWeight.ExtraBold
                        )
                    }
                }
            }

            AnimatedVisibility(visible = state.isAudioReadoutActive) {
                Column {
                    Spacer(modifier = Modifier.height(10.dp))
                    Surface(
                        shape = RoundedCornerShape(10.dp),
                        color = TacticalPalette.bgElevated(sunlight),
                        border = BorderStroke(1.dp, TacticalPalette.CyberTeal.copy(alpha = 0.6f)),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text(
                            text = "🔊 Voice Readout (Hindi/EN): \"Namaskar Jawan. Aapka FRSI score ${state.frsiScore}/100 hai (${TacticalPalette.tierHeadline(state.currentTier, true)}). Resting pulse ${state.restingPulseBpm} bpm aur SpO2 ${state.spO2Percent}% samanya hai.\"",
                            color = TacticalPalette.textPrimary(sunlight),
                            fontSize = 12.5.sp,
                            lineHeight = 18.sp,
                            modifier = Modifier.padding(12.dp)
                        )
                    }
                }
            }
        }

        // Adaptive Phone (1-Column) vs Tablet (2-Column Side-by-Side Bento Grid)
        if (isTabletLayout) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(16.dp),
                verticalAlignment = Alignment.Top
            ) {
                Column(
                    modifier = Modifier.weight(1f),
                    verticalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    FrsiHeroBentoCard(state = state, sunlight = sunlight, hindi = hindi)
                    PathWiseHeatmapCard(state = state, sunlight = sunlight, hindi = hindi)
                }
                Column(
                    modifier = Modifier.weight(1f),
                    verticalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    RapidCheckInBentoCard(
                        state = state,
                        sunlight = sunlight,
                        hindi = hindi,
                        onShowSnackbar = onShowSnackbar
                    )
                    BoxBreathingAndCounselingCard(
                        sunlight = sunlight,
                        hindi = hindi,
                        isBreathingActive = isBreathingActive,
                        breathingPhase = breathingPhase,
                        secondsLeft = secondsLeft,
                        onToggleBreathing = {
                            isBreathingActive = !isBreathingActive
                            breathingPhase = 0
                            secondsLeft = 4
                        },
                        onRequestMo = { showConfidentialDialog = true }
                    )
                }
            }
        } else {
            Column(verticalArrangement = Arrangement.spacedBy(14.dp)) {
                FrsiHeroBentoCard(state = state, sunlight = sunlight, hindi = hindi)
                RapidCheckInBentoCard(
                    state = state,
                    sunlight = sunlight,
                    hindi = hindi,
                    onShowSnackbar = onShowSnackbar
                )
                PathWiseHeatmapCard(state = state, sunlight = sunlight, hindi = hindi)
                BoxBreathingAndCounselingCard(
                    sunlight = sunlight,
                    hindi = hindi,
                    isBreathingActive = isBreathingActive,
                    breathingPhase = breathingPhase,
                    secondsLeft = secondsLeft,
                    onToggleBreathing = {
                        isBreathingActive = !isBreathingActive
                        breathingPhase = 0
                        secondsLeft = 4
                    },
                    onRequestMo = { showConfidentialDialog = true }
                )
            }
        }

        Spacer(modifier = Modifier.height(20.dp))
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun FrsiHeroBentoCard(
    state: RakshakState,
    sunlight: Boolean,
    hindi: Boolean
) {
    val tier = state.currentTier
    val accent = TacticalPalette.tierColor(tier)

    TacticalBentoCard(
        sunlight = sunlight,
        accentLeftColor = accent
    ) {
        FlowRow(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Column {
                Text(
                    text = if (hindi)
                        "बल लचीलापन और तनाव सूचकांक (FRSI)"
                    else
                        "FORCE RESILIENCE & STRESS INDEX (FRSI)",
                    color = TacticalPalette.textSecondary(sunlight),
                    fontSize = 11.5.sp,
                    fontWeight = FontWeight.ExtraBold,
                    letterSpacing = 0.5.sp
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = TacticalPalette.tierHeadline(tier, hindi),
                    color = accent,
                    fontSize = 17.sp,
                    fontWeight = FontWeight.ExtraBold
                )
            }
            StatusPillBadge(
                label = if (state.isOfflineEdgeMode) "EDGE SQLITE CACHED" else "LIVE TELEMETRY",
                color = if (state.isOfflineEdgeMode) TacticalPalette.Amber else TacticalPalette.Emerald
            )
        }

        Spacer(modifier = Modifier.height(16.dp))

        Box(
            modifier = Modifier.fillMaxWidth(),
            contentAlignment = Alignment.Center
        ) {
            DoubleRingFrsiGauge(
                score = state.frsiScore,
                tier = tier,
                sunlight = sunlight
            )
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Sehat Setu 3-Tile Vitals Telemetry Row
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            VitalMiniTile(
                modifier = Modifier.weight(1f),
                title = "Resting Pulse",
                value = "${state.restingPulseBpm} bpm",
                color = if (state.restingPulseBpm > 88) TacticalPalette.Red else TacticalPalette.Emerald,
                sunlight = sunlight
            )
            VitalMiniTile(
                modifier = Modifier.weight(1f),
                title = "SpO2 Level",
                value = "${state.spO2Percent}%",
                color = TacticalPalette.CyberTeal,
                sunlight = sunlight
            )
            VitalMiniTile(
                modifier = Modifier.weight(1f),
                title = "Sleep Deficit",
                value = state.sleepDeficitText,
                color = if (state.sleepHours < 6.0f) TacticalPalette.Amber else TacticalPalette.Emerald,
                sunlight = sunlight
            )
        }

        Spacer(modifier = Modifier.height(12.dp))

        // PathWise Inline "[✨ Why this FRSI?]" Explainability Toggle
        Surface(
            shape = RoundedCornerShape(12.dp),
            color = TacticalPalette.bgElevated(sunlight),
            border = BorderStroke(1.2.dp, TacticalPalette.CyberTeal.copy(alpha = 0.55f)),
            modifier = Modifier
                .fillMaxWidth()
                .clickable { state.showFrsiExplainability = !state.showFrsiExplainability }
        ) {
            Column(modifier = Modifier.padding(12.dp)) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(
                        modifier = Modifier.weight(1f),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector = Icons.Default.AutoAwesome,
                            contentDescription = null,
                            tint = TacticalPalette.CyberTeal,
                            modifier = Modifier.size(16.dp)
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                        Text(
                            text = if (hindi)
                                "✨ यह FRSI स्कोर क्यों है? (AI विश्लेषण)"
                            else
                                "✨ Why this FRSI? (AI Explainability)",
                            color = TacticalPalette.textPrimary(sunlight),
                            fontSize = 12.5.sp,
                            fontWeight = FontWeight.ExtraBold
                        )
                    }
                    Icon(
                        imageVector = if (state.showFrsiExplainability) Icons.Default.ExpandLess else Icons.Default.ExpandMore,
                        contentDescription = null,
                        tint = TacticalPalette.CyberTeal
                    )
                }

                AnimatedVisibility(visible = state.showFrsiExplainability) {
                    Column(
                        modifier = Modifier.padding(top = 10.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        state.jawanFrsiFactors.forEach { factor ->
                            val factorColor = if (factor.isAlert) TacticalPalette.Amber else TacticalPalette.Emerald
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.Top
                            ) {
                                Column(modifier = Modifier.weight(1f)) {
                                    Text(
                                        text = factor.label,
                                        color = TacticalPalette.textPrimary(sunlight),
                                        fontSize = 12.5.sp,
                                        fontWeight = FontWeight.Bold
                                    )
                                    Text(
                                        text = factor.detail,
                                        color = TacticalPalette.textSecondary(sunlight),
                                        fontSize = 11.5.sp,
                                        lineHeight = 16.sp
                                    )
                                }
                                Spacer(modifier = Modifier.width(8.dp))
                                StatusPillBadge(label = factor.weight, color = factorColor)
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun VitalMiniTile(
    modifier: Modifier,
    title: String,
    value: String,
    color: Color,
    sunlight: Boolean
) {
    Surface(
        modifier = modifier,
        shape = RoundedCornerShape(12.dp),
        color = TacticalPalette.bgElevated(sunlight),
        border = BorderStroke(1.dp, TacticalPalette.border(sunlight))
    ) {
        Column(
            modifier = Modifier.padding(horizontal = 8.dp, vertical = 10.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = title,
                color = TacticalPalette.textSecondary(sunlight),
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = value,
                color = color,
                fontSize = 14.5.sp,
                fontWeight = FontWeight.ExtraBold,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun RapidCheckInBentoCard(
    state: RakshakState,
    sunlight: Boolean,
    hindi: Boolean,
    onShowSnackbar: (String) -> Unit
) {
    val moodEmojis = listOf("😊", "🙂", "😐", "😟", "😣")
    val fatigueLabels = listOf("Fresh", "Light", "Mod", "Heavy", "Max")

    TacticalBentoCard(
        sunlight = sunlight,
        accentLeftColor = TacticalPalette.CyberTeal
    ) {
        FlowRow(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            Column {
                Text(
                    text = if (hindi)
                        "दैनिक 30-सेकंड त्वरित स्वास्थ्य चेक-इन"
                    else
                        "DAILY 30-SECOND RAPID WELLNESS CHECK-IN",
                    color = TacticalPalette.CyberTeal,
                    fontSize = 11.5.sp,
                    fontWeight = FontWeight.ExtraBold,
                    letterSpacing = 0.5.sp
                )
                Spacer(modifier = Modifier.height(2.dp))
                Text(
                    text = if (hindi) "अपनी नींद, थकान और मानसिक स्थिति दर्ज करें" else "Calibrate Edge-AI FRSI with self-reported post-shift inputs",
                    color = TacticalPalette.textSecondary(sunlight),
                    fontSize = 12.sp
                )
            }
            StatusPillBadge(label = "Check-in #${state.checkInCount}", color = TacticalPalette.CyberTeal)
        }

        Spacer(modifier = Modifier.height(14.dp))

        // Slider 1: Sleep Duration
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(
                modifier = Modifier.weight(1f),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = Icons.Default.NightlightRound,
                    contentDescription = null,
                    tint = TacticalPalette.CyberTeal,
                    modifier = Modifier.size(16.dp)
                )
                Spacer(modifier = Modifier.width(6.dp))
                Text(
                    text = "1. Sleep Duration (Last 24h)",
                    color = TacticalPalette.textPrimary(sunlight),
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold
                )
            }
            Text(
                text = "${"%.1f".format(state.sleepHours)} hrs",
                color = if (state.sleepHours < 5.5f) TacticalPalette.Red else TacticalPalette.Emerald,
                fontSize = 14.sp,
                fontWeight = FontWeight.ExtraBold
            )
        }
        Slider(
            value = state.sleepHours,
            onValueChange = { state.sleepHours = (it * 2f).toInt() / 2f },
            valueRange = 2f..10f,
            steps = 15,
            colors = SliderDefaults.colors(
                thumbColor = TacticalPalette.Emerald,
                activeTrackColor = TacticalPalette.Emerald
            )
        )

        Spacer(modifier = Modifier.height(8.dp))

        // Selector 2: Operational Fatigue (1..5)
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "2. Operational Fatigue Level",
                color = TacticalPalette.textPrimary(sunlight),
                fontSize = 13.sp,
                fontWeight = FontWeight.Bold
            )
            Text(
                text = "Level ${state.fatigueLevel}/5 (${fatigueLabels[state.fatigueLevel - 1]})",
                color = if (state.fatigueLevel >= 4) TacticalPalette.Amber else TacticalPalette.CyberTeal,
                fontSize = 12.5.sp,
                fontWeight = FontWeight.ExtraBold
            )
        }
        Spacer(modifier = Modifier.height(8.dp))
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            for (lvl in 1..5) {
                val selected = state.fatigueLevel == lvl
                Surface(
                    modifier = Modifier
                        .weight(1f)
                        .clickable { state.fatigueLevel = lvl },
                    shape = RoundedCornerShape(10.dp),
                    color = if (selected) TacticalPalette.CyberTeal.copy(alpha = 0.24f) else TacticalPalette.bgElevated(sunlight),
                    border = BorderStroke(
                        if (selected) 1.5.dp else 1.dp,
                        if (selected) TacticalPalette.CyberTeal else TacticalPalette.border(sunlight)
                    )
                ) {
                    Column(
                        modifier = Modifier.padding(vertical = 9.dp, horizontal = 2.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(
                            text = "$lvl",
                            color = if (selected) TacticalPalette.CyberTeal else TacticalPalette.textPrimary(sunlight),
                            fontSize = 14.sp,
                            fontWeight = FontWeight.ExtraBold
                        )
                        Spacer(modifier = Modifier.height(2.dp))
                        Text(
                            text = fatigueLabels[lvl - 1],
                            color = TacticalPalette.textSecondary(sunlight),
                            fontSize = 10.5.sp,
                            fontWeight = FontWeight.SemiBold,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(14.dp))

        // Selector 3: Mental Distress / Anxiety (1..5 with Sehat Setu Emojis)
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "3. Mental Distress / Anxiety",
                color = TacticalPalette.textPrimary(sunlight),
                fontSize = 13.sp,
                fontWeight = FontWeight.Bold
            )
            Text(
                text = "${moodEmojis[state.stressLevel - 1]} Level ${state.stressLevel}/5",
                color = if (state.stressLevel >= 4) TacticalPalette.Red else TacticalPalette.Emerald,
                fontSize = 12.5.sp,
                fontWeight = FontWeight.ExtraBold
            )
        }
        Spacer(modifier = Modifier.height(8.dp))
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            for (lvl in 1..5) {
                val selected = state.stressLevel == lvl
                val activeColor = if (lvl >= 4) TacticalPalette.Red else TacticalPalette.Emerald
                Surface(
                    modifier = Modifier
                        .weight(1f)
                        .clickable { state.stressLevel = lvl },
                    shape = RoundedCornerShape(10.dp),
                    color = if (selected) activeColor.copy(alpha = 0.22f) else TacticalPalette.bgElevated(sunlight),
                    border = BorderStroke(
                        if (selected) 1.5.dp else 1.dp,
                        if (selected) activeColor else TacticalPalette.border(sunlight)
                    )
                ) {
                    Column(
                        modifier = Modifier.padding(vertical = 8.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(text = moodEmojis[lvl - 1], fontSize = 18.sp)
                        Spacer(modifier = Modifier.height(2.dp))
                        Text(
                            text = "$lvl/5",
                            color = TacticalPalette.textPrimary(sunlight),
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        Button(
            onClick = {
                val updated = state.submitCheckIn()
                onShowSnackbar("Check-in Logged • FRSI Recalibrated to $updated/100")
            },
            modifier = Modifier
                .fillMaxWidth()
                .height(48.dp),
            shape = RoundedCornerShape(12.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = TacticalPalette.Emerald,
                contentColor = Color(0xFF042F2E)
            )
        ) {
            Icon(imageVector = Icons.Default.CheckCircle, contentDescription = null)
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = if (hindi) "चेक-इन सबमिट करें (Submit Check-in)" else "Submit Check-in & Recalibrate FRSI",
                fontWeight = FontWeight.ExtraBold,
                fontSize = 14.sp
            )
        }

        Spacer(modifier = Modifier.height(12.dp))

        // PathWise AI Re-Adapt Feedback Banner
        Surface(
            shape = RoundedCornerShape(10.dp),
            color = TacticalPalette.bgElevated(sunlight),
            border = BorderStroke(1.dp, TacticalPalette.border(sunlight)),
            modifier = Modifier.fillMaxWidth()
        ) {
            Row(
                modifier = Modifier.padding(12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = Icons.Default.Bolt,
                    contentDescription = null,
                    tint = TacticalPalette.Amber,
                    modifier = Modifier.size(18.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = state.reAdaptSummary,
                    color = TacticalPalette.textPrimary(sunlight),
                    fontSize = 12.sp,
                    lineHeight = 17.sp
                )
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        // 1-Tap Jury Demo Presets
        Text(
            text = "QUICK JURY DEMO SCENARIOS (1-TAP SIMULATION):",
            color = TacticalPalette.textSecondary(sunlight),
            fontSize = 11.sp,
            fontWeight = FontWeight.ExtraBold,
            letterSpacing = 0.5.sp
        )
        Spacer(modifier = Modifier.height(8.dp))
        FlowRow(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            PresetChip(
                label = "🟢 Rested Patrol (82)",
                color = TacticalPalette.Emerald,
                onClick = {
                    val s = state.applyPreset(7.5f, 2, 1)
                    onShowSnackbar("Simulated Rested Patrol: FRSI $s/100 (Optimal)")
                }
            )
            PresetChip(
                label = "🟠 Double Shift (58)",
                color = TacticalPalette.Amber,
                onClick = {
                    val s = state.applyPreset(5.5f, 3, 3)
                    onShowSnackbar("Simulated Double Shift: FRSI $s/100 (Moderate Fatigue)")
                }
            )
            PresetChip(
                label = "🔴 72h LRP Exhaustion (32)",
                color = TacticalPalette.Red,
                onClick = {
                    val s = state.applyPreset(3.5f, 5, 4)
                    onShowSnackbar("Simulated 72h LRP Exhaustion: FRSI $s/100 (Critical Alert)")
                }
            )
        }
    }
}

@Composable
private fun PresetChip(
    label: String,
    color: Color,
    onClick: () -> Unit
) {
    Surface(
        shape = RoundedCornerShape(999.dp),
        color = color.copy(alpha = 0.16f),
        border = BorderStroke(1.dp, color.copy(alpha = 0.6f)),
        modifier = Modifier.clickable(onClick = onClick)
    ) {
        Text(
            text = label,
            color = color,
            fontSize = 12.sp,
            fontWeight = FontWeight.ExtraBold,
            modifier = Modifier.padding(horizontal = 12.dp, vertical = 7.dp)
        )
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun PathWiseHeatmapCard(
    state: RakshakState,
    sunlight: Boolean,
    hindi: Boolean
) {
    TacticalBentoCard(sunlight = sunlight) {
        FlowRow(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Column {
                Text(
                    text = if (hindi)
                        "28-दिवसीय गश्त लचीलापन हीटमैप"
                    else
                        "PATHWISE 28-DAY PATROL RESILIENCE HEATMAP",
                    color = TacticalPalette.textPrimary(sunlight),
                    fontSize = 12.sp,
                    fontWeight = FontWeight.ExtraBold,
                    letterSpacing = 0.5.sp
                )
                Spacer(modifier = Modifier.height(2.dp))
                Text(
                    text = "Longitudinal circadian & stress stability across 4 operational weeks",
                    color = TacticalPalette.textSecondary(sunlight),
                    fontSize = 11.5.sp
                )
            }
            StatusPillBadge(label = "🔥 14 Days Active", color = TacticalPalette.Amber)
        }

        Spacer(modifier = Modifier.height(14.dp))

        // 4 rows x 7 columns heatmap grid (spacious cells, zero clipping)
        Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
            for (week in 0 until 4) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "W${week + 1}",
                        color = TacticalPalette.textSecondary(sunlight),
                        fontSize = 11.5.sp,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.width(28.dp)
                    )
                    for (day in 0 until 7) {
                        val idx = week * 7 + day
                        val intensity = state.resilienceHeatmap28Days.getOrElse(idx) { 2 }
                        val cellColor = when (intensity) {
                            3 -> TacticalPalette.Emerald
                            2 -> TacticalPalette.CyberTeal
                            1 -> TacticalPalette.Amber
                            else -> TacticalPalette.Red
                        }
                        Box(
                            modifier = Modifier
                                .weight(1f)
                                .height(26.dp)
                                .clip(RoundedCornerShape(6.dp))
                                .background(cellColor),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = "D${idx + 1}",
                                color = Color(0xFF042F2E),
                                fontSize = 10.sp,
                                fontWeight = FontWeight.ExtraBold
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun BoxBreathingAndCounselingCard(
    sunlight: Boolean,
    hindi: Boolean,
    isBreathingActive: Boolean,
    breathingPhase: Int,
    secondsLeft: Int,
    onToggleBreathing: () -> Unit,
    onRequestMo: () -> Unit
) {
    val phaseLabels = listOf(
        "INHALE SLOWLY (4s)",
        "HOLD BREATH (4s)",
        "EXHALE STEADILY (4s)",
        "HOLD EMPTY (4s)"
    )
    // Animate size inside a fixed 114.dp Box so it NEVER overlaps sibling text
    val targetDiameter = when {
        !isBreathingActive -> 92.dp
        breathingPhase == 0 || breathingPhase == 1 -> 110.dp
        else -> 76.dp
    }
    val animatedDiameter by animateDpAsState(
        targetValue = targetDiameter,
        animationSpec = tween(durationMillis = 850),
        label = "breathDiameter"
    )

    TacticalBentoCard(
        sunlight = sunlight,
        accentLeftColor = TacticalPalette.Emerald
    ) {
        Text(
            text = if (hindi)
                "तत्काल तनाव नियंत्रण और गोपनीय सहायता"
            else
                "INSTANT SELF-CARE & TACTICAL DE-ESCALATION TOOLKIT",
            color = TacticalPalette.Emerald,
            fontSize = 12.sp,
            fontWeight = FontWeight.ExtraBold,
            letterSpacing = 0.5.sp
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = "Combat Tactical Box Breathing (4s Inhale • 4s Hold • 4s Exhale • 4s Hold)",
            color = TacticalPalette.textSecondary(sunlight),
            fontSize = 12.sp
        )

        Spacer(modifier = Modifier.height(14.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Fixed-size bounding container prevents any overlap with adjacent text
            Box(
                modifier = Modifier.size(114.dp),
                contentAlignment = Alignment.Center
            ) {
                Box(
                    modifier = Modifier
                        .size(animatedDiameter)
                        .clip(CircleShape)
                        .background(TacticalPalette.CyberTeal.copy(alpha = 0.18f))
                        .border(2.dp, TacticalPalette.CyberTeal, CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            text = if (isBreathingActive) "${secondsLeft}s" else "4-4-4-4",
                            color = TacticalPalette.CyberTeal,
                            fontSize = 17.sp,
                            fontWeight = FontWeight.ExtraBold
                        )
                        Text(
                            text = if (isBreathingActive)
                                phaseLabels[breathingPhase].substringBefore(" ")
                            else
                                "READY",
                            color = TacticalPalette.textPrimary(sunlight),
                            fontSize = 10.5.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.width(14.dp))

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = if (isBreathingActive) phaseLabels[breathingPhase] else "Autonomic Vagal Reset Drill",
                    color = TacticalPalette.textPrimary(sunlight),
                    fontSize = 14.sp,
                    fontWeight = FontWeight.ExtraBold
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = "Lowers acute sympathetic heart-rate spike after high-alert patrol or night sentry shift.",
                    color = TacticalPalette.textSecondary(sunlight),
                    fontSize = 12.sp,
                    lineHeight = 17.sp
                )
                Spacer(modifier = Modifier.height(10.dp))
                OutlinedButton(
                    onClick = onToggleBreathing,
                    border = BorderStroke(1.2.dp, TacticalPalette.CyberTeal),
                    shape = RoundedCornerShape(10.dp)
                ) {
                    Icon(
                        imageVector = if (isBreathingActive) Icons.Default.Stop else Icons.Default.PlayArrow,
                        contentDescription = null,
                        tint = TacticalPalette.CyberTeal
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Text(
                        text = if (isBreathingActive) "Stop Breathing Drill" else "Start 60s Breathing",
                        color = TacticalPalette.textPrimary(sunlight),
                        fontWeight = FontWeight.ExtraBold,
                        fontSize = 12.sp
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        Button(
            onClick = onRequestMo,
            modifier = Modifier
                .fillMaxWidth()
                .height(48.dp),
            shape = RoundedCornerShape(12.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = TacticalPalette.CyberTeal,
                contentColor = Color(0xFF042F2E)
            )
        ) {
            Icon(imageVector = Icons.Default.MedicalServices, contentDescription = null)
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = if (hindi)
                    "यूनिट मेडिकल ऑफिसर से गोपनीय बात का अनुरोध करें"
                else
                    "Request Confidential Talk with Unit MO",
                fontWeight = FontWeight.ExtraBold,
                fontSize = 13.5.sp,
                textAlign = TextAlign.Center,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}
