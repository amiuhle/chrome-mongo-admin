'use strict';
var lrSnippet = require('grunt-contrib-livereload/lib/utils').livereloadSnippet;
var mountFolder = function (connect, dir) {
  return connect.static(require('path').resolve(dir));
};

// # Globbing
// for performance reasons we're only matching one level down:
// 'test/spec/{,*/}*.js'
// use this if you want to match all subfolders:
// 'test/spec/**/*.js'

module.exports = function (grunt) {
  // load all grunt tasks
  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);

  // configurable paths
  var yeomanConfig = {
    app: 'app',
    dist: 'dist',
    src: 'src'
  };

  grunt.initConfig({
    yeoman: yeomanConfig,
    watch: {
      coffee: {
        files: ['<%= yeoman.src %>/scripts/{,*/}*.coffee'],
        tasks: ['coffee:dist']
      },
      coffeeTest: {
        files: ['test/spec/{,*/}*.coffee'],
        tasks: ['coffee:test']
      },
      compass: {
        files: ['<%= yeoman.src %>/styles/{,*/}*.{scss,sass}'],
        tasks: ['compass']
      },
      livereload: {
        files: [
          '<%= yeoman.app %>/*.html',
          '<%= yeoman.app %>/styles/{,*/}*.css',
          '<%= yeoman.app %>/scripts/{,*/}*.js',
          '<%= yeoman.app %>/images/{,*/}*.{png,jpg,jpeg,gif,webp}'
        ],
        tasks: ['livereload']
      },
      handlebars: {
        files: [
          '<%= yeoman.src %>/templates/*.hbs'
        ],
        tasks: ['handlebars']
      }
    },
    connect: {
      options: {
        port: 9000,
        // change this to '0.0.0.0' to access the server from outside
        hostname: 'localhost'
      },
      livereload: {
        options: {
          middleware: function (connect) {
            return [
              lrSnippet,
              // mountFolder(connect, '.tmp'),
              mountFolder(connect, 'app')
            ];
          }
        }
      },
      test: {
        options: {
          middleware: function (connect) {
            return [
              // mountFolder(connect, '.tmp'),
              mountFolder(connect, 'test')
            ];
          }
        }
      },
      dist: {
        options: {
          middleware: function (connect) {
            return [
              mountFolder(connect, 'dist')
            ];
          }
        }
      }
    },
    open: {
      server: {
        path: 'http://localhost:<%= connect.options.port %>'
      }
    },
    clean: {
      dist: ['.tmp', '<%= yeoman.dist %>/*'],
      server: '.tmp'
    },
    jshint: {
      options: {
        jshintrc: '.jshintrc'
      },
      all: [
        'Gruntfile.js',
        '<%= yeoman.src %>/scripts/{,*/}*.js',
        '!<%= yeoman.src %>/scripts/vendor/*',
        'test/spec/{,*/}*.js'
      ]
    },
    coffee: {
      dist: {
        files: [{
          // rather than compiling multiple files here you should
          // require them into your main .coffee file
          expand: true,
          cwd: '<%= yeoman.src %>/scripts',
          src: '{,*/}*.coffee',
          dest: 'app/scripts',
          ext: '.js'
        }]
      },
      test: {
        files: [{
          expand: true,
          cwd: 'test/spec',
          src: '{,*/}*.coffee',
          dest: '.tmp/spec',
          ext: '.js'
        }]
      }
    },
    compass: {
      options: {
        sassDir: '<%= yeoman.src %>/styles',
        cssDir: 'app/styles',
        imagesDir: '<%= yeoman.app %>/images',
        javascriptsDir: '<%= yeoman.app %>/scripts',
        fontsDir: '<%= yeoman.app %>/styles/fonts',
        importPath: 'app/components',
        relativeAssets: true
      },
      dist: {},
      server: {
        options: {
          debugInfo: true
        }
      }
    },
    uglify: {
      dist: {
        files: {
          '<%= yeoman.dist %>/scripts/main.js': [
            '<%= yeoman.app %>/scripts/{,*/}*.js'
          ],
        }
      }
    },
    useminPrepare: {
      html: '<%= yeoman.app %>/index.html',
      options: {
        dest: '<%= yeoman.dist %>'
      }
    },
    usemin: {
      html: ['<%= yeoman.dist %>/{,*/}*.html'],
      css: ['<%= yeoman.dist %>/styles/{,*/}*.css'],
      options: {
        dirs: ['<%= yeoman.dist %>']
      }
    },
    imagemin: {
      dist: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>/images',
          src: '{,*/}*.{png,jpg,jpeg}',
          dest: '<%= yeoman.dist %>/images'
        }]
      }
    },
    cssmin: {
      dist: {
        files: {
          '<%= yeoman.dist %>/styles/main.css': [
            '.tmp/styles/{,*/}*.css',
            '<%= yeoman.app %>/styles/{,*/}*.css'
          ]
        }
      }
    },
    htmlmin: {
      dist: {
        options: {
          /*removeCommentsFromCDATA: true,
          // https://github.com/yeoman/grunt-usemin/issues/44
          //collapseWhitespace: true,
          collapseBooleanAttributes: true,
          removeAttributeQuotes: true,
          removeRedundantAttributes: true,
          useShortDoctype: true,
          removeEmptyAttributes: true,
          removeOptionalTags: true*/
        },
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>',
          src: '*.html',
          dest: '<%= yeoman.dist %>'
        }]
      }
    },
    copy: {
      dist: {
        files: [{
          expand: true,
          dot: true,
          cwd: '<%= yeoman.app %>',
          dest: '<%= yeoman.dist %>',
          src: [
            '_locales/**/*.json',
            'manifest.json',
            'main.js',
            '*.{ico,txt}',
            'images/{,*/}*.{webp,gif}'
          ]
        }]
      }
    },
    bower: {
      all: {
        rjsConfig: '<%= yeoman.app %>/scripts/main.js'
      }
    },
    handlebars: {
      compile: {
        options: {
          namespace: 'JST'
        },
        files: {
          '<%= yeoman.app %>/scripts/templates.js': '<%= yeoman.src %>/templates/*.hbs'
          // "path/to/another.js": ["path/to/sources/*.hbs", "path/to/more/*.hbs"]
        }
      }
    },
    browserify: {
      bundle: {
        src: [], //['src/scripts/app.js'],
        require: ['mongodb', 'tcp_wrap-chromeify'],
        dest: 'app/scripts/vendor/bundle.js',
        ignore: 'node_modules/browser-resolve/node_modules/buffer-browserify/index.js',
        options: {
          globals: {
            process: 'browser-resolve/builtin/process',
            Buffer: 'buffer-browserify'
          }
        }
      }
    },
    jasmine: {
      test: {
        src: [
          '<%= yeoman.app %>/scripts/{,*/}*.js',
          '!<%= yeoman.app %>/scripts/vendor/*',
          '!<%= yeoman.app %>/scripts/app.js'
        ],
        options: {
          vendor: [
            'test/shims.js',
            // '<%= yeoman.app %>/scripts/vendor/*.js',
            '<%= yeoman.app %>/components/jquery/jquery.js',
            '<%= yeoman.app %>/components/underscore/underscore.js',
            '<%= yeoman.app %>/components/backbone/backbone.js',
            '<%= yeoman.app %>/components/indexeddb-backbonejs-adapter/backbone-indexeddb.js',
            '<%= yeoman.app %>/components/handlebars/handlebars.runtime.js'
          ],
          helpers: [
            'test/helpers/*.js'
          ],
          specs: ['{test,.tmp}/{spec,fixtures}/{,*/}*.js']
        }
      },
      chrome: {

      },
    },
  });

  grunt.renameTask('regarde', 'watch');

  grunt.registerTask('init', [
    'browserify:bundle'
  ]);

  grunt.registerTask('app', [
    'coffee:dist',
    'handlebars',
    'compass:server'
  ]);

  grunt.registerTask('server', [
    'clean:server',
    'app',
    'livereload-start',
    'connect:livereload',
    // 'open',
    'watch'
  ]);

  grunt.registerTask('test', [
    'clean:server',
    'coffee',
    'handlebars',
    // 'compass',
    'jasmine:test',
    // 'watch'
    // 'jasmine:chrome:build'
  ]);

  grunt.registerTask('build', [
    'clean:dist',
    'coffee',
    'handlebars',
    'compass:dist',
    'useminPrepare',
    'imagemin',
    'htmlmin',
    'concat',
    'cssmin',
    'uglify',
    'copy:dist',
    'usemin'
  ]);

  grunt.registerTask('dist', [
    'browserify:bundle',
    'jshint',
    // 'test',
    'build'
  ]);

  // grunt.registerTask('default', [
  //   'browserify:bundle',
  //   'app'
  // ]);
};