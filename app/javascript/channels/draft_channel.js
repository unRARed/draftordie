import consumer from "./consumer"

document.addEventListener('turbo:load', () => {
  const draftSlug = document.
    querySelector("meta[name='draft-slug']")?.
    getAttribute("content");

  const draftChannel = consumer.subscriptions.create(
    { channel: "DraftChannel", slug: draftSlug },
    {
      refresh() {
        // fade out the draft board and prevent null
        // poiner on the dashboard page
        if (document.querySelector(".c-draft__board")) {
          document.querySelector(".c-draft").
            classList.add("c-draft--fade");
        }
        setTimeout(() => {
          location.reload();
          // Turbo.visit(location.href, { action: "advance" })
        }, 3000)
      },
      // reacting to action cable commands sent from the server
      received(data) {
        if (!data.command) { return; }
        if (!data.payload) { return; }

        switch (data.command) {
          case "refresh":
            draftChannel.refresh();
            break;
          default:
            console.log(`Unknown Command: ${data.command}`);
            break;
        }
     },
    }
  );
});
