RegClient = require 'npm-registry-client'

class SinopiaNpm

  sinopia_version: '1.1.0'

  constructor: ({@client, @timeout, @registry}={}) ->
    @client ?= new RegClient
    @timeout ?= 1000
    @registry ?= 'https://registry.npmjs.org'

  _getEmail: (username, cb) ->
    @client.get "#{@registry}/-/user/org.couchdb.user:#{encodeURIComponent username}", {@timeout}, (err, data) ->
      return cb() if err?.code is 'E404'
      return cb(err) if err?
      cb null, data.email

  authenticate: (username, password, cb) ->
    @_getEmail username, (err, email) =>
      return cb(err) if err?
      return cb() unless email?
      @client.adduser @registry, {auth: {username, password, email}, @timeout}, (err, data) ->
        return cb(null, false) if err?.code is 'E400'
        return cb(err) if err?
        cb null, [username]

module.exports = SinopiaNpm
