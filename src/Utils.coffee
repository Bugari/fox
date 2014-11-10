require './registerGlobals'

class Utils
  @byteLength: (str) ->
    return 0 if not str?
    # returns the byte length of an utf8 string
    s = str.length
    i = str.length - 1

    while i >= 0
      code = str.charCodeAt(i)
      if code > 0x7f && code <= 0x7ff
        s++
      else s += 2 if code > 0x7ff && code <= 0xffff
      i--
    s

  forbiddenJIDChars = [
    String.fromCharCode(0x22) #(")
    String.fromCharCode(0x26) #(&)
    String.fromCharCode(0x27) #(')
    String.fromCharCode(0x2F) #(/)
    String.fromCharCode(0x3A) #(:)
    String.fromCharCode(0x3C) #(<)
    String.fromCharCode(0x3E) #(>)
    String.fromCharCode(0x40) #(@)
    String.fromCharCode(0x7F) #(del)
    String.fromCharCode(0xFFFE) #(BOM)
    String.fromCharCode(0xFFFF) #(BOM)
  ]
  hasForbiddenJIDChars = (str) -> _.any forbiddenJIDChars, (c) -> str.indexOf(c) != -1

  @testJID: (s, allowEmptyLocal = false) ->
    # test works according to XEP-0029
    local = null
    resource = null
    domain = null

    #let's cut the stuff up
    if s.indexOf('@') >= 0
      local = s.substr 0, s.lastIndexOf('@')
      s = s.substr s.lastIndexOf('@') + 1
 
    if s.indexOf('/') >= 0
      resource = s.substr s.indexOf('/') + 1
      s = s.substr 0, s.indexOf('/')

    domain = s

    #empty local is correct according to XEP-0029, but pretty useless in current case.
    return false if not local? && not allowEmptyLocal

    #any fields should not contain forbidden characters
    return false if local? && hasForbiddenJIDChars local
    return false if hasForbiddenJIDChars domain
    return false if resource? && hasForbiddenJIDChars resource
    
    #any of the fields should not be longer than 1023 bytes
    return false if (_.any [local, domain, resource], (x) -> Utils.byteLength(x) > 1023)
    return true
    
module.exports = Utils
