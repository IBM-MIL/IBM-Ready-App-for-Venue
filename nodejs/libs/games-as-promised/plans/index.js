/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
'use strict';

var _    = require('lodash');
var rp   = require('request-promise');
var when = require('when');

var deedsCtrl     = require('../deeds');
var eventsCtrl    = require('../events');
var missionsCtrl  = require('../missions');
var varsCtrl      = require('../variables');

var ctrl = {};

 /**
  * args = { planName: (required), key: (required), plan: (required-as defined by the REST docs), 
  *          gameConfig: (require), connParams: (required) }
  */
ctrl.setupPlan = function(args) {
  var deferred = when.defer();
  // check that the plan exists 
  ctrl.getPlanInfo({
      planName:   args.planName,
      key:        args.key,
      connParams: args.connParams 
    })
    .then(function(plan) {
      var setupPromises = [];
      var planSetup = args.plan;
      var gameConfig = args.gameConfig;

      if(!plan) {
        deferred.reject(new Error('Plan not found. Plan must be created through the Bluemix UI.'));
      } else {
        // The logic below is required for resending request since gamification 
        // fails at times when sending multiple creation requests
        var retries = 0;
        var successHandler = function(result) {
          // once the retries aren't needed this could just resolve with the
          // result
          var deeds = [], events = [], missions =[], variables = [];
          _.forEach(planSetup.deeds, function(deed) {
            deeds.push(deed.name);
          });
          _.forEach(planSetup.events, function(event) {
            events.push(event.name);
          });
          _.forEach(planSetup.missions, function(mission) {
            missions.push(mission.name);
          });
          _.forEach(planSetup.variables, function(variable) {
            variables.push(variable.name);
          });          

          deferred.resolve({ 
            deeds: deeds,
            events: events,
            missions: missions,
            variables: variables
          });
        };
        var errorHandler = function(err) {
          if(err === 'internal server error' && retries < 5) {
            setupGamePlanComponents({planSetup: planSetup, gameConfig: gameConfig})
              .then(successHandler, errorHandler);
            retries++;
          } else {
            deferred.reject(err);
          }
        };

        setupGamePlanComponents({planSetup: planSetup, gameConfig: gameConfig})
          .then(successHandler, errorHandler);
      }
    });

  return deferred.promise;
};

/**
  * args = { planName: (required), key: (required),connParams: (required)}
  */
ctrl.getPlanInfo = function(args) {
  var deferred = when.defer();
  var key = args.key;
  var planName = args.planName;
  var connParams = args.connParams;

  var reqOptions = {
    uri: 'https://' + connParams.gamiHost + '/service/plan/' + planName + 
         '?key=' + key + '&tenantId=' + connParams.tenantId,
    method: 'GET',
    headers: {
      'Content-Type': 'application/json'
    } 
  };

  rp(reqOptions)
    .then(function(response) {
        deferred.resolve(JSON.parse(response));
      },function(err) {
        console.log(err);
        deferred.reject(err);
      });

  return deferred.promise;
};


/**
  * args = { planName: (required), key: (required), 
  *         plan: (required- with attribute per component type as array
  *                   with the component names), 
  *           gameConfig: (require), connParams: (required) }
  */
ctrl.clearPlan = function(args) {
  var deferred = when.defer();
  // check that the plan exists 
  ctrl.getPlanInfo({
      planName:   args.planName,
      key:        args.key,
      connParams: args.connParams 
    })
    .then(function(plan) {
      var setupPromises = [];
      var planSetup = args.plan;
      var gameConfig = args.gameConfig;

      if(!plan) {
        deferred.reject(new Error('Plan not found. Plan must be created through the Bluemix UI.'));
      } else {
        // The logic below is required for resending request since gamification 
        // fails at times when sending multiple creation requests
        var retries = 0;
        var successHandler = function(result) {
          // once the retries aren't needed this could just resolve with the
          // result
          // deferred.resolve(result);
          var deeds = [], events = [], missions =[], variables = [];

          _.forEach(planSetup.deeds, function(deed) {
            deeds.push(deed.name);
          });
          _.forEach(planSetup.events, function(event) {
            events.push(event.name);
          });
          _.forEach(planSetup.missions, function(mission) {
            missions.push(mission.name);
          });
          _.forEach(planSetup.variables, function(variable) {
            variables.push(variable.name);
          });          

          deferred.resolve({ 
            deeds: deeds,
            events: events,
            missions: missions,
            variables: variables
          });
        };
        var errorHandler = function(err) {
          if(err === 'internal server error' && retries < 3) {
            clearGamePlanComponents({planSetup: planSetup, gameConfig: gameConfig})
              .then(successHandler, errorHandler);
            retries++;
          } else {
            deferred.reject(err);
          }
        };

        clearGamePlanComponents({planSetup: planSetup, gameConfig: gameConfig})
          .then(successHandler, errorHandler);
      }  
    });

  return deferred.promise;
};

module.exports = ctrl;


function setupGamePlanComponents(args) {
  var deferred = when.defer();
  var setupResult = {};
  var planSetup = args.planSetup;
  var gameConfig = args.gameConfig;

  var varsCreation = { variables: planSetup.variables, gameConfig: gameConfig };
  var eventsCreation = { events: planSetup.events, gameConfig: gameConfig };
  var deedsCreation = { deeds: planSetup.deeds, gameConfig: gameConfig };
  var missionsCreation = { missions: planSetup.missions, gameConfig: gameConfig };
  
  // given the way that the creation components is done error handling must happen
  // at each step
  var errorHandler = function(err) {
    deferred.reject(err);
  };

  // create variables first
  varsCtrl.createVariables(varsCreation)
    .then(function(varsCreated) {
      setupResult.variables = varsCreated;
      // then create the events
      eventsCtrl.createEvents(eventsCreation)
        .then(function(eventsCreated) {
            setupResult.events = eventsCreated;
            // then create the deeds
            deedsCtrl.createDeeds(deedsCreation)
              .then(function(createDeeds) {
                setupResult.deeds = createDeeds;
                // then create the missions
                missionsCtrl.createMissions(missionsCreation)
                  .then(function(missionsCreated) {
                    setupResult.missions = missionsCreated;
                    // after all the last step resolve the result promise
                    deferred.resolve(setupResult);
                  }, errorHandler);
              }, errorHandler);
        }, errorHandler);
    }, errorHandler);

  return deferred.promise;
}

function clearGamePlanComponents(args) {
  var deferred = when.defer();
  var setupPromises = [];
  var planSetup = args.planSetup;
  var gameConfig = args.gameConfig;

  setupPromises.push(deedsCtrl.deleteDeeds({
      deeds: planSetup.deeds,
      gameConfig: gameConfig
    })
  );

  setupPromises.push(eventsCtrl.deleteEvents({
      events: planSetup.events,
      gameConfig: gameConfig, 
    })
  );

  setupPromises.push(missionsCtrl.deleteMissions({
      missions: planSetup.missions,
      gameConfig: gameConfig, 
    })
  );

  setupPromises.push(varsCtrl.deleteVariables({
      variables: planSetup.variables,
      gameConfig: gameConfig, 
    })
  );

  when.all(setupPromises)
    .then(function(results) {
      // the results are expected in the order that 
      // they were pushed to the promises array
      deferred.resolve({ 
        deeds: results[0],
        events: results[1],
        missions: results[2],
        variables: results[3]
      });
    }, function(err) {
      deferred.reject(err);
    });

  return deferred.promise;
}
