package `in`.gov.mha.crpf.rakshaksense.ui

import androidx.compose.animation.AnimatedVisibility
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
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.ExpandLess
import androidx.compose.material.icons.filled.ExpandMore
import androidx.compose.material.icons.filled.FlightTakeoff
import androidx.compose.material.icons.filled.Schedule
import androidx.compose.material.icons.filled.SupportAgent
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import `in`.gov.mha.crpf.rakshaksense.model.PersonnelRecord
import `in`.gov.mha.crpf.rakshaksense.model.RakshakState

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun MoCommanderConsoleScreen(
    state: RakshakState,
    isTabletLayout: Boolean,
    onShowSnackbar: (String) -> Unit
) {
    val sunlight = state.isSunlightMode
    val hindi = state.isHindi
    var modalPersonnel by remember { mutableStateOf<PersonnelRecord?>(null) }
    val expandedExplainabilityMap = remember {
        mutableStateMapOf("CRPF-84920" to true)
    }

    modalPersonnel?.let { person ->
        WelfareInterventionDialog(
            person = person,
            sunlight = sunlight,
            onDismiss = { modalPersonnel = null },
            onSelectAction = { actionLabel ->
                state.scheduleIntervention(person.id, actionLabel)
                modalPersonnel = null
                onShowSnackbar("Intervention Scheduled for ${person.name}: $actionLabel")
            }
        )
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = if (isTabletLayout) 24.dp else 16.dp, vertical = 12.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // 1. Battalion Readiness & Welfare Overview (Bento KPI Cards)
        TacticalBentoCard(sunlight = sunlight) {
            FlowRow(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Column {
                    Text(
                        text = if (hindi)
                            "बटालियन तत्परता और कल्याण अवलोकन • 204 कोबरा बटालियन"
                        else
                            "BATTALION READINESS & WELFARE OVERVIEW • 204 CoBRA BN",
                        color = TacticalPalette.CyberTeal,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.ExtraBold,
                        letterSpacing = 0.5.sp
                    )
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(
                        text = "Predictive Edge-AI Force Health & Preventive Welfare Triage",
                        color = TacticalPalette.textSecondary(sunlight),
                        fontSize = 12.sp
                    )
                }
                StatusPillBadge(label = "SECTOR: BASTAR SOUTH", color = TacticalPalette.Emerald)
            }

            Spacer(modifier = Modifier.height(14.dp))

            // 4 KPI Bento Cards (2x2 on Phone, 4x1 on Tablet)
            if (isTabletLayout) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    KpiStatTile(
                        modifier = Modifier.weight(1f),
                        title = "Total Monitored",
                        value = "120",
                        subtitle = "100% Wearable Sync",
                        color = TacticalPalette.CyberTeal,
                        sunlight = sunlight
                    )
                    KpiStatTile(
                        modifier = Modifier.weight(1f),
                        title = "Optimal (Green)",
                        value = "104 (86%)",
                        subtitle = "FRSI 70–100 • Fit",
                        color = TacticalPalette.Emerald,
                        sunlight = sunlight
                    )
                    KpiStatTile(
                        modifier = Modifier.weight(1f),
                        title = "Moderate (Amber)",
                        value = "12 (10%)",
                        subtitle = "FRSI 50–69 • Watch",
                        color = TacticalPalette.Amber,
                        sunlight = sunlight
                    )
                    KpiStatTile(
                        modifier = Modifier.weight(1f),
                        title = "High Alert (Red)",
                        value = "4 (4%)",
                        subtitle = "FRSI <50 • MO Triage",
                        color = TacticalPalette.Red,
                        sunlight = sunlight
                    )
                }
            } else {
                Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                        KpiStatTile(
                            modifier = Modifier.weight(1f),
                            title = "Total Monitored",
                            value = "120",
                            subtitle = "100% Active Sync",
                            color = TacticalPalette.CyberTeal,
                            sunlight = sunlight
                        )
                        KpiStatTile(
                            modifier = Modifier.weight(1f),
                            title = "Optimal (Green)",
                            value = "104 (86%)",
                            subtitle = "FRSI 70–100 • Fit",
                            color = TacticalPalette.Emerald,
                            sunlight = sunlight
                        )
                    }
                    Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                        KpiStatTile(
                            modifier = Modifier.weight(1f),
                            title = "Moderate (Amber)",
                            value = "12 (10%)",
                            subtitle = "FRSI 50–69 • Watch",
                            color = TacticalPalette.Amber,
                            sunlight = sunlight
                        )
                        KpiStatTile(
                            modifier = Modifier.weight(1f),
                            title = "High Alert (Red)",
                            value = "4 (4%)",
                            subtitle = "FRSI <50 • Action Req.",
                            color = TacticalPalette.Red,
                            sunlight = sunlight
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(14.dp))

            Text(
                text = "BATTALION READINESS DISTRIBUTION (86% OPTIMAL • 10% MODERATE • 4% HIGH PRIORITY)",
                color = TacticalPalette.textSecondary(sunlight),
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 0.4.sp
            )
            Spacer(modifier = Modifier.height(6.dp))
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(12.dp)
                    .clip(RoundedCornerShape(999.dp))
            ) {
                Box(
                    modifier = Modifier
                        .weight(0.86f)
                        .fillMaxSize()
                        .background(TacticalPalette.Emerald)
                )
                Box(
                    modifier = Modifier
                        .weight(0.10f)
                        .fillMaxSize()
                        .background(TacticalPalette.Amber)
                )
                Box(
                    modifier = Modifier
                        .weight(0.04f)
                        .fillMaxSize()
                        .background(TacticalPalette.Red)
                )
            }
        }

        // 2. Actionable Personnel Triage Roster (Split-Pane on Tablet, Stack on Phone)
        if (isTabletLayout) {
            val selectedPerson = state.roster.find { it.id == state.selectedPersonnelId } ?: state.roster.first()
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(16.dp),
                verticalAlignment = Alignment.Top
            ) {
                Column(
                    modifier = Modifier.weight(1.25f),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Text(
                        text = "ACTIONABLE PERSONNEL TRIAGE ROSTER (TAP TO INSPECT OR INTERVENE)",
                        color = TacticalPalette.textPrimary(sunlight),
                        fontSize = 12.sp,
                        fontWeight = FontWeight.ExtraBold,
                        letterSpacing = 0.5.sp
                    )
                    state.roster.forEach { person ->
                        PersonnelRosterCard(
                            person = person,
                            sunlight = sunlight,
                            isSelected = person.id == selectedPerson.id,
                            showExplainability = expandedExplainabilityMap[person.id] == true,
                            onToggleExplainability = {
                                expandedExplainabilityMap[person.id] = !(expandedExplainabilityMap[person.id] ?: false)
                            },
                            onSelectCard = { state.selectedPersonnelId = person.id },
                            onInitiateIntervention = { modalPersonnel = person }
                        )
                    }
                }

                Column(
                    modifier = Modifier.weight(0.95f),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Text(
                        text = "TABLET COMMAND INSPECTOR • SELECTED PERSONNEL DOSSIER",
                        color = TacticalPalette.CyberTeal,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.ExtraBold,
                        letterSpacing = 0.5.sp
                    )
                    TabletInspectorDossierCard(
                        person = selectedPerson,
                        sunlight = sunlight,
                        onDispatchAction = { actionLabel ->
                            state.scheduleIntervention(selectedPerson.id, actionLabel)
                            onShowSnackbar("Intervention Scheduled for ${selectedPerson.name}: $actionLabel")
                        }
                    )
                }
            }
        } else {
            Text(
                text = "ACTIONABLE PERSONNEL TRIAGE ROSTER (PRIORITIZED BY PREDICTIVE RISK)",
                color = TacticalPalette.textPrimary(sunlight),
                fontSize = 12.sp,
                fontWeight = FontWeight.ExtraBold,
                letterSpacing = 0.5.sp
            )
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                state.roster.forEach { person ->
                    PersonnelRosterCard(
                        person = person,
                        sunlight = sunlight,
                        isSelected = false,
                        showExplainability = expandedExplainabilityMap[person.id] == true,
                        onToggleExplainability = {
                            expandedExplainabilityMap[person.id] = !(expandedExplainabilityMap[person.id] ?: false)
                        },
                        onSelectCard = { state.selectedPersonnelId = person.id },
                        onInitiateIntervention = { modalPersonnel = person }
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(20.dp))
    }
}

@Composable
private fun KpiStatTile(
    modifier: Modifier,
    title: String,
    value: String,
    subtitle: String,
    color: Color,
    sunlight: Boolean
) {
    Surface(
        modifier = modifier,
        shape = RoundedCornerShape(12.dp),
        color = TacticalPalette.bgElevated(sunlight),
        border = BorderStroke(1.2.dp, color.copy(alpha = 0.50f))
    ) {
        Column(modifier = Modifier.padding(12.dp)) {
            Text(
                text = title,
                color = TacticalPalette.textPrimary(sunlight),
                fontSize = 11.5.sp,
                fontWeight = FontWeight.Bold,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = value,
                color = color,
                fontSize = 20.sp,
                fontWeight = FontWeight.ExtraBold,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            Spacer(modifier = Modifier.height(2.dp))
            Text(
                text = subtitle,
                color = TacticalPalette.textSecondary(sunlight),
                fontSize = 11.sp,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun PersonnelRosterCard(
    person: PersonnelRecord,
    sunlight: Boolean,
    isSelected: Boolean,
    showExplainability: Boolean,
    onToggleExplainability: () -> Unit,
    onSelectCard: () -> Unit,
    onInitiateIntervention: () -> Unit
) {
    val tierColor = TacticalPalette.tierColor(person.tier)
    val isScheduled = person.status == "Intervention Scheduled"
    val statusColor = if (isScheduled) TacticalPalette.Emerald else tierColor

    TacticalBentoCard(
        sunlight = sunlight,
        accentLeftColor = tierColor,
        borderColor = if (isSelected) TacticalPalette.CyberTeal else null,
        modifier = Modifier.clickable { onSelectCard() }
    ) {
        // Header row with FlowRow so badges never collide with long names
        FlowRow(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Column {
                Text(
                    text = person.name,
                    color = TacticalPalette.textPrimary(sunlight),
                    fontSize = 15.sp,
                    fontWeight = FontWeight.ExtraBold
                )
                Spacer(modifier = Modifier.height(2.dp))
                Text(
                    text = "${person.id} • ${person.unit}",
                    color = TacticalPalette.textSecondary(sunlight),
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Medium
                )
            }
            FlowRow(
                horizontalArrangement = Arrangement.spacedBy(6.dp),
                verticalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                StatusPillBadge(
                    label = "FRSI: ${person.frsiScore}/100",
                    color = tierColor
                )
                StatusPillBadge(
                    label = person.status,
                    color = statusColor
                )
            }
        }

        Spacer(modifier = Modifier.height(10.dp))

        // Primary Risk Driver Banner
        Surface(
            shape = RoundedCornerShape(10.dp),
            color = tierColor.copy(alpha = 0.14f),
            border = BorderStroke(1.dp, tierColor.copy(alpha = 0.45f)),
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(modifier = Modifier.padding(12.dp)) {
                Text(
                    text = "Primary Risk Driver: ${person.riskDriver}",
                    color = tierColor,
                    fontSize = 12.5.sp,
                    fontWeight = FontWeight.ExtraBold
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = person.telemetryDetail,
                    color = TacticalPalette.textPrimary(sunlight),
                    fontSize = 12.sp,
                    lineHeight = 17.sp
                )
            }
        }

        if (person.activeIntervention != null) {
            Spacer(modifier = Modifier.height(10.dp))
            Surface(
                shape = RoundedCornerShape(10.dp),
                color = TacticalPalette.Emerald.copy(alpha = 0.16f),
                border = BorderStroke(1.2.dp, TacticalPalette.Emerald),
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier.padding(12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector = Icons.Default.CheckCircle,
                        contentDescription = null,
                        tint = TacticalPalette.Emerald,
                        modifier = Modifier.size(18.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = "Dispatched Welfare Action: ${person.activeIntervention}",
                        color = TacticalPalette.textPrimary(sunlight),
                        fontSize = 12.5.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(10.dp))

        // Sehat Setu 3-Step Closed-Loop Intervention Timeline (Wrapped cleanly)
        ClosedLoopTimelineRow(currentStep = person.closedLoopStep, sunlight = sunlight)

        Spacer(modifier = Modifier.height(12.dp))

        // Action Buttons (Stacked/Wrapped cleanly so buttons never overlap or clip)
        FlowRow(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(10.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            OutlinedButton(
                onClick = onToggleExplainability,
                border = BorderStroke(1.2.dp, TacticalPalette.CyberTeal),
                shape = RoundedCornerShape(10.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.AutoAwesome,
                    contentDescription = null,
                    tint = TacticalPalette.CyberTeal,
                    modifier = Modifier.size(16.dp)
                )
                Spacer(modifier = Modifier.width(6.dp))
                Text(
                    text = if (showExplainability) "Hide AI Breakdown" else "✨ Why this? (AI Signals)",
                    color = TacticalPalette.textPrimary(sunlight),
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold
                )
                Spacer(modifier = Modifier.width(4.dp))
                Icon(
                    imageVector = if (showExplainability) Icons.Default.ExpandLess else Icons.Default.ExpandMore,
                    contentDescription = null,
                    tint = TacticalPalette.CyberTeal,
                    modifier = Modifier.size(16.dp)
                )
            }

            Button(
                onClick = onInitiateIntervention,
                shape = RoundedCornerShape(10.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = if (isScheduled) TacticalPalette.CyberTeal else tierColor,
                    contentColor = Color(0xFF042F2E)
                )
            ) {
                Text(
                    text = if (isScheduled) "Update Intervention" else "Initiate Welfare Intervention",
                    fontSize = 12.5.sp,
                    fontWeight = FontWeight.ExtraBold
                )
            }
        }

        AnimatedVisibility(visible = showExplainability) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 10.dp)
                    .clip(RoundedCornerShape(10.dp))
                    .background(TacticalPalette.bgElevated(sunlight))
                    .border(1.dp, TacticalPalette.border(sunlight), RoundedCornerShape(10.dp))
                    .padding(12.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Text(
                    text = "PATHWISE AI SIGNAL ATTRIBUTION BREAKDOWN:",
                    color = TacticalPalette.CyberTeal,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.ExtraBold
                )
                person.aiAttributionFactors.forEach { factor ->
                    val c = if (factor.isAlert) TacticalPalette.Red else TacticalPalette.Amber
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.Top
                    ) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text(
                                text = factor.label,
                                color = TacticalPalette.textPrimary(sunlight),
                                fontSize = 12.sp,
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
                        StatusPillBadge(label = factor.weight, color = c)
                    }
                }
            }
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun ClosedLoopTimelineRow(
    currentStep: Int,
    sunlight: Boolean
) {
    val steps = listOf(
        "1. Edge-AI Risk Flagged",
        "2. MO Triage Review",
        "3. Welfare Action Dispatched"
    )
    FlowRow(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        steps.forEachIndexed { idx, label ->
            val stepNum = idx + 1
            val reached = currentStep >= stepNum
            val color = if (reached) TacticalPalette.Emerald else TacticalPalette.textMuted(sunlight)
            Row(
                modifier = Modifier
                    .clip(RoundedCornerShape(8.dp))
                    .background(
                        if (reached) TacticalPalette.Emerald.copy(alpha = 0.16f)
                        else TacticalPalette.bgElevated(sunlight)
                    )
                    .border(
                        1.dp,
                        if (reached) TacticalPalette.Emerald.copy(alpha = 0.55f)
                        else TacticalPalette.border(sunlight),
                        RoundedCornerShape(8.dp)
                    )
                    .padding(horizontal = 10.dp, vertical = 6.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .size(8.dp)
                        .clip(CircleShape)
                        .background(color)
                )
                Spacer(modifier = Modifier.width(6.dp))
                Text(
                    text = label,
                    color = if (reached) TacticalPalette.textPrimary(sunlight) else TacticalPalette.textSecondary(sunlight),
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}

@Composable
private fun TabletInspectorDossierCard(
    person: PersonnelRecord,
    sunlight: Boolean,
    onDispatchAction: (String) -> Unit
) {
    val tierColor = TacticalPalette.tierColor(person.tier)

    TacticalBentoCard(
        sunlight = sunlight,
        accentLeftColor = tierColor
    ) {
        Column(
            modifier = Modifier.fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            DoubleRingFrsiGauge(
                score = person.frsiScore,
                tier = person.tier,
                sunlight = sunlight,
                size = 148.dp
            )
            Spacer(modifier = Modifier.height(10.dp))
            Text(
                text = person.name,
                color = TacticalPalette.textPrimary(sunlight),
                fontSize = 16.sp,
                fontWeight = FontWeight.ExtraBold
            )
            Text(
                text = "${person.id} • ${person.unit}",
                color = TacticalPalette.textSecondary(sunlight),
                fontSize = 12.sp
            )
        }

        Spacer(modifier = Modifier.height(14.dp))

        Text(
            text = "ONE-CLICK PREVENTIVE WELFARE DISPATCH:",
            color = TacticalPalette.CyberTeal,
            fontSize = 11.5.sp,
            fontWeight = FontWeight.ExtraBold,
            letterSpacing = 0.5.sp
        )
        Spacer(modifier = Modifier.height(8.dp))

        InterventionOptionTile(
            icon = Icons.Default.SupportAgent,
            title = "Schedule Tele-Counseling with MO",
            subtitle = "Private 1-on-1 session with Battalion Medical Officer today at 17:30 HRS",
            color = TacticalPalette.Emerald,
            sunlight = sunlight,
            onClick = { onDispatchAction("Tele-Counseling with Unit MO (17:30 HRS)") }
        )
        Spacer(modifier = Modifier.height(8.dp))
        InterventionOptionTile(
            icon = Icons.Default.Schedule,
            title = "Recommend 72h Duty Rotation & Rest",
            subtitle = "Reassign from night LRP patrol to daytime reserve lines for circadian recovery",
            color = TacticalPalette.Amber,
            sunlight = sunlight,
            onClick = { onDispatchAction("72h Duty Rotation & Rest Recovery") }
        )
        Spacer(modifier = Modifier.height(8.dp))
        InterventionOptionTile(
            icon = Icons.Default.FlightTakeoff,
            title = "Fast-Track Welfare Leave Request",
            subtitle = "Priority endorsement to Company Commander for 7-day family welfare leave",
            color = TacticalPalette.CyberTeal,
            sunlight = sunlight,
            onClick = { onDispatchAction("Fast-Track Welfare Leave Endorsed") }
        )
    }
}

@Composable
private fun WelfareInterventionDialog(
    person: PersonnelRecord,
    sunlight: Boolean,
    onDismiss: () -> Unit,
    onSelectAction: (String) -> Unit
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        containerColor = TacticalPalette.bgCard(sunlight),
        title = {
            Column {
                Text(
                    text = "ONE-CLICK WELFARE INTERVENTION",
                    color = TacticalPalette.CyberTeal,
                    fontSize = 11.5.sp,
                    fontWeight = FontWeight.ExtraBold,
                    letterSpacing = 0.6.sp
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = "${person.name} • FRSI ${person.frsiScore}/100",
                    color = TacticalPalette.textPrimary(sunlight),
                    fontSize = 16.sp,
                    fontWeight = FontWeight.ExtraBold
                )
            }
        },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                Text(
                    text = "Driver: ${person.riskDriver}",
                    color = TacticalPalette.textSecondary(sunlight),
                    fontSize = 12.5.sp,
                    lineHeight = 17.sp
                )
                InterventionOptionTile(
                    icon = Icons.Default.SupportAgent,
                    title = "Schedule Tele-Counseling with MO",
                    subtitle = "Private 1-on-1 medical consultation (Zero ACR impact)",
                    color = TacticalPalette.Emerald,
                    sunlight = sunlight,
                    onClick = { onSelectAction("Schedule Tele-Counseling with MO") }
                )
                InterventionOptionTile(
                    icon = Icons.Default.Schedule,
                    title = "Recommend 72h Duty Rotation & Rest",
                    subtitle = "Shift from forward night patrol to reserve recovery duty",
                    color = TacticalPalette.Amber,
                    sunlight = sunlight,
                    onClick = { onSelectAction("Recommend 72h Duty Rotation & Rest") }
                )
                InterventionOptionTile(
                    icon = Icons.Default.FlightTakeoff,
                    title = "Fast-Track Welfare Leave Request",
                    subtitle = "Priority medical-welfare leave endorsement to Commandant",
                    color = TacticalPalette.CyberTeal,
                    sunlight = sunlight,
                    onClick = { onSelectAction("Fast-Track Welfare Leave Request") }
                )
            }
        },
        confirmButton = {
            OutlinedButton(onClick = onDismiss) {
                Text("Cancel", color = TacticalPalette.textPrimary(sunlight))
            }
        }
    )
}

@Composable
private fun InterventionOptionTile(
    icon: ImageVector,
    title: String,
    subtitle: String,
    color: Color,
    sunlight: Boolean,
    onClick: () -> Unit
) {
    Surface(
        shape = RoundedCornerShape(12.dp),
        color = color.copy(alpha = 0.15f),
        border = BorderStroke(1.2.dp, color.copy(alpha = 0.55f)),
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
    ) {
        Row(
            modifier = Modifier.padding(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = color,
                modifier = Modifier.size(22.dp)
            )
            Spacer(modifier = Modifier.width(10.dp))
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = title,
                    color = TacticalPalette.textPrimary(sunlight),
                    fontSize = 13.5.sp,
                    fontWeight = FontWeight.ExtraBold
                )
                Spacer(modifier = Modifier.height(2.dp))
                Text(
                    text = subtitle,
                    color = TacticalPalette.textSecondary(sunlight),
                    fontSize = 12.sp,
                    lineHeight = 16.sp
                )
            }
        }
    }
}
