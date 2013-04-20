String::toCamelCase = ->
  return this.replace /_(\w)/, (match, p1) ->
    return p1.toUpperCase();

mixin = (mixin) ->
  _.extend this, mixin.class if mixin.class?
  _.extend this.prototype, mixin.instance if mixin.instance?
Backbone.Model.mixin = mixin
Backbone.Collection.mixin = mixin
Backbone.View.mixin = mixin
Backbone.Router.mixin = mixin