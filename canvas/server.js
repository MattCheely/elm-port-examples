var express = require('express');
var app = express();
var http = require('http');
var join = require('path').join;
var bodyParser = require('body-parser');

module.exports = function (PORT, log) {

  app.use(bodyParser.json());

  app.use(express.static(join(__dirname, '/public')));

  app.get('/', function (req, res, next) {
    var indexPage = join(__dirname, 'public/index.html');
    return res.status(200).sendFile(indexPage);
  })

  var httpServer = http.createServer(app);

  httpServer.listen(PORT, function () {
    log("Server running on ", PORT);
  })

}