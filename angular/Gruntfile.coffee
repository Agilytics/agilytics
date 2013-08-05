"use strict"
proxySnippet = require("grunt-connect-proxy/lib/utils").proxyRequest
lrSnippet = require("grunt-contrib-livereload/lib/utils").livereloadSnippet
mountFolder = (connect, dir) ->
  connect.static require("path").resolve(dir)

module.exports = (grunt) ->

  # load all grunt tasks
  require("matchdep").filterDev("grunt-*").forEach grunt.loadNpmTasks

  # configurable paths
  yeomanConfig =
    app: "app"
    dist: "dist"


  try
    yeomanConfig.app = require("./component.json").appPath or yeomanConfig.app

  grunt.initConfig
    yeoman: yeomanConfig

    watch:
      haml:
        files: ["**/*.haml"]
        tasks: ["haml:dist"]
        options:
          spawn: false

      coffee:
        files: ["**/*.coffee"]
        tasks: ["coffee:dist"]
        options:
          spawn: false

      coffeeTest:
        files: ["test/**/*.coffee"]
        tasks: ["coffee:test"]
        options:
          spawn: false

      compass:
        files: ["**/*.scss", "**/*.sass"]
        tasks: ["compass"]
        options:
          spawn: false

      livereload:
        files: [".tmp/**/*{.html,css,js,png,jpg,jpeg,gif,webp,svg}"]
        tasks: ["livereload"]
        options:
          spawn: false

    connect:
      options:
        port: 9000

        # Change this to '0.0.0.0' to access the server from outside.
        hostname: "localhost"

      proxies: [
        context: "/api"
        host: "localhost"
        port: 3000
        https: false
        changeOrigin: false
      ]
      livereload:
        options:
          middleware: (connect) ->
            [proxySnippet, lrSnippet, mountFolder(connect, ".tmp"), mountFolder(connect, yeomanConfig.app)]

      test:
        options:
          middleware: (connect) ->
            [mountFolder(connect, ".tmp"), mountFolder(connect, "test")]

    open:
      server:
        url: "http://localhost:<%= connect.options.port %>"

    clean:
      dist:
        files: [
          dot: true
          src: [".tmp", "<%= yeoman.dist %>/*", "!<%= yeoman.dist %>/.git*"]
        ]

      server: ".tmp"

    jshint:
      options:
        jshintrc: ".jshintrc"

      all: ["Gruntfile.js", "<%= yeoman.app %>/scripts/{,*/}*.js"]

    karma:
      unit:
        configFile: "karma.conf.js"
        singleRun: true

    coffee:
      dist:
        files: [
          expand: true
          cwd: "<%= yeoman.app %>/scripts"
          src: "{,*/}*.coffee"
          dest: ".tmp/scripts"
          ext: ".js"
        ]

      test:
        files: [
          expand: true
          cwd: "test/spec"
          src: "{,*/}*.coffee"
          dest: ".tmp/spec"
          ext: ".js"
        ]

    haml:
      options:
        language: "ruby"

      dist:
        files: [
          expand: true
          cwd: "<%= yeoman.app %>/views"
          src: "*.haml"
          dest: ".tmp/views"
          ext: ".html"
        ,
          expand: true
          cwd: "<%= yeoman.app %>/views/directives"
          src: "*.haml"
          dest: ".tmp/views/directives/"
          ext: ".html"
        ,
          expand: true
          cwd: "<%= yeoman.app %>/"
          src: "*.haml"
          dest: ".tmp/"
          ext: ".html"
        ]

    compass:
      options:
        sassDir: "<%= yeoman.app %>/styles"
        cssDir: ".tmp/styles"
        imagesDir: "<%= yeoman.app %>/images"
        javascriptsDir: "<%= yeoman.app %>/scripts"
        fontsDir: "<%= yeoman.app %>/styles/fonts"
        importPath: "<%= yeoman.app %>/components"
        relativeAssets: true

      dist: {}
      server:
        options:
          debugInfo: true

    concat:
      dist:
        files:
          "<%= yeoman.dist %>/scripts/scripts.js": [".tmp/scripts/{,*/}*.js", "<%= yeoman.app %>/scripts/{,*/}*.js"]

    useminPrepare:
      html: "<%= yeoman.app %>/index.html"
      options:
        dest: "<%= yeoman.dist %>"

    usemin:
      html: ["<%= yeoman.dist %>/{,*/}*.html"]
      css: ["<%= yeoman.dist %>/styles/{,*/}*.css"]
      options:
        dirs: ["<%= yeoman.dist %>"]

    imagemin:
      dist:
        files: [
          expand: true
          cwd: "<%= yeoman.app %>/images"
          src: "{,*/}*.{png,jpg,jpeg}"
          dest: "<%= yeoman.dist %>/images"
        ]

    cssmin:
      dist:
        files:
          "<%= yeoman.dist %>/styles/main.css": [".tmp/styles/{,*/}*.css", "<%= yeoman.app %>/styles/{,*/}*.css"]

    htmlmin:
      dist:
        options: {}

        #removeCommentsFromCDATA: true,
        #          // https://github.com/yeoman/grunt-usemin/issues/44
        #          //collapseWhitespace: true,
        #          collapseBooleanAttributes: true,
        #          removeAttributeQuotes: true,
        #          removeRedundantAttributes: true,
        #          useShortDoctype: true,
        #          removeEmptyAttributes: true,
        #          removeOptionalTags: true
        files: [
          expand: true
          cwd: "<%= yeoman.app %>"
          src: ["*.html", "views/*.html"]
          dest: "<%= yeoman.dist %>"
        ]

    cdnify:
      dist:
        html: ["<%= yeoman.dist %>/*.html"]

    ngmin:
      dist:
        files: [
          expand: true
          cwd: "<%= yeoman.dist %>/scripts"
          src: "*.js"
          dest: "<%= yeoman.dist %>/scripts"
        ]

    uglify:
      dist:
        files:
          "<%= yeoman.dist %>/scripts/scripts.js": ["<%= yeoman.dist %>/scripts/scripts.js"]

    rev:
      dist:
        files:
          src: ["<%= yeoman.dist %>/scripts/{,*/}*.js", "<%= yeoman.dist %>/styles/{,*/}*.css", "<%= yeoman.dist %>/images/{,*/}*.{png,jpg,jpeg,gif,webp,svg}", "<%= yeoman.dist %>/styles/fonts/*"]

    copy:
      dist:
        files: [
          expand: true
          dot: true
          cwd: "<%= yeoman.app %>"
          dest: "<%= yeoman.dist %>"
          src: ["*.{ico,txt}", ".htaccess", "components/**/*", "img/{,*/}*.{gif,webp}", "styles/fonts/*", "cubes/*"]
        ]

  grunt.event.on "watch", (action, filepath) ->

    if grunt.file.isMatch(grunt.config("watch.haml.files"), filepath)
      filepath = filepath.replace(grunt.config("haml.all.cwd") + "/", "")
      grunt.config "haml.all.src", filepath

    if grunt.file.isMatch(grunt.config("watch.coffee.files"), filepath)
      filepath = filepath.replace(grunt.config("coffee.all.cwd") + "/", "")
      grunt.config "coffee.all.src", filepath

  grunt.renameTask "regarde", "watch"
  grunt.registerTask "server", ["clean:server", "coffee:dist", "copy:dist", "haml:dist", "compass:server", "configureProxies", "livereload-start", "connect:livereload", "open", "watch"]
  grunt.registerTask "test", ["clean:server", "coffee", "haml", "compass", "connect:test", "karma"]
  grunt.registerTask "build", ["clean:dist", "jshint", "test", "coffee", "compass:dist", "useminPrepare", "imagemin", "cssmin", "htmlmin", "concat", "copy", "cdnify", "ngmin", "uglify", "rev", "usemin"]
  grunt.registerTask "default", ["build"]