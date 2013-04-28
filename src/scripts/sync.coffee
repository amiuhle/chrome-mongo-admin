mongodb = require('mongodb')
Db = mongodb.Db

defer = $.Deferred

connections = {}

connection = $.Deferred()

sync = (method, model, options) ->
  console.log 'mongo sync', method, model, options
  mongoUrl = _.result model, 'urlRoot'

  # make sure we have a connection for the specified URL
  unless connections[mongoUrl]
    connection = connections[mongoUrl] = defer()
    Db.connect mongoUrl,  (err, db) ->
      if err
        connection.reject err
      else
        connection.resolve db

      connection.fail (err) ->
        console.error "Connection to #{mongoUrl} failed", err

  connection = connections[mongoUrl]

  success = options.success
  error = options.error

  deferred = defer()

  # handle special mongo calls
  if options.mongo?.call
    call = options.mongo?.call
    console.log "Calling #{call} on #{mongoUrl}"
    connection.then (db) ->
      db[call] (err, result) ->
        if err
          error(err) if error
          deferred.reject err
        else
          success(result) if success
          deferred.resolve result
    return deferred

  collectionName = _.result model, 'url'

  if method == 'read'
    connection.then (db) ->
      db.collection collectionName, (err, collection) ->
        collection.find {}, { batchSize: 20 }, (err, cursor) ->
          console.log err, cursor
          if err
            error(err) if error
            deferred.reject err
          else
            success(cursor) if success
            deferred.resolve cursor 



_.extend(sync, Backbone.Events);

# sync.on 'mongo:connect', (url) ->
#   if typeof url == 'string'
#     url = new mb.Models.Connection url: url
  
#   Db.connect url.mongoUrl(), (err, db) ->
#     if err
#       connection.reject err
#     else
#       connection.resolve db

# connection.fail (err) ->
#   console.log 'failed', err

mb.sync = sync
