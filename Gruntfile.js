module.exports = function( grunt ) {
  'use strict';

  grunt.initConfig({

    browserify: {
      app: {
        src: ['scripts/app.js'],
        dest: 'app/scripts/bundle.js',
        ignore: 'node_modules/browser-resolve/node_modules/buffer-browserify/index.js',
        options: {
          globals: {
            process: 'browser-resolve/builtin/process',
            Buffer: 'buffer-browserify'
          }
        }
      },
      test: {
        src: 'scripts/test.js',
        dest: 'app/scripts/bundle.js',
        ignore: 'node_modules/browser-resolve/node_modules/buffer-browserify/index.js',
        options: {
          globals: {
            process: 'browser-resolve/builtin/process',
            Buffer: 'buffer-browserify'
          }
        }
      }
    }

  });

  grunt.loadNpmTasks('grunt-browserify');

};
