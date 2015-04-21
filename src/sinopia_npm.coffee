RegClient = require 'npm-registry-client'
LRU = require 'lru-cache'
ms = require 'to-ms'
_ = require 'lodash'

class SinopiaNpm

  sinopia_version: '1.1.0'

  constructor: ({@client, @cache, @timeout, @registry, registryConfig, cacheConfig}={}) ->
    @client ?= new RegClient registryConfig
    @cache ?= LRU _.defaults({}, cacheConfig, max: 1000, maxAge: ms.minutes(15))
    @timeout ?= 1000
    @registry ?= 'https://registry.npmjs.org'

  _getEmail: (username, cb) ->
    @client.get "#{@registry}/-/user/org.couchdb.user:#{encodeURIComponent username}", {@timeout}, (err, data) ->
      return cb() if err?.code is 'E404'
      return cb(err) if err?
      cb null, data.email

  authenticate: (username, password, cb) ->
    return process.nextTick(-> cb(null, [username])) if @cache.get("password-#{username}") is password
    @_getEmail username, (err, email) =>
      return cb(err) if err?
      return cb() unless email?
      @client.adduser @registry, {auth: {username, password, email}, @timeout}, (err, data) =>
        return cb(null, false) if err?.code is 'E400'
        return cb(err) if err?
        @cache.set "password-#{username}", password
        cb null, [username]

  add_user: (username, password, cb) ->
    @authenticate username, password, cb

module.exports = SinopiaNpm

