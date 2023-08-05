import consumer from "./consumer"

document.addEventListener('turbo:load', () => {
  // Only load once
  if (typeof poll !== "undefined") { return; }

  const draftSlug = document.
    querySelector("meta[name='draft-slug']").
    getAttribute("content");

  const draftChannel = consumer.subscriptions.create(
    { channel: "DraftChannel", slug: draftSlug },
    {
      received(data) {
        if (!data.command) { return; }
        if (!data.payload) { return; }

        switch (data.command) {
          case "selection_state":
            if (data.payload.is_time_expired) {
              draftChannel.advanceSelection();
            }
            break;
          case "reload":
            console.log("reloading");
            clearInterval(poll);
            Turbo.visit(
              `/drafts/${draftSlug}`,
              { action: "replace",
                frame: data.payload.current_selection_id
              }
            )
            break;
          case "draft_ended":
            console.log("ending draft");
            clearInterval(poll);
            break;
          default:
            console.log("unknown action");
            break;
        }
      },

      advanceSelection() {
        console.log("advancing selection");
        this.perform(
          "requested_selection_advance", { slug: draftSlug }
        );
      },

      pollCurrentSelection() {
        console.log("polling selection");
        return this.perform(
          "requested_selection_state", { slug: draftSlug }
        );
      },
    }
  );

  var poll = setInterval(() => {
    if (!draftChannel.pollCurrentSelection()) { return; }
  }, 2000)
});
