/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
'use strict';

var restClient = require('./libs/gamification');

var deedsCtrl     = require('./deeds');
var eventsCtrl    = require('./events');
var followingCtrl = require('./following');
var missionsCtrl  = require('./missions');
var plansCtrl     = require('./plans');
var playersCtrl   = require('./players');
var varsCtrl      = require('./variables');

var games = {};
var globalConfig;

games.configure = function(config) {
  if(!config || !config.gamiHost || !config.tenantId || 
     !config.planName || !config.key || !config.getLoginUid) {
    throw new Error('Invalid configuration');
  } 

  globalConfig = restClient.config(config);
  return globalConfig;
};

/* ----------------------------------------------------
 * Plan Management
 * ----------------------------------------------------*/

/**
  * args = { planName: (required), key: (required), plan: (required), 
  *          gameConfig: (optional), connParams: (optional) }
  */
games.setupPlan = function(args) {
  args._command = plansCtrl.setupPlan;
  args.connParams = getValidConnectionParams(args);
  args.gameConfig = getValidGameConfig({ config: args.connParams });
  return perfomWithCallbackOrPromise(args);
};

/**
  * args = { planName: (required), config: (optional)}
  */
games.getPlanInfo = function(args) {
  args._command = plansCtrl.getPlanInfo;
  args.connParams = getValidConnectionParams(args);
  return perfomWithCallbackOrPromise(args);
};

/**
  * args = { planName: (required), key: (required), plan: (required), 
  *          gameConfig: (optional), connParams: (optional) }
  */
games.clearPlan = function(args) {
  args._command = plansCtrl.clearPlan;
  args.connParams = getValidConnectionParams(args);
  args.gameConfig = getValidGameConfig({ config: args.connParams });
  return perfomWithCallbackOrPromise(args);
};

/* ----------------------------------------------------
 * Player Management
 * ----------------------------------------------------*/
/**
 * args = { player: (must meet REST requirements), config: (optional)}
 */
games.registerPlayer = function(args) {
  args._command = playersCtrl.registerPlayer;
  args.gameConfig = getValidGameConfig(args);
  return perfomWithCallbackOrPromise(args);
};

/**
 * args = { uid: (required), config: (optional)}
 */
games.getPlayerById = function(args) {
  args._command = playersCtrl.getPlayerById;
  args.gameConfig = getValidGameConfig(args);
  return perfomWithCallbackOrPromise(args);
};

/**
 * args = { player: (must meet REST requirements), config: (optional)}
 */
games.updatePlayer = function(args) {
  args._command = playersCtrl.updatePlayer;
  args.gameConfig = getValidGameConfig(args);
  return perfomWithCallbackOrPromise(args);
};

/**
 * args = { uid: (required), config: (optional)}
 */
games.deletePlayer = function(args) {
  args._command = playersCtrl.deletePlayer;
  args.gameConfig = getValidGameConfig(args);
  return perfomWithCallbackOrPromise(args);
};



/* ----------------------------------------------------
 * Deed Management
 * ----------------------------------------------------*/
 
/**
 * args = { deed: (must meet REST requirements)
 *          config(optional), successHandler(optional), errorHandler(optional)}
 */
games.createDeed = function(args) {
  args._command = deedsCtrl.createDeed;
  args.gameConfig = getValidGameConfig(args);
  return perfomWithCallbackOrPromise(args);
};

/**
 * args = { deedName: (required),
 *          config(optional), successHandler(optional), errorHandler(optional)}
 */
games.getDeedByName = function(args) {
  args._command = deedsCtrl.getDeedByName;
  args.gameConfig = getValidGameConfig(args);
  return perfomWithCallbackOrPromise(args);
};


/**
 * args = { deed: (must meet REST requirements)
 *          config(optional), successHandler(optional), errorHandler(optional)}
 */
games.updateDeed = function(args) {
  args._command = deedsCtrl.updateDeed;
  args.gameConfig = getValidGameConfig(args);
  return perfomWithCallbackOrPromise(args);
};

/**
 * args = { deedName: (required),
 *          config(optional), successHandler(optional), errorHandler(optional)}
 */
games.deleteDeed = function(args) {
  args._command = deedsCtrl.deleteDeed;
  args.gameConfig = getValidGameConfig(args);
  return perfomWithCallbackOrPromise(args);
};

/**
  * args = { deedPath(required), receiverId(required), 
  *          config(optional), successHandler(optional), errorHandler(optional)}
  */
games.awardDeed = function(args) {
  args._command = deedsCtrl.awardDeed;
  args.connParams = getValidConnectionParams(args);
  return perfomWithCallbackOrPromise(args);
};

/* ----------------------------------------------------
 * Event Management
 * ----------------------------------------------------*/
/**
 * args = { event: (must meet REST requirements)
 *          config(optional), successHandler(optional), errorHandler(optional)}
 */
games.createEvent = function(args) {
  args._command = eventsCtrl.createEvent;
  args.gameConfig = getValidGameConfig(args);
  return perfomWithCallbackOrPromise(args);
};

/**
 * args = { eventName: (required),
 *          config(optional), successHandler(optional), errorHandler(optional)}
 */
games.getEventByName = function(args) {
  args._command = eventsCtrl.getEventByName;
  args.gameConfig = getValidGameConfig(args);
  return perfomWithCallbackOrPromise(args);
};


/**
 * args = { event: (must meet REST requirements)
 *          config(optional), successHandler(optional), errorHandler(optional)}
 */
games.updateEvent = function(args) {
  args._command = eventsCtrl.updateEvent;
  args.gameConfig = getValidGameConfig(args);
  return perfomWithCallbackOrPromise(args);
};

/**
 * args = { eventName: (required),
 *          config(optional), successHandler(optional), errorHandler(optional)}
 */
games.deleteEvent = function(args) {
  args._command = eventsCtrl.deleteEvent;
  args.gameConfig = getValidGameConfig(args);
  return perfomWithCallbackOrPromise(args);
};

/**
 * args = { eventName: (required), eventSource:(required), uid: (required),
 *          config(optional), successHandler(optional), errorHandler(optional)}
 */
games.fireEvent = function(args) {
  args._command = eventsCtrl.fireEvent;
  args.gameConfig = getValidGameConfig(args);
  return perfomWithCallbackOrPromise(args);
};

/**
 * args = { config(optional), successHandler(optional), errorHandler(optional)}
 */
games.getEventHistory = function(args) {
  args._command = eventsCtrl.getEventHistory;
  args.connParams = getValidConnectionParams(args);
  return perfomWithCallbackOrPromise(args);
};

/* ----------------------------------------------------
 * Mission Management
 * ----------------------------------------------------*/
/**
 * args = { mission: (must meet REST requirements)
 *          config(optional), successHandler(optional), errorHandler(optional)}
 */
games.createMission = function(args) {
  args._command = missionsCtrl.createMission;
  args.gameConfig = getValidGameConfig(args);
  return perfomWithCallbackOrPromise(args);
};

/**
 * args = { missionName: (required),
 *          config(optional), successHandler(optional), errorHandler(optional)}
 */
games.getMissionByName = function(args) {
  args._command = missionsCtrl.getMissionByName;
  args.gameConfig = getValidGameConfig(args);
  return perfomWithCallbackOrPromise(args);
};


/**
 * args = { mission: (must meet REST requirements)
 *          config(optional), successHandler(optional), errorHandler(optional)}
 */
games.updateMission = function(args) {
  args._command = missionsCtrl.updateMission;
  args.gameConfig = getValidGameConfig(args);
  return perfomWithCallbackOrPromise(args);
};

/**
 * args = { missionName: (required),
 *          config(optional), successHandler(optional), errorHandler(optional)}
 */
games.deleteMission = function(args) {
  args._command = missionsCtrl.deleteMission;
  args.gameConfig = getValidGameConfig(args);
  return perfomWithCallbackOrPromise(args);
};

/**
  * args = { uid(required), missionName(required), 
  *          config(optional), successHandler(optional), errorHandler(optional)}
  */
games.startMission = function(args) {
  args._command = missionsCtrl.startMission;
  args.connParams = getValidConnectionParams(args);
  return perfomWithCallbackOrPromise(args);
};

/**
 * args = { uid: (required), missionName: (required)
 *          config(optional), successHandler(optional), errorHandler(optional)}
 */
games.acceptMission = function(args) {
  args._command = missionsCtrl.acceptMission;
  args.gameConfig = getValidGameConfig(args);
  return perfomWithCallbackOrPromise(args);
};

/**
 * args = { uid: (required), missionName: (required)
 *          config(optional), successHandler(optional), errorHandler(optional)}
 */
games.completeMission = function(args) {
  args._command = missionsCtrl.completeMission;
  args.gameConfig = getValidGameConfig(args);
  return perfomWithCallbackOrPromise(args);
};

/**
 * args = { uid: (required), missionName: (required)
 *          config(optional), successHandler(optional), errorHandler(optional)}
 */
games.abandonMission = function(args) {
  args._command = missionsCtrl.abandonMission;
  args.gameConfig = getValidGameConfig(args);
  return perfomWithCallbackOrPromise(args);
};

/* ----------------------------------------------------
 * Following Management
 * ----------------------------------------------------*/
/**
 * args = { followerId:(required), followeeId:(required), 
 *           config:(optional)}
 */
games.requestFollow = function(args) {
  args._command = followingCtrl.requestFollow;
  args.connParams = getValidConnectionParams(args);
  return perfomWithCallbackOrPromise(args);
};

/**
 * args = { followerId:(required), followeeId:(required), 
 *           state: (required), config:(optional)}
 */
games.updateFollowRequestState = function(args) {
  args._command = followingCtrl.updateFollowRequestState;
  args.connParams = getValidConnectionParams(args);
  return perfomWithCallbackOrPromise(args);
};

/**
 *
 * args = { followeeId:(required), config:(optional)}
 */
games.getFollowers = function(args) {
  args._command = followingCtrl.getFollowers;
  args.connParams = getValidConnectionParams(args);
  return perfomWithCallbackOrPromise(args);
};


/* ----------------------------------------------------
 * Player Management
 * ----------------------------------------------------*/
/**
 * args = { player: (must meet REST requirements), config: (optional)}
 */
games.createUserVariable = function(args) {
  args._command = varsCtrl.createUserVariable;
  args.gameConfig = getValidGameConfig(args);
  return perfomWithCallbackOrPromise(args);
};

/**
 * args = { uid: (required), config: (optional)}
 */
games.getUserVariableByName = function(args) {
  args._command = varsCtrl.getUserVariableByName;
  args.gameConfig = getValidGameConfig(args);
  return perfomWithCallbackOrPromise(args);
};

/**
 * args = { player: (must meet REST requirements), config: (optional)}
 */
games.updateUserVar = function(args) {
  args._command = varsCtrl.updateUserVar;
  args.gameConfig = getValidGameConfig(args);
  return perfomWithCallbackOrPromise(args);
};

/**
 * args = { uid: (required), config: (optional)}
 */
games.deleteUserVar = function(args) {
  args._command = varsCtrl.deleteUserVar;
  args.gameConfig = getValidGameConfig(args);
  return perfomWithCallbackOrPromise(args);
};

module.exports = games;

/* ----------------------------------------------------
 * Private functions
 * ----------------------------------------------------*/

function getValidGameConfig(args) {
  var gameConfig;
  var customConfig = args.config;
  delete args.config;

  if(!customConfig) {
    if(globalConfig) {
      gameConfig = globalConfig;
    } else {
      throw new Error('SDK must configure or provide a config for this request');     
    }
  } else {
    // config must have all the connection params 
    if(!customConfig || !customConfig.gamiHost || !customConfig.tenantId || 
       !customConfig.planName || !customConfig.key || !customConfig.getLoginUid) {
      throw new Error('Invalid connection configuration');
    }

    gameConfig = restClient.config(customConfig);
  }

  return gameConfig;
}

/**
 * args = { deedPath(required), receiverId(required), 
 *          config(optional), successHandler(optional), errorHandler(optional)}
 */
function getValidConnectionParams(args) {
  var connectionParams;
  var customConfig = args.config;
  delete args.config;

  if(!customConfig) {
    if(globalConfig && globalConfig.conf) {
      connectionParams = globalConfig.conf;
    } else {
      throw new Error('SDK must configure or provide a config for this request');     
    }
  } else {
    // config must have all the connection params 
    if(!customConfig.gamiHost || !customConfig.planName || 
       !customConfig.key || !customConfig.tenantId) {
      throw new Error('Invalid connection configuration');
    }

    connectionParams = customConfig;
  }

  return connectionParams;
}

/**
 * args = { _action: (required) function that returns a promise,
 *          successHandler: (optional) defines if promise or callback behavior,
 *          errorHandler: (option) ignore if no successHandler is provided
 *          ...: all args expected by _action}
 */
function perfomWithCallbackOrPromise(args) {
  // action is expected to be a function that return a promise
  var command = args._command;
  delete args._command;

  // support for callbacks
  if(args.successHandler) {
    command(args)
      .then(
        // when promise is resolved
        function(result) {
          args.successHandler(result);
        }, 
        // when promises is rejected
        function(err) {
          if(args.errorHandler) {
            args.errorHandler(err);
          } else {
            // notify unhandled error
            throw new Error(err);
          }
        });
  // support for promises
  } else {
    return command(args);
  }
}