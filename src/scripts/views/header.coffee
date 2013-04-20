class mb.Views.Header extends Backbone.View
  template: JST['src/templates/header.hbs']

  initialize: ->
    @render()

  render: ->
    @$el.html(@template(this))