//./ui/register/RegisterScreen.kt
package com.hmuriy.shesh.ui.register

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CutCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.*
import androidx.compose.material3.TabRowDefaults.tabIndicatorOffset
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.hmuriy.shesh.ui.theme.*

@Composable
fun RegisterScreen(
    onBackClick: () -> Unit,
    onRegisterSuccess: () -> Unit,
    viewModel: RegisterViewModel = viewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    // Анимация цвета: CyberCyan для Secure, SoftViolet для Stealth
    val accentColor by animateColorAsState(
        targetValue = if (viewModel.selectedTabIndex == 0) CyberCyan else SoftViolet,
        animationSpec = tween(500), label = "Accent"
    )

    LaunchedEffect(uiState) {
        if (uiState is RegisterUiState.Success) {
            onRegisterSuccess()
        }
    }

    Scaffold(
        containerColor = VoidDark,
        topBar = {
            Box(modifier = Modifier.fillMaxWidth().statusBarsPadding().padding(16.dp)) {
                IconButton(onClick = onBackClick) {
                    Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back", tint = TextGray)
                }
            }
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
        ) {
            // Header
            Column(modifier = Modifier.padding(horizontal = 24.dp)) {
                Text("UPLINK_PROTOCOL //", color = TextGray, style = MaterialTheme.typography.labelSmall)
                Text("New Identity", color = TextWhite, style = MaterialTheme.typography.displayMedium, fontWeight = FontWeight.Bold)
            }

            Spacer(modifier = Modifier.height(24.dp))

            // --- TABS ---
            TabRow(
                selectedTabIndex = viewModel.selectedTabIndex,
                containerColor = Color.Transparent,
                contentColor = accentColor,
                indicator = { tabPositions ->
                    TabRowDefaults.SecondaryIndicator(
                        Modifier.tabIndicatorOffset(tabPositions[viewModel.selectedTabIndex]),
                        color = accentColor,
                        height = 2.dp
                    )
                },
                divider = { HorizontalDivider(color = SurfaceLighter) }
            ) {
                Tab(
                    selected = viewModel.selectedTabIndex == 0,
                    onClick = { viewModel.switchTab(0) },
                    text = { Text("SECURE", fontWeight = FontWeight.Bold) },
                    selectedContentColor = CyberCyan,
                    unselectedContentColor = TextGray
                )
                Tab(
                    selected = viewModel.selectedTabIndex == 1,
                    onClick = { viewModel.switchTab(1) },
                    text = { Text("STEALTH", fontWeight = FontWeight.Bold) },
                    selectedContentColor = SoftViolet,
                    unselectedContentColor = TextGray
                )
            }

            Spacer(modifier = Modifier.height(32.dp))

            // --- FIELDS ---
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 24.dp)
                    .weight(1f)
            ) {
                // Email (Secure Only)
                if (viewModel.selectedTabIndex == 0) {
                    OutlinedTextField(
                        value = viewModel.email,
                        onValueChange = { viewModel.email = it },
                        label = { Text("EMAIL_RELAY") },
                        modifier = Modifier.fillMaxWidth(),
                        singleLine = true,
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email, imeAction = ImeAction.Next),
                        colors = registerInputColors(accentColor),
                        shape = CutCornerShape(topStart = 8.dp)
                    )
                    Spacer(modifier = Modifier.height(16.dp))
                }

                // Username
                OutlinedTextField(
                    value = viewModel.username,
                    onValueChange = { viewModel.username = it },
                    label = { Text("CODENAME / ALIAS") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true,
                    keyboardOptions = KeyboardOptions(imeAction = ImeAction.Next),
                    colors = registerInputColors(accentColor),
                    shape = if (viewModel.selectedTabIndex == 1) CutCornerShape(topStart = 8.dp) else CutCornerShape(0.dp)
                )

                Spacer(modifier = Modifier.height(16.dp))

                // Password
                OutlinedTextField(
                    value = viewModel.password,
                    onValueChange = { viewModel.password = it },
                    label = { Text("SECRET_KEY") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true,
                    visualTransformation = PasswordVisualTransformation(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password, imeAction = ImeAction.Done),
                    colors = registerInputColors(accentColor),
                    shape = CutCornerShape(bottomEnd = 16.dp)
                )

                // --- STEALTH WARNING ---
                if (viewModel.selectedTabIndex == 1) {
                    Spacer(modifier = Modifier.height(24.dp))
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.Warning, null, tint = WarningAmber, modifier = Modifier.size(16.dp))
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            text = "Внимание: Без привязки Email восстановление доступа невозможно. Не забудьте пароль.",
                            color = WarningAmber,
                            style = MaterialTheme.typography.bodySmall,
                            lineHeight = 14.sp
                        )
                    }
                }

                // Error
                if (uiState is RegisterUiState.Error) {
                    Spacer(modifier = Modifier.height(16.dp))
                    Text(
                        text = ">> ERROR: ${(uiState as RegisterUiState.Error).message}",
                        color = CriticalRed,
                        style = MaterialTheme.typography.labelMedium
                    )
                }
            }

            // Button
            Button(
                onClick = { viewModel.register() },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(24.dp)
                    .height(56.dp),
                shape = CutCornerShape(bottomEnd = 16.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = accentColor,
                    contentColor = if (viewModel.selectedTabIndex == 0) Color.Black else TextWhite
                )
            ) {
                if (uiState is RegisterUiState.Loading) {
                    CircularProgressIndicator(modifier = Modifier.size(24.dp), color = Color.White)
                } else {
                    Text(if (viewModel.selectedTabIndex == 0) "INITIALIZE LINK" else "GHOST MODE ACTIVATE")
                }
            }
        }
    }
}

@Composable
fun registerInputColors(accent: Color) = OutlinedTextFieldDefaults.colors(
    focusedBorderColor = accent,
    unfocusedBorderColor = SurfaceLighter,
    cursorColor = accent,
    focusedLabelColor = accent,
    unfocusedLabelColor = TextGray,
    focusedTextColor = TextWhite,
    focusedContainerColor = Color.Transparent,
    unfocusedContainerColor = Color.Transparent
)
