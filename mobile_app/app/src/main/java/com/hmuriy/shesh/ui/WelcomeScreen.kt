package com.hmuriy.shesh.ui

import androidx.compose.animation.core.*
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.gestures.waitForUpOrCancellation
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CutCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.draw.scale
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.*
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.hmuriy.shesh.ui.theme.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlin.math.pow
import kotlin.random.Random

// --- Constants ---
private const val BUTTON_FILL_DURATION = 1500f // Time to arm in ms
private const val NOISE_DENSITY = 2000 // Number of noise points
private const val LOGO_TEXT = "shesh"

// --- Boot Stages ---
private enum class BootPhase {
    KERNEL_LOG,
    TYPEWRITER,
    INTERACTIVE, // Glitch effect active, button visible
    ACCESS_GRANTED
}

@Composable
fun WelcomeScreen() {
    // --- State Management ---
    var bootPhase by remember { mutableStateOf(BootPhase.KERNEL_LOG) }

    // Global Transition Animations (Access Granted)
    val screenScale = remember { Animatable(1f) }
    val screenAlpha = remember { Animatable(1f) }

    val haptic = LocalHapticFeedback.current

    // Logic: Success Transition
    LaunchedEffect(bootPhase) {
        if (bootPhase == BootPhase.ACCESS_GRANTED) {
            haptic.performHapticFeedback(HapticFeedbackType.LongPress)
            // Dive into the Void
            launch { screenScale.animateTo(3f, tween(1500, easing = ExpoInEasing)) }
            launch { screenAlpha.animateTo(0f, tween(1000, easing = LinearEasing)) }
        }
    }

    // --- The Void Mainframe (Root) ---
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(VoidDark)
            // Apply Global Transition
            .graphicsLayer {
                scaleX = screenScale.value
                scaleY = screenScale.value
                alpha = screenAlpha.value
            }
            // Layer 3: Lens Distortion (Scanlines & Vignette) applied to the whole screen
            .lensOverlay()
    ) {
        // --- Layer 1: Substrate (Atmosphere & Noise) ---
        AtmosphereGlow()
        SystemNoise()

        // --- Layer 2: Horizon Grid (Bottom 40%) ---
        BoxWithConstraints(
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight(0.4f)
                .align(Alignment.BottomCenter)
        ) {
            RetroHorizonGrid(
                width = maxWidth.value,
                height = maxHeight.value,
                isAccelerating = bootPhase == BootPhase.ACCESS_GRANTED
            )
        }

        // --- UI Layer: Tactical Constructs ---
        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            // Optical centering
            Spacer(modifier = Modifier.weight(1f))

            // The Identity
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier.height(100.dp)
            ) {
                if (bootPhase == BootPhase.KERNEL_LOG) {
                    KernelLogSequence { bootPhase = BootPhase.TYPEWRITER }
                } else {
                    IdentityConstruct(
                        startTyping = bootPhase == BootPhase.TYPEWRITER,
                        onTypingFinished = { bootPhase = BootPhase.INTERACTIVE },
                        isAccessGranted = bootPhase == BootPhase.ACCESS_GRANTED
                    )
                }
            }

            Spacer(modifier = Modifier.height(64.dp))

            // The Arming Mechanism
            Box(modifier = Modifier.height(60.dp)) {
                if (bootPhase == BootPhase.INTERACTIVE || bootPhase == BootPhase.ACCESS_GRANTED) {
                    ArmingButton(
                        isSuccess = bootPhase == BootPhase.ACCESS_GRANTED,
                        onSuccess = { bootPhase = BootPhase.ACCESS_GRANTED }
                    )
                }
            }

            Spacer(modifier = Modifier.weight(1.2f))
        }

        // --- Status Anchors (HUD) ---
        if (bootPhase != BootPhase.KERNEL_LOG) {
            StatusHUD()
        }
    }
}

// -----------------------------------------------------------------------------
// VISUAL COMPONENTS: "The Void"
// -----------------------------------------------------------------------------

@Composable
private fun SystemNoise() {
    // Optimization: Pre-generate 4 frames of noise to cycle through.
    // Generating random points every frame in onDraw is too expensive.
    val noiseFrames = remember {
        List(4) {
            List(NOISE_DENSITY) { Offset(Random.nextFloat(), Random.nextFloat()) }
        }
    }
    var currentFrame by remember { mutableIntStateOf(0) }

    // Animate frames @ ~15fps for "Live Signal" look
    LaunchedEffect(Unit) {
        while (isActive) {
            delay(60)
            currentFrame = (currentFrame + 1) % noiseFrames.size
        }
    }

    Canvas(modifier = Modifier.fillMaxSize()) {
        val w = size.width
        val h = size.height
        val points = noiseFrames[currentFrame]

        // Map normalized points to canvas size
        val mappedPoints = points.map { Offset(it.x * w, it.y * h) }

        drawPoints(
            points = mappedPoints,
            pointMode = PointMode.Points,
            color = Color.White.copy(alpha = 0.03f), // 3% opacity
            strokeWidth = 2f
        )
    }
}

@Composable
private fun AtmosphereGlow() {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        Box(
            modifier = Modifier
                .size(350.dp)
                .background(
                    brush = Brush.radialGradient(
                        colors = listOf(DeepViolet.copy(alpha = 0.3f), Color.Transparent)
                    )
                )
                .blur(100.dp)
        )
    }
}

@Composable
private fun RetroHorizonGrid(width: Float, height: Float, isAccelerating: Boolean) {
    val infiniteTransition = rememberInfiniteTransition(label = "Grid")
    // Animate phase shift for forward movement
    val scrollPhase by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            // Speed up significantly on access granted
            animation = tween(if (isAccelerating) 300 else 3000, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "GridPhase"
    )

    Canvas(modifier = Modifier.fillMaxSize()) {
        val horizonY = 0f // Top of this container is the horizon
        val vanishingPoint = Offset(size.width / 2, horizonY)

        val fadeBrush = Brush.verticalGradient(
            0f to Color.Transparent,
            0.2f to CyberCyan.copy(alpha = 0.15f),
            1f to CyberCyan.copy(alpha = 0.15f),
            startY = 0f,
            endY = size.height
        )

        // 1. Vertical Lines (Converging Perspective)
        val verticalCount = 12
        val baseSpacing = size.width / 4 // Spread at bottom

        for (i in -verticalCount..verticalCount) {
            val bottomX = (size.width / 2) + (i * baseSpacing)
            drawLine(
                brush = fadeBrush,
                start = vanishingPoint,
                end = Offset(bottomX, size.height),
                strokeWidth = 1f
            )
        }

        // 2. Horizontal Lines (Movement)
        // Math: y = t^2 (Quadratic) makes lines denser near 0 (horizon)
        val horizontalCount = 12
        for (i in 0 until horizontalCount) {
            val t = ((i + scrollPhase) % horizontalCount) / horizontalCount.toFloat()
            val y = t.pow(2) * size.height

            if (y > 1f) { // Don't draw exactly at 0 to avoid flicker
                val alpha = t.coerceIn(0f, 1f) * 0.15f // Fade out near horizon
                drawLine(
                    color = CyberCyan.copy(alpha = alpha),
                    start = Offset(0f, y),
                    end = Offset(size.width, y),
                    strokeWidth = 1f
                )
            }
        }
    }
}

private fun Modifier.lensOverlay() = this.drawWithContent {
    drawContent()

    // 1. Scanlines
    val lineSpacing = 4.dp.toPx()
    val count = (size.height / lineSpacing).toInt()
    for (i in 0..count) {
        val y = i * lineSpacing
        drawLine(
            color = Color.Black.copy(alpha = 0.05f),
            start = Offset(0f, y),
            end = Offset(size.width, y),
            strokeWidth = 1f
        )
    }

    // 2. Vignette
    drawRect(
        brush = Brush.radialGradient(
            colors = listOf(Color.Transparent, VoidDark),
            center = center,
            radius = size.minDimension / 0.8f
        ),
        blendMode = BlendMode.SrcOver
    )
}

// -----------------------------------------------------------------------------
// UI COMPONENTS: "Tactical Constructs"
// -----------------------------------------------------------------------------

@Composable
private fun IdentityConstruct(
    startTyping: Boolean,
    onTypingFinished: () -> Unit,
    isAccessGranted: Boolean
) {
    val haptic = LocalHapticFeedback.current
    var displayedText by remember { mutableStateOf("") }
    val fullText = if (isAccessGranted) "ACCESS GRANTED" else LOGO_TEXT

    // Typewriter Logic
    LaunchedEffect(startTyping, isAccessGranted) {
        if (isAccessGranted) {
            displayedText = fullText
            return@LaunchedEffect
        }

        if (startTyping) {
            fullText.forEachIndexed { index, _ ->
                displayedText = fullText.take(index + 1)
                haptic.performHapticFeedback(HapticFeedbackType.TextHandleMove)
                delay(150)
            }
            onTypingFinished()
        }
    }

    // Glitch Animation Logic
    val redOffset = remember { Animatable(0f) }
    val cyanOffset = remember { Animatable(0f) }

    if (!isAccessGranted && !startTyping) {
        LaunchedEffect(Unit) {
            while (isActive) {
                delay(Random.nextLong(3000, 5000))
                // Glitch Shake
                repeat(5) {
                    val magnitude = 4f
                    redOffset.snapTo(Random.nextFloat() * magnitude - magnitude/2)
                    cyanOffset.snapTo(Random.nextFloat() * magnitude - magnitude/2)
                    delay(30)
                }
                redOffset.snapTo(0f)
                cyanOffset.snapTo(0f)
            }
        }
    }

    // Cursor Blink
    val infiniteTransition = rememberInfiniteTransition(label = "Cursor")
    val cursorAlpha by infiniteTransition.animateFloat(
        initialValue = 1f,
        targetValue = 0f,
        animationSpec = infiniteRepeatable(tween(500), RepeatMode.Reverse),
        label = "CursorAlpha"
    )

    Box(contentAlignment = Alignment.Center) {
        val font = FontFamily.Monospace
        val fontSize = if (isAccessGranted) 32.sp else 56.sp
        val fontWeight = FontWeight.Bold

        if (!isAccessGranted) {
            // RGB Split Layers
            Text(
                text = displayedText,
                color = CriticalRed.copy(alpha = 0.8f),
                fontFamily = font, fontSize = fontSize, fontWeight = fontWeight,
                modifier = Modifier
                    .offset { IntOffset(x = (-2.dp.toPx() + redOffset.value.dp.toPx()).toInt(), y = 0) }
                    .graphicsLayer { compositingStrategy = CompositingStrategy.ModulateAlpha }
            )
            Text(
                text = displayedText,
                color = CyberCyan.copy(alpha = 0.8f),
                fontFamily = font, fontSize = fontSize, fontWeight = fontWeight,
                modifier = Modifier
                    .offset { IntOffset(x = (2.dp.toPx() + cyanOffset.value.dp.toPx()).toInt(), y = 0) }
                    .graphicsLayer { compositingStrategy = CompositingStrategy.ModulateAlpha }
            )
        }

        // Main Text Layer
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(
                text = displayedText,
                color = if (isAccessGranted) TerminalGreen else TextWhite,
                fontFamily = font, fontSize = fontSize, fontWeight = fontWeight,
                letterSpacing = if (isAccessGranted) 4.sp else 0.sp
            )
            // Cursor
            if (!isAccessGranted) {
                Text(
                    text = "█",
                    color = CyberCyan.copy(alpha = cursorAlpha),
                    fontFamily = font, fontSize = fontSize, fontWeight = fontWeight,
                    modifier = Modifier.padding(start = 4.dp)
                )
            }
        }
    }
}

@Composable
private fun ArmingButton(
    isSuccess: Boolean,
    onSuccess: () -> Unit
) {
    val haptic = LocalHapticFeedback.current
    var isHolding by remember { mutableStateOf(false) }
    val progress = remember { Animatable(0f) }

    // Phase 4: Pulse Animation
    val infiniteTransition = rememberInfiniteTransition(label = "Pulse")
    val borderAlpha by infiniteTransition.animateFloat(
        initialValue = 0.5f, targetValue = 1f,
        animationSpec = infiniteRepeatable(tween(1500), RepeatMode.Reverse),
        label = "BorderAlpha"
    )

    // Hold & Fill Logic
    LaunchedEffect(isHolding, isSuccess) {
        if (isSuccess) return@LaunchedEffect

        if (isHolding) {
            val startTime = System.nanoTime()
            var hapticInterval = 100L // Start slow
            var lastHapticTime = 0L

            while (isActive && progress.value < 1f) {
                val now = System.nanoTime()
                val elapsed = (now - startTime) / 1_000_000f // ms

                // Update Progress
                progress.snapTo((elapsed / BUTTON_FILL_DURATION).coerceAtMost(1f))

                // Rising Haptic Vibration
                if ((now - lastHapticTime) / 1_000_000L > hapticInterval) {
                    haptic.performHapticFeedback(HapticFeedbackType.TextHandleMove)
                    lastHapticTime = now
                    // Accelerate ticks
                    hapticInterval = (hapticInterval * 0.9f).toLong().coerceAtLeast(20)
                }

                delay(16) // Frame tick
            }

            if (progress.value >= 1f) {
                onSuccess()
            }
        } else {
            // Rapid Drain on Release
            progress.animateTo(0f, tween(300, easing = FastOutSlowInEasing))
        }
    }

    val shape = CutCornerShape(topStart = 12.dp, bottomEnd = 12.dp)
    val borderColor = if (isSuccess) TerminalGreen else CyberCyanDark.copy(alpha = borderAlpha)

    Box(
        modifier = Modifier
            .size(width = 260.dp, height = 56.dp)
            .pointerInput(isSuccess) {
                if (isSuccess) return@pointerInput
                // Precise gesture handling for Hold mechanics
                awaitEachGesture {
                    awaitFirstDown()
                    isHolding = true
                    waitForUpOrCancellation()
                    isHolding = false
                }
            }
            .border(BorderStroke(1.dp, borderColor), shape)
            .background(Color.Transparent, shape)
            .drawWithContent {
                drawContent()
                // Decor: Tiny squares at corners
                val decorSize = 2.dp.toPx()
                val decorColor = if (isSuccess) VoidDark else CyberCyan
                val pts = listOf(
                    Offset(0f, 0f), Offset(size.width - decorSize, 0f),
                    Offset(0f, size.height - decorSize), Offset(size.width - decorSize, size.height - decorSize)
                )
                drawPoints(pts, PointMode.Points, decorColor, strokeWidth = decorSize * 2)
            }
    ) {
        // Progress Fill
        Box(
            modifier = Modifier
                .fillMaxSize()
                .graphicsLayer {
                    this.shape = shape
                    this.clip = true
                }
        ) {
            Box(
                modifier = Modifier
                    .fillMaxHeight()
                    .fillMaxWidth(if (isSuccess) 1f else progress.value)
                    .background(if (isSuccess) TerminalGreen else CyberCyan)
            )
        }

        // Label
        Text(
            text = if (isSuccess) "INITIALIZED" else "HOLD TO INITIALIZE",
            color = if (isSuccess || progress.value > 0.5f) VoidDark else CyberCyan,
            fontFamily = FontFamily.Monospace,
            fontSize = 14.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.align(Alignment.Center)
        )
    }
}

@Composable
private fun KernelLogSequence(onFinished: () -> Unit) {
    val logs = listOf(
        "> Mounting assets...",
        "> Bypassing proxies...",
        "> Allocating memory blocks...",
        "> Optimizing signals...",
        "> Uplink established."
    )
    var currentLogIndex by remember { mutableIntStateOf(0) }

    LaunchedEffect(Unit) {
        for (i in logs.indices) {
            currentLogIndex = i
            delay(120) // Fast scroll
        }
        delay(400)
        onFinished()
    }

    Box(modifier = Modifier.fillMaxSize().padding(32.dp), contentAlignment = Alignment.BottomStart) {
        Column {
            logs.take(currentLogIndex + 1).takeLast(4).forEach { log ->
                Text(
                    text = log,
                    color = TextGray,
                    fontFamily = FontFamily.Monospace,
                    fontSize = 12.sp,
                    lineHeight = 16.sp
                )
            }
        }
    }
}

@Composable
private fun StatusHUD() {
    Box(modifier = Modifier.fillMaxSize().padding(16.dp)) {
        Text(
            text = "NET: SECURE // v1.0.4",
            color = TerminalGreen.copy(alpha = 0.6f),
            fontFamily = FontFamily.Monospace,
            fontSize = 10.sp,
            modifier = Modifier.align(Alignment.BottomStart)
        )
        Text(
            text = "LATENCY: 3ms",
            color = TerminalGreen.copy(alpha = 0.6f),
            fontFamily = FontFamily.Monospace,
            fontSize = 10.sp,
            modifier = Modifier.align(Alignment.BottomEnd)
        )
    }
}
