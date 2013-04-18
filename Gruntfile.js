module.exports = function( grunt ) {
  'use strict';

  grunt.initConfig({

    browserify: {
      all: {
        src: ['scripts/app.js'],
        dest: 'app/scripts/bundle.js'
      },
      test: {
        src: 'scripts/test.js',
        dest: 'app/scripts/bundle.js'
      }
    }

  });

  grunt.loadNpmTasks('grunt-browserify');

};
