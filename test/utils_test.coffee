chai = require 'chai'
chai.should()
Utils = require('../src/Utils')

console.log('.....', require('../src/Utils'))
describe 'Utils', () ->
  describe 'testing JID', () ->
    describe 'should accept correct JID', () ->
      it 'address@example.com', () ->
        Utils.testJID('address@example.com').should.be.ok
      it 'address@example.com/locale', () ->
        Utils.testJID('address@example.com/locale').should.be.ok
      it 'address@localhost', () ->
        Utils.testJID('address@localhost').should.be.ok
      it 'address@localhost/locale', () ->
        Utils.testJID('address@localhost/locale').should.be.ok
      it 'zażółć@gęśląjaźń.com', () ->
        Utils.testJID('zażółć@gęśląjaźń.com').should.be.ok
      it 'address@127.0.0.1', () ->
        Utils.testJID('address@127.0.0.1').should.be.ok
      it 'address@127.0.0.1/locale', () ->
        Utils.testJID('address@127.0.0.1/locale').should.be.ok
      it 'example.com with allowed domain only', () ->
        Utils.testJID('example.com', true).should.be.ok
    describe 'should reject incorrect JID', () ->
      it 'char"isbad@localhost', () ->
        not Utils.testJID('char"isbad@localhost.com').should.be.not.ok
      it 'char@isbad@localhost', () ->
        not Utils.testJID('char@isbad@localhost.com').should.be.not.ok
      it 'address@bad"char', () ->
        not Utils.testJID('address@bad"char').should.be.not.ok
      it 'address@localhost/bad"char', () ->
        Utils.testJID('address@bad"char').should.be.not.ok
      it 'example.com', () ->
        not Utils.testJID('example.com').should.be.not.ok
      
