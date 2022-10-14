// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

let plugin = require('tailwindcss/plugin')

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
          '50': '#f2f7fd',
          '100': '#e3edfb',
          '200': '#c1dbf6',
          '300': '#8bbcee',
          '400': '#60a5e6',
          '500': '#267ed1',
          '600': '#1862b1',
          '700': '#144e90',
          '800': '#154477',
          '900': '#173963',
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
        grai: {
          "50": "#a1a6bc",
          "100": "#979cb2",
          "200": "#8d92a8",
          "300": "#83889e",
          "400": "#797e94",
          "500": "#6f748a",
          "600": "#656a80",
          "700": "#5b6076",
          "800": "#51566c",
          "900": "#474c62"
        }
      },
      fontFamily: {
        primary: 'Poppins'
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
