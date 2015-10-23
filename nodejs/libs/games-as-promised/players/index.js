/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
'use strict';

var _ = require('lodash');
var restClient = require('../libs/gamification');
var when = require('when');

var ctrl = {};

/**
 * args = { player: (must meet REST requirements), gameConfig: (required)}
 */
ctrl.registerPlayer = function(args) {
  var deferred = when.defer();
  var player = args.player;
  var gameConfig = args.gameConfig;
  
  ctrl.getPlayerById({ uid: player.uid, gameConfig: gameConfig})
    .then(function(userFound) {
        if(!userFound) {
          var userManager = new restClient.UserManager(gameConfig);
          userManager.create(
            JSON.stringify(player),
            function(result) {
              result = JSON.parse(result);
              deferred.resolve(result);
            },
            function(err) {
              deferred.reject(err);
            }
          );
        } else {
          deferred.resolve(userFound);
        }
    });

  return deferred.promise;
}; 

/**
 * args = { uid: (required), gameConfig: (required)}
 */
ctrl.getPlayerById = function(args) {
  var deferred = when.defer();
  var uid = args.uid;
  var gameConfig = args.gameConfig;
  
  var userManager = new restClient.UserManager(gameConfig);
  userManager.byName(
    uid,
    function(result) {
      result = result ? JSON.parse(result) : null;
      deferred.resolve(result);
    },
    function(err) {
      // workaround for the error thrown when no user is found 
      if(_.includes(err, 'not exist')) {
        return deferred.resolve(null);
      } else {
        deferred.reject(err);
      }
    }
  );

  return deferred.promise;
}; 

/**
 * args = { player: (must meet REST requirements), gameConfig: (required)}
 */
ctrl.updatePlayer = function(args) {
  var deferred = when.defer();
  var player = args.player;
  var gameConfig = args.gameConfig;
  
  var userManager = new restClient.UserManager(gameConfig);
  userManager.update(
    JSON.stringify(player),
    function(result) {
      result = JSON.parse(result);
      deferred.resolve(result);
    },
    function(err) {
      deferred.reject(err);
    }
  );

  return deferred.promise;
}; 

/**
 * args = { uid: (required), gameConfig: (required)}
 */
ctrl.deletePlayer = function(args) {
  var deferred = when.defer();
  var uid = args.uid;
  var gameConfig = args.gameConfig;

  var userManager = new restClient.UserManager(gameConfig);
  userManager.del(
    uid,
    function(result) {
      deferred.resolve(result);
    },
    function(err) {      
      deferred.reject(err);
    }
  );

  return deferred.promise;
}; 


module.exports = ctrl;