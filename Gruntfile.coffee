# grunt-update
# https://github.com/osteele/grunt-contextualize
#
# Copyright (c) 2013 Oliver Steele
# Licensed under the MIT license.

fs =require 'fs'

module.exports = (grunt) ->
  grunt.initConfig
    coffeelint:
      all: ['**/*.coffee', '!node_modules/**/*']
      options:
        max_line_length: { value: 120 }

    clean:
      files: 'tmp'

    copy:
      one:
        files: {'tmp/a.txt': 'test/files/a.txt'}
      two:
        expand: true
        cwd: 'test/files'
        src: '*'
        dest: 'tmp'
        filter: 'isFile'
      chainedCopy:
        files: {'tmp/a2.txt': 'tmp/a.txt'}

    nodeunit:
      targetOne: 'test/targetOne_test.coffee'
      allTargets: 'test/allTargets_test.coffee'
      noticedUpdatedFile: 'test/noticedUpdatedFile_test.coffee'

    update:
      targetOne:
        tasks: ['copy:one']
      chainedCopy:
        tasks: ['copy:chainedCopy']
      allTargets:
        tasks: ['copy']
      starTarget:
        tasks: ['copy:*']
      undefinedTask:
        tasks: ['undefinedTask']
      undefinedTarget:
        tasks: ['copy:undefinedTarget']

  grunt.loadTasks 'tasks'

  require('load-grunt-tasks')(grunt)

  grunt.registerTask 'replaceIntermediateFile', ->
    path = 'tmp/a.txt'
    grunt.file.write path, "replaced\n"
    stats = fs.statSync(path)
    console.info path, stats.atime, stats.mtime, typeof stats.mtime
    fs.utimesSync path, stats.atime, stats.mtime.getTime() / 1000 + 1
    stats = fs.statSync(path)
    console.info path, stats.atime, stats.mtime

  grunt.registerTask 'test', [
    'clean', 'update:targetOne', 'nodeunit:targetOne',
    'clean', 'update:allTargets', 'nodeunit:allTargets',
    'clean', 'update:starTarget', 'nodeunit:allTargets',
    'clean', 'copy:one', 'copy:chainedCopy', 'replaceIntermediateFile', 'update:chainedCopy', 'nodeunit:noticedUpdatedFile',
  ]
  grunt.registerTask 'default', ['coffeelint']
