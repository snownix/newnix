import "phoenix_html"

import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";

import Hooks from "./hooks";
import topbar from "../vendor/topbar";

const csrfToken = document.querySelector("meta[name='csrf-token']")
    .getAttribute("content");
const liveSocket = new LiveSocket("/live", Socket, {
    hooks: Hooks,
    params: {
        _csrf_token: csrfToken,
        states: Hooks.SaveState.getAllStates(),
        agent: window.navigator && window.navigator.userAgent || ""
    }
});

topbar.config({
    barColors: { 0: "#29d" },
    shadowColor: "rgba(0, 0, 0, .3)"
});
window.addEventListener("phx:page-loading-start", () => {
    topbar.show();
});
window.addEventListener("phx:page-loading-stop", () => {
    topbar.hide();


    document.querySelectorAll('[data-link]').forEach(el => {
        if (el.dataset.link == window.location.pathname) {
            el.classList.add('active');
        } else {
            el.classList.remove('active');
        }
    });
});

liveSocket.connect();
liveSocket.disableLatencySim();
window.liveSocket = liveSocket;