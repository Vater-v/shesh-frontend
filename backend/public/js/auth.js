document.addEventListener("DOMContentLoaded", () => {
  // --- Configuration ---
  const API_ENDPOINT = "/auth/register";

  // --- DOM Elements ---
  const authCard = document.getElementById("authCard");
  const toggleContainer = document.querySelector(".toggle-container");

  // Tabs
  const tabClassic = document.getElementById("tab-classic");
  const tabAnon = document.getElementById("tab-anon");

  // Field Groups
  const groupEmail = document.getElementById("group-email");
  const groupUsername = document.getElementById("group-username");

  // Inputs
  const inputEmail = document.getElementById("email");
  const inputUsername = document.getElementById("username");
  const inputPassword = document.getElementById("password");

  // UI Controls
  const form = document.getElementById("registerForm");
  const submitBtn = document.getElementById("submitBtn");
  const formFeedback = document.getElementById("form-feedback");
  const passwordToggle = document.getElementById("togglePassword");
  const eyeIcon = document.querySelector(".eye-icon");
  const eyeOffIcon = document.querySelector(".eye-off-icon");
  const strengthBar = document.querySelector(".strength-bar");

  // --- State ---
  let currentMode = "classic"; // 'classic' | 'anon'

  // --- 1. Spotlight Effect ---
  // Tracks mouse position relative to the card to update CSS variables
  document.addEventListener("mousemove", (e) => {
    if (!authCard) return;
    const rect = authCard.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;

    authCard.style.setProperty("--mouse-x", `${x}px`);
    authCard.style.setProperty("--mouse-y", `${y}px`);
  });

  // --- 2. Mode Switching Logic ---
  const setMode = (mode) => {
    currentMode = mode;

    if (mode === "classic") {
      // UI Update
      toggleContainer.setAttribute("data-mode", "classic");
      tabClassic.classList.add("active");
      tabClassic.setAttribute("aria-selected", "true");
      tabAnon.classList.remove("active");
      tabAnon.setAttribute("aria-selected", "false");

      // Toggle Fields
      groupEmail.classList.remove("hidden");
      groupUsername.classList.add("hidden");

      // Validation Rules
      inputEmail.required = true;
      inputUsername.required = false;

      // Cleanup
      inputUsername.value = "";
      inputUsername.classList.remove("valid", "invalid");
      setTimeout(() => inputEmail.focus(), 300);
    } else {
      // UI Update
      toggleContainer.setAttribute("data-mode", "anon");
      tabAnon.classList.add("active");
      tabAnon.setAttribute("aria-selected", "true");
      tabClassic.classList.remove("active");
      tabClassic.setAttribute("aria-selected", "false");

      // Toggle Fields
      groupEmail.classList.add("hidden");
      groupUsername.classList.remove("hidden");

      // Validation Rules
      inputEmail.required = false;
      inputEmail.value = "";
      inputEmail.classList.remove("valid", "invalid");
      inputUsername.required = true;
      setTimeout(() => inputUsername.focus(), 300);
    }

    hideFeedback();
  };

  tabClassic.addEventListener("click", () => setMode("classic"));
  tabAnon.addEventListener("click", () => setMode("anon"));

  // --- 3. Password Visibility ---
  passwordToggle.addEventListener("click", () => {
    const type =
      inputPassword.getAttribute("type") === "password" ? "text" : "password";
    inputPassword.setAttribute("type", type);

    if (type === "text") {
      eyeIcon.classList.add("hidden");
      eyeOffIcon.classList.remove("hidden");
    } else {
      eyeIcon.classList.remove("hidden");
      eyeOffIcon.classList.add("hidden");
    }
  });

  // --- 4. Real-time Validation & Strength ---
  const validateEmail = (email) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  const validateUsername = (user) => /^[a-zA-Z0-9_]{3,}$/.test(user);

  const updateInputState = (input, isValid) => {
    if (input.value.length === 0) {
      input.classList.remove("valid", "invalid");
      return;
    }
    if (isValid) {
      input.classList.add("valid");
      input.classList.remove("invalid");
    } else {
      input.classList.add("invalid");
      input.classList.remove("valid");
    }
  };

  // Input Listeners
  inputEmail.addEventListener("input", () => {
    if (currentMode === "classic")
      updateInputState(inputEmail, validateEmail(inputEmail.value));
  });

  inputUsername.addEventListener("input", () => {
    if (currentMode === "anon")
      updateInputState(inputUsername, validateUsername(inputUsername.value));
  });

  inputPassword.addEventListener("input", () => {
    const val = inputPassword.value;
    let score = 0;

    // Strength Logic
    if (val.length >= 8) score += 25;
    if (/[A-Z]/.test(val)) score += 25;
    if (/[0-9]/.test(val)) score += 25;
    if (/[^A-Za-z0-9]/.test(val)) score += 25;

    strengthBar.style.width = `${Math.min(score, 100)}%`;

    // Color Logic
    if (score <= 25) strengthBar.style.backgroundColor = "var(--accent-error)";
    else if (score <= 50) strengthBar.style.backgroundColor = "#ffd700"; // Gold
    else if (score <= 75)
      strengthBar.style.backgroundColor = "var(--accent-cyan)";
    else strengthBar.style.backgroundColor = "var(--accent-success)";

    updateInputState(inputPassword, val.length >= 8);
  });

  // --- 5. Form Submission ---
  const showFeedback = (msg, type) => {
    formFeedback.textContent = msg;
    formFeedback.className = `form-message ${type}`;
    formFeedback.classList.remove("hidden");
  };

  const hideFeedback = () => {
    formFeedback.classList.add("hidden");
  };

  const setLoading = (isLoading) => {
    if (isLoading) {
      submitBtn.classList.add("loading");
      submitBtn.disabled = true;
    } else {
      submitBtn.classList.remove("loading");
      submitBtn.disabled = false;
    }
  };

  form.addEventListener("submit", async (e) => {
    e.preventDefault();
    hideFeedback();

    // Client-Side Validation
    const password = inputPassword.value;
    if (password.length < 8) {
      showFeedback("Пароль должен быть не менее 8 символов", "error");
      return;
    }

    const payload = { password };

    if (currentMode === "classic") {
      const email = inputEmail.value.trim();
      if (!validateEmail(email)) {
        showFeedback("Введите корректный email адрес", "error");
        return;
      }
      payload.email = email;
      payload.login = null; // Explicit null for backend validation
    } else {
      const login = inputUsername.value.trim();
      if (!validateUsername(login)) {
        showFeedback(
          "Псевдоним должен содержать только буквы, цифры и _",
          "error"
        );
        return;
      }
      payload.login = login;
      payload.email = null; // Explicit null for backend validation
    }

    // API Request
    setLoading(true);

    try {
      const response = await fetch(API_ENDPOINT, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
        },
        body: JSON.stringify(payload),
      });

      const data = await response.json();

      if (!response.ok) {
        // Parse backend error messages
        let errorMsg = data.detail || "Ошибка регистрации";
        if (errorMsg.includes("already exists") || errorMsg.includes("taken")) {
          errorMsg = "Пользователь с такими данными уже существует.";
        }
        throw new Error(errorMsg);
      }

      // Success
      showFeedback("Успешная регистрация. Перенаправление...", "success");

      // Store tokens
      if (data.access_token) {
        localStorage.setItem("access_token", data.access_token);
        localStorage.setItem("refresh_token", data.refresh_token);
      }

      // Redirect to home/dashboard
      setTimeout(() => {
        window.location.href = "/";
      }, 1500);
    } catch (error) {
      showFeedback(error.message, "error");
      setLoading(false);
    }
  });
});
