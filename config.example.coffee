module.exports =
  sitemaps = [
    __dir + 'sitemaps/sitemap.xml'
  ]
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