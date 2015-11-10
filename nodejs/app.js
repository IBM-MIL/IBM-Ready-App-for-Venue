
/*  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
'use strict';

var cfenv   = require('cfenv');
var express = require('express');
var http    = require('http');
// var ssh     = require('./db/sshTunnel');
var rethink = require('./db/rethinkdb');

var app = express();
var appEnv = cfenv.getAppEnv();

/* ----------------------------------
 * Beggining of start up script.
 * ---------------------------------- */
// setup the express configuration
require('./config/express')(app);
// setup routesç
require('./routes')(app);

rethink.setup()
  .then(startServer);

/* ----------------------------------
 * End of start up script.
 * ---------------------------------- */

// expose the app object for testing purposes
module.exports = app;

/**
 * @ignore
 * Helper function for starting the express app and log the result.
 */
function startServer() {
  http.createServer(app).listen((process.env.PORT || appEnv.port), function () {
    // only log the start of the server when not in test mode
    if(process.env.NODE_ENV !== 'test') {
      // take the values of url and port from env variables or from the cf environment
      var url = (process.env.DOMAIN || appEnv.url);
      console.log("server starting on " + url);
    }
  });
}

/**
 * @typedef {Object} mfpResponse 
 * 
 * @property {Object} data - The data contained in the response
 * @property {Boolean} isSuccessful - A flag to determine is the request was 
 *             successful or not.
 */