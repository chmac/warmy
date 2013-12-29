config =
  sitemaps: [
    __dirname + '/sitemaps/sitemap.xml'
    __dirname + '/sitemaps/sitemap2.xml'
  ]
  # Target multiple machines with all requests
  targets: [
    'host1.domain.tld'
    'host2.domain.tld'
  ]
  # Make one of each of these requests on the target machine
  requests: [
    method: 'PURGE'
  ,
    method: 'PURGE'
    headers:
      'X-Forwarded-HTTPS': "on"
  ,
    method: 'PURGE'
    headers:
      'X-Forwarded-HTTPS': "on"
      'X-PSA-Optimize-For-SPDY': '2'
  ]
  concurrency:
    sitemaps: 2
    urls: 3

module.exports = config