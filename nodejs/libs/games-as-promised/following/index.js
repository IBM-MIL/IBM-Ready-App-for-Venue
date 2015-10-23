/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
'use strict';

var _    = require('lodash');
var rp   = require('request-promise');
var when = require('when');

var ctrl = {};

/**
 * args = { followerId: (required), followeeId: (required), connParams: (required) }
 */
ctrl.requestFollow = function(args) {
  var deferred = when.defer();
  var followerId = args.followerId;
  var followeeId = args.followeeId;
  var connParams = args.connParams;

  var url = 'https://' + connParams.gamiHost + '/service/plan/' +
           connParams.planName + '/user/' + followerId +
           '/following?key=' + connParams.key + '&tenantId=' + connParams.tenantId;

  var reqOptions = {
    uri : url,
    method: 'POST',
    json: { "followee": followeeId }
  };

  rp(reqOptions)
    .then(function(response) {
        deferred.resolve(response);
      },function(err) {
        if(_.includes(err.error.message, "already exists")) {
          deferred.resolve({ state: "accepted" });
        } else {
          deferred.reject(new Error(err.error.message));
        }        
      });

  return deferred.promise;
};


/**
 * args = { followerId: (required), followeeId: (required), connParams: (required) }
 */
ctrl.updateFollowRequestState = function(args) {
  var deferred = when.defer();
  var state = args.state;
  var followerId = args.followerId;
  var followeeId = args.followeeId;
  var connParams = args.connParams;

  var reqOptions = {
    uri: 'https://' + connParams.gamiHost + '/service/plan/' + connParams.planName + 
         '/user/' + followeeId + '/followBy/' + followerId + '?key=' + connParams.key + 
         '&tenantId=' + connParams.tenantId,
    method: 'PUT',
    json:{ "state": state }
  };

  perfomRequestRepotedToDeffered(reqOptions, deferred, false);

  return deferred.promise;
};


/**
 * args = { followeeId: (required), connParams: (required) }
 */
ctrl.getFollowers = function(args) {
  var deferred = when.defer();
  var followeeId = args.followeeId;
  var connParams = args.connParams;

  
  var reqOptions = {
    uri: 'https://' + connParams.gamiHost + '/service/plan/' + connParams.planName +
         '/user/' + followeeId + '/followBy?key=' + connParams.key + '&tenantId=' + 
         connParams.tenantId + '&limit=500',
    method: 'GET',
    headers: {
      'Content-Type': 'application/json'
    } 
  };

  perfomRequestRepotedToDeffered(reqOptions, deferred, true);

  return deferred.promise;
};

module.exports = ctrl;

/* ----------------------------------------------------
 * Private functions
 * ----------------------------------------------------*/
function perfomRequestRepotedToDeffered(reqOptions, deferred, shouldParseJSON) {
  rp(reqOptions)
    .then(
      function(response) {
        deferred.resolve(shouldParseJSON ? JSON.parse(response) : response);
      },
      function(err) {
        deferred.reject(err);
      });
}