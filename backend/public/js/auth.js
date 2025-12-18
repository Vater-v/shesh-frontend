/**
 * SHESH AUTHENTICATION MODULE
 * Handles: Protocol switching, form validation, and mock backend submission.
 */
const SheshAuth = (() => {
  "use strict";

  const selectors = {
    form: "#reg-form, #login-form",
    protocolTabs: ".protocol-switcher__tab",
    emailPanel: "#panel-operational",
    ghostPanel: "#panel-ghost",
    protocolInput: "#input-protocol",
    togglePassword: '[data-action="toggle-password"]',
    errorBox: "#form-global-error",
  };

  /**
   * Protocol Switcher (Operational vs Ghost)
   */
  const initProtocolSwitcher = () => {
    const tabs = document.querySelectorAll(selectors.protocolTabs);
    const emailPanel = document.querySelector(selectors.emailPanel);
    const ghostPanel = document.querySelector(selectors.ghostPanel);
    const protocolInput = document.querySelector(selectors.protocolInput);

    tabs.forEach((tab) => {
      tab.addEventListener("click", () => {
        const protocol = tab.dataset.protocol;

        // Update UI States
        tabs.forEach((t) => {
          t.setAttribute("aria-selected", "false");
          t.classList.remove("protocol-switcher__tab--active");
        });

        tab.setAttribute("aria-selected", "true");
        tab.classList.add("protocol-switcher__tab--active");

        // Toggle logic
        if (protocol === "ghost") {
          emailPanel.hidden = true;
          ghostPanel.hidden = false;
          protocolInput.value = "ghost";
        } else {
          emailPanel.hidden = false;
          ghostPanel.hidden = true;
          protocolInput.value = "operational";
        }
      });
    });
  };

  /**
   * Password Visibility Toggle
   */
  const initPasswordToggle = () => {
    document.querySelectorAll(selectors.togglePassword).forEach((btn) => {
      btn.addEventListener("click", () => {
        const input = btn
          .closest(".form-group__control")
          .querySelector("input");
        const isPassword = input.type === "password";

        input.type = isPassword ? "text" : "password";
        btn.setAttribute("aria-pressed", !isPassword);
      });
    });
  };

  /**
   * Real-time Validation
   */
  const validate = (input) => {
    const value = input.value.trim();
    let isValid = true;
    let message = "";

    if (input.name === "login") {
      if (value.length < 3) {
        isValid = false;
        message = "Минимум 3 символа";
      } else if (value.includes("@")) {
        isValid = false;
        message = "Используйте Email в поле канала связи";
      }
    }

    if (input.name === "password" && value.length < 8) {
      isValid = false;
      message = "Энтропия слишком низка (мин. 8)";
    }

    const group = input.closest(".form-group");
    const errorDisplay = group?.querySelector(".form-group__error");

    if (errorDisplay) {
      errorDisplay.textContent = message;
      input.setAttribute("aria-invalid", !isValid);
    }

    return isValid;
  };

  /**
   * Mock Backend Integration
   */
  const mockSubmit = async (formData) => {
    return new Promise((resolve, reject) => {
      console.log(">>> INITIALIZING UPLINK:", Object.fromEntries(formData));

      setTimeout(() => {
        // Mock logic: fail if password is "password"
        if (formData.get("password") === "12345678") {
          reject({ message: "PROTOCOL_DENIED: Слабый ключ доступа." });
        } else {
          resolve({ status: "AUTHORIZED", redirect: "/home" });
        }
      }, 2000);
    });
  };

  const initFormSubmission = () => {
    const form = document.querySelector(selectors.form);
    if (!form) return;

    form.addEventListener("submit", async (e) => {
      e.preventDefault();

      // Clear previous errors
      const errorBox = document.querySelector(selectors.errorBox);
      errorBox.hidden = true;

      // Final validation check
      const inputs = form.querySelectorAll("input[required]");
      let formValid = true;
      inputs.forEach((input) => {
        if (!validate(input)) formValid = false;
      });

      if (!formValid) return;

      // Loading state
      const submitBtn = form.querySelector('button[type="submit"]');
      const originalText = submitBtn.innerHTML;
      submitBtn.disabled = true;
      submitBtn.innerHTML = '<span class="btn__content">SYNCING...</span>';

      try {
        const result = await mockSubmit(new FormData(form));
        submitBtn.classList.add("btn--success");
        submitBtn.innerHTML =
          '<span class="btn__content">ACCESS GRANTED</span>';

        // Simulated redirect
        setTimeout(() => (window.location.href = result.redirect), 1000);
      } catch (err) {
        errorBox.textContent = err.message;
        errorBox.hidden = false;
        submitBtn.disabled = false;
        submitBtn.innerHTML = originalText;
      }
    });

    // Attach real-time validation listeners
    form.querySelectorAll("input").forEach((input) => {
      input.addEventListener("input", () => validate(input));
    });
  };

  return {
    init: () => {
      initProtocolSwitcher();
      initPasswordToggle();
      initFormSubmission();
    },
  };
})();

// Initialize Auth on DOM Ready
document.addEventListener("DOMContentLoaded", SheshAuth.init);
