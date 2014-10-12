fs = require 'fs'
q = require 'q'
stream = require 'stream'
base64 = require 'base64-stream'

class FileWriter
  @create: (filepath) ->
    q.promise (good, bad) =>
      reader = null
      try
        writer = new @ filepath
        good(writer)
      catch err
        bad(err)

  constructor: (filepath) ->
    @decoder = base64.decode()
    input = new stream.PassThrough()
    @_fileOutput = fs.createWriteStream filepath,
      encoding: 'base64'
    input.pipe(@decoder).pipe @_fileOutput
    @stream = input

  write: (chunk) ->
    @stream.write chunk

  close: () ->
    q.Promise (good,bad) =>
      @_fileOutput.on 'finish', () ->
        good()
      @stream.end null,null, () =>
        null #for now


module.exports =
  FileWriter: FileWriter
