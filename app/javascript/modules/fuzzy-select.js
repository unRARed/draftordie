document.addEventListener('turbo:frame-load', () => {
  const draftSlug = document.
    querySelector("meta[name='draft-slug']")?.
    getAttribute("content");
  let components = document.querySelectorAll(".c-fuzzy-select");
  let isTyping = false;

  components.forEach((component) => {
    let input = component.querySelector(".c-fuzzy-select__input");
    let frame = component.querySelector("turbo-frame");
    let items = component.
      querySelectorAll(".c-fuzzy-select__item");
    let hiddenInput = component.
      querySelector("input[type='hidden']");

    input.addEventListener("input", (e) => {
      if (isTyping) { return; }

      let searchTerm = e.target.value;

      isTyping = true;
      Turbo.visit(
        `/drafts/${draftSlug}/players?search=${searchTerm}`,
        {
          frame: frame.id,
          action: "replace"
        }
      )
      setTimeout(() => { isTyping = false }, 100);
    });

    items.forEach((item) => {
      item.addEventListener("click", (e) => {
        console.log(e.target.getAttribute('value'));
        hiddenInput.value = e.target.getAttribute('value');
        input.value = e.target.textContent;
      });
    });
  });
});
