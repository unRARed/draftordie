import consumer from "./consumer"

document.addEventListener('turbo:load', () => {
  // Only load once
  if (typeof poll !== "undefined") { return; }

  // No need to keep polling if the draft is over
  let isDraftEnded = document.
    querySelector("meta[name='is-draft-ended']")?.
    getAttribute("content") === "true";
  //console.log(`isDraftEnded: ${isDraftEnded}`);
  if (isDraftEnded) { return; }

  let audioMap = {
    "core_draft_begun": document.
      getElementById("core_draft_begun"),
    "core_draft_ended": document.
      getElementById("core_draft_ended"),
    "core_draft_selection_time_expired": document.
      getElementById("core_draft_selection_time_expired")
  };

  let isSoundEnabled = document.
    querySelector("meta[name='is-sound-enabled']")?.
    getAttribute("content") === "true";
  //console.log(`isSoundEnabled: ${isSoundEnabled}`);

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
            if (data?.payload?.is_time_expired) {
              console.log("time expired");
              if (isSoundEnabled) {
                audioMap["core_draft_selection_time_expired"].
                  play();
              }
              draftChannel.advanceSelection();
            }
            break;
          case "selection_made":
            if (data?.payload?.is_time_expired) {
              console.log("time expired");
              if (isSoundEnabled) {
                audioMap["core_draft_selection_made"].
                  play();
              }
              draftChannel.advanceSelection();
            }
            break;
          case "reload":
            console.log("reloading");
            clearInterval(poll);
            location.reload();
            // Turbo.visit(`/drafts/${draftSlug}`)
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
