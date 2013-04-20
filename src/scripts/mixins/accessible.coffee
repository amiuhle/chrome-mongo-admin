mb.Mixins.Accessible =
  class:
    accessor: ->
      for attribute in arguments
        do (attribute) =>
          this::[attribute.toCamelCase()] = (value) ->
            if value? then @set(attribute, value) else @get(attribute)

  instance:
    accessible: true
