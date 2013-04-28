# mongodb = require('mongodb')
# Db = mongodb.Db

# class CollectionItem extends Backbone.View
#   @mixin mb.Mixins.Delegating
#   @delegate 'collection_name', 'count'

#   tagName: 'li'
#   className: 'collection-list-item'
#   template: JST['src/templates/collection_list_item.hbs']
#   events: 'click a': 'collection'

#   initialize: ->
#     @listenTo @model, 'all', @render

#   render: ->
#     @$el.html @template(this)
#     this

#   collectionName: =>
#     @model.get 'collectionName'

#   collection: =>
#     @$el.toggleClass 'active', true
#     @$el.siblings().toggleClass 'active', false
#     mb.sync.trigger 'mongo:collection', @model

# class MongoCollection extends Backbone.Model
#   @mixin mb.Mixins.Accessible
#   @accessor 'collection_name', 'count'

#   constructor: (collection) ->
#     super
#     @collectionName collection.collectionName
#     @count(false)
#     collection.count (err, result) => @count(result) unless err

# class CollectionList extends Backbone.View
#   tagName: 'ul'
#   className: 'nav nav-list'

#   initialize: ->
#     @collection ?= new Backbone.Collection
#     @listenTo @collection, 'change', _.debounce @render, 100

#   render: =>
#     el = @$el.empty()
#     @collection.each (item) ->
#       view = new CollectionItem model: item
#       el.append view.render().el
#     this

#   setCollections: (items) ->
#     @collection.reset()
#     items.forEach (item) =>
#       @collection.add new MongoCollection item


# class MongoObject extends Backbone.Model
#   @mixin mb.Mixins.Accessible
#   @accessor 'name', 'value'

#   class: -> if Object::toString.apply(@value()) == '[object Array]' then 'array' else typeof @value()
#   type: -> @value().constructor.name
  
#   isObject: -> @class() == 'object'

# class Document extends Backbone.VanillaJsObjects.Views.Array


# class QueryCollection extends Backbone.Collection

#   constructor: () ->


# class CollectionDetails extends Backbone.View

#   render: (err, collection) =>
#     throw err if err
#     return this unless collection
    
#     el = @$el.empty()
#     ul = $('<ul class="mongo-collection">')
#     el.append(ul)
    
#     cursor = collection.find({}, { limit: 10 })
#     cursor.each (err, item) ->
#       console.dir(item) if item
#       if item?
#         view = new Document inspect: item
#         ul.append(view.render().el)

#     this


# class mb.Views.Database extends Backbone.View

#   template: JST['src/templates/database.hbs']

#   initialize: ->
#     mb.on 'mongo:connect', @connect
#     mb.on 'mongo:collection', @collection
#     @collectionList = new CollectionList
#     @collectionDetails = new CollectionDetails

#   render: =>
#     @$el.html(@template())
#     @$el.find('#collection-list').html(@collectionList.render().el)
#     @$el.find('#collection-details').html(@collectionDetails.render().el)

#   connect: (url) =>
#     if typeof url == 'string'
#       url = new mb.Models.Connection url: url
#     Db.connect url.mongoUrl(), @onConnect

#   onConnect: (err, @db) =>
#     console.log err
#     throw err if err
#     # console.log 'success', @db
#     @render()
#     db.collections (err, items) =>
#       console.log err if err
#       @collectionList.setCollections items

#   collection: (collection) =>
#     collectionName = collection.get('collectionName')
#     # console.log 'collection', collectionName
#     @db.collection collectionName, @collectionDetails.render

ObjectID = require('mongodb').ObjectID

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

    _(@cursor.batchSizeValue).times =>
      nextObject = cursor.nextObject (err, item) => @add item if item
      console.log 'nextObject', nextObject
    return []


class mb.Views.Query extends Backbone.VanillaJsObjects.Views.Array 
  
  initialize: ->
    mb.sync.on 'mongo:query', @onQuery, this
    @collection = new mb.Collections.Cursor
    @listenTo @collection, 'add', @addOne

  onQuery: (query) ->
    @collection.urlRoot = query.urlRoot
    @collection.url = query.url
    @collection.fetch()

  render: ->
    console.log 'Query.render', arguments
    super

  addOne: (model) ->
    view = new Backbone.VanillaJsObjects.Views.Property({model: model});
    view.render();
    this.$el.append(view.el);
    model.on('remove', view.remove, view);

  
    

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