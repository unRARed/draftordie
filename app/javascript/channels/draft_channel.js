import consumer from "./consumer"

console.log("draft_channel.js loaded");

const draftSlug = document.
  querySelector("meta[name='draft-slug']").
  getAttribute("content");

const draftChannel = consumer.subscriptions.create(
  { channel: "DraftChannel", slug: draftSlug },
  {
    received(data) {
      console.log("received data");
      if (!data.command) { return; }
      if (!data.payload) { return; }

      switch (data.command) {
        case "poll_current_selection":
          if (data.payload.is_time_expired) {
            draftChannel.advanceSelection();
          }
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

let poll = setInterval(() => {
  if (!draftChannel.pollCurrentSelection()) { return; }
}, 2000)
