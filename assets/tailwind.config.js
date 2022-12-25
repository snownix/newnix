const plugin = require('tailwindcss/plugin');

module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex'
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          '50': '#edf9ff',
          '100': '#d7f1ff',
          '200': '#b8e8ff',
          '300': '#87dbff',
          '400': '#4ec5ff',
          '500': '#25a7ff',
          '600': '#0e88ff',
          '700': '#076ae1',
          '800': '#0d59c0',
          '900': '#124d96',
        },
        dark: {
          '50': '#404350',
          '100': '#363946',
          '200': '#2c2f3c',
          '300': '#222532',
          '400': '#181b28',
          '500': '#0e111e',
          '600': '#040714',
          '700': '#00000a',
          '800': '#000000',
          '900': '#000000'
        },
        redo: {
          "50": "#ffb1c8",
          "100": "#ffa7be",
          "200": "#ff9db4",
          "300": "#ff93aa",
          "400": "#fa89a0",
          "500": "#f07f96",
          "600": "#e6758c",
          "700": "#dc6b82",
          "800": "#d26178",
          "900": "#c8576e"
        },
        purpo: {
          "50": "#b8a9ff",
          "100": "#ae9fff",
          "200": "#a495ff",
          "300": "#9a8bff",
          "400": "#9081f7",
          "500": "#8677ed",
          "600": "#7c6de3",
          "700": "#7263d9",
          "800": "#6859cf",
          "900": "#5e4fc5"
        },
        orango: {
          "50": "#ffdfb3",
          "100": "#ffd5a9",
          "200": "#ffcb9f",
          "300": "#ffc195",
          "400": "#ffb78b",
          "500": "#fdad81",
          "600": "#f3a377",
          "700": "#e9996d",
          "800": "#df8f63",
          "900": "#d58559"
        },
        grai: {
          DEFAULT: '#6b7280',
          low: '#9098a6'
        }
      },
      fontFamily: {
        primary: 'Inter, sans-serif'
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    plugin(({ addVariant }) => addVariant('phx-no-feedback', ['&.phx-no-feedback', '.phx-no-feedback &'])),
    plugin(({ addVariant }) => addVariant('phx-click-loading', ['&.phx-click-loading', '.phx-click-loading &'])),
    plugin(({ addVariant }) => addVariant('phx-submit-loading', ['&.phx-submit-loading', '.phx-submit-loading &'])),
    plugin(({ addVariant }) => addVariant('phx-change-loading', ['&.phx-change-loading', '.phx-change-loading &']))
  ]
}
