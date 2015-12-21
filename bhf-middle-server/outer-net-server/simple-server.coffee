bodyParser = require 'body-parser'
multer = require 'multer'

app = require('express')()
server = require('http').createServer(app)

server.listen(3002)

app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))
app.use(multer())

app.post("/api/account/token", (req, resp, next)->
  resp.end(req.body)
)
