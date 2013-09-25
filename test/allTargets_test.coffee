grunt = require('grunt')

exports.allTargets =
  files_exist: (test) ->
    test.equal grunt.file.exists('tmp/a.txt'), true, 'should copy a.txt'
    test.equal grunt.file.exists('tmp/b.txt'), true, 'should copy b.txt'
    test.done()
