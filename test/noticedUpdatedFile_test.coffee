grunt = require('grunt')

exports.noticedUpdatedFile =
  a2_replaced: (test) ->
    test.equal grunt.file.read('tmp/a2.txt'), "replaced\n", 'a2.txt should have been updated from the modified a.txt'
    test.done()
