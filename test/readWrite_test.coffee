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
    
    chunk = null
    while (chunk = fileReader.readChunk()) != null
      fileWriter.write chunk
    fileWriter.close()
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
  .catch (err) ->
    fs.unlinkSync(testFileCopy) if fs.exists(@testFileCopy)
    test.ok(false, 'We should never get here')
    test.done()
  .done()

module.exports =
  setUp: (callback) ->
    callback()
  tearDown: (callback) ->
    callback()
  readWriteBigFileChunkA: (test) ->
    readWrite test, './test/testFile.jpg', './test/testFile.jpg~copy', 7
  readWriteSmallFileChunkA: (test) ->
    readWrite test, './test/testFile.txt', './test/testFile.txt~copy', 7
  readWriteBigFileChunkB: (test) ->
    readWrite test, './test/testFile.jpg', './test/testFile.jpg~copy', 49
  readWriteSmallFileChunkB: (test) ->
    readWrite test, './test/testFile.txt', './test/testFile.txt~copy', 49





