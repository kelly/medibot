["Bot",
 "Camera",
 "Motors",
 "Sonar"].forEach (constructor) ->
  filepath = "../lib/" + constructor.toLowerCase()
  module.exports[constructor] = require(filepath)  if constructor