require '../src/registerGlobals'
crc = require 'crc'
fs = require 'fs'

{Transfer} = require('../src/Transfer')

chai = require 'chai'
chai.should()

describe 'Transfer', () ->
  describe 'Shared features', () ->
    it 'should calculate CRC the way proven good for small files', (done) ->
      testFile = __dirname+'/testFile.jpg'
      try
        properCrc = 'fc2123f' #calculated with crc32 from libarchive-zip-perl package
        Transfer.prototype._calcCrc(testFile)
        .then (crc) ->
          crc.should.equal properCrc
          done()
        .done()
      catch err
        L.debug err
        done err
