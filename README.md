# chrome-mongo-admin

Manage your MongoDBs from Chrome!

## Contributing

To build the code, you need to install grunt and bower:

```
    npm install -g grunt-cli bower 
```

After cloning, install the required dependencies with

```
    npm install & bower install
```

Then you have to run `grunt init` once to build the required libraries into `app/scripts/vendor/bundle.js`.

After that, you can start a development by running

```
    grunt server
```

This will start a server and open a new browser window, while compiling coffee script and sass in the background. Of course, opening Chrome Mongo Admin in the browser is only good for layout styling and coding stuff that doesn't deal with `chrome.*` APIs.

To test the full app, open `app` as an unpackaged app.

## Insights

I [ported the mongodb NodeJS driver](https://github.com/amiuhle/mongodb-browserify) using 
[browserify](https://github.com/substack/node-browserify) and 
[browser-resolve](https://github.com/shtylman/node-browser-resolve).

The underlying Socket IO is done with a [port of NodeJS's net package](https://github.com/amiuhle/net-chromeify),
which uses [dns-chromeify](https://github.com/amiuhle/dns-chromeify) and [tcp_wrap-chromeify](https://github.com/amiuhle/tcp_wrap-chromeify),
a Chrome App specific implementation of `process.binding('tcp_wrap')`

