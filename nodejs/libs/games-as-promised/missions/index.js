/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
'use strict';

var _          = require('lodash');
var rp   = require('request-promise');
var restClient = require('../libs/gamification');
var when = require('when');

var ctrl = {};

/**
 * args = { mission: (must meet REST requirements), gameConfig: (required)}
 */
ctrl.createMission = function(args) {
  var deferred = when.defer();
  var mission = args.mission;
  var gameConfig = args.gameConfig;
  
  ctrl.getMissionByName({
      missionName: mission.name,
      gameConfig: args.gameConfig
    }).then(function(missionFound) {
      if(!missionFound) {
        var MissionManager = new restClient.MissionManager(gameConfig);
        MissionManager.create(
          JSON.stringify(mission),
          function(missionCreated) {
            missionCreated = JSON.parse(missionCreated);
            deferred.resolve({ wasFound: false, mission: missionCreated});          },
          function(err) {
            deferred.reject(err);
          }
        );
      } else {
        deferred.resolve({ wasFound: true, mission: missionFound});
      }
    }, function(err) {
      deferred.reject(err);
    });

  return deferred.promise;
}; 

/**
 * args = { missions: [(must meet REST requirements)], gameConfig: (required)}
 */
ctrl.createMissions = function(args) {
  var promises = [];
  var deferred = when.defer();

  _.forEach(args.missions, function(mission) {
    promises.push(ctrl.createMission({ mission: mission, gameConfig: args.gameConfig}));
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
 * args = { missionName: (required), gameConfig: (required)}
 */
ctrl.getMissionByName = function(args) {
  var deferred = when.defer();
  var missionName = args.missionName;
  var gameConfig = args.gameConfig;
  
  var MissionManager = new restClient.MissionManager(gameConfig);
  MissionManager.byName(
    missionName,
    function(result) {
      deferred.resolve(JSON.parse(result));
    },
    function(err) {
      // workaround for the error thrown when no event is found 
      if(_.includes(err, 'not found')) {
        return deferred.resolve(null);
      } else {
        deferred.reject(err);
      }
    }
  );

  return deferred.promise;
}; 

/**
 * args = { mission: (must meet REST requirements), gameConfig: (required)}
 */
ctrl.updateMission = function(args) {
  var deferred = when.defer();
  var mission = args.mission;
  var gameConfig = args.gameConfig;
  
  var MissionManager = new restClient.MissionManager(gameConfig);
  MissionManager.update(
    JSON.stringify(mission),
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
 * args = { missions: [(must meet REST requirements)], gameConfig: (required)}
 */
ctrl.deleteMissions = function(args) {
  var promises = [];
  var deferred = when.defer();

  _.forEach(args.missions, function(mission) {
    promises.push(ctrl.deleteMission({ missionName: mission.name, gameConfig: args.gameConfig }));
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
 * args = { missionName: (required), gameConfig: (required)}
 */
ctrl.deleteMission = function(args) {
  var deferred = when.defer();
  var missionName = args.missionName;
  var gameConfig = args.gameConfig;
  
  var MissionManager = new restClient.MissionManager(gameConfig);
  MissionManager.del(
    missionName,
    function(result) {
      deferred.resolve({ name: missionName });
    },
    function(err) {
      deferred.resolve(null);
    }
  );

  return deferred.promise;
}; 

/**
 * args = { uid: (required), missionName: (required), gameConfig: (required)}
 */
ctrl.startMission = function(args) {
  var deferred = when.defer();
  var uid = args.uid;
  var missionName = args.missionName;
  var connParams = args.connParams;

  var url = 'https://' + connParams.gamiHost + '/trigger/plan/' +
           connParams.planName + '/mission/' + missionName +
           '?key=' + connParams.key + '&tenantId=' + connParams.tenantId;

  var reqOptions = {
    uri : url,
    method: 'POST',
    json: { "uid": uid }
  };

  rp(reqOptions)
    .then(function(response) {
        deferred.resolve(response);
      },function(err) {
        console.log('Got Error starting mission');
        console.log(err);
        deferred.reject(err);
      });

  return deferred.promise;
};

/**
 * args = { uid: (required), missionName: (required), gameConfig: (required)}
 */
ctrl.acceptMission = function(args) {
  var deferred = when.defer();
  var uid = args.uid;
  var missionName = args.missionName;
  var gameConfig = args.gameConfig;
  
  var MissionManager = new restClient.MissionManager(gameConfig);
  MissionManager.acceptMission(
    missionName,
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

/**
 * args = { uid: (required), missionName: (required), gameConfig: (required)}
 */
ctrl.completeMission = function(args) {
  var deferred = when.defer();
  var uid = args.uid;
  var missionName = args.missionName;
  var gameConfig = args.gameConfig;
  
  var MissionManager = new restClient.MissionManager(gameConfig);
  MissionManager.completeMission(
    missionName,
    uid,
    function(result) {
      deferred.resolve(JSON.parse(result));
    },
    function(err) {
      deferred.reject(err);
    }
  );

  return deferred.promise;
}; 

/**
 * args = { uid: (required), missionName: (required), gameConfig: (required)}
 */
ctrl.abandonMission = function(args) {
  var deferred = when.defer();
  var uid = args.uid;
  var missionName = args.missionName;
  var gameConfig = args.gameConfig;
  
  var MissionManager = new restClient.MissionManager(gameConfig);
  MissionManager.abandonMission(
    missionName,
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