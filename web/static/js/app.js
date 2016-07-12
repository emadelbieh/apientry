// Set up 3rd-party libs (don't use `import`)
window.jQuery = window.$ = require('jquery')
window.onmount = require('onmount')
require('bootstrap-sass')

onmount('[data-toggle="dropdown"]', function () {
  $(this).dropdown()
})

$(function () { onmount() })

/*
 * jQuery implementation of phoenix_html, because for some reason
 * phoenix_html doesn't play well with Bootstrap sass.
 */

$(document).on('click', 'a[data-submit="parent"]', function (e) {
  e.preventDefault()
  var message = this.getAttribute('data-confirm')
  if (message === null || confirm(message)) {
    this.parentNode.submit()
  }
})
