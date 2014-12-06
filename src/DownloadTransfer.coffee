Transfer = require './Transfer'
FileWriter = require './FileWriter'
fs = require 'fs'

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
    hloAck =
      time: +new Date()
      type: 'HLOACK'
      id: @id

  _mkDataAck: (msgId) ->
    dataAck =
      time: +new Date()
      type: 'DATAACK'
      id: @id
      msgId: msgId
      
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
        @sendMessage _mkDataAck message.msgId
      when "END"
        @fileWriter.close().fin () ->
          #TODO: validate CRC
          end @

  constructor: (message, @fileWriter, @sendMessage, @end) ->
    @from = message.from
    @id = message.id
    @_hlo = message
    @handle message
    @_updateLastMsgTime()

exports.DownloadTransfer = DownloadTransfer
