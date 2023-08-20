document.addEventListener('turbo:load', () => {
  let navTrigger = document.querySelectorAll(".c-nav-trigger");
  let body = document.querySelector("body");
  let isNavOpen = false;

  let cancelNav = (e) => {
    if (!isNavOpen) { return; }
    // if the click is on the nav itself, don't close it
    if (e.target.matches('[class*="c-nav"], [class*="c-nav"] path')) { return; }

    document.querySelector(".c-nav").classList.remove("block");
    navTrigger.forEach((trigger) => {
      trigger.classList.remove("hidden");
    });
    isNavOpen = false;
  };

  navTrigger.forEach((trigger) => {
    trigger.addEventListener("click", (e) => {
      trigger.parentElement.
        querySelector(".c-nav").classList.add("block");
      trigger.classList.add("hidden");
      isNavOpen = true;
    });
  });

  body.addEventListener("click", cancelNav)
});
