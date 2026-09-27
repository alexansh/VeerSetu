package `in`.gov.mha.crpf.rakshaksense

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.Crossfade
import androidx.compose.animation.core.tween
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Bolt
import androidx.compose.material.icons.filled.CloudDone
import androidx.compose.material.icons.filled.CloudOff
import androidx.compose.material.icons.filled.DarkMode
import androidx.compose.material.icons.filled.Dashboard
import androidx.compose.material.icons.filled.Language
import androidx.compose.material.icons.filled.LightMode
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.PhoneAndroid
import androidx.compose.material.icons.filled.Security
import androidx.compose.material.icons.filled.TabletMac
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Snackbar
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import `in`.gov.mha.crpf.rakshaksense.model.RakshakState
import `in`.gov.mha.crpf.rakshaksense.ui.JawanCompanionScreen
import `in`.gov.mha.crpf.rakshaksense.ui.MoCommanderConsoleScreen
import `in`.gov.mha.crpf.rakshaksense.ui.TacticalPalette
import `in`.gov.mha.crpf.rakshaksense.ui.VeerSetuLogoBadge
import `in`.gov.mha.crpf.rakshaksense.ui.VeerSetuSplashScreen
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            val state = remember { RakshakState() }
            RakshakSenseApp(state = state)
        }
    }
}

@Composable
fun RakshakSenseApp(state: RakshakState) {
    val sunlight = state.isSunlightMode
    val snackbarHostState = remember { SnackbarHostState() }
    val scope = rememberCoroutineScope()

    val colorScheme = if (sunlight) {
        lightColorScheme(
            primary = TacticalPalette.Emerald,
            secondary = TacticalPalette.CyberTeal,
            background = TacticalPalette.SunBg,
            surface = TacticalPalette.SunCard
        )
    } else {
        darkColorScheme(
            primary = TacticalPalette.Emerald,
            secondary = TacticalPalette.CyberTeal,
            background = TacticalPalette.DeepNavy,
            surface = TacticalPalette.SlateCard
        )
    }

    MaterialTheme(colorScheme = colorScheme) {
        Crossfade(
            targetState = state.showSplash,
            animationSpec = tween(durationMillis = 450),
            label = "splashCrossfade"
        ) { isSplashVisible ->
            if (isSplashVisible) {
                VeerSetuSplashScreen(
                    onFinished = { state.showSplash = false }
                )
            } else {
                BoxWithConstraints(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(TacticalPalette.bgPrimary(sunlight))
                        .windowInsetsPadding(WindowInsets.safeDrawing)
                ) {
                    val autoTablet = maxWidth >= 680.dp
                    val isTabletLayout = when (state.layoutModeOverride) {
                        1 -> false
                        2 -> true
                        else -> autoTablet
                    }

            Scaffold(
                containerColor = TacticalPalette.bgPrimary(sunlight),
                contentWindowInsets = WindowInsets(0, 0, 0, 0),
                snackbarHost = {
                    SnackbarHost(hostState = snackbarHostState) { data ->
                        Snackbar(
                            snackbarData = data,
                            containerColor = TacticalPalette.Emerald,
                            contentColor = Color(0xFF042F2E)
                        )
                    }
                },
                bottomBar = {
                    SehatSetuFloatingBottomDock(
                        state = state,
                        sunlight = sunlight
                    )
                }
            ) { innerPadding ->
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(innerPadding)
                ) {
                    SehatSetuTopIslandHeader(
                        state = state,
                        isTabletLayout = isTabletLayout,
                        sunlight = sunlight
                    )

                    AnimatedVisibility(visible = state.isOfflineEdgeMode) {
                        Surface(
                            color = TacticalPalette.Amber.copy(alpha = 0.18f),
                            border = BorderStroke(1.2.dp, TacticalPalette.Amber),
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(
                                    horizontal = if (isTabletLayout) 24.dp else 16.dp,
                                    vertical = 4.dp
                                ),
                            shape = RoundedCornerShape(12.dp)
                        ) {
                            Row(
                                modifier = Modifier.padding(horizontal = 14.dp, vertical = 10.dp),
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
                                    text = "OFFLINE-FIRST EDGE ENGINE ACTIVE: On-device SQLite/Room queue enabled for zero-connectivity forward posts.",
                                    color = TacticalPalette.textPrimary(sunlight),
                                    fontSize = 12.sp,
                                    fontWeight = FontWeight.Bold,
                                    lineHeight = 17.sp
                                )
                            }
                        }
                    }

                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .fillMaxWidth()
                    ) {
                        if (state.activeTab == 0) {
                            JawanCompanionScreen(
                                state = state,
                                isTabletLayout = isTabletLayout,
                                onShowSnackbar = { msg ->
                                    scope.launch { snackbarHostState.showSnackbar(msg) }
                                }
                            )
                        } else {
                            MoCommanderConsoleScreen(
                                state = state,
                                isTabletLayout = isTabletLayout,
                                onShowSnackbar = { msg ->
                                    scope.launch { snackbarHostState.showSnackbar(msg) }
                                }
                            )
                        }
                    }
                }
            }
                }
            }
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun SehatSetuTopIslandHeader(
    state: RakshakState,
    isTabletLayout: Boolean,
    sunlight: Boolean
) {
    Surface(
        shape = RoundedCornerShape(18.dp),
        color = TacticalPalette.bgCard(sunlight),
        border = BorderStroke(1.2.dp, TacticalPalette.border(sunlight)),
        shadowElevation = 4.dp,
        modifier = Modifier
            .fillMaxWidth()
            .padding(
                horizontal = if (isTabletLayout) 24.dp else 16.dp,
                vertical = 8.dp
            )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(14.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            // Row 1: Brand Title + SIH Badge (never overlapped by utility pills)
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Row(
                    modifier = Modifier.weight(1f),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    VeerSetuLogoBadge(
                        size = 44.dp,
                        modifier = Modifier
                            .clip(CircleShape)
                            .clickable { state.showSplash = true }
                    )
                    Spacer(modifier = Modifier.width(10.dp))
                    Column(modifier = Modifier.weight(1f)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text(
                                text = "VEER SETU • RAKSHAK SENSE",
                                color = TacticalPalette.textPrimary(sunlight),
                                fontSize = 15.5.sp,
                                fontWeight = FontWeight.ExtraBold,
                                letterSpacing = 0.6.sp,
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(6.dp))
                                    .background(TacticalPalette.Emerald.copy(alpha = 0.20f))
                                    .border(
                                        1.dp,
                                        TacticalPalette.Emerald.copy(alpha = 0.6f),
                                        RoundedCornerShape(6.dp)
                                    )
                                    .padding(horizontal = 6.dp, vertical = 2.dp)
                            ) {
                                Text(
                                    text = "SIH26186",
                                    color = TacticalPalette.Emerald,
                                    fontSize = 10.sp,
                                    fontWeight = FontWeight.ExtraBold
                                )
                            }
                        }
                        Spacer(modifier = Modifier.height(2.dp))
                        Text(
                            text = "CRPF / MHA • AI Personnel Stress & Welfare System (Tap logo for Intro)",
                            color = TacticalPalette.textSecondary(sunlight),
                            fontSize = 11.5.sp,
                            fontWeight = FontWeight.Medium,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    }
                }
            }

            // Row 2: Sehat Setu Utility Pills (Wrapped cleanly in their own dedicated row)
            FlowRow(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                TopActionPill(
                    icon = Icons.Default.Language,
                    label = if (state.isHindi) "हिन्दी" else "EN / हिं",
                    active = state.isHindi,
                    activeColor = TacticalPalette.CyberTeal,
                    sunlight = sunlight,
                    onClick = { state.isHindi = !state.isHindi }
                )
                TopActionPill(
                    icon = if (state.isOfflineEdgeMode) Icons.Default.CloudOff else Icons.Default.CloudDone,
                    label = if (state.isOfflineEdgeMode) "Offline Edge" else "Online Sync",
                    active = state.isOfflineEdgeMode,
                    activeColor = if (state.isOfflineEdgeMode) TacticalPalette.Amber else TacticalPalette.Emerald,
                    sunlight = sunlight,
                    onClick = { state.isOfflineEdgeMode = !state.isOfflineEdgeMode }
                )
                TopActionPill(
                    icon = if (sunlight) Icons.Default.LightMode else Icons.Default.DarkMode,
                    label = if (sunlight) "Sunlight UI" else "Dark UI",
                    active = sunlight,
                    activeColor = TacticalPalette.Amber,
                    sunlight = sunlight,
                    onClick = { state.isSunlightMode = !state.isSunlightMode }
                )
                TopActionPill(
                    icon = if (isTabletLayout) Icons.Default.TabletMac else Icons.Default.PhoneAndroid,
                    label = if (isTabletLayout) "Tablet View" else "Phone View",
                    active = isTabletLayout,
                    activeColor = TacticalPalette.CyberTeal,
                    sunlight = sunlight,
                    onClick = {
                        state.layoutModeOverride = if (isTabletLayout) 1 else 2
                    }
                )
            }

            // Row 3: 3-Tier RBAC Role Switcher Bar (#6 Role-Based Access Control)
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(12.dp))
                    .background(TacticalPalette.bgElevated(sunlight))
                    .border(1.dp, TacticalPalette.border(sunlight), RoundedCornerShape(12.dp))
                    .padding(4.dp),
                horizontalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                RoleSwitcherTab(
                    modifier = Modifier.weight(1f),
                    selected = state.activeTab == 0,
                    label = if (state.isHindi) "जवान (स्वयं)" else "Personnel (Self)",
                    icon = Icons.Default.Person,
                    sunlight = sunlight,
                    onClick = { state.activeTab = 0 }
                )
                RoleSwitcherTab(
                    modifier = Modifier.weight(1f),
                    selected = state.activeTab == 1 && state.consoleSubRole == 0,
                    label = if (state.isHindi) "कल्याण अधिकारी" else "Welfare Officer",
                    icon = Icons.Default.Security,
                    sunlight = sunlight,
                    onClick = {
                        state.activeTab = 1
                        state.consoleSubRole = 0
                    }
                )
                RoleSwitcherTab(
                    modifier = Modifier.weight(1f),
                    selected = state.activeTab == 1 && state.consoleSubRole == 1,
                    label = if (state.isHindi) "कमांडर (समग्र)" else "Commander",
                    icon = Icons.Default.Dashboard,
                    sunlight = sunlight,
                    onClick = {
                        state.activeTab = 1
                        state.consoleSubRole = 1
                    }
                )
            }
        }
    }
}

@Composable
private fun TopActionPill(
    icon: ImageVector,
    label: String,
    active: Boolean,
    activeColor: Color,
    sunlight: Boolean,
    onClick: () -> Unit
) {
    Surface(
        shape = RoundedCornerShape(999.dp),
        color = if (active) activeColor.copy(alpha = 0.20f) else TacticalPalette.bgElevated(sunlight),
        border = BorderStroke(
            1.dp,
            if (active) activeColor else TacticalPalette.border(sunlight)
        ),
        modifier = Modifier.clickable(onClick = onClick)
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = if (active) activeColor else TacticalPalette.textPrimary(sunlight),
                modifier = Modifier.size(14.dp)
            )
            Spacer(modifier = Modifier.width(5.dp))
            Text(
                text = label,
                color = if (active) activeColor else TacticalPalette.textPrimary(sunlight),
                fontSize = 11.5.sp,
                fontWeight = FontWeight.Bold
            )
        }
    }
}

@Composable
private fun RoleSwitcherTab(
    modifier: Modifier,
    selected: Boolean,
    label: String,
    icon: ImageVector,
    sunlight: Boolean,
    onClick: () -> Unit
) {
    Surface(
        modifier = modifier.clickable(onClick = onClick),
        shape = RoundedCornerShape(9.dp),
        color = if (selected) TacticalPalette.Emerald else Color.Transparent
    ) {
        Row(
            modifier = Modifier.padding(vertical = 8.dp, horizontal = 6.dp),
            horizontalArrangement = Arrangement.Center,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = if (selected) Color(0xFF042F2E) else TacticalPalette.textPrimary(sunlight),
                modifier = Modifier.size(15.dp)
            )
            Spacer(modifier = Modifier.width(4.dp))
            Text(
                text = label,
                color = if (selected) Color(0xFF042F2E) else TacticalPalette.textPrimary(sunlight),
                fontSize = 11.5.sp,
                fontWeight = FontWeight.ExtraBold,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}

@Composable
private fun SehatSetuFloatingBottomDock(
    state: RakshakState,
    sunlight: Boolean
) {
    Surface(
        color = TacticalPalette.bgPrimary(sunlight),
        modifier = Modifier.fillMaxWidth()
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 12.dp, vertical = 8.dp),
            contentAlignment = Alignment.Center
        ) {
            Surface(
                shape = RoundedCornerShape(28.dp),
                color = TacticalPalette.bgCard(sunlight),
                border = BorderStroke(1.2.dp, TacticalPalette.border(sunlight)),
                shadowElevation = 8.dp,
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 6.dp, vertical = 6.dp),
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    BottomDockPillItem(
                        modifier = Modifier.weight(1f),
                        selected = state.activeTab == 0,
                        icon = Icons.Default.Person,
                        label = "Jawan",
                        badge = "${state.frsiScore}",
                        sunlight = sunlight,
                        onClick = { state.activeTab = 0 }
                    )
                    BottomDockPillItem(
                        modifier = Modifier.weight(1f),
                        selected = state.activeTab == 1 && state.consoleSubRole == 0,
                        icon = Icons.Default.Security,
                        label = "Welfare MO",
                        badge = "${state.welfareAlerts.size}",
                        sunlight = sunlight,
                        onClick = {
                            state.activeTab = 1
                            state.consoleSubRole = 0
                        }
                    )
                    BottomDockPillItem(
                        modifier = Modifier.weight(1f),
                        selected = state.activeTab == 1 && state.consoleSubRole == 1,
                        icon = Icons.Default.Dashboard,
                        label = "Commander",
                        badge = "PDF",
                        sunlight = sunlight,
                        onClick = {
                            state.activeTab = 1
                            state.consoleSubRole = 1
                        }
                    )
                }
            }
        }
    }
}

@Composable
private fun BottomDockPillItem(
    modifier: Modifier,
    selected: Boolean,
    icon: ImageVector,
    label: String,
    badge: String,
    sunlight: Boolean,
    onClick: () -> Unit
) {
    val activeColor = TacticalPalette.Emerald
    Surface(
        shape = RoundedCornerShape(22.dp),
        color = if (selected) activeColor.copy(alpha = 0.20f) else Color.Transparent,
        border = if (selected) BorderStroke(1.2.dp, activeColor) else null,
        modifier = modifier.clickable(onClick = onClick)
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 10.dp, vertical = 9.dp),
            horizontalArrangement = Arrangement.Center,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = if (selected) activeColor else TacticalPalette.textPrimary(sunlight),
                modifier = Modifier.size(17.dp)
            )
            Spacer(modifier = Modifier.width(6.dp))
            Text(
                text = label,
                color = TacticalPalette.textPrimary(sunlight),
                fontSize = 12.5.sp,
                fontWeight = FontWeight.ExtraBold,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            Spacer(modifier = Modifier.width(6.dp))
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(999.dp))
                    .background(
                        if (selected) activeColor else TacticalPalette.bgElevated(sunlight)
                    )
                    .padding(horizontal = 6.dp, vertical = 2.dp)
            ) {
                Text(
                    text = badge,
                    color = if (selected) Color(0xFF042F2E) else TacticalPalette.textSecondary(sunlight),
                    fontSize = 10.sp,
                    fontWeight = FontWeight.ExtraBold
                )
            }
        }
    }
}
