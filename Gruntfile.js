module.exports = function( grunt ) {
  'use strict';

  grunt.initConfig({

    browserify: {
      app: {
        src: ['scripts/app.js'],
        dest: 'app/scripts/bundle.js'
      },
      test: {
        src: 'scripts/test.js',
        dest: 'app/scripts/bundle.js'
        // ,
        // options: {
        //   globals: {
        //     process: 'browser-resolve/builtin/process',
        //     Buffer: 'buffer'
        //   }
        // }
      }
    }

  });

  grunt.loadNpmTasks('grunt-browserify');

};
