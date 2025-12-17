const navToggle = document.querySelector(".mobile-toggle");
const navMenu = document.querySelector(".header__nav");
const body = document.body;

if (navToggle && navMenu) {
  navToggle.addEventListener("click", () => {
    const isOpened = navToggle.getAttribute("aria-expanded") === "true";

    navToggle.setAttribute("aria-expanded", !isOpened);
    navMenu.classList.toggle("is-open");
    navToggle.classList.toggle("is-active");

    // Prevent background scrolling when menu is open
    body.style.overflow = isOpened ? "auto" : "hidden";
  });

  // Close menu when clicking a link
  navMenu.querySelectorAll("a").forEach((link) => {
    link.addEventListener("click", () => {
      navToggle.setAttribute("aria-expanded", "false");
      navMenu.classList.remove("is-open");
      navToggle.classList.remove("is-active");
      body.style.overflow = "auto";
    });
  });
}
