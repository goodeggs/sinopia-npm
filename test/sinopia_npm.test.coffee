fibrous = require 'fibrous'
require 'mocha-sinon'
{expect} = chai = require 'chai'
chai.use require 'sinon-chai'
RegClient = require 'npm-registry-client'

sinopiaNpm = require '..'

makeError = (message, code) ->
  e = new Error(message)
  e.code = code
  e

describe 'sinopia-npm', ->
  {npm, auth} = {}

  beforeEach ->
    npm = new RegClient
    auth = sinopiaNpm client: npm

  describe '::authenticate', ->

    describe 'unknown user', ->
      beforeEach ->
        @sinon.stub(npm, 'get')
          .withArgs('https://registry.npmjs.org/-/user/org.couchdb.user:bobzoller')
          .yields(makeError('not found', 'E404'))

      it 'returns undefined', ->
        expect(auth.sync.authenticate('bobzoller', 'foobar')).to.be.undefined

    describe 'incorrect password', ->
      beforeEach ->
        @sinon.stub(npm, 'get')
          .withArgs('https://registry.npmjs.org/-/user/org.couchdb.user:bobzoller')
          .yields(null, {email: 'bob@example.com', name: 'bobzoller'})
        @sinon.stub(npm, 'adduser')
          .withArgs('https://registry.npmjs.org', auth: {username: 'bobzoller', email: 'bob@example.com', password: 'foobar'}, timeout: 1000)
          .yields(makeError('bad auth', 'E400'))

      it 'returns false', ->
        expect(auth.sync.authenticate('bobzoller', 'foobar')).to.equal false

    describe 'correct password', ->
      beforeEach ->
        @sinon.stub(npm, 'get')
          .withArgs('https://registry.npmjs.org/-/user/org.couchdb.user:bobzoller')
          .yields(null, {email: 'bob@example.com', name: 'bobzoller'})
        @sinon.stub(npm, 'adduser')
          .withArgs('https://registry.npmjs.org', auth: {username: 'bobzoller', email: 'bob@example.com', password: 'foobar'}, timeout: 1000)
          .yields(null, {"ok": true})

      it 'returns array of perms', ->
        expect(auth.sync.authenticate('bobzoller', 'foobar')).to.eql ['bobzoller']

