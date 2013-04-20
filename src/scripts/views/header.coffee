class mb.Views.Header extends Backbone.View
  events:
    'submit form': 'connect'
  
  template: JST['src/templates/header.hbs']

  initialize: ->
    @render()

  render: ->
    @$el.html(@template(this))

  connect: ->
    console.log @$el.find('input').val()
    console.log 'connect!!!'
    false