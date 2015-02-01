module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    karma:
      unit:
        configFile: 'karma.conf.js'

    coffee:
      compileWithMaps:
        options:
          # join: true
          sourceMap: true
        files:
          'temper.js': [
            'src/utils.coffee'
            'src/note.coffee'
            'src/interval.coffee'
            'src/collection.coffee'
            'src/chord.coffee'
            'src/scale.coffee'
            'src/temper.coffee'
            'src/playback.coffee'
          ]

    watch:
      tasks: ['coffee']
      files: [
          'src/*.coffee'
          # 'tests/*.coffee'
        ]

    uglify:
      my_target:
        files:
          'temper.min.js': ['temper.js']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-karma'
  grunt.registerTask 'default', ['coffee', 'uglify']
