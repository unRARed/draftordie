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
          case "poll_current_selection":
            if (data.payload.is_time_expired) {
              draftChannel.advanceSelection();
            }
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
          "advance_selection", { slug: draftSlug }
        );
      },

      pollCurrentSelection() {
        console.log("polling selection");
        return this.perform(
          "poll_current_selection", { slug: draftSlug }
        );
      },
    }
  );

  var poll = setInterval(() => {
    if (!draftChannel.pollCurrentSelection()) { return; }
  }, 2000)
});
