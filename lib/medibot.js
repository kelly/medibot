[
  "Bot",
  "Camera",
  "Motors",
  "Sonar"

].forEach(function( constructor ) {
  var filepath = "../lib/" + constructor.toLowerCase();

  if ( constructor ) {
    module.exports[ constructor ] = require( filepath );
  }
});