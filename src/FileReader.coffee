fs = require 'fs'
Q = require 'q'

class FileReader
  @create: (filepath, chunkSize) ->
    Q.promise (good, bad) =>
      if not fs.existsSync(filepath)
        bad new Error('file does not exist')
        return
      fs.open filepath, 'r', (err, fd) =>
        if err?
          bad err
        else
          good new @ fd, chunkSize

  constructor: (@fd, @chunkSize) ->
    if @chunkSize%7 != 0
      console.log 'chunk size must be multiplication of 7. rounding up...'
      @chunkSize += @chunkSize%7


  close: () ->
    Q.promise (good, bad) =>
      fs.close @fd, (err) ->
        if err?
          bad(err)
        else
          good()

  # empty buffer means EOF  
  readChunk: () ->
    Q.promise (good, bad) =>
      fs.read @fd, new Buffer(@chunkSize), 0, @chunkSize, null, (err, bytesRead, buffer) =>
        if err?
          bad(err)
        else
          @leftToRead -= bytesRead
          if bytesRead != @chunkSize
            good buffer.slice(0, bytesRead)
          else
            good buffer

module.exports =
  FileReader: FileReader
