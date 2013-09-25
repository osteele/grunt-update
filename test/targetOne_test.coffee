grunt = require('grunt')

exports.oneTarget =
  a_exists: (test) ->
    test.equal grunt.file.exists('tmp/a.txt'), true, 'should copy a.txt'
    test.done()

  b_doesnt_exist: (test) ->
    test.equal grunt.file.exists('tmp/b.txt'), false, 'should not copy b.txt'
    test.done()
