Client = require 'node-xmpp-client'
TransferManager = require './TransferManager'
class UberClient
  @_parseStanza = (stanza) ->
    if not stanza.root()?.children?
      return null
    properChild = _.find stanza.root().children, (x) -> x.name == 'fox'
    if not properChild?.children?[0]?
      return null
    try
      msg = JSON.parse properChild.children[0]
      msg.from = stanza.root().attrs.from
      msg
    catch err
      return null

  constructor: (jid, password, @errCb) ->
    @transferManager = new TransferManager()
    @client = new Client
      jid: jid
      password: password
    @client.on 'stanza', (stanza) ->
      parsedStanza = UberClient._parseStanza(stanza)
      @transferManager.handleMessage(parsedStanza) if parsedStanza?
