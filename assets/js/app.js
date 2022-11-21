import "phoenix_html"

import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";

import Hooks from "./hooks";
import topbar from "../vendor/topbar";

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
    hooks: Hooks,
    params: {
        _csrf_token: csrfToken,
        states: Hooks.SaveState.getAllStates()
    }
})

topbar.config({
    barColors: { 0: "#29d" },
    shadowColor: "rgba(0, 0, 0, .3)"
})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

liveSocket.connect()
liveSocket.disableLatencySim()
window.liveSocket = liveSocket

