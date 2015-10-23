/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
'use strict';

var _       = require('lodash');
var fs      = require('fs');
var path    = require('path');
var tunnel  = require('tunnel-ssh');

var config    = {
    host:       process.env.RETHINKDB_HOST,
    port:       process.env.RETHINKDB_PORT,
    localHost:  process.env.RETHINKDB_LOCAL_HOST,
    localPort:  process.env.RETHINKDB_LOCAL_PORT,
    dstHost:    process.env.RETHINKDB_REMOTE_HOST,
    dstPort:    process.env.RETHINKDB_REMOTE_PORT,
    username:   process.env.RETHINKDB_USER,
    privateKey: fs.readFileSync(path.join(__dirname, '../', 'id_rsa')),
    srcHost:    process.env.RETHINKDB_LOCAL_HOST,
    srcPort:    process.env.RETHINKDB_LOCAL_PORT,
    // required so that ssh tunnel stays open after a
    // connection created by a callback is closed
    keepAlive:  true 
  };
var iddleTimeLimit = 2700000; // 45 minutes in milliseconds
var iddleTimeout;
var isCreatingTunnel;
var isServerUp;
var sshSever;
var waitingCallbacks = [];

exports.withValidTunnel = function(callback) {

  // if the server send the current connections params to the callback
  if(isServerUp) {
    updateIddleTimer();
    
    var serverInfo = sshSever.address();
    callback(serverInfo.address, serverInfo.port);
  // otherwise create an ssh tunnel before calling the callback
  } else if(isCreatingTunnel) {
    waitingCallbacks.push(callback);
  } else {
    isCreatingTunnel = true;
    waitingCallbacks.push(callback);

    sshSever = tunnel(config, function (err, results) {
      if(process.env.NODE_ENV !== 'test') {
        console.log('shh tunnel setup successfully  at ' + Date.now());
      }

      // Update flags and register to the closing event of the server
      isServerUp = true;
      isCreatingTunnel = false;
      sshSever.once('close', onServerClose);

      // setup iddle timer
      updateIddleTimer();

      // sent the connection params to the callbacks that have been 
      // waiting for the tunnel
      var serverInfo = sshSever.address();
      _.forEach(waitingCallbacks, function(cb) {
        cb(serverInfo.address, serverInfo.port);
      });
      // clear the waiting callback collection
      waitingCallbacks = [];
    });
  }
};

function onServerClose() {
  if(process.env.NODE_ENV !== 'test') {
    console.log('shh tunnel closed successfully at ' + Date.now());
  }

  sshSever = null;
  isServerUp = false;
}

function updateIddleTimer() {
  // if there is a timout going cancel it
  if(iddleTimeout) {
    clearTimeout(iddleTimeout);
  }

  iddleTimeout = setTimeout(function() {
    sshSever.close();
  }, iddleTimeLimit);
}