ltx = require 'ltx'
stream = require 'stream'
crc = require 'crc'
fs = require 'fs'
class Transfer
  _mkMsg: (to, data) ->
    new ltx.Element("message",
      to: to
      fox: JSON.stringify(data)
    )
  _calcCrc: (filePath) ->
    Q.Promise (good, bad) ->
      try
        currentCrc = null
        crcWs = stream.Writable()
        crcWs._write = (chunk, enc, next) ->
          if currentCrc?
            currentCrc = crc.crc32 chunk, currentCrc
          else
            currentCrc = crc.crc32 chunk
          next()
        crcWs.on 'finish', () ->
          good(currentCrc.toString 16)
        fstream = fs.createReadStream(filePath)
        fstream.on 'open', ->
          fstream.pipe(crcWs)
        fstream.on 'error', (err) ->
          done err
      catch err
        bad err

exports.Transfer = Transfer
