package `in`.gov.mha.crpf.rakshaksense.ui

import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowForward
import androidx.compose.material.icons.filled.Bolt
import androidx.compose.material.icons.filled.Shield
import androidx.compose.material.icons.filled.VerifiedUser
import androidx.compose.material3.Icon
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay

/**
 * Custom vector-drawn VeerSetu / RakshakSense emblem used across the Splash Screen
 * and Top Island Header. Combines the Tactical Shield of Valor ("Veer"),
 * Bridge Arch of Care ("Setu"), Golden Crest Star, and Biometric ECG Pulse.
 */
@Composable
fun VeerSetuLogoBadge(
    modifier: Modifier = Modifier,
    size: Dp = 44.dp
) {
    Canvas(modifier = modifier.size(size)) {
        val w = this.size.width
        val h = this.size.height

        // 1. Rounded tactical container background
        drawCircle(
            brush = Brush.linearGradient(
                colors = listOf(
                    Color(0xFF0A192F),
                    Color(0xFF063B3A)
                )
            ),
            radius = w * 0.48f,
            center = Offset(w * 0.5f, h * 0.5f)
        )

        // Outer subtle ring
        drawCircle(
            brush = Brush.linearGradient(
                colors = listOf(TacticalPalette.Emerald, TacticalPalette.CyberTeal)
            ),
            radius = w * 0.47f,
            center = Offset(w * 0.5f, h * 0.5f),
            style = Stroke(width = w * 0.035f)
        )

        // 2. Outer Tactical Shield Path
        val outerShield = Path().apply {
            moveTo(w * 0.50f, h * 0.13f)
            lineTo(w * 0.81f, h * 0.25f)
            lineTo(w * 0.81f, h * 0.49f)
            cubicTo(
                w * 0.81f, h * 0.69f,
                w * 0.67f, h * 0.83f,
                w * 0.50f, h * 0.89f
            )
            cubicTo(
                w * 0.33f, h * 0.83f,
                w * 0.19f, h * 0.69f,
                w * 0.19f, h * 0.49f
            )
            lineTo(w * 0.19f, h * 0.25f)
            close()
        }
        drawPath(
            path = outerShield,
            brush = Brush.linearGradient(
                colors = listOf(TacticalPalette.Emerald, TacticalPalette.CyberTeal),
                start = Offset(w * 0.2f, h * 0.15f),
                end = Offset(w * 0.8f, h * 0.85f)
            )
        )

        // 3. Inner Dark Core Shield
        val innerShield = Path().apply {
            moveTo(w * 0.50f, h * 0.18f)
            lineTo(w * 0.76f, h * 0.29f)
            lineTo(w * 0.76f, h * 0.48f)
            cubicTo(
                w * 0.76f, h * 0.65f,
                w * 0.64f, h * 0.77f,
                w * 0.50f, h * 0.83f
            )
            cubicTo(
                w * 0.36f, h * 0.77f,
                w * 0.24f, h * 0.65f,
                w * 0.24f, h * 0.48f
            )
            lineTo(w * 0.24f, h * 0.29f)
            close()
        }
        drawPath(
            path = innerShield,
            brush = Brush.verticalGradient(
                colors = listOf(Color(0xFF0B192C), Color(0xFF052E2B))
            )
        )

        // 4. "Setu" Bridge Arch inside lower shield
        val bridgeArch = Path().apply {
            moveTo(w * 0.31f, h * 0.65f)
            quadraticBezierTo(w * 0.50f, h * 0.51f, w * 0.69f, h * 0.65f)
        }
        drawPath(
            path = bridgeArch,
            color = TacticalPalette.CyberTeal.copy(alpha = 0.70f),
            style = Stroke(width = w * 0.032f, cap = StrokeCap.Round)
        )

        // 5. Golden Valor Crest Diamond/Star at top of shield
        val crestPath = Path().apply {
            moveTo(w * 0.50f, h * 0.23f)
            lineTo(w * 0.545f, h * 0.285f)
            lineTo(w * 0.50f, h * 0.34f)
            lineTo(w * 0.455f, h * 0.285f)
            close()
        }
        drawPath(path = crestPath, color = TacticalPalette.Amber)

        // 6. Biometric ECG Heartbeat + 'V' Pulse Line
        val ecgPath = Path().apply {
            moveTo(w * 0.27f, h * 0.51f)
            lineTo(w * 0.38f, h * 0.51f)
            lineTo(w * 0.42f, h * 0.41f)
            lineTo(w * 0.48f, h * 0.63f)
            lineTo(w * 0.54f, h * 0.35f)
            lineTo(w * 0.59f, h * 0.55f)
            lineTo(w * 0.63f, h * 0.51f)
            lineTo(w * 0.73f, h * 0.51f)
        }
        drawPath(
            path = ecgPath,
            color = Color(0xFF34D399),
            style = Stroke(
                width = w * 0.042f,
                cap = StrokeCap.Round,
                join = StrokeJoin.Round
            )
        )

        // Endpoints
        drawCircle(
            color = TacticalPalette.CyberTeal,
            radius = w * 0.025f,
            center = Offset(w * 0.27f, h * 0.51f)
        )
        drawCircle(
            color = TacticalPalette.Amber,
            radius = w * 0.025f,
            center = Offset(w * 0.73f, h * 0.51f)
        )
    }
}

/**
 * Full-screen animated Splash Screen Intro inspired by SehatSetu & PathWise,
 * tailored for VeerSetu / RakshakSense (SIH26186 — CRPF / MHA).
 */
@Composable
fun VeerSetuSplashScreen(
    onFinished: () -> Unit
) {
    var startAnim by remember { mutableStateOf(false) }

    val logoScale by animateFloatAsState(
        targetValue = if (startAnim) 1f else 0.55f,
        animationSpec = spring(
            dampingRatio = Spring.DampingRatioMediumBouncy,
            stiffness = Spring.StiffnessLow
        ),
        label = "logoScale"
    )

    val contentAlpha by animateFloatAsState(
        targetValue = if (startAnim) 1f else 0f,
        animationSpec = tween(durationMillis = 750, easing = FastOutSlowInEasing),
        label = "contentAlpha"
    )

    val infiniteTransition = rememberInfiniteTransition(label = "splashPulse")
    val haloScale by infiniteTransition.animateFloat(
        initialValue = 0.92f,
        targetValue = 1.14f,
        animationSpec = infiniteRepeatable(
            animation = tween(1300, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "haloScale"
    )
    val ecgPhase by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(1800, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "ecgPhase"
    )

    LaunchedEffect(Unit) {
        startAnim = true
        delay(2400)
        onFinished()
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    colors = listOf(
                        Color(0xFF050B14),
                        Color(0xFF0A1628),
                        Color(0xFF072227)
                    )
                )
            )
            .windowInsetsPadding(WindowInsets.safeDrawing),
        contentAlignment = Alignment.Center
    ) {
        Column(
            modifier = Modifier
                .widthIn(max = 540.dp)
                .fillMaxWidth()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 24.dp, vertical = 20.dp)
                .alpha(contentAlpha),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            // Top Ministry / SIH Tag
            Surface(
                shape = RoundedCornerShape(50),
                color = TacticalPalette.Emerald.copy(alpha = 0.14f),
                border = BorderStroke(1.dp, TacticalPalette.Emerald.copy(alpha = 0.45f))
            ) {
                Row(
                    modifier = Modifier.padding(horizontal = 14.dp, vertical = 6.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector = Icons.Default.Shield,
                        contentDescription = null,
                        tint = TacticalPalette.Emerald,
                        modifier = Modifier.size(15.dp)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Text(
                        text = "MINISTRY OF HOME AFFAIRS • CRPF • SIH26186",
                        color = Color(0xFF6EE7B7),
                        fontSize = 11.sp,
                        fontWeight = FontWeight.ExtraBold,
                        letterSpacing = 0.8.sp
                    )
                }
            }

            Spacer(modifier = Modifier.height(22.dp))

            // Fixed-size Logo Container (prevents any scale/pulse overlap with text below)
            Box(
                modifier = Modifier.size(176.dp),
                contentAlignment = Alignment.Center
            ) {
                // Outer pulsing tactical sonar ring
                Box(
                    modifier = Modifier
                        .size(164.dp)
                        .scale(haloScale)
                        .clip(CircleShape)
                        .background(TacticalPalette.Emerald.copy(alpha = 0.08f))
                        .border(
                            1.5.dp,
                            TacticalPalette.Emerald.copy(alpha = 0.28f),
                            CircleShape
                        )
                )
                // Middle steady glow ring
                Box(
                    modifier = Modifier
                        .size(140.dp)
                        .clip(CircleShape)
                        .background(TacticalPalette.CyberTeal.copy(alpha = 0.10f))
                        .border(
                            1.dp,
                            TacticalPalette.CyberTeal.copy(alpha = 0.35f),
                            CircleShape
                        )
                )
                // Core VeerSetu Shield Logo Badge
                VeerSetuLogoBadge(
                    size = 118.dp,
                    modifier = Modifier.scale(logoScale)
                )
            }

            Spacer(modifier = Modifier.height(18.dp))

            // Brand Title: VEER SETU
            Text(
                text = buildAnnotatedString {
                    withStyle(SpanStyle(color = Color(0xFFF8FAFC))) {
                        append("VEER")
                    }
                    withStyle(SpanStyle(color = TacticalPalette.Emerald)) {
                        append("SETU")
                    }
                },
                fontSize = 36.sp,
                fontWeight = FontWeight.Black,
                letterSpacing = 2.sp,
                textAlign = TextAlign.Center
            )

            Spacer(modifier = Modifier.height(4.dp))

            Text(
                text = "RAKSHAK SENSE • वीर सेतु सुरक्षा कवच",
                color = TacticalPalette.CyberTeal,
                fontSize = 13.5.sp,
                fontWeight = FontWeight.ExtraBold,
                letterSpacing = 1.1.sp,
                textAlign = TextAlign.Center
            )

            Spacer(modifier = Modifier.height(14.dp))

            // Animated ECG Heartbeat Waveform Strip
            Surface(
                shape = RoundedCornerShape(14.dp),
                color = Color(0xFF0D1B2E),
                border = BorderStroke(1.dp, Color(0xFF1E3A5F)),
                modifier = Modifier
                    .widthIn(max = 320.dp)
                    .fillMaxWidth()
            ) {
                Column(
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 10.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Canvas(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(32.dp)
                    ) {
                        val w = size.width
                        val h = size.height
                        val mid = h / 2f

                        val path = Path().apply {
                            moveTo(0f, mid)
                            lineTo(w * 0.22f, mid)
                            lineTo(w * 0.28f, mid - h * 0.22f)
                            lineTo(w * 0.33f, mid)
                            lineTo(w * 0.39f, mid + h * 0.18f)
                            lineTo(w * 0.45f, mid - h * 0.44f)
                            lineTo(w * 0.51f, mid + h * 0.36f)
                            lineTo(w * 0.57f, mid - h * 0.14f)
                            lineTo(w * 0.63f, mid)
                            lineTo(w, mid)
                        }
                        drawPath(
                            path = path,
                            brush = Brush.horizontalGradient(
                                colors = listOf(
                                    TacticalPalette.CyberTeal.copy(alpha = 0.4f),
                                    TacticalPalette.Emerald,
                                    TacticalPalette.Amber.copy(alpha = 0.8f)
                                )
                            ),
                            style = Stroke(
                                width = 3.dp.toPx(),
                                cap = StrokeCap.Round,
                                join = StrokeJoin.Round
                            )
                        )

                        // Scanning telemetry dot
                        val dotX = w * ecgPhase
                        drawCircle(
                            color = Color(0xFF34D399),
                            radius = 4.5.dp.toPx(),
                            center = Offset(dotX, mid)
                        )
                    }
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = "Edge-AI Biometric & Welfare Telemetry Engine",
                        color = Color(0xFF94A3B8),
                        fontSize = 11.sp,
                        fontWeight = FontWeight.SemiBold,
                        textAlign = TextAlign.Center
                    )
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Bilingual Mission Statement
            Text(
                text = "हर जवान के स्वास्थ्य, मनोबल और कल्याण का स्मार्ट साथी",
                color = Color(0xFFF1F5F9),
                fontSize = 14.sp,
                fontWeight = FontWeight.SemiBold,
                textAlign = TextAlign.Center,
                lineHeight = 20.sp
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = "Predictive Stress Monitoring & Zero-Stigma Welfare System for Uniformed Forces",
                color = Color(0xFFCBD5E1),
                fontSize = 12.5.sp,
                textAlign = TextAlign.Center,
                lineHeight = 18.sp
            )

            Spacer(modifier = Modifier.height(20.dp))

            // Architecture Readiness Badges
            Column(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(8.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                SplashFeaturePill(
                    icon = Icons.Default.VerifiedUser,
                    text = "Zero-Stigma Medical Firewall • Raw Vitals Restricted to Unit MO",
                    tint = TacticalPalette.Emerald
                )
                SplashFeaturePill(
                    icon = Icons.Default.Bolt,
                    text = "100% Offline-First Edge AI • Forward-Post SQLite Sync Ready",
                    tint = TacticalPalette.CyberTeal
                )
            }

            Spacer(modifier = Modifier.height(22.dp))

            // Progress bar + Immediate Enter CTA
            LinearProgressIndicator(
                modifier = Modifier
                    .widthIn(max = 240.dp)
                    .fillMaxWidth()
                    .height(4.dp)
                    .clip(RoundedCornerShape(4.dp)),
                color = TacticalPalette.Emerald,
                trackColor = Color(0xFF1E293B)
            )

            Spacer(modifier = Modifier.height(14.dp))

            Surface(
                shape = RoundedCornerShape(12.dp),
                color = TacticalPalette.Emerald.copy(alpha = 0.18f),
                border = BorderStroke(1.2.dp, TacticalPalette.Emerald),
                modifier = Modifier
                    .clip(RoundedCornerShape(12.dp))
                    .clickable { onFinished() }
            ) {
                Row(
                    modifier = Modifier.padding(horizontal = 18.dp, vertical = 10.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Launch Tactical Console",
                        color = Color(0xFFF8FAFC),
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Icon(
                        imageVector = Icons.Default.ArrowForward,
                        contentDescription = null,
                        tint = TacticalPalette.Emerald,
                        modifier = Modifier.size(16.dp)
                    )
                }
            }
        }
    }
}

@Composable
private fun SplashFeaturePill(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    text: String,
    tint: Color
) {
    Surface(
        shape = RoundedCornerShape(12.dp),
        color = Color(0xFF0F1E33),
        border = BorderStroke(1.dp, tint.copy(alpha = 0.35f)),
        modifier = Modifier.widthIn(max = 420.dp).fillMaxWidth()
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 14.dp, vertical = 9.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = tint,
                modifier = Modifier.size(17.dp)
            )
            Spacer(modifier = Modifier.width(10.dp))
            Text(
                text = text,
                color = Color(0xFFE2E8F0),
                fontSize = 11.5.sp,
                fontWeight = FontWeight.Medium,
                lineHeight = 16.sp
            )
        }
    }
}
