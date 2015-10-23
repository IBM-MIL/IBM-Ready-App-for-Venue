/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
'use strict';

var _          = require('lodash');
var restClient = require('../libs/gamification');
var rp   = require('request-promise');
var when       = require('when');

var ctrl = {};

/**
 * args = { event: (must meet REST requirements), gameConfig: (required)}
 */
ctrl.createEvent = function(args) {
  var deferred = when.defer();
  var event = args.event;
  var gameConfig = args.gameConfig;
  
  ctrl.getEventByName({
      eventName: event.name,
      gameConfig: args.gameConfig
    }).then(function(eventFound) {
      if(!eventFound) {
        var EventManager = new restClient.EventManager(gameConfig);
        EventManager.create(
        JSON.stringify(event),
          function(eventCreated) {
            eventCreated = JSON.parse(eventCreated);
            deferred.resolve({ wasFound: false, event: eventCreated});
          },
          function(err) {
            deferred.reject(err);
          }
        );
      } else {
        deferred.resolve({ wasFound: true, event: eventFound});
      }
    }, function(err) {
      deferred.reject(err);
    });


  return deferred.promise;
}; 

/**
 * args = { events: [(must meet REST requirements)], gameConfig: (required)}
 */
ctrl.createEvents = function(args) {
  var promises = [];
  var deferred = when.defer();

  _.forEach(args.events, function(event) {
    promises.push(ctrl.createEvent({ event: event, gameConfig: args.gameConfig}));
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
 * args = { eventName: (required), gameConfig: (required)}
 */
ctrl.getEventByName = function(args) {
  var deferred = when.defer();
  var eventName = args.eventName;
  var gameConfig = args.gameConfig;
 
  var EventManager = new restClient.EventManager(gameConfig);
  EventManager.byName(
    eventName,
    function(result) {
      deferred.resolve(JSON.parse(result));
    },
    function(err) {
      // workaround for the error thrown when no event is found 
      return deferred.resolve(null);
    }
  );

  return deferred.promise;
}; 

/**
 * args = { event: (must meet REST requirements), gameConfig: (required)}
 */
ctrl.updateEvent = function(args) {
  var deferred = when.defer();
  var event = args.event;
  var gameConfig = args.gameConfig;
  
  var EventManager = new restClient.EventManager(gameConfig);
  EventManager.create(
    JSON.stringify(event),
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
 * args = { events: [(must meet REST requirements)], gameConfig: (required)}
 */
ctrl.deleteEvents = function(args) {
  var promises = [];
  var deferred = when.defer();

  _.forEach(args.events, function(event) {
    promises.push(ctrl.deleteEvent({ eventName: event.name, gameConfig: args.gameConfig }));
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
 * args = { eventName: (required), gameConfig: (required)}
 */
ctrl.deleteEvent = function(args) {
  var deferred = when.defer();
  var eventName = args.eventName;
  var gameConfig = args.gameConfig;
  
  var EventManager = new restClient.EventManager(gameConfig);
  EventManager.del(
    eventName,
    function(result) {
      deferred.resolve(result);
    },
    function(err) {
      // workaround for the error thrown when no user is found 
      if(_.includes(err, 'cannot find event')) {
        return deferred.resolve(null);
      } else {
        deferred.reject(err);
      }
    }
  );

  return deferred.promise;
};

/**
 * args = { eventName: (required), eventSource:(required), 
 *           uid: (required), gameConfig: (required)}
 */
ctrl.fireEvent = function(args) {
  var deferred = when.defer();
  var uid = args.uid;
  var eventName = args.eventName;
  var eventSource = args.eventSource;
  var gameConfig = args.gameConfig;
  
  var EventManager = new restClient.EventManager(gameConfig);
  EventManager.fireEvent(
    eventName,
    eventSource,
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
 * args = { connParams: (required)}
 */
ctrl.getEventHistory = function(args){
  var deferred = when.defer();
  var connParams = args.connParams;

  var url = 'https://' + connParams.gamiHost + '/trigger/plan/' +
           connParams.planName + '/event'+
           '?key=' + connParams.key + '&tenantId=' + connParams.tenantId;

  var reqOptions = {
    uri : url,
    method: 'GET'
  };

  rp(reqOptions)
    .then(function(response) {
        deferred.resolve(JSON.parse(response));
      },function(err) {
        deferred.reject(err);       
      });

  return deferred.promise;
};

module.exports = ctrl;