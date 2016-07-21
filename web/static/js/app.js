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

/*
 * .try-this -- for the publishers
 */

!(function () {
  onmount('[role~="try-this"]', function () {
    var $this = $(this)

    var $trackingId = $('[role~="trackingid"]', this)
    var $ipAddress = $('[role~="ipaddress"]', this)
    var $keyword = $('[role~="keyword"]', this)
    var $text = $('[role~="text"]', this)
    var $userAgent = $('[role~="useragent"]', this)
    var $as = $('[role~="as"]', this)

    var apiKey = $(this).attr('data-apikey')

    update()

    $(this).on('change', 'select', update)
    $(this).on('input', 'input[type="text"]', update)

    function update () {
      $text.val(build({
        apiKey: apiKey,
        ipAddress: $ipAddress.val(),
        userAgent: $userAgent.val(),
        trackingId: $trackingId.val(),
        keyword: $keyword.val(),
        as: $as.val()
      }))
    }
  })

  /*
   * Builds a test string
   */

  function build (options) {
    var base = ''
      + window.location.protocol
      + '//'
      + window.location.hostname
      + (window.location.port
        ? (':' + window.location.port)
        : '')

    var query = queryString({
      apiKey: options.apiKey,
      keyword: options.keyword,
      visitorIPAddress: options.ipAddress,
      visitorUserAgent: options.userAgent,
      domain: 'shopping.com',
      trackingId: options.trackingId
    })

    if (options.as === 'curl') {
      var url = base + '/publisher?' + query
      return 'curl ' + JSON.stringify(url)
    } else if (options.as === 'curl-dryrun') {
      var url = base + '/dryrun/publisher?' + query
      return 'curl ' + JSON.stringify(url) + ' -u admin'
    } else {
      var url = base + '/publisher?' + query
      return url
    }
  }

  /*
   * Joins an object into a query string
   */

  function queryString (obj) {
    var parts = Object.keys(obj).map(function (key) {
      var val = obj[key]
      if (val) {
        return window.encodeURIComponent(key)
          + '=' + window.encodeURIComponent(val)
      } else {
        return ''
      }
    })

    return parts.join('&')
  }
}())
