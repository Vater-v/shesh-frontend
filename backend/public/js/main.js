document.addEventListener("DOMContentLoaded", () => {
  const navToggle = document.querySelector(".mobile-toggle");
  const navMenu = document.querySelector(".header__nav");
  const body = document.body;

  /* --- 1. Мобильная навигация --- */
  if (navToggle && navMenu) {
    const toggleMenu = (shouldOpen) => {
      navToggle.setAttribute("aria-expanded", shouldOpen);
      if (shouldOpen) {
        navMenu.classList.add("is-open");
        navToggle.classList.add("is-active");
        body.style.overflow = "hidden";
      } else {
        navMenu.classList.remove("is-open");
        navToggle.classList.remove("is-active");
        body.style.overflow = "auto";
      }
    };

    navToggle.addEventListener("click", (e) => {
      e.stopPropagation();
      const isOpened = navToggle.getAttribute("aria-expanded") === "true";
      toggleMenu(!isOpened);
    });

    navMenu.querySelectorAll("a").forEach((link) => {
      link.addEventListener("click", () => toggleMenu(false));
    });

    document.addEventListener("click", (e) => {
      if (
        navToggle.getAttribute("aria-expanded") === "true" &&
        !navMenu.contains(e.target) &&
        !navToggle.contains(e.target)
      ) {
        toggleMenu(false);
      }
    });
  }

  /* --- 2. Эффект Spotlight для карточек --- */
  const cards = document.querySelectorAll(".feature-card, .auth-terminal");
  cards.forEach((card) => {
    card.addEventListener("mousemove", (e) => {
      requestAnimationFrame(() => {
        const rect = card.getBoundingClientRect();
        card.style.setProperty("--mouse-x", `${e.clientX - rect.left}px`);
        card.style.setProperty("--mouse-y", `${e.clientY - rect.top}px`);
      });
    });
  });

  /* --- 3. Переключатель протоколов (Auth Switcher) --- */
  const protocolTabs = document.querySelectorAll(".protocol-switcher__btn");
  if (protocolTabs.length > 0) {
    protocolTabs.forEach((tab) => {
      tab.addEventListener("click", (e) => {
        // Визуальное переключение табов
        protocolTabs.forEach((t) => {
          t.setAttribute("aria-selected", "false");
          t.classList.remove("protocol-switcher__btn--active");
        });
        tab.setAttribute("aria-selected", "true");
        tab.classList.add("protocol-switcher__btn--active");

        // Переключение видимости форм
        const targetId = tab.getAttribute("aria-controls");
        document
          .querySelectorAll(".auth-form")
          .forEach((form) => (form.hidden = true));
        const targetForm = document.getElementById(targetId);
        if (targetForm) targetForm.hidden = false;

        // Генерация ключа для Ghost-протокола
        if (targetId === "protocol-b") {
          const keyInput = document.getElementById("ghost-local-key");
          if (
            keyInput &&
            (keyInput.value === "" || keyInput.value.includes("WAITING"))
          ) {
            generateGhostKey();
          }
        }
      });
    });
  }

  console.log(
    "%c SHESH SYSTEM %c ONLINE ",
    "background: #00e5ff; color: #000; font-weight: bold; padding: 4px;",
    "background: #121212; color: #00e5ff; padding: 4px;"
  );
});
