class mb.Models.Connection extends Backbone.Model
  @mixin mb.Mixins.Accessible
  @accessor 'url'
  
  database: mb.database
  storeName: 'connections'

  updatedAt: (value) ->
    if value instanceof Date then @set('updated_at', value.getTime()) else new Date(@get('updated_at'))

  save: ->
    @updatedAt(new Date())
    super

  mongoUrl: -> "mongodb://#{@url()}?w=0"

  toString: -> @url()