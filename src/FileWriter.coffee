fs = require 'fs'
q = require 'q'
stream = require 'stream'
mkdirp = require 'mkdirp'

class FileWriter
  @create: (filepath) ->
    q.promise (good, bad) =>
      reader = null
      try
        FileWriter.ensurePathExists(filepath).then () ->
          writer = new @ filepath
          good(writer)
        .done()
      catch err
        bad(err)
  @ensurePathExists: (filepath) ->
    Q.Promise (good, bad) ->
      path = filepath.split('/')[0...-1].join('/') #it removes filename from path end
      mkdirp path, (err) ->
        return bad(err) if err?
        good()

  constructor: (filepath) ->
    @stream = fs.createWriteStream filepath

  write: (chunk) ->
    @stream.write new Buffer(chunk, 'base64')

  close: () ->
    q.Promise (good,bad) =>
      @stream.on 'finish', ->
        good()
      @stream.end()
module.exports =
  FileWriter: FileWriter
