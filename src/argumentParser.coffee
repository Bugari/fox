Utils = require '../src/Utils'
exports.createArgv = (params) ->
  require('yargs')
  .usage 'Send or recieve files through XMPP'
  .example '$0 -u myJid@example.com -p passwd -t recipient@example.com ./some_file.txt', 'sends ./some_file.txt to recipient@example.com'
  .example '$0 -u myJid@example.com -p passwd', 'connects to server and waits for a file to be recieved'

  .demand 'u', 'you must provide jid with -u'
  .alias 'u', 'jid'
  .alias 'u', 'username'
  .describe 'u', 'jid, with optional resource'
  
  .demand 'p', 'you must provide password with -p'
  .alias 'p', 'password'

  .describe 't', 'jid of person that the message should be sent to. Required only when file is provided'
  .alias 't', 'to'

  .check (argv, options) -> # if all JID's are proper
    Utils.testJID(argv.u) and (if argv.t then Utils.testJID(argv.t) else true)
  .check (argv, options) -> # if has -t should have file specified
    if argv.t > 0 && _.length != 1
      false



