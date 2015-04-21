SinopiaNpm = require './sinopia_npm'

module.exports = (settings, params) ->
  new SinopiaNpm (settings is true and {} or settings), params

