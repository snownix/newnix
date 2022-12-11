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
          '50': '#f2f8fd',
          '100': '#e3effb',
          '200': '#c1dff6',
          '300': '#8ac5ef',
          '400': '#4ca7e4',
          '500': '#3498db',
          '600': '#176fb2',
          '700': '#145990',
          '800': '#144c78',
          '900': '#164064',
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
        primary: 'Inter'
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
