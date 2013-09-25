# grunt-update
# https://github.com/osteele/grunt-contextualize
#
# Copyright (c) 2013 Oliver Steele
# Licensed under the MIT license.

fs = require 'fs'

module.exports = (grunt) ->
  _ = grunt.util._
  path = require 'path'
  description = grunt.file.readJSON(path.join(path.dirname(module.filename), '../package.json')).description

  class UndefinedTaskError extends Error
    constructor: (@task) ->

  #
  # File utilities
  #

  statSyncOrNull = (path) ->
    # exception instead of separate test, for unlikely race condition
    try
      fs.statSync(path)
    catch error
      throw error unless error.errno == 34 and error.code == 'ENOENT'
      return null

  # Returns true iff at least one `destFile` is older than at least one `srcFile`, or does not exist
  filesAreOutdated = (srcFiles, destFiles) ->
    newestSrcTime = Math.max((statSyncOrNull(path)?.mtime || -Infinity for path in srcFiles)...)
    return destFiles.some (path) ->
      (statSyncOrNull(path)?.mtime || -Infinity) < newestSrcTime

  #
  # Task Utilities
  #

  # from lib/grunt/task.js
  isValidMultiTaskTarget = (target) ->
    return !/^_|^options$/.test(target)

  # there doesn't seem to be a way to use the public API for this
  isMultiTask = (task) ->
    taskObject = grunt.task._tasks[task]
    return Boolean(taskObject?.multi)

  getTaskFiles = (task, target) ->
    return getMultiTaskFiles(task, target) if isMultiTask(task)
    config = grunt.config.getRaw(task)
    throw new UndefinedTaskError(task) unless config
    return grunt.task.normalizeMultiTaskFiles(config)

  getMultiTaskFiles = (task, target) ->
    target = null if target == '*'
    targets = if target then [target] else Object.keys(grunt.config.getRaw(task || {})).filter(isValidMultiTaskTarget)
    return _.flatten(targets.map (target) ->
      config = grunt.config.getRaw(_.compact([task, target]))
      throw new UndefinedTaskError(_.compact([task, target]).join(':')) unless config
      grunt.task.normalizeMultiTaskFiles(config))

  taskIsOutdated = (task) ->
    [task, target] = task.split(/:/)[0..1]
    files = getTaskFiles(task, target)
    return files.some ({src, dest}) -> filesAreOutdated(src, [dest])

  grunt.registerMultiTask 'update', description, ->
    try
      tasks = this.data.tasks
      outdatedTasks = tasks.filter(taskIsOutdated)
      grunt.task.run outdatedTasks
      return true
    catch e
      throw e unless e instanceof UndefinedTaskError
      grunt.fail.warn "Task \"#{e.task}\" not found."
      return false
