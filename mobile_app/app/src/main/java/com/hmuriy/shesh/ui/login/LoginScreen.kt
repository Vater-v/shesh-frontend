//./ui/login/LoginScreen.kt
package com.hmuriy.shesh.ui.login

import androidx.compose.animation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CutCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.AlternateEmail
import androidx.compose.material.icons.filled.Fingerprint
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.*
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.hmuriy.shesh.ui.theme.*

@Composable
fun LoginScreen(
    onBackClick: () -> Unit,
    onLoginSuccess: () -> Unit,
    viewModel: LoginViewModel = viewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val passwordFocusRequester = remember { FocusRequester() }

    LaunchedEffect(uiState) {
        if (uiState is LoginUiState.Success) {
            onLoginSuccess()
            viewModel.resetState()
        }
    }

    // Auto-focus: как только поле пароля становится видимым, запрашиваем фокус
    LaunchedEffect(viewModel.isIdentitySubmitted) {
        if (viewModel.isIdentitySubmitted) {
            passwordFocusRequester.requestFocus()
        }
    }

    Scaffold(
        containerColor = VoidDark,
        topBar = {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .statusBarsPadding()
                    .padding(16.dp)
            ) {
                IconButton(onClick = onBackClick) {
                    Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Abort", tint = TextGray)
                }
            }
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(horizontal = 24.dp),
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.Start
        ) {
            // --- HEADER ---
            Text(
                text = "GATEWAY_AUTH //",
                color = CyberCyan,
                style = MaterialTheme.typography.labelSmall,
                letterSpacing = 2.sp
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = "Identity",
                color = TextWhite,
                style = MaterialTheme.typography.displayMedium,
                fontWeight = FontWeight.Bold
            )

            Spacer(modifier = Modifier.height(48.dp))

            // --- SMART IDENTITY INPUT ---
            val labelText = if (viewModel.identityInput.isEmpty()) "USERNAME / EMAIL"
            else if (viewModel.isEmailDetected) "IDENTITY :: EMAIL"
            else "IDENTITY :: USERNAME"

            OutlinedTextField(
                value = viewModel.identityInput,
                onValueChange = { viewModel.updateIdentity(it) },
                label = { Text(labelText) },
                modifier = Modifier.fillMaxWidth(),
                singleLine = true,
                textStyle = MaterialTheme.typography.bodyLarge.copy(color = CyberCyan),
                keyboardOptions = KeyboardOptions(imeAction = ImeAction.Next),
                keyboardActions = KeyboardActions(onNext = { viewModel.submitIdentity() }),
                trailingIcon = {
                    val icon = if (viewModel.isEmailDetected) Icons.Default.AlternateEmail else Icons.Default.Fingerprint
                    Icon(icon, contentDescription = null, tint = if(viewModel.identityInput.isNotEmpty()) CyberCyan else TextGray)
                },
                colors = terminalInputColors(),
                shape = CutCornerShape(topStart = 0.dp, bottomEnd = 16.dp)
            )

            // --- ANIMATED PASSWORD FIELD ---
            AnimatedVisibility(
                visible = viewModel.isIdentitySubmitted,
                enter = expandVertically() + fadeIn(),
                exit = shrinkVertically() + fadeOut()
            ) {
                Column {
                    Spacer(modifier = Modifier.height(16.dp))
                    OutlinedTextField(
                        value = viewModel.password,
                        onValueChange = { viewModel.updatePassword(it) },
                        label = { Text("PASSPHRASE") },
                        modifier = Modifier
                            .fillMaxWidth()
                            .focusRequester(passwordFocusRequester),
                        singleLine = true,
                        visualTransformation = PasswordVisualTransformation(),
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password, imeAction = ImeAction.Done),
                        keyboardActions = KeyboardActions(onDone = { viewModel.login() }),
                        trailingIcon = {
                            Icon(Icons.Default.Lock, contentDescription = null, tint = TextGray)
                        },
                        colors = terminalInputColors(),
                        shape = CutCornerShape(bottomEnd = 16.dp)
                    )
                }
            }

            // --- STATUS / ERROR ---
            Spacer(modifier = Modifier.height(24.dp))
            Box(modifier = Modifier.height(24.dp)) {
                if (uiState is LoginUiState.Error) {
                    Text(
                        text = ">> ERR: ${(uiState as LoginUiState.Error).message}",
                        color = CriticalRed,
                        style = MaterialTheme.typography.labelMedium
                    )
                }
            }

            // --- ACTION BUTTON ---
            Spacer(modifier = Modifier.height(24.dp))
            AnimatedVisibility(visible = viewModel.isIdentitySubmitted) {
                Button(
                    onClick = { viewModel.login() },
                    modifier = Modifier.fillMaxWidth().height(56.dp),
                    shape = CutCornerShape(bottomEnd = 16.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = CyberCyan,
                        contentColor = VoidDark,
                        disabledContainerColor = SurfaceLighter
                    ),
                    enabled = uiState !is LoginUiState.Loading
                ) {
                    if (uiState is LoginUiState.Loading) {
                        CircularProgressIndicator(modifier = Modifier.size(24.dp), color = VoidDark)
                    } else {
                        Text("ESTABLISH CONNECTION", fontWeight = FontWeight.Bold)
                    }
                }
            }
        }
    }
}

@Composable
fun terminalInputColors() = OutlinedTextFieldDefaults.colors(
    focusedBorderColor = CyberCyan,
    unfocusedBorderColor = TextGray.copy(alpha = 0.5f),
    cursorColor = CyberCyan,
    focusedLabelColor = CyberCyan,
    unfocusedLabelColor = TextGray,
    focusedTextColor = CyberCyan,
    unfocusedTextColor = TextWhite,
    focusedContainerColor = Color.Transparent,
    unfocusedContainerColor = Color.Transparent
)
