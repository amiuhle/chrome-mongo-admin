class ConnectionItem extends Backbone.View
  template: JST['src/templates/connection_list_item.hbs']
  tagName: 'li'
  events:
    'click a': -> mb.trigger 'connect', @model

  initialize: ->

  render: ->
    @$el.html(@template(this))
    this

  url: => @model.url()

class ConnectionList extends Backbone.View

  initialize: ->
    mb.on 'connect', @connect
    @ready = $.Deferred()
    @collection ?= new mb.Collections.Connections
    @collection.fetch().done(@ready.resolve)
    @listenTo @collection, 'sync', _.debounce @render, 100

  render: =>
    el = @$el.empty()
    console.log 'render list', arguments
    @collection.sort().each (item) ->
      view = new ConnectionItem model: item
      el.append view.render().el
    this

  connect: (url) =>
    if typeof url == 'string'
      url = new mb.Models.Connection url: url
    url.save()


class mb.Views.Header extends Backbone.View
  events:
    'submit form': 'submit'
  
  template: JST['src/templates/header.hbs']

  initialize: ->
    mb.on 'connect', @connect
    @render()

  render: ->
    @$el.html(@template(this))
    @urlInput = @$el.find('input')
    @connections = new ConnectionList el: @$el.find('ul#recent-connections')
    @connections.render()
    this

  submit: ->
    url = @urlInput.val()
    mb.trigger('connect', url) if url
    false

  connect: (url) =>
    url = url.url() if url instanceof mb.Models.Connection
    @urlInput.val(url)
