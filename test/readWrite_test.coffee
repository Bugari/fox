{FileReader} = require('../build/FileReader')
fs = require 'fs'

module.exports =
  setUp: (callback) ->
    callback()
  tearDown: (callback) ->
    callback()
  test1: (test) ->
    FileReader.create('./test/test_file.bin', 5).then (fileReader) ->
      chunk = null
      count = 0
      while (chunk = fileReader.readChunk()) != null
        count++
      console.log('count:', count)
      test.ok(count == 10, "weird chunk count O.o")
      test.done()
