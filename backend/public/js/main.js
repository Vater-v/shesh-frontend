document.addEventListener("DOMContentLoaded", () => {
  const navToggle = document.querySelector(".mobile-toggle");
  const navMenu = document.querySelector(".header__nav");
  const body = document.body;

  /* --- Mobile Navigation Logic --- */
  if (navToggle && navMenu) {
    // Toggle Menu
    navToggle.addEventListener("click", (e) => {
      e.stopPropagation();
      const isOpened = navToggle.getAttribute("aria-expanded") === "true";
      toggleMenu(!isOpened);
    });

    // Close when clicking a link
    navMenu.querySelectorAll("a").forEach((link) => {
      link.addEventListener("click", () => toggleMenu(false));
    });

    // Close when clicking outside
    document.addEventListener("click", (e) => {
      const isOpened = navToggle.getAttribute("aria-expanded") === "true";
      if (
        isOpened &&
        !navMenu.contains(e.target) &&
        !navToggle.contains(e.target)
      ) {
        toggleMenu(false);
      }
    });

    // Close on Escape key
    document.addEventListener("keydown", (e) => {
      if (
        e.key === "Escape" &&
        navToggle.getAttribute("aria-expanded") === "true"
      ) {
        toggleMenu(false);
      }
    });
  }

  function toggleMenu(shouldOpen) {
    if (!navToggle || !navMenu) return;

    navToggle.setAttribute("aria-expanded", shouldOpen);

    if (shouldOpen) {
      navMenu.classList.add("is-open");
      navToggle.classList.add("is-active");
      body.style.overflow = "hidden"; // Lock scroll
    } else {
      navMenu.classList.remove("is-open");
      navToggle.classList.remove("is-active");
      body.style.overflow = "auto"; // Unlock scroll
    }
  }

  /* --- Optimized Feature Card Spotlight --- */
  const cards = document.querySelectorAll(".feature-card");

  if (cards.length > 0) {
    cards.forEach((card) => {
      card.addEventListener("mousemove", (e) => {
        // Use requestAnimationFrame for 60fps performance
        requestAnimationFrame(() => {
          const rect = card.getBoundingClientRect();
          const x = e.clientX - rect.left;
          const y = e.clientY - rect.top;

          card.style.setProperty("--mouse-x", `${x}px`);
          card.style.setProperty("--mouse-y", `${y}px`);
        });
      });
    });
  }

  /* --- Form Submit Micro-Interaction --- */
  const form = document.getElementById("auth-form");
  if (form) {
    form.addEventListener("submit", (e) => {
      e.preventDefault();
      const btn = form.querySelector("button[type='submit']");
      const input = form.querySelector("input");
      const originalText = btn.textContent;

      // Processing State
      btn.textContent = "ОБРАБОТКА...";
      btn.style.opacity = "0.7";
      input.disabled = true;

      // Simulate Network Delay
      setTimeout(() => {
        // Success State
        btn.textContent = "ДОСТУП РАЗРЕШЕН";
        btn.classList.add("btn--success");
        input.value = "";

        // Reset after delay
        setTimeout(() => {
          btn.classList.remove("btn--success");
          btn.textContent = originalText;
          btn.style.opacity = "1";
          input.disabled = false;
        }, 3000);
      }, 1200);
    });
  }

  console.log(
    "%c SHESH SYSTEM %c ONLINE ",
    "background: #00e5ff; color: #000; font-weight: bold; padding: 4px;",
    "background: #121212; color: #00e5ff; padding: 4px;"
  );
});
