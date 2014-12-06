Transfer = require './Transfer'
FileReader = require './FileReader'
uuid = require 'node-uuid'
path = require 'path'
fs = require 'fs'

class UploadTransfer extends Transfer
  @create: (filePath, sendMessage, end) =>
    Q.Promise (good, bad) =>
      Q.all([
        Q.denodeify(fs.stat) filePath
        @_calcCrc filePath
        FileReader.create
      ]).spread (stat, crc, fileReader) =>
        good(@ to, filePath, stat, crc, fileReader)

  constructor: (@filePath, @fileStats, @fileCrc, @fileReader) ->
    @transferId = uuid.v4()
    sendMessage _mkHlo()

  handle: (message) ->
    if message.type == 'HLOACK' or message.type == 'DATAACK'
      @_mkData().then (responce) ->
        @sendMessage responce


  #XXX: only _mk that returns promise -.-
  _mkData: () ->
    @fileReader.readChunk().then (data) ->
      msg =
        transferId: @transferId
        id: uuid.v4()
        type: 'DATA'
        data: data

  _mkHlo: () ->
    msg =
      transferId: @transferId
      id: uuid.v4()
      type: 'HLO'
      fileName: path.basename @filePath
      fileSize: @fileStats.size
      fileCrc: @crc
    
exports.UploadTransfer = UploadTransfer
