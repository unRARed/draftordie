import consumer from "./consumer"

console.log("draft_channel.js loaded");

const draftSlug = document.
  querySelector("meta[name='draft-slug']").
  getAttribute("content");

const draftChannel = consumer.subscriptions.create(
  { channel: "DraftChannel" },
  {
    // Called once when the subscription is created.
    initialized() {
      //this.update = this.update.bind(this)
    },
    // Called when the subscription is ready for use.
    connected() { },
    // Called when the WebSocket connection is closed.
    disconnected() { },
    // Called when the subscription is rejected by the server.
    rejected() { },
    update() { },
    appear() { },

    advanceSelection() {
      this.perform("advance_selection", { slug: draftSlug });
    },

    isBetweenSelections() {
      this.perform("is_between_selections", { slug: draftSlug });
    },
  }
);

let poll = setInterval(() => {
  console.log(draftChannel.isBetweenSelections());
  if (!draftChannel.isBetweenSelections()) { return; }

  console.log("advancing selection");

  draftChannel.advanceSelection();
  clearInterval(poll);
}, 1000)
