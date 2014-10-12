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
    @leftToRead = fs.statSync(filepath).size
    @stream = fs.createReadStream filepath,
      encoding: 'base64'

  readChunk: () ->
    data = @stream.read @chunkSize
    # if data is null, then it's EOF *or* we don't have that much data left
    if data?
      @leftToRead -= @chunkSize
      #console.log "data left:", @leftToRead
      data
    else if @leftToRead > 0
      data = @stream.read @leftToRead
      @leftToRead = 0
      #console.log 'leftovers', data
    else
      null

module.exports =
  FileReader: FileReader
