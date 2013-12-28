config =
  sitemaps = [
    __dir + 'sitemaps/sitemap.xml'
  ]
  # Target multiple machines with all requests
  targets = [
    'front.mcspr.net'
    'usa1.pergento.net'
  ]
  # Make one of each of these requests on the target machine
  requests = [
    method: 'PURGE'
  ,
    method: 'PURGE'
    headers:
      X-Forwarded-HTTPS: "on"
  ,
    method: 'PURGE'
    headers:
      X-Forwarded-HTTPS: "on"
      X-PSA-Optimize-For-SPDY: '2'
  ]

module.exports = config