class mb.Collections.Connections extends Backbone.Collection
  model: mb.Models.Connection
  
  database: mb.database
  storeName: 'connections'

  comparator: (model) -> model.get('updated_at') * -1