/**
 * SHESH SYSTEM - Global UI Controller
 * Handles: Mobile Navigation, Spotlight Effects, Auth State, and System Logging.
 */
const SheshUI = (() => {
  "use strict";

  // Состояние UI компонентов
  const state = {
    isNavOpen: false,
    lastSpotlightUpdate: 0,
  };

  /**
   * Логика мобильной навигации
   * Управляет состояниями ARIA и блокировкой прокрутки для терминального меню.
   */
  const initMobileNav = () => {
    const navToggle = document.querySelector(".mobile-toggle");
    const navMenu = document.querySelector(".header__nav");
    const body = document.body;

    if (!navToggle || !navMenu) return;

    const toggleMenu = (open) => {
      state.isNavOpen = open;
      navToggle.setAttribute("aria-expanded", open);
      navToggle.classList.toggle("is-active", open);
      navMenu.classList.toggle("is-open", open);

      // Запрет прокрутки фона при активном меню
      body.style.overflow = open ? "hidden" : "";
    };

    navToggle.addEventListener("click", (e) => {
      e.stopPropagation();
      toggleMenu(!state.isNavOpen);
    });

    // Закрытие меню при клике на ссылку или вне меню
    document.addEventListener("click", (e) => {
      if (state.isNavOpen && !navMenu.contains(e.target)) {
        toggleMenu(false);
      }
    });
  };

  /**
   * Эффект прожектора (Spotlight)
   * Оптимизированный градиент следования за мышью для интерактивных карточек.
   */
  const initSpotlight = () => {
    const cards = document.querySelectorAll(
      ".feature-card, .terminal, .auth-form, .auth-card"
    );

    const updateSpotlight = (e) => {
      requestAnimationFrame(() => {
        cards.forEach((card) => {
          const rect = card.getBoundingClientRect();
          const x = e.clientX - rect.left;
          const y = e.clientY - rect.top;

          card.style.setProperty("--mouse-x", `${x}px`);
          card.style.setProperty("--mouse-y", `${y}px`);
        });
      });
    };

    if (cards.length > 0) {
      window.addEventListener("mousemove", updateSpotlight);
    }
  };

  /**
   * Управление состоянием авторизации в UI
   * Переключает видимость элементов для гостей и зарегистрированных пользователей.
   */
  const updateAuthUI = () => {
    const token = localStorage.getItem("access_token");
    const guestElements = document.querySelectorAll(".guest-only");
    const userElements = document.querySelectorAll(".user-only");

    if (token) {
      // Пользователь авторизован
      guestElements.forEach((el) => el.classList.add("hidden"));
      userElements.forEach((el) => el.classList.remove("hidden"));
    } else {
      // Пользователь — гость
      guestElements.forEach((el) => el.classList.remove("hidden"));
      userElements.forEach((el) => el.classList.add("hidden"));
    }
  };

  /**
   * Логика выхода из системы
   * Очищает токены и обновляет состояние страницы.
   */
  const initLogout = () => {
    const logoutBtn = document.getElementById("logoutBtn");
    if (logoutBtn) {
      logoutBtn.addEventListener("click", (e) => {
        e.preventDefault();
        // Удаление данных из хранилища
        localStorage.removeItem("access_token");
        localStorage.removeItem("refresh_token");

        // Редирект на главную или перезагрузка для обновления UI
        window.location.href = "/";
      });
    }
  };

  /**
   * Стилизованное логирование статуса системы
   */
  const logSystemStatus = () => {
    const styles = {
      cyan: "background: #00e5ff; color: #000; font-weight: bold; padding: 4px; border-radius: 2px;",
      dark: "background: #121212; color: #00e5ff; padding: 4px; border: 1px solid #00e5ff;",
    };
    console.log(
      "%c SHESH SYSTEM %c STABLE / ONLINE ",
      styles.cyan,
      styles.dark
    );
  };

  return {
    init: () => {
      initMobileNav();
      initSpotlight();
      updateAuthUI();
      initLogout();
      logSystemStatus();
    },
  };
})();

// Инициализация при готовности DOM
document.addEventListener("DOMContentLoaded", SheshUI.init);
