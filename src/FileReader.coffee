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
    if @chunkSize%7 != 0
      console.log 'chunk size must be multiplication of 7. rounding up...'
      @chunkSize += @chunkSize%7

    @leftToRead = fs.statSync(filepath).size
    @stream = fs.createReadStream filepath

  readChunk: () =>
    data = @stream.read @chunkSize
    # if data is null, then it's EOF *or* we don't have that much data left
    if data?
      @leftToRead -= @chunkSize
    else if @leftToRead > 0
      data = @stream.read @leftToRead
      @leftToRead = 0

    data = data.toString('base64') if data?
    data

module.exports =
  FileReader: FileReader
