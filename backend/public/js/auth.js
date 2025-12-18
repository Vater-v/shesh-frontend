document.addEventListener("DOMContentLoaded", () => {
  // --- Config ---
  const API_ENDPOINT = "/auth/register";

  // --- Elements ---
  const authCard = document.getElementById("authCard");
  const toggleContainer = document.querySelector(".toggle-container");
  const tabClassic = document.getElementById("tab-classic");
  const tabAnon = document.getElementById("tab-anon");

  const groupEmail = document.getElementById("group-email");
  const groupUsername = document.getElementById("group-username");

  const inputEmail = document.getElementById("email");
  const inputUsername = document.getElementById("username");
  const inputPassword = document.getElementById("password");

  const form = document.getElementById("registerForm");
  const submitBtn = document.getElementById("submitBtn");
  const formFeedback = document.getElementById("form-feedback");
  const passwordToggle = document.getElementById("togglePassword");
  const strengthBar = document.querySelector(".strength-bar");

  // State
  let currentMode = "classic"; // 'classic' | 'anon'

  // --- Utils ---
  // Debounce (предотвращает частый вызов валидации при наборе текста)
  const debounce = (func, wait) => {
    let timeout;
    return (...args) => {
      clearTimeout(timeout);
      timeout = setTimeout(() => func.apply(this, args), wait);
    };
  };

  // --- 1. Spotlight Effect ---
  document.addEventListener("mousemove", (e) => {
    if (!authCard) return;
    requestAnimationFrame(() => {
      const rect = authCard.getBoundingClientRect();
      authCard.style.setProperty("--mouse-x", `${e.clientX - rect.left}px`);
      authCard.style.setProperty("--mouse-y", `${e.clientY - rect.top}px`);
    });
  });

  // --- 2. Mode Switching ---
  const setMode = (mode) => {
    currentMode = mode;
    toggleContainer.setAttribute("data-mode", mode);
    hideFeedback();

    if (mode === "classic") {
      tabClassic.classList.add("active");
      tabClassic.setAttribute("aria-selected", "true");
      tabAnon.classList.remove("active");
      tabAnon.setAttribute("aria-selected", "false");

      groupEmail.classList.remove("hidden");
      groupUsername.classList.add("hidden");

      inputEmail.required = true;
      inputUsername.required = false;

      // Очистка скрытого поля и сброс классов валидации
      inputUsername.value = "";
      inputUsername.classList.remove("valid", "invalid");

      setTimeout(() => inputEmail.focus(), 100);
    } else {
      tabAnon.classList.add("active");
      tabAnon.setAttribute("aria-selected", "true");
      tabClassic.classList.remove("active");
      tabClassic.setAttribute("aria-selected", "false");

      groupEmail.classList.add("hidden");
      groupUsername.classList.remove("hidden");

      inputEmail.required = false;
      inputEmail.value = "";
      inputEmail.classList.remove("valid", "invalid");

      inputUsername.required = true;
      setTimeout(() => inputUsername.focus(), 100);
    }
  };

  tabClassic.addEventListener("click", () => setMode("classic"));
  tabAnon.addEventListener("click", () => setMode("anon"));

  // --- 3. Password Toggle ---
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

  // --- 4. Validation ---
  const validateEmail = (email) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  const validateUsername = (user) => /^[a-zA-Z0-9_]{3,}$/.test(user);

  const updateStatus = (input, isValid) => {
    if (!input.value) {
      input.classList.remove("valid", "invalid");
      return;
    }
    input.classList.toggle("valid", isValid);
    input.classList.toggle("invalid", !isValid);
  };

  inputEmail.addEventListener(
    "input",
    debounce(() => {
      if (currentMode === "classic")
        updateStatus(inputEmail, validateEmail(inputEmail.value));
    }, 300)
  );

  inputUsername.addEventListener(
    "input",
    debounce(() => {
      if (currentMode === "anon")
        updateStatus(inputUsername, validateUsername(inputUsername.value));
    }, 300)
  );

  inputPassword.addEventListener("input", () => {
    const val = inputPassword.value;
    let score = 0;
    if (val.length >= 8) score += 25;
    if (/[A-Z]/.test(val)) score += 25;
    if (/[0-9]/.test(val)) score += 25;
    if (/[^A-Za-z0-9]/.test(val)) score += 25;

    strengthBar.style.width = `${Math.min(score, 100)}%`;
    if (score <= 25) strengthBar.style.backgroundColor = "var(--accent-error)";
    else if (score <= 50) strengthBar.style.backgroundColor = "#ffd700";
    else strengthBar.style.backgroundColor = "var(--accent-success)";

    updateStatus(inputPassword, val.length >= 8);
  });

  // --- 5. Submit ---
  const showFeedback = (msg, type) => {
    formFeedback.textContent = msg;
    formFeedback.className = `form-message ${type}`;
    formFeedback.classList.remove("hidden");

    // Эффект тряски при ошибке
    if (type === "error") {
      authCard.classList.add("shake");
      setTimeout(() => authCard.classList.remove("shake"), 400);
    }
  };

  const hideFeedback = () => formFeedback.classList.add("hidden");

  form.addEventListener("submit", async (e) => {
    e.preventDefault();
    hideFeedback();

    const password = inputPassword.value;
    if (password.length < 8) {
      showFeedback("Пароль слишком короткий", "error");
      return;
    }

    // ВАЖНО: Отправляем null для пустого поля,
    // чтобы валидатор Pydantic не ругался.
    const payload = {
      password: password,
      email: null,
      login: null,
    };

    if (currentMode === "classic") {
      const email = inputEmail.value.trim();
      if (!validateEmail(email)) {
        showFeedback("Некорректный E-mail", "error");
        inputEmail.classList.add("invalid");
        return;
      }
      payload.email = email;
    } else {
      const login = inputUsername.value.trim();
      if (!validateUsername(login)) {
        showFeedback("Логин содержит недопустимые символы", "error");
        inputUsername.classList.add("invalid");
        return;
      }
      payload.login = login;
    }

    // Отправка
    submitBtn.classList.add("loading");
    submitBtn.disabled = true;

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
        // Парсинг ошибок от FastAPI (Pydantic возвращает массив detail)
        let msg = "Ошибка сервера";

        if (data.detail) {
          if (Array.isArray(data.detail)) {
            // Это ошибка валидации Pydantic (422)
            // Берем первую ошибку из массива
            const err = data.detail[0];
            msg = err.msg;

            // Перевод частых технических сообщений на русский
            if (msg.includes("String should have at least"))
              msg = "Слишком короткое значение";
            if (msg.includes("value is not a valid email"))
              msg = "Некорректный формат email";
            if (msg.includes("Field required"))
              msg = "Обязательное поле не заполнено";
          } else {
            // Обычная HTTP ошибка (400/409)
            msg = data.detail;
            if (msg.includes("already exists") || msg.includes("taken")) {
              msg = "Пользователь с такими данными уже существует";
            }
          }
        }
        throw new Error(msg);
      }

      // Успех
      showFeedback("Успешная регистрация! Вход...", "success");

      // Сохраняем токены
      if (data.access_token) {
        localStorage.setItem("access_token", data.access_token);
        localStorage.setItem("refresh_token", data.refresh_token);
      }

      // Редирект
      setTimeout(() => {
        window.location.href = "/";
      }, 1500);
    } catch (err) {
      showFeedback(err.message, "error");
    } finally {
      submitBtn.classList.remove("loading");
      submitBtn.disabled = false;
    }
  });
});
