exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: "js/app.js"
    },
    stylesheets: {
      joinTo: "css/app.css"
    },
    templates: {
      joinTo: "js/app.js"
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    assets: /^(web\/static\/assets)/
  },

  paths: {
    watched: [
      "web/static",
      "test/static"
    ],

    public: "priv/static" // Where to compile files to
  },

  plugins: {
    babel: {
      ignore: [/web\/static\/vendor/]
    },
    sass: {
      options: {
        includePaths: [
          'node_modules'
        ]
      }
    },
    postcss: {
      processors: [
        require('autoprefixer')()
      ]
    }
  },

  modules: {
    autoRequire: {
      "js/app.js": ["web/static/js/app"]
    }
  },

  npm: {
    enabled: true
    // static: [
    //   "phoenix",
    //   "phoenix_html"
    // ]
  }
};
