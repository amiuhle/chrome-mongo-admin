ObjectID = require('mongodb').ObjectID

ObjectID::inspect = ->
  @toString()

class mb.Models.MongoCollection extends Backbone.Model
  @mixin mb.Mixins.Accessible
  @accessor 'collectionName', 'count'

  constructor: (@mongoCollection, options) ->
    attributes =
      collectionName: @mongoCollection.collectionName
    @mongoCollection.count (err, result) => @count(result) unless err
    @urlRoot = options.collection.urlRoot
    @url = attributes.collectionName
    super attributes, options

class mb.Collections.MongoCollections extends Backbone.Collection
  model: mb.Models.MongoCollection
  sync: mb.sync

class mb.Views.MongoCollection extends Backbone.View
  @mixin mb.Mixins.Delegating
  @delegate 'collectionName', 'count'
  tagName: 'li'

  className: 'collection-list-item'
  template: JST['src/templates/collection_list_item.hbs']
  events: 'click a': 'click'

  initialize: ->
    @model.on 'all', @render, this

  render: ->
    @$el.html(@template(this))

  click: ->
    mb.sync.trigger 'mongo:query', @model


class mb.Views.MongoCollections extends Backbone.View
  tagName: 'ul'

  initialize: ->
    mb.sync.on 'mongo:connect', @onConnect, this
    @collection = new mb.Collections.MongoCollections
    @listenTo @collection, 'all', @render

  onConnect: (url) ->
    if typeof url == 'string'
      url = new mb.Models.Connection url: url
    @collection.urlRoot = url.mongoUrl()
    @collection.fetch 
      mongo:
        call: 'collections'

  render: ->
    console.log('render collection list')
    @$el.empty()
    @collection.each @addOne, this

  addOne: (model) ->
    view = new mb.Views.MongoCollection model: model
    view.render()
    @$el.append(view.$el)
    model.on 'remove', view.remove, view

# class mb.Collections.Document extends Backbone.VanillaJsObjects.Object
#   sync: mb.sync

#   constructor: (@document, options) ->
#     console.log 'Document', @document, options

class mb.Models.Document extends Backbone.VanillaJsObjects.Property

  constructor: (attributes, options) ->
    console.log 'Document', attributes
    super value: attributes, options

class mb.Collections.Cursor extends Backbone.VanillaJsObjects.Array
  sync: mb.sync
  model: mb.Models.Document

  parse: (@cursor) ->
    cursor.each (err, item) => @add item if item
    return []


class mb.Views.Query extends Backbone.VanillaJsObjects.Views.Array
  
  initialize: ->
    mb.sync.on 'mongo:query', @onQuery, this
    @collection = new mb.Collections.Cursor
    @paginator = new mb.Views.QueryPaginator collection: @collection
    @listenTo @collection, 'add', @addOne

  onQuery: (query) ->
    @collection.urlRoot = query.urlRoot
    @collection.url = query.url
    @collection.fetch()

  render: ->
    console.log 'Query.render', arguments
    super
    @$el.append(@paginator.render().el)

  addOne: (model) ->
    view = new Backbone.VanillaJsObjects.Views.Property({model: model});
    view.render();
    this.$el.append(view.el);
    model.on('remove', view.remove, view);

class mb.Views.QueryPaginator extends Backbone.View

  template: JST['src/templates/query_paginator.hbs']

  render: ->
    @template(this)
    

class mb.Views.Database extends Backbone.View

  template: JST['src/templates/database.hbs']

  initialize: (models, options) ->
    @collectionList = new mb.Views.MongoCollections
    @query = new mb.Views.Query
    @render()

  render: =>
    console.log 'render'
    @$el.html(@template())
    @collectionList.setElement(@$el.find('#collection-list'))
    @$el.find('#collection-details').html @query.el