package `in`.gov.mha.crpf.rakshaksense.ui

import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import `in`.gov.mha.crpf.rakshaksense.model.RiskTier

object TacticalPalette {
    val DeepNavy = Color(0xFF0B1120)
    val SlateCard = Color(0xFF1E293B)
    val SlateElevated = Color(0xFF0F172A)
    val CardBorder = Color(0xFF334155)

    val SunBg = Color(0xFFF1F5F9)
    val SunCard = Color(0xFFFFFFFF)
    val SunElevated = Color(0xFFE2E8F0)
    val SunBorder = Color(0xFFCBD5E1)

    val Emerald = Color(0xFF10B981)
    val CyberTeal = Color(0xFF14B8A6)
    val Amber = Color(0xFFF59E0B)
    val Red = Color(0xFFEF4444)

    fun bgPrimary(sunlight: Boolean) = if (sunlight) SunBg else DeepNavy
    fun bgCard(sunlight: Boolean) = if (sunlight) SunCard else SlateCard
    fun bgElevated(sunlight: Boolean) = if (sunlight) SunElevated else SlateElevated
    fun border(sunlight: Boolean) = if (sunlight) SunBorder else CardBorder

    // High-contrast WCAG AA/AAA text colors
    fun textPrimary(sunlight: Boolean) = if (sunlight) Color(0xFF0F172A) else Color(0xFFF8FAFC)
    fun textSecondary(sunlight: Boolean) = if (sunlight) Color(0xFF1E293B) else Color(0xFFE2E8F0)
    fun textMuted(sunlight: Boolean) = if (sunlight) Color(0xFF475569) else Color(0xFFCBD5E1)

    fun tierColor(tier: RiskTier): Color = when (tier) {
        RiskTier.OPTIMAL -> Emerald
        RiskTier.MODERATE -> Amber
        RiskTier.CRITICAL -> Red
    }

    fun tierHeadline(tier: RiskTier, hindi: Boolean): String = when (tier) {
        RiskTier.OPTIMAL -> if (hindi) "उत्तम तत्परता (Optimal)" else "OPTIMAL READINESS"
        RiskTier.MODERATE -> if (hindi) "मध्यम थकान (Moderate)" else "MODERATE FATIGUE"
        RiskTier.CRITICAL -> if (hindi) "उच्च तनाव चेतावनी (Alert)" else "ELEVATED STRESS ALERT"
    }
}

@Composable
fun TacticalBentoCard(
    sunlight: Boolean,
    modifier: Modifier = Modifier,
    accentLeftColor: Color? = null,
    borderColor: Color? = null,
    padding: Dp = 16.dp,
    content: @Composable ColumnScope.() -> Unit
) {
    val resolvedBorder = borderColor ?: TacticalPalette.border(sunlight)
    val bg = TacticalPalette.bgCard(sunlight)
    Surface(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        color = bg,
        border = BorderStroke(1.2.dp, resolvedBorder),
        shadowElevation = if (sunlight) 2.dp else 4.dp
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .then(
                    if (accentLeftColor != null) {
                        Modifier.drawBehind {
                            drawRect(
                                color = accentLeftColor,
                                topLeft = Offset.Zero,
                                size = Size(5.dp.toPx(), size.height)
                            )
                        }
                    } else {
                        Modifier
                    }
                )
                .padding(padding),
            content = content
        )
    }
}

@Composable
fun StatusPillBadge(
    label: String,
    color: Color,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .clip(RoundedCornerShape(999.dp))
            .background(color.copy(alpha = 0.18f))
            .border(1.dp, color.copy(alpha = 0.65f), RoundedCornerShape(999.dp))
            .padding(horizontal = 10.dp, vertical = 5.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(7.dp)
                .clip(CircleShape)
                .background(color)
        )
        Spacer(modifier = Modifier.width(6.dp))
        Text(
            text = label,
            color = color,
            fontSize = 11.5.sp,
            fontWeight = FontWeight.Bold
        )
    }
}

@Composable
fun DoubleRingFrsiGauge(
    score: Int,
    tier: RiskTier,
    sunlight: Boolean,
    size: Dp = 172.dp
) {
    val animatedProgress by animateFloatAsState(
        targetValue = (score.coerceIn(0, 100)) / 100f,
        animationSpec = tween(durationMillis = 650, easing = FastOutSlowInEasing),
        label = "frsiProgress"
    )
    val accent = TacticalPalette.tierColor(tier)
    val trackColor = TacticalPalette.border(sunlight).copy(alpha = 0.7f)

    Box(
        modifier = Modifier.size(size),
        contentAlignment = Alignment.Center
    ) {
        Canvas(modifier = Modifier.size(size)) {
            val strokeWidth = 13.dp.toPx()
            val outerRingStroke = 2.dp.toPx()
            drawCircle(
                color = accent.copy(alpha = 0.30f),
                radius = (this.size.minDimension / 2f) - outerRingStroke,
                style = Stroke(width = outerRingStroke)
            )
            drawCircle(
                color = accent.copy(alpha = 0.08f),
                radius = (this.size.minDimension / 2f) - 8.dp.toPx()
            )
            val arcInset = 15.dp.toPx()
            val arcSize = Size(
                width = this.size.width - arcInset * 2,
                height = this.size.height - arcInset * 2
            )
            drawArc(
                color = trackColor,
                startAngle = 135f,
                sweepAngle = 270f,
                useCenter = false,
                topLeft = Offset(arcInset, arcInset),
                size = arcSize,
                style = Stroke(width = strokeWidth, cap = StrokeCap.Round)
            )
            drawArc(
                color = accent,
                startAngle = 135f,
                sweepAngle = 270f * animatedProgress,
                useCenter = false,
                topLeft = Offset(arcInset, arcInset),
                size = arcSize,
                style = Stroke(width = strokeWidth, cap = StrokeCap.Round)
            )
        }
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                text = "FRSI SCORE",
                color = TacticalPalette.textMuted(sunlight),
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 0.8.sp
            )
            Spacer(modifier = Modifier.height(2.dp))
            Row(verticalAlignment = Alignment.Bottom) {
                Text(
                    text = "$score",
                    color = TacticalPalette.textPrimary(sunlight),
                    fontSize = 36.sp,
                    fontWeight = FontWeight.ExtraBold
                )
                Text(
                    text = "/100",
                    color = TacticalPalette.textSecondary(sunlight),
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding(bottom = 5.dp, start = 2.dp)
                )
            }
            Spacer(modifier = Modifier.height(4.dp))
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(999.dp))
                    .background(accent.copy(alpha = 0.20f))
                    .padding(horizontal = 10.dp, vertical = 3.dp)
            ) {
                Text(
                    text = when (tier) {
                        RiskTier.OPTIMAL -> "OPTIMAL"
                        RiskTier.MODERATE -> "MODERATE"
                        RiskTier.CRITICAL -> "ALERT"
                    },
                    color = accent,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.ExtraBold
                )
            }
        }
    }
}
