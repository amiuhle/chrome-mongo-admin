mongodb = require('mongodb')
Db = mongodb.Db

class CollectionItem extends Backbone.View
  @mixin mb.Mixins.Delegating
  @delegate 'collection_name', 'count'

  tagName: 'li'
  className: 'collection-list-item'
  template: JST['src/templates/collection_list_item.hbs']
  events: 'click a': 'collection'

  initialize: ->
    @listenTo @model, 'all', @render

  render: ->
    @$el.html @template(this)
    this

  collectionName: =>
    @model.get 'collectionName'

  collection: =>
    @$el.toggleClass 'active', true
    @$el.siblings().toggleClass 'active', false
    mb.trigger 'collection', @model

class MongoCollection extends Backbone.Model
  @mixin mb.Mixins.Accessible
  @accessor 'collection_name', 'count'

  constructor: (collection) ->
    super
    @collectionName collection.collectionName
    @count(false)
    collection.count (err, result) => @count(result) unless err

class CollectionList extends Backbone.View
  tagName: 'ul'
  className: 'nav nav-list'

  initialize: ->
    @collection ?= new Backbone.Collection
    @listenTo @collection, 'change', _.debounce @render, 100

  render: =>
    el = @$el.empty()
    @collection.each (item) ->
      view = new CollectionItem model: item
      el.append view.render().el
    this

  setCollections: (items) ->
    @collection.reset()
    items.forEach (item) =>
      @collection.add new MongoCollection item


class MongoObject extends Backbone.Model
  @mixin mb.Mixins.Accessible
  @accessor 'name', 'value'

  class: -> if Object::toString.apply(@value()) == '[object Array]' then 'array' else typeof @value()
  type: -> @value().constructor.name
  
  isObject: -> @class() == 'object'

class Document extends Backbone.View
  tagName: 'li'
  className: 'mongo-document mongo-object'
  template: JST['src/templates/document.hbs']

  constructor: (@document) ->
    @collection = new Backbone.Collection
    @collection.reset (@modelify property for property of @document)
    super

  modelify: (property) ->
    value = @document[property]
    new MongoObject
      name: property
      value: value

  render: ->
    el = @$el.empty()
    ul = $('<ul class="mongo-properties">')
    el.append(ul)
    @collection.each (model) =>
      ul.append(@template(model))
    this


class CollectionDetails extends Backbone.View

  render: (err, collection) =>
    throw err if err
    el = @$el.empty()
    ul = $('<ul class="mongo-collection">')
    el.append(ul)
    collection?.find().each (err, item) ->
      console.dir(item) if item
      if item?
        view = new Document item
        ul.append(view.render().el)
    this


class mb.Views.Database extends Backbone.View

  template: JST['src/templates/database.hbs']

  initialize: ->
    mb.on 'connect', @connect
    mb.on 'collection', @collection
    @collectionList = new CollectionList
    @collectionDetails = new CollectionDetails

  render: =>
    @$el.html(@template())
    @$el.find('#collection-list').html(@collectionList.render().el)
    @$el.find('#collection-details').html(@collectionDetails.render().el)

  connect: (url) =>
    if typeof url == 'string'
      url = new mb.Models.Connection url: url
    Db.connect url.mongoUrl(), @onConnect

  onConnect: (err, @db) =>
    throw err if err
    # console.log 'success', @db
    @render()
    db.collections (err, items) =>
      @collectionList.setCollections items

  collection: (collection) =>
    collectionName = collection.get('collectionName')
    # console.log 'collection', collectionName
    @db.collection collectionName, @collectionDetails.render


