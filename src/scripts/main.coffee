require('process').registerBinding('tcp_wrap', require('tcp_wrap-chromeify'));

mongodb = require 'mongodb'
Db = mongodb.Db
Connection = mongodb.Connection
Server = mongodb.Server

$('#connect').submit ->
  $this = $(this)
  host = $this.find('[name=host]').val()
  port = $this.find('[name=port]').val()
  port = parseInt(port) or Connection.DEFAULT_PORT
  database = $this.find('[name=database]').val()
  console.log host, port, database

  server = new Server host, port
  connector = new Db database, server, { w: 0 }

  connector.open (err, db) ->
    throw err if err
    window.db = db
    db.collections (err, items) ->
      ul = $('<ul>')
      for collection in items
        ul.append "<li><a>#{collection.collectionName}</a></li>"
      $('#sidebar').html ul


  false