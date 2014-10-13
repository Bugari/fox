{FileReader} = require('../build/FileReader')
{FileWriter} = require('../build/FileWriter')
fs = require 'fs'
crc = require 'crc'
q = require 'q'
q.longStackSupport = true

module.exports =
  setUp: (callback) ->
    @test_file = './test/test_file.txt'
    @test_file_copy = './test/test_file.txt~copy'
    callback()
  tearDown: (callback) ->
    callback()
  readWrite: (test) ->
    infileCrcPre = crc.crc32(fs.readFileSync(@test_file, 'base64')).toString 16
    q(0).then () =>
      FileReader.create(@test_file, 8)
    .then (fileReader) =>
      [fileReader, FileWriter.create(@test_file_copy)]
    .spread (fileReader, fileWriter) ->
      
      chunk = null
      while (chunk = fileReader.readChunk()) != null
        fileWriter.write chunk
      fileWriter.close()
    .then () =>
      try
        infileCrcPost = crc.crc32(fs.readFileSync(@test_file, 'base64')).toString 16
        outfileCrc = crc.crc32(fs.readFileSync(@test_file_copy, 'base64')).toString 16

        test.ok infileCrcPre == infileCrcPost, "Input file has changed! crc before: #{infileCrcPre} crc after: #{infileCrcPost}"
        test.ok infileCrcPost == outfileCrc, "File was modified while transfer crc before: #{infileCrcPost} crc after: #{outfileCrc}"
        fs.unlinkSync(@test_file_copy)  if fs.exists(@test_file_copy)
      catch err
        console.log 'err:', err
        test.done()

    .then () ->
      test.done()
    .catch (err) ->
      fs.unlinkSync(@test_file_copy)  if fs.exists(@test_file_copy)
      test.ok(false, 'We should never get here')
      test.done()
    .done()






