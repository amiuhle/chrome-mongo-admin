process.registerBinding('tcp_wrap', require('tcp_wrap-chromeify'));

window.onload = function() {
  var Db = require('mongodb').Db, 
    Connection = require('mongodb').Connection,
    Server = require('mongodb').Server,
    format = require('util').format;

  var host = '127.0.0.1';
  var port = Connection.DEFAULT_PORT;
  var options = {
    server: {
      socketOptions: {
        noDelay: true,
        keepAlive: 1000
      }
    }
  };

  console.log('Connecting to ' + host + ':' + port);
  Db.connect(format('mongodb://%s:%s/node-mongo-examples?w=1', host, port), options, function(err, db) {
    db.dropDatabase(function(err, result) {
      db.collection('test', function(err, collection) {
        // Erase all records from the collection, if any
        collection.remove({}, function(err, result) {
          // Insert 3 records
          for(var i = 0; i < 3; i++) {
            collection.insert({'a':i}, {w:0});
          }
          
          collection.count(function(err, count) {
            console.log("There are " + count + " records in the test collection. Here they are:");

            collection.find().each(function(err, item) {
              if(item != null) {
                console.dir(item);
                console.log("created at " + new Date(item._id.generationTime) + "\n")
              }

              // Null signifies end of iterator
              if(item == null) {                
                // Destory the collection
                collection.drop(function(err, collection) {
                  db.close();
                });
              }
            });
          });
        });      
      });
    });
  });
};