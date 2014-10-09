require('../src/registerGlobals')

xmpp = require('node-xmpp-server')
c2s = null
Client = require('node-xmpp-client')
ltx = require('ltx')

module.exports =
  startServer: (done) ->
  
    # Sets up the server.
    c2s = new xmpp.C2SServer
      port: 5222
      domain: "localhost"
    
    
    # On Connect event. When a client connects.
    c2s.on "connect", (client) ->
      
      # That's the way you add mods to a given server.
      
      # Allows the developer to register the jid against anything they want
      c2s.on "register", (opts, cb) ->
        L.debug 'XMPP REGISTRATION'
        cb true
        return

      # Allows the developer to authenticate users against anything they want.
      client.on "authenticate", (opts, cb) ->
        L.debug("XMPP AUTH " + opts.jid + " -> " + opts.password)
        if "secret" is opts.password
          L.debug 'XMPP AUTH SUCCESS'
          return cb(null, opts)
        L.debug 'XMPP AUTH FAIL'
        cb false
        return

      client.on "online", ->
        L.debug 'XMPP ONLINE'
        return
      
      # Stanza handling
      client.on "stanza", (stanza) ->
        L.debug "STANZA"+stanza.root().toString()
        from = stanza.attrs.from
        stanza.attrs.from = stanza.attrs.to
        stanza.attrs.to = from
        client.send stanza
        return

      
      # On Disconnect event. When a client disconnects
      client.on "disconnect", ->
        L.debug 'XMPP DISCONNECT'
        return

      return

    done() if done
    return
