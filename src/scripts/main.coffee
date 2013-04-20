require('process').registerBinding('tcp_wrap', require('tcp_wrap-chromeify'));

Db = require('mongodb').Db
format = require('util').format

$('#connect').submit ->
  console.log $(this).serialize()