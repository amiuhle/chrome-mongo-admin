require('process').registerBinding('tcp_wrap', require('tcp_wrap-chromeify'));

window.mb =
  Mixins: {}
  Models: {}
  Collections: {}
  Views: {}
  database:
    id: 'chrome-mongo-admin'
    migrations: [
      {
        version: 1
        migrate: (transaction, next) ->
          store = transaction.db.createObjectStore('connections')
          next()
      },
      {
        version: 2
        migrate: (transaction, next) ->
          store = transaction.objectStore 'connections'
          store.createIndex('urlIndex', 'url', { unique: true });
          next()
      }
    ]
  
  root: '/'
_.extend(window.mb, Backbone.Events);

class mb.App
  constructor: (@$el) ->
    @header = new mb.Views.Header el: @$el.find('header')
    @database = new mb.Views.Database el: @$el.find('#container')

$ ->
  console.log 'booting...'
  app = new mb.App($('#app'));

    # $header = $('header')
    # @header = new yb.Views.Header(el: $header)
    # @header.render()
    # @router = new yb.PageRouter(routes: yb.Routes, $el: @$el)
    # @$el.add($header).on 'click', 'a', (event) =>
    #   href = $(event.target).attr('href')
    #   if href.indexOf(yb.root) == 0
    #     href = href.substr(yb.root.length)
    #     event.preventDefault()
    #   yb.navigate href
    
    # if !Backbone.History.started
    #   Backbone.history.start pushState: true, root: mb.root


# $('#connect').submit ->
#   $this = $(this)
#   host = $this.find('[name=host]').val()
#   port = $this.find('[name=port]').val()
#   port = parseInt(port) or Connection.DEFAULT_PORT
#   database = $this.find('[name=database]').val()
#   console.log host, port, database

#   server = new Server host, port
#   connector = new Db database, server, { w: 0 }

#   connector.open (err, db) ->
#     throw err if err
#     window.db = db
#     db.collections (err, items) ->
#       ul = $('<ul>')
#       for collection in items
#         ul.append "<li><a>#{collection.collectionName}</a></li>"
#       $('#sidebar').html ul


#   false