/**
 * loading 1.0.0, 2022-11-05
 * https://rais.me
 * Copyright (c) 2022 Yassine R.
 */
(function (window, document) {
    "use strict";

    const loadingOverlay = document.querySelector('.newnix-loading');

    var loading = {
        init: () => {
            document.body.appendChild(loadingOverlay);
        },

        show: () => {
            loadingOverlay.style.display = 'flex';
        },

        hide: () => {
            loadingOverlay.style.display = 'none';
        }
    }

    loading.init();

    if (typeof module === "object" && typeof module.exports === "object") {
        module.exports = loading;
    } else if (typeof define === "function" && define.amd) {
        define(function () {
            return loading;
        });
    } else {
        this.loading = loading;
    }
}.call(this, window, document));