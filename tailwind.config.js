module.exports = {
  purge: {
    './app/**/*.html.slim',
  },
  darkMode: true,
  content: [
    './app/views/**/*.html.erb',
    './app/views/**/*.html.slim',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      fontFamily: {
        heading: ['Keania One', 'cursive'],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
  ]
}
