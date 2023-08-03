import consumer from "./consumer"

console.log("draft_channel.js loaded");

const draftSlug = document.
  querySelector("meta[name='draft-slug']").
  getAttribute("content");

const draftChannel = consumer.subscriptions.create(
  { channel: "DraftChannel", slug: draftSlug },
  {
    // Called once when the subscription is created.
    // initialized() {
      //this.update = this.update.bind(this)
    // },
    // Called when the subscription is ready for use.
    // connected() { },
    // Called when the WebSocket connection is closed.
    // disconnected() { },
    // Called when the subscription is rejected by the server.
    // rejected() { },
    // update() { },
    // appear() { },
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
      clearInterval(poll);
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
}, 1000)
