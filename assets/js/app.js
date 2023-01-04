import 'phoenix_html';
import Alpine from 'alpinejs';

import { Socket } from 'phoenix';
import { LiveSocket } from 'phoenix_live_view';

import Hooks from './hooks';
import topbar from '../vendor/topbar';

window.Alpine = Alpine;

const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
const liveSocket = new LiveSocket('/live', Socket, {
    hooks: Hooks,
    params: {
        _csrf_token: csrfToken,
        states: Hooks.SaveState.getAllStates(),
        agent: window.navigator && window.navigator.userAgent || ''
    },
    dom: {
        onBeforeElUpdated(from, to) {
            if (from._x_dataStack) {
                window.Alpine.clone(from, to)
            }
        }
    }
});
window.liveSocket = liveSocket;

topbar.config({
    barColors: { 0: '#29d' },
    shadowColor: 'rgba(0, 0, 0, .3)'
});
window.addEventListener('phx:page-loading-start', () => {
    topbar.show();
});
window.addEventListener('phx:page-loading-stop', () => {
    topbar.hide();

    document.querySelectorAll('[data-link]').forEach(el => {
        if (el.dataset.link == window.location.pathname) {
            el.classList.add('active');
        } else {
            el.classList.remove('active');
        }
    });
});


Alpine.start();
liveSocket.connect();
liveSocket.disableLatencySim();
