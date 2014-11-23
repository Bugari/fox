Utils = require '../src/Utils'
exports.createArgv = (params) ->
  require('yargs')
  .usage 'Send or recieve files through XMPP'
  .example '$0 -u myJid@example.com -p passwd -t recipient@example.com ./some_file.txt', 'sends ./some_file.txt to recipient@example.com'
  .example '$0 -u myJid@example.com -p passwd', 'connects to server and starts in listen mode - waits for a file to be recieved'
  .example '$0 -u myJid@example.com -p passwd -s downloads/fox', 'connects to server and starts in listen mode - waits for a file to be recieved to directory downloads/fox'

  .demand 'u', 'you must provide jid with -u'
  .alias 'u', 'jid'
  .alias 'u', 'username'
  .describe 'u', 'jid, with optional resource'
  
  .demand 'p', 'you must provide password with -p'
  .alias 'p', 'password'

  .describe 't', 'jid of person that the message should be sent to. Required only when file is provided'
  .alias 't', 'to'

  .describe 's', 'store directory, for downloaded files. Required only when in listen mode'
  .default 's', 'downloads'
  .alias 's', 'store'

  .check (argv, options) -> # if all JID's are proper
    Utils.testJID(argv.u) and (if argv.t then Utils.testJID(argv.t) else true)
  .check (argv, options) ->
    if argv.t? && _.length != 1
      throw new Error('If file name has been provided, -t is required')
    if argv.s? && _.length != 0
      throw new Error('If file name has not been provided, -s is required')

