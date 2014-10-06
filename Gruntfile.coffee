module.exports = (grunt) ->

  grunt.initConfig
    notify:
      watch:
        options:
          message: 'Watcher is ready'
    notify_hooks: 
      options: 
        enabled: true
        max_jshint_notifications: 5 
    
    coffee:
      options:
        sourceMap: true
        bare: true
        force: true # needs to be added to the plugin
      all:
        expand: true
        cwd: 'src/'
        src: '**/*.coffee'
        dest: 'js'
        ext: '.js'
      modified:
        message: 'modified'
        expand: true
        cwd: 'src/'
        src: '**/*.coffee'
        dest: 'js'
        ext: '.js'

    coffeelint:
      options:
        force: true
      all:
        expand: true
        cwd: 'src'
        src: '**/*.coffee'
      modified:
        expand: true
        cwd: 'src'
        src: '**/*.coffee'
    nodeunit:
      all: ['test/**/*_test.coffee']

    watch:
      coffeescript:
        files: ['src/**/*.coffee']
        tasks: ['coffeelint:modified', 'coffee:modified']

  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-notify'
  grunt.loadNpmTasks 'grunt-contrib-nodeunit'
  grunt.task.run 'notify_hooks'
  grunt.registerTask 'default', ['notify','coffeelint:all', 'coffee:all', 'watch']
