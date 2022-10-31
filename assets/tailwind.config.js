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
