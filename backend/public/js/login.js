/**
 * SHESH SYSTEM - Login Module
 * Handles authentication, UI interactions, and token management.
 */

// Проверка авторизации: если токен есть, уходим на главную
if (localStorage.getItem("access_token")) {
  window.location.href = "/";
}

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
  document.addEventListener("mousemove", (e) => {
    if (!authCard) return;
    requestAnimationFrame(() => {
      const rect = authCard.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const y = e.clientY - rect.top;
      authCard.style.setProperty("--mouse-x", `${x}px`);
      authCard.style.setProperty("--mouse-y", `${y}px`);
    });
  });

  // --- 2. Password Visibility Toggle ---
  if (passwordToggle) {
    passwordToggle.addEventListener("click", () => {
      const isPass = inputPassword.type === "password";
      inputPassword.type = isPass ? "text" : "password";

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
    formFeedback.className = `form-message ${type}`;
    formFeedback.classList.remove("hidden");

    if (type === "error") {
      authCard.classList.remove("shake");
      void authCard.offsetWidth;
      authCard.classList.add("shake");

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

    if (!credential || !password) {
      showFeedback("Пожалуйста, заполните все поля", "error");
      return;
    }

    toggleLoadingState(true);

    try {
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
        let msg = "Ошибка авторизации";
        if (response.status === 401 || response.status === 404) {
          msg = "Неверные учетные данные";
        } else if (data.detail) {
          msg = Array.isArray(data.detail) ? data.detail[0].msg : data.detail;
        }
        throw new Error(msg);
      }

      showFeedback("Вход выполнен успешно. Перенаправление...", "success");

      if (data.access_token) {
        localStorage.setItem("access_token", data.access_token);
        localStorage.setItem("refresh_token", data.refresh_token);
      }

      setTimeout(() => {
        window.location.href = DASHBOARD_URL;
      }, 800);
    } catch (err) {
      showFeedback(err.message, "error");
      inputPassword.value = "";
      if (inputPassword.value === "") inputPassword.focus();
    } finally {
      toggleLoadingState(false);
    }
  });

  [inputCredential, inputPassword].forEach((input) => {
    input.addEventListener("focus", () => input.classList.remove("invalid"));
  });
});
