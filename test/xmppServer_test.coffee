require('../src/registerGlobals')
ltx = require('ltx')
Client = require('node-xmpp-client')
{startServer} = require('./xmppServer.coffee')

describe 'XMPP', () ->
  describe 'basic tests', () ->
    before  (done) ->
      startServer done

    it 'should be able to connect and transfer messages', (done) ->
      client1 = new Client(
        jid: "client1@localhost"
        password: "secret"
      )
      client1.on "online", (data) ->
        # L.log "client1", data
        client1.send new ltx.Element("message",
          to: "localhost"
        ).c("body").t("HelloWorld")
        done()
        return

      client1.on "stanza", (stanza) ->
        # L.log "client1", "received stanza", stanza.root().toString()
        return

      client2 = new Client(
        jid: "client2@localhost"
        password: "secret"
      )
      client2.on "error", (error) ->
        L.log "client2 auth failed"
        L.log "client2", error
        return
