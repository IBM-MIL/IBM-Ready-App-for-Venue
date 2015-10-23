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
 * args = { variable: (must meet REST requirements), gameConfig: (required)}
 */
ctrl.createUserVariable = function(args) {
  var deferred = when.defer();
  var variable = args.variable;
  var gameConfig = args.gameConfig;
  
  ctrl.getUserVariableByName({
      varName: variable.name,
      gameConfig: args.gameConfig
    }).then(function(varFound) {
      if(!varFound) {
        var varManager = new restClient.VarManager(gameConfig);
        varManager.create(
          JSON.stringify(variable),
          function(varCreated) {
            varCreated = JSON.parse(varCreated);
            deferred.resolve({ wasFound: false, variable: varCreated});          },
          function(err) {
            deferred.reject(err);
          }
        );
      } else {
        deferred.resolve({ wasFound: true, variable: varFound});
      }
    }, function(err) {
      deferred.reject(err);
    });

  return deferred.promise;
}; 

/**
 * args = { variables: [(must meet REST requirements)], gameConfig: (required)}
 */
ctrl.createVariables = function(args) {
  var promises = [];
  var deferred = when.defer();

  _.forEach(args.variables, function(variable) {
    promises.push(ctrl.createUserVariable({ variable: variable, gameConfig: args.gameConfig}));
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
 * args = { varName: (required), gameConfig: (required)}
 */
ctrl.getUserVariableByName = function(args) {
  var deferred = when.defer();
  var varName = args.varName;
  var gameConfig = args.gameConfig;
  
  var VarManager = new restClient.VarManager(gameConfig);
  VarManager.byName(
    varName,
    function(result) {
      result = result ? JSON.parse(result) : null;
      deferred.resolve(result);
    },
    function(err) {  
      // workaround for the error thrown when no user is found 
      if(_.includes(err, 'not exists')) {
        deferred.resolve(null);
      } else {
        console.log('Rejecting variable fetch promise');
        console.log(err);
        deferred.reject(err);
      }
    }
  );

  return deferred.promise;
}; 

/**
 * args = { variable: (must meet REST requirements), gameConfig: (required)}
 */
ctrl.updateUserVar = function(args) {
  var deferred = when.defer();
  var variable = args.variable;
  var gameConfig = args.gameConfig;
  
  var VarManager = new restClient.VarManager(gameConfig);
  VarManager.update(
    JSON.stringify(variable),
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
 * args = { variables: [(must meet REST requirements)], gameConfig: (required)}
 */
ctrl.deleteVariables = function(args) {
  var promises = [];
  var deferred = when.defer();

  _.forEach(args.variables, function(variable) {
    promises.push(ctrl.deleteUserVar({ varName: variable.name, gameConfig: args.gameConfig }));
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
 * args = { varName: (required), gameConfig: (required)}
 */
ctrl.deleteUserVar = function(args) {
  var deferred = when.defer();
  var varName = args.varName;
  var gameConfig = args.gameConfig;

  var VarManager = new restClient.VarManager(gameConfig);
  VarManager.del(
    varName,
    function(result) {
      deferred.resolve({ name: varName });
    },
    function(err) {
      deferred.resolve(null);
    }
  );

  return deferred.promise;
}; 


module.exports = ctrl;