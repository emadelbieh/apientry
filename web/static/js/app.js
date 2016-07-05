import 'phoenix_html'

// Set up 3rd-party libs (don't use `import`)
window.jQuery = window.$ = require('jquery')
window.onmount = require('onmount')
require('bootstrap-sass')
require('phoenix_html')

$.onmount('[data-toggle="dropdown"]', function () {
  $(this).dropdown()
})

$(function () { onmount() })
