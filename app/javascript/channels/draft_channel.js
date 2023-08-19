import consumer from "./consumer"

document.addEventListener('turbo:load', () => {
  const draftSlug = document.
    querySelector("meta[name='draft-slug']")?.
    getAttribute("content");

  const draftChannel = consumer.subscriptions.create(
    { channel: "DraftChannel", slug: draftSlug },
    {
      refresh() {
        Turbo.visit(location.href, { action: "replace" })
      },
      // reacting to action cable commands sent from the server
      received(data) {
        if (!data.command) { return; }
        if (!data.payload) { return; }

        switch (data.command) {
          case "refresh":
            //console.log("State changed");
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
