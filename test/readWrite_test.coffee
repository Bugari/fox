chai = require 'chai'
chai.should()

{FileReader} = require('../build/FileReader')
{FileWriter} = require('../build/FileWriter')
fs = require 'fs'
crc = require 'crc'
require('../src/registerGlobals')

readWrite = (done, testFile, testFileCopy, chunkSize) ->
  infileCrcPre = crc.crc32(fs.readFileSync(testFile, 'base64')).toString 16
  Q(0).then () ->
    FileReader.create(testFile, chunkSize)
  .then (fileReader) ->
    [fileReader, FileWriter.create(testFileCopy)]
  .spread (fileReader, fileWriter) ->
    Q.Promise (good, bad) ->
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
  .then () ->
    infileCrcPost = crc.crc32(fs.readFileSync(testFile, 'base64')).toString 16
    outfileCrc = crc.crc32(fs.readFileSync(testFileCopy, 'base64')).toString 16
    infileCrcPre.should.equal(infileCrcPost)
    infileCrcPost.should.equal(outfileCrc)
    fs.unlinkSync(testFileCopy)  if fs.exists(testFileCopy)
  .then () ->
    done()
  .fail (err) ->
    done(err)
  .done()
 
describe 'copying files through base64', () ->
  describe 'big file', () ->
    it 'should succeed with large chunk', (done) ->
      readWrite done,  __dirname+'/testFile.jpg', __dirname+'/testFile.jpg~copy', 14000
    it 'should succeed with small chunk', (done) ->
      readWrite done,  __dirname+'/testFile.jpg', __dirname+'/testFile.jpg~copy', 700
  describe 'small file', () ->
    it 'should succeed with large chunk', (done) ->
      readWrite done, __dirname+'/testFile.txt', __dirname+'/testFile.txt~copy', 70
    it 'should succeed with small chunk', (done) ->
      readWrite done, __dirname+'/testFile.txt', __dirname+'/testFile.txt~copy', 7





