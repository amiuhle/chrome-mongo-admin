class ConfirmDialog extends Backbone.View
  events:
    'click .close': 'reject'
    'click .cancel': 'reject'
    'click .confirm': 'resolve'

  template: JST['src/templates/dialog_confirm.hbs']

  initialize: ->
    @header = @options.header
    @body = @options.body
    @cancel = @options.cancel or "Cancel"
    @confirm = @options.confirm or "OK"
    @ready = $.Deferred()
    @render()

  render: ->
    @setElement @template(this)
    @$el.modal('show')
    this

  reject: =>
    @$el.modal('hide')
    @ready.reject()
  resolve: =>
    @$el.modal('hide')
    @ready.resolve()


class ConnectionItem extends Backbone.View
  template: JST['src/templates/connection_list_item.hbs']
  tagName: 'li'
  events:
    'click a': -> mb.trigger 'connect', @model
    'click .icon-trash': 'delete'

  initialize: ->

  render: ->
    @$el.html(@template(this))
    this

  url: => @model.url()

  delete: =>
    dlg = new ConfirmDialog
      header: "Delete Connection"
      body: "Delete saved Connection <code>mongodb://#{@url()}</code>?"
    .ready.then =>
      @model.destroy()
    false

class ConnectionList extends Backbone.View

  initialize: ->
    mb.on 'connect', @connect
    @ready = $.Deferred()
    @collection ?= new mb.Collections.Connections
    @collection.fetch().done(@ready.resolve)
    rate_limit = _.debounce @render, 100
    ['sync', 'remove', 'add'].forEach (e) => @listenTo @collection, e, rate_limit

  render: =>
    el = @$el.empty()
    @collection.sort().each (item) ->
      view = new ConnectionItem model: item
      el.append view.render().el
    this

  connect: (url) =>
    if typeof url == 'string'
      url = new mb.Models.Connection url: url
    url.save()
    @collection.add url


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

  submit: (e) ->
    e.preventDefault()
    url = @urlInput.val()
    mb.trigger('connect', url) if url
    false

  connect: (url) =>
    url = url.url() if url instanceof mb.Models.Connection
    @urlInput.val(url)
