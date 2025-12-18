/**
 * SHESH SYSTEM - Global UI Controller
 * Handles: Mobile Navigation, Spotlight Effects, and System Logging.
 */
const SheshUI = (() => {
  "use strict";

  // State management for UI components
  const state = {
    isNavOpen: false,
    lastSpotlightUpdate: 0,
  };

  /**
   * Mobile Navigation Logic
   * Manages ARIA states and scroll-locking for the terminal menu.
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

      // Prevent background scrolling when menu is active
      body.style.overflow = open ? "hidden" : "";
    };

    navToggle.addEventListener("click", (e) => {
      e.stopPropagation();
      toggleMenu(!state.isNavOpen);
    });

    // Close menu on link click or clicking outside
    document.addEventListener("click", (e) => {
      if (state.isNavOpen && !navMenu.contains(e.target)) {
        toggleMenu(false);
      }
    });
  };

  /**
   * Spotlight Effect
   * Optimized mouse-tracking gradient for interactive cards.
   */
  const initSpotlight = () => {
    const cards = document.querySelectorAll(
      ".feature-card, .terminal, .auth-form"
    );

    const updateSpotlight = (e) => {
      // Throttled using requestAnimationFrame for performance
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
   * Stylized System Logging
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
      logSystemStatus();
    },
  };
})();

// Initialize on DOM Ready
document.addEventListener("DOMContentLoaded", SheshUI.init);
