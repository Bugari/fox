fs = require 'fs'
q = require 'q'
stream = require 'stream'

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
    @stream = fs.createWriteStream filepath

  write: (chunk) ->
    @stream.write new Buffer(chunk, 'base64')

  close: () ->
    q.Promise (good,bad) =>
      @stream.end null,null, () ->
        good()
module.exports =
  FileWriter: FileWriter
