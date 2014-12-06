Transfer = require './Transfer'
FileWriter = require './FileWriter'
fs = require 'fs'
uuid = require 'node-uuid'

class DownloadTransfer extends Transfer
  @create: (hloMessage, sendMessage, end) ->
    Q.Promise (good, bad) =>
      if hloMessage.type != 'hlo'
        good(null)
      else
        message.fileName = DownloadTransfer._sanitizeFilename hloMessage.fileName
        FileWriter.create(hloMessage.fileName).then (fileWriter) =>
          good(@ message, fileWriter, sendMessage, end)

  _mkHloAck: () ->
    msg =
      id: uuid.v4()
      transferId: @transferId
      time: +new Date()
      type: 'HLOACK'

  _mkDataAck: (msgId) ->
    msg =
      id: uuid.v4()
      transferId: @transferId
      ackToId: msgId
      type: 'DATAACK'
      
  @_sanitizeFilename: (filename) ->
    #make sure filename does not contain any weird escape ideas, like '../../etc/passwd' :D
    filename.split('\\').join('/').split('/')[-1..][0]
  
  _updateLastMsgTime: () ->
    @lastMsg = new Date()

  handle: (message) ->
    switch message.type
      when "HLO"
        @sendMessage _mkHloAck()
      when "DATA"
        @fileWriter message.data
        @sendMessage _mkDataAck message.id
      when "END"
        @fileWriter.close().fin () ->
          #TODO: validate CRC
          end @

  constructor: (message, @fileWriter, @sendMessage, @end) ->
    @from = message.from
    @transferId = message.transferId
    @_hlo = message
    @handle message
    @_updateLastMsgTime()

exports.DownloadTransfer = DownloadTransfer
