{FileReader} = require('../build/FileReader')
{FileWriter} = require('../build/FileWriter')
fs = require 'fs'
crc = require 'crc'
q = require 'q'
q.longStackSupport = true

readWrite = (test, testFile, testFileCopy, chunkSize) ->
  infileCrcPre = crc.crc32(fs.readFileSync(testFile, 'base64')).toString 16
  q(0).then () =>
    FileReader.create(testFile, chunkSize)
  .then (fileReader) =>
    [fileReader, FileWriter.create(testFileCopy)]
  .spread (fileReader, fileWriter) ->
    q.Promise (good, bad) ->
      read = () ->
        fileReader.readChunk()
        .then (chunk) ->
          if chunk.length > 0
            fileWriter.write chunk
            read()
          else
            fileWriter.close()
            .then () -> good()
            .done()
        .fail (err) ->
          bad err
      read()
  .then () =>
    try
      infileCrcPost = crc.crc32(fs.readFileSync(testFile, 'base64')).toString 16
      outfileCrc = crc.crc32(fs.readFileSync(testFileCopy, 'base64')).toString 16

      test.ok infileCrcPre == infileCrcPost, "Input file has changed! crc before: #{infileCrcPre} crc after: #{infileCrcPost}"
      test.ok infileCrcPost == outfileCrc, "File was modified while transfer crc before: #{infileCrcPost} crc after: #{outfileCrc}"
      fs.unlinkSync(testFileCopy)  if fs.exists(testFileCopy)
    catch err
      console.log 'err:', err
      test.done()
  .then () ->
    test.done()
  .fail (err) =>
    test.ok(false, 'We should never get here')
    fs.unlinkSync(testFileCopy) if fs.exists(@testFileCopy)
    test.done()
  .done()
 

module.exports =
  setUp: (callback) ->
    callback()
  tearDown: (callback) ->
    callback()
  readWriteBigFileChunkA: (test) ->
    readWrite test,  __dirname+'/testFile.jpg', __dirname+'/testFile.jpg~copy', 700
  readWriteSmallFileChunkA: (test) ->
    readWrite test, __dirname+'/testFile.txt', __dirname+'/testFile.txt~copy', 7 
  readWriteBigFileChunkB: (test) ->
    readWrite test, __dirname+'/testFile.jpg', __dirname+'/testFile.jpg~copy', 70
  readWriteSmallFileChunkB: (test) ->
    readWrite test, __dirname+'/testFile.txt', __dirname+'/testFile.txt~copy', 14





