fs = require 'fs'
q = require 'q'

class FileReader
  @create: (filepath, chunkSize) ->
    q.promise (good, bad) =>
      reader = null
      try
        reader = new @ filepath, chunkSize
        reader.stream.on 'readable', () ->
          good(reader)
      catch err
        bad(err)

  constructor: (filepath, @chunkSize) ->
    throw new Error('file does not exist') if not fs.existsSync(filepath)
    @stream = fs.createReadStream filepath,
      encoding: 'base64'

  readChunk: () ->
    @stream.read @chunkSize

module.exports =
  FileReader: FileReader
