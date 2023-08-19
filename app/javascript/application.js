// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./channels"
import "./controllers"
import "./countdown"
import mermaid from "mermaid"

let config = {
  startOnLoad: true,
  theme: "dark",
  flowchart: { useMaxWidth: false, htmlLabels: true }
};
mermaid.initialize(config);
