mb.Mixins.Delegating =
  class:
    delegate: ->
      for attribute in arguments
        do (attribute) =>
          this::[attribute.toCamelCase()] = ->
            @model[attribute]()