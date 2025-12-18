/**
 * SHESH SYSTEM - Login Module
 * Handles authentication, UI interactions, and token management.
 */
document.addEventListener("DOMContentLoaded", () => {
  // --- Configuration ---
  const API_ENDPOINT = "/auth/login";
  const DASHBOARD_URL = "/";

  // --- UI Elements ---
  const authCard = document.getElementById("authCard");
  const form = document.getElementById("loginForm");
  const inputCredential = document.getElementById("credential");
  const inputPassword = document.getElementById("password");
  const submitBtn = document.getElementById("submitBtn");
  const formFeedback = document.getElementById("form-feedback");
  const passwordToggle = document.getElementById("togglePassword");

  // --- 1. Spotlight Effect (Mouse Tracking) ---
  // Replicates the 'Deep Void' interactive border effect
  document.addEventListener("mousemove", (e) => {
    if (!authCard) return;
    requestAnimationFrame(() => {
      const rect = authCard.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const y = e.clientY - rect.top;
      // Updates CSS variables used by .spotlight-border in auth.css
      authCard.style.setProperty("--mouse-x", `${x}px`);
      authCard.style.setProperty("--mouse-y", `${y}px`);
    });
  });

  // --- 2. Password Visibility Toggle ---
  if (passwordToggle) {
    passwordToggle.addEventListener("click", () => {
      const isPass = inputPassword.type === "password";
      inputPassword.type = isPass ? "text" : "password";

      // Toggle Icons
      passwordToggle
        .querySelector(".eye-icon")
        .classList.toggle("hidden", isPass);
      passwordToggle
        .querySelector(".eye-off-icon")
        .classList.toggle("hidden", !isPass);
    });
  }

  // --- 3. UI Helper Functions ---
  const showFeedback = (msg, type) => {
    formFeedback.textContent = msg;
    formFeedback.className = `form-message ${type}`; // 'error' or 'success'
    formFeedback.classList.remove("hidden");

    if (type === "error") {
      // Trigger Shake Animation:
      // Remove class -> Force Reflow -> Add class (restarts animation)
      authCard.classList.remove("shake");
      void authCard.offsetWidth;
      authCard.classList.add("shake");

      // Highlight inputs
      inputCredential.classList.add("invalid");
      inputPassword.classList.add("invalid");
    }
  };

  const hideFeedback = () => {
    formFeedback.classList.add("hidden");
    inputCredential.classList.remove("invalid");
    inputPassword.classList.remove("invalid");
  };

  const toggleLoadingState = (isLoading) => {
    if (isLoading) {
      submitBtn.classList.add("loading");
      submitBtn.disabled = true;
      inputCredential.disabled = true;
      inputPassword.disabled = true;
    } else {
      submitBtn.classList.remove("loading");
      submitBtn.disabled = false;
      inputCredential.disabled = false;
      inputPassword.disabled = false;
    }
  };

  // --- 4. Authentication Logic ---
  form.addEventListener("submit", async (e) => {
    e.preventDefault();
    hideFeedback();

    const credential = inputCredential.value.trim();
    const password = inputPassword.value;

    // Basic Client-Side Validation
    if (!credential || !password) {
      showFeedback("Пожалуйста, заполните все поля", "error");
      return;
    }

    toggleLoadingState(true);

    try {
      // Maps to UserLogin schema
      const payload = {
        credential: credential,
        password: password,
      };

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
        // Handle FastAPI/Pydantic errors
        let msg = "Ошибка авторизации";

        // 401/404 are standard generic credentials errors
        if (response.status === 401 || response.status === 404) {
          msg = "Неверные учетные данные";
        } else if (data.detail) {
          // Extract message if it's a Pydantic array or a simple string
          msg = Array.isArray(data.detail) ? data.detail[0].msg : data.detail;
        }

        throw new Error(msg);
      }

      // --- Success ---
      showFeedback("Вход выполнен успешно. Перенаправление...", "success");

      // Persist Tokens
      if (data.access_token) {
        localStorage.setItem("access_token", data.access_token);
        localStorage.setItem("refresh_token", data.refresh_token);
      }

      // Redirect
      setTimeout(() => {
        window.location.href = DASHBOARD_URL;
      }, 800);
    } catch (err) {
      showFeedback(err.message, "error");
      // Security: Clear password on failure
      inputPassword.value = "";
      if (inputPassword.value === "") inputPassword.focus();
    } finally {
      toggleLoadingState(false);
    }
  });

  // Clear invalid state on focus
  [inputCredential, inputPassword].forEach((input) => {
    input.addEventListener("focus", () => input.classList.remove("invalid"));
  });
});
