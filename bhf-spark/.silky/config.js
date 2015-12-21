module.exports = {
  'port': 14422,
  'proxy': {
    'forward': {
      '/api': "http://127.0.0.1:8001"
    }
  },
  'routers': [{
    'path': /^(.+)\.source(\.js)$/,
    'to': "$1$2",
    'next': false
  }, {
    'path': /^\/blog\/$/i,
    'to': "/blog/index.html",
    'next': false,
    'static': true
  }, {
    'path': /^\/blog\/(.+)$/i,
    'to': "/blog/$1",
    'next': false,
    'static': true
  }, {
    'path': /.*(\/[^\.]+(\/)?)$/i,
    'to': "/main.html",
    'next': false
  }, {
    'path': /^\/login$/,
    'to': "/main.html",
    'next': false
  }, {
    'path': /^(\/)$/,
    'to': "/main.html",
    'next': true
  }],
  'build': {
    'output': "./build",
    'rename': [{
      'source': /^template\/(.+)/i,
      'target': "$1",
      'next': false
    }, {
      'source': /source\.(js)$/i,
      'target': "$1"
    }],
    'compress': {
      'js': true,
      'css': false,
      'html': false,
      'internal': false,
      'ignore': [/\.min\.js$/, "js/vendor", "blog", "build"]
    },
    'copy': ["images", "package", "fonts", "blog", "build.js"],
    'ignore': [
        /^template\/module$/i, /^css\/module$/i, /(^|\/)\.(.+)$/,
        "js/vendor-original", "design", /\.md$/i]
  },
  'version': 0.2,
  'compatibleModel': true,
  'plugins': {
      "bhf": {}
  }
}