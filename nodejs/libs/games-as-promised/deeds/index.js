/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
'use strict';

var _          = require('lodash');
var rp         = require('request-promise');
var restClient = require('../libs/gamification');
var when       = require('when');

var ctrl = {};

/**
 * args = { deed: (must meet REST requirements), gameConfig: (required)}
 */
ctrl.createDeed = function(args) {
  var deferred = when.defer();
  var deed = args.deed;
  var gameConfig = args.gameConfig;

  ctrl.getDeedByName({
      deedName: deed.name,
      gameConfig: args.gameConfig
    }).then(function(deedFound) {
      // if no deed found then create it
      if(!deedFound) {
        var DeedManager = new restClient.DeedManager(gameConfig);
        DeedManager.create(
          JSON.stringify(deed),
          function(deedCreated) {
            deferred.resolve({ wasFound: false, deed: JSON.parse(deedCreated)});
          },
          function(err) {
            deferred.reject(err);
          }
        );
      } else {
        deferred.resolve({ wasFound: true, deed: deedFound});
      }
    }, function(err) {
      deferred.reject(err);
    });

  return deferred.promise;
}; 

/**
 * args = { deeds: [(must meet REST requirements)], gameConfig: (required)}
 */
ctrl.createDeeds = function(args) {
  var promises = [];
  var deferred = when.defer();

  _.forEach(args.deeds, function(deed) {
    promises.push(ctrl.createDeed({ deed: deed, gameConfig: args.gameConfig}));
  });

  when.all(promises)
    .then(function(results) {
      deferred.resolve(results);
    }, function(err) {
      deferred.reject(err);
    });

  return deferred.promise;
};

/**
 * args = { deedName: (required), gameConfig: (required)}
 */
ctrl.getDeedByName = function(args) {
  var deferred = when.defer();
  var deedName = args.deedName;
  var gameConfig = args.gameConfig;

  var DeedManager = new restClient.DeedManager(gameConfig);
  DeedManager.byName(
    deedName,
    function(result) {
      deferred.resolve(JSON.parse(result));
    },
    function(err) {
      // workaround for the error thrown when no user is found 
      if(_.includes(err, 'not exist')) {
        return deferred.resolve(null);
      } else {
        console.log('Rejecting deed fetch promise');
        console.log(err);
        deferred.reject(err);
      }
    }
  );

  return deferred.promise;
}; 

/**
 * args = { deed: (must meet REST requirements), gameConfig: (required)}
 */
ctrl.updateDeed = function(args) {
  var deferred = when.defer();
  var deed = args.deed;
  var gameConfig = args.gameConfig;
  
  var DeedManager = new restClient.DeedManager(gameConfig);
  DeedManager.create(
    JSON.stringify(deed),
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
 * args = { deeds: [(must meet REST requirements)], gameConfig: (required)}
 */
ctrl.deleteDeeds = function(args) {
  var promises = [];
  var deferred = when.defer();

  _.forEach(args.deeds, function(deed) {
    promises.push(ctrl.deleteDeed({ deedName: deed.name, gameConfig: args.gameConfig }));
  });

  when.all(promises)
    .then(function(results) {
      deferred.resolve(results);
    }, function(err) {
      deferred.reject(err);
    });

  return deferred.promise;
};

/**
 * args = { deedName: (required), gameConfig: (required)}
 */
ctrl.deleteDeed = function(args) {
  var deferred = when.defer();
  var deedName = args.deedName;
  var gameConfig = args.gameConfig;

  var DeedManager = new restClient.DeedManager(gameConfig);
  DeedManager.del(
    deedName,
    function(result) {
      deferred.resolve({ name: deedName});
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
 * args = { deedPath(required), receiverId(required), connParams: (required) }
 */
ctrl.awardDeed = function(args) {
  var deferred = when.defer();
  var deedPath = args.deedPath;
  var receiverId = args.receiverId;
  var connParams = args.connParams;

  if(!deedPath || !receiverId || !connParams) {
    deferred.reject(new Error('Invalid params'));
  }

  if(!connParams.gamiHost || !connParams.planName || 
     !connParams.key || !connParams.tenantId) {
      deferred.reject(new Error('Invalid connection params'));
  }
  
  var reqOptions = {
    uri:  'https://' + connParams.gamiHost + '/trigger/plan/' + connParams.planName + 
          '/deed/' + deedPath + '?key=' + connParams.key + '&tenantId=' + connParams.tenantId,
    method : 'POST',
    json: { "uid": receiverId }
  };

  perfomRequestRepotedToDeffered(reqOptions, deferred);

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