/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
'use strict';

var _            = require('lodash');
var utils        = require('../../utils');
var when         = require('when');

/**
 * @constructor DemoController
 * @description Constructor
 *
 * @param {Object} depencies - a json with the attributes dbHelper and 
 *                             gamification with the appropiate objects. 
 */
module.exports = function(dependencies) {
  var dbHelper = dependencies.dbHelper;
  var gamification = dependencies.gamification;

  // setup gamification
  gamification.configure(utils.getGamificationConfig());

  var ctrl = {};


  /**
   * @function setupGamePlan
   * @memberof DemoController
   * @instance
   * @description Populates a Game Plan on the Gamification Service with the desired
   * game plan components.
   *
   * @param {Object} gameGameplan - a JSON with the data for the gameplan 
   *                      components. Ex: projectRoot/nodejs/test/unit/demo/data/gameplan.js
   * @param {String} key - the key as a String for the plan to be setup 
   * @return {Promise} a promise of a json with the names of the 
   *              components created. Ex:
   *              {
   *                 deeds: [
   *                     'rideChampion',
   *                     'selfieSultan'
   *                 ],
   *                 events: [
   *                     'rideCompleted',
   *                     'pictureShared'
   *                 ],
   *                 missions: [
   *                     'rideChampionMission',
   *                     'selfieSultanMission'
   *                 ],
   *                 variables: [
   *                    'xp',
   *                     'cash'
   *                 ]
   *               }
   */
  ctrl.setupGamePlan = function(gamePlan, key) {
    var deferred = when.defer();

    if(!gamePlan) {
      deferred.reject(new Error('gamePlan is required'));
    } else if(!key) {
      deferred.reject(new Error('key is required'));
    } else {
      var params = { planName: gamePlan.name, key: key, plan: gamePlan};

      gamification.setupPlan(params)
        .then(function(result) {
          deferred.resolve(result);
        }, function (err) {
          deferred.reject(err);
        });
    }

    return deferred.promise;
  };

  /**
   * @function getPlanInfo
   * @memberof DemoController
   * @instance
   * @description Get the current setup of a plan on the Gamification Service
   * 
   * @param {String} planName - The plan name as a String
   * @param {String} key - The key as a String
   * @return {Promise} - The plan current setup as a json as described at 
   *                     http://gs.ng.bluemix.net/index.html#GamePlan
   */
  ctrl.getPlanInfo = function(planName, key) {
    var deferred = when.defer();

    if(!planName) {
      deferred.reject(new Error('planName is required'));
    } else if(!key) {
      deferred.reject(new Error('key is required'));
    } else {
      gamification.getPlanInfo({
        planName: planName,
        key: key
      })
      .then(function(response) {
        deferred.resolve(response);
      }, function (err) {
        deferred.reject(err);
      });
    }
    
    return deferred.promise;
  };

  /**
   * @function clearGamePlan
   * @memberof DemoController
   * @instance
   * @description Deletes the specified game plan componenets
   *
   * @param {Object} - a JSON with the components that are to be deleted
   *               {
   *                 name: 'The Best Plan Ever!',
   *                 deeds: [
   *                   { name: 'rideChampion' },
   *                   { name: 'selfieSultan' }
   *                 ],
   *                 events: [
   *                   { name: 'rideCompleted' },
   *                   { name: 'pictureShared' }
   *                 ],
   *                missions: [
   *                   { name: 'rideChampionMission' },
   *                   { name: 'selfieSultanMission' }
   *                 ],
   *                 variables: [
   *                   { name: 'xp' },
   *                   { name: 'cash' }
   *                 ]
   *               }
   * @param {String} key - the key for the plan to be setup 
   * @return {Promise} - a promise of a json with the names of the 
   *              components created. Ex:
   *              {
   *                 deeds: [
   *                     'rideChampion',
   *                     'selfieSultan'
   *                 ],
   *                 events: [
   *                     'rideCompleted',
   *                     'pictureShared'
   *                 ],
   *                 missions: [
   *                     'rideChampionMission',
   *                     'selfieSultanMission'
   *                 ],
   *                 variables: [
   *                    'xp',
   *                     'cash'
   *                 ]
   *               }
   */
  ctrl.clearGamePlan = function(plan, key) {
    var deferred = when.defer();

    if(!plan) {
      deferred.reject(new Error('plan is required'));
    } else if(!key) {
      deferred.reject(new Error('key is required'));
    } else {
      gamification.clearPlan({
        planName: plan.name,
        key: key,
        plan: plan
      })
        .then(function(response) {
          deferred.resolve(response);
        }, function (err) {
          deferred.reject(err);
        });
    }
    
    return deferred.promise;
  };

  /**
   * @function createPlayers
   * @memberof DemoController
   * @instance
   * @description Creates the desired players in the Gamification Services 
   *              instance of this application.
   *
   * @param {Array.<Object>} players - an array with the data for the 
   *                         player that will be created. Each player 
   *                         should the required fields for Bluemix's 
   *                         Gamification Service as described  
   *                         {@link http://gs.ng.bluemix.net/index.html#User|here}
   * @return {Promise} - a promise of the players created in the Gamification Service.
   *                     { players: [Object], groups: [Object] }
   *                     Both Arrays will have entry of the form described in the 
   *                     {@link http://gs.ng.bluemix.net/index.html#User|Gamification docs}.
   */
  ctrl.createPlayers = function(players) {
    var deferred = when.defer();

    if(!players) {
      deferred.reject(new Error('players array is required'));
    } else {
      registerPlayers(players)
      .then(function(registeredPlayers) {
        deferred.resolve(registeredPlayers);
      }, function(err) {
       deferred.reject(err);
      });
    }

    return deferred.promise;
  };

  /**
   * @function deletePlayers
   * @memberof DemoController
   * @instance
   * @description Creates the desired players in the Gamification Services 
   *              instance of this application.
   *
   * @param {Array.<Object>} players - an array with the data for the player that 
   *                         will be deleted. Each player should be of the form: 
   *                         {"id": String (required), "groupId": String (optional) }.
   *                         NOTE: All group listed the groupId attribute will be deleted.
   * @return {Promise} - a promise of the deletion result which will have a this form:
   *                     { "players": [String], "groups": [String] }. Both attribute will 
   *                     be arrays with the respect id of players and groupds deleted. 
   */
  ctrl.deletePlayers = function(players) {
    var deferred = when.defer();

    if(!players) {
      deferred.reject(new Error('players array is required'));
    } else {
      deregisterPlayers(players)
        .then(function(deletion) {
          deferred.json(deletion);
        }, function(err) {
          deferred.reject(err);
        });
    }

    return deferred.promise;
  };

  /**
   * @function dataBlobUpdateCheck
   * @memberof DemoController
   * @instance
   * @description Verifies if the the app version has the latest revision of demo data
   *
   * @param {String} appVersion - the app version
   * @param {Number} revision - the current revision of demo data
   * 
   * @return {Promise} - a promise with the form of 
   *                     {
   *                      "isUpToDate": Boolean 
   *                      "blob": JSON (this will be undefined if isUptoDate is true)
   *                     }
   */
  ctrl.dataBlobUpdateCheck = function(appVersion, revision) {
    var deferred = when.defer();

    if(!appVersion) {
      deferred.reject(new Error('appVersion is required'));
    } else if(revision === undefined) {
      deferred.reject(new Error('revision is required'));
    } else {
      dbHelper.getFilteredEntries(dbHelper.APP_REVS_TABLE, { appVersion: appVersion })
        .then(function(docs) {
          if(docs.length === 1) {
            var appVersionEntry = docs[0];
            
            if(appVersionEntry.revision > revision) {
              dbHelper.getEntryById(dbHelper.BLOBS_TABLE, appVersionEntry.revisionId)
                .then(function(blob) {
                  blob.revision = appVersionEntry.revision;
                  deferred.resolve({ isUpToDate: false, blob: blob });
                });
            } else {
              deferred.resolve({ isUpToDate: true });
            }
          } else {
            deferred.reject(new Error('no data revisions found for app verion: ' + appVersion));
          }
        });
    }

    return deferred.promise;
  };

  /**
   * @function insertDataBlob
   * @memberof DemoController
   * @instance
   * @description Verifies if the the app version has the latest revision of demo data
   *
   * @param {Object} blob - demo data that will be inserted
   * @param {String} appVersion - the app version that the blob data is for
   * @param {Number} revision - the current revision of demo data
   * 
   * @return {Promise} - a promise of the saved data that will be like the 
   *                     blob with the addition of an "id" attribute
   */
  ctrl.insertDataBlob = function(blob, appVersion, revision) {
    var deferred = when.defer();
    var errorHandler = function(err) {
      deferred.reject(err);
    };

    if(!blob) {
      deferred.reject(new Error('blob is required'));
    } else if(!appVersion) {
      deferred.reject(new Error('appVersion is required'));
    } else {
      dbHelper.getFilteredEntries(dbHelper.APP_REVS_TABLE, { appVersion: appVersion })
      .then(function(appVersions) {
        if(appVersions.length == 1) {
          var appVersionEntry = appVersions[0];

          if(revision !== undefined && appVersionEntry.revision > revision) {
            deferred.reject(new Error('new revision must be greater than current. Current revision: ' + appVersionEntry.revision));
          } else if (!revision) {
            revision = appVersionEntry.revision === 0 ? appVersionEntry.revision : (appVersionEntry.revision + 1);
          }

          dbHelper.insert(dbHelper.BLOBS_TABLE, blob)
            .then(function(savedBlob) {
              dbHelper.updateEntry(dbHelper.APP_REVS_TABLE, appVersionEntry.id, { revision: revision, revisionId: savedBlob.id } )
                .then(function(updatedAppEntry) {
                  deferred.resolve(updatedAppEntry);
                }, errorHandler);
            }, errorHandler);
        } else {
          revision = revision || 1;

          dbHelper.insert(dbHelper.BLOBS_TABLE, blob)
            .then(function(savedBlob) {
              dbHelper.insert(
                dbHelper.APP_REVS_TABLE, 
                { appVersion: appVersion, revision: revision, revisionId: savedBlob.id })
                .then(function(savedAppEntry) {
                  deferred.resolve(savedAppEntry);
                }, errorHandler);
            }, errorHandler);
        }
      });
    }

    return deferred.promise;
  };

  /**
   * @function getblobHistory
   * @memberof DemoController
   * @instance
   * @description Fetches db for app version entries that contain what is the latest data revision 
   * for that version and also of the blob entries.
   *
   *  @return {Promise} - that resolves to a JSON of the form 
   *                      {
   *                        "appVersionMatches": [
   *                          { "appVersion": 'X.Y.Z', revision: 19, revisionId: 'revId19' },
   *                          ...
   *                        ],
   *                        "blobs": [
   *                          { "id": 'revId19', ... // attributes for the blobs inserted },
   *                          ...
   *                        ]
   *                      }
   */
  ctrl.getblobHistory = function() {
    var deferred = when.defer();
    var promises = [];

    promises.push(dbHelper.getAllEntries(dbHelper.APP_REVS_TABLE));
    promises.push(dbHelper.getAllEntries(dbHelper.BLOBS_TABLE));

    when.all(promises)
      .then(function(results) {
        deferred.resolve({
          appVersionMatches: results[0],
          blobs: results[1] 
        });
      }, function(err) {
        deferred.reject(err);
      });

    return deferred.promise;
  };

  /**
   * Helper function for creating player and group records in the Gamification Service.
   *
   * @param {Array.<Object>} players - an array with the data for the 
   *                         player that will be created. Each player 
   *                         should the required fields for Bluemix's 
   *                         Gamification Service as described  
   *                         {@link http://gs.ng.bluemix.net/index.html#User|here}
   * @return {Promise} - a promise of the players created in the Gamification Service.
   *                     { players: [Object], groups: [Object] }
   *                     Both Arrays will have entry of the form described in the 
   *                     {@link http://gs.ng.bluemix.net/index.html#User|Gamification docs}.
   */
  function registerPlayers(players) {
    var deferred = when.defer();
    var registrationPromises = [];
    var groupCreationPromises = [];
    var groupIds = [];
    var groupAffiliations = [];
    var errorHandler = function(err) { deferred.reject(new Error(err)); };
    
    // Create Players
    _.forEach(players, function(player) {
      var playerRegistration = { uid: player.id, firstName: player.name };
      var playerPromise = gamification.registerPlayer({ player: playerRegistration });
      registrationPromises.push(playerPromise);

      if(player.group) {
        groupAffiliations.push({ group: player.group, player: player.id });
        groupIds.push(player.group);
      }
    });


    // Create Groups
    groupIds = _.uniq(groupIds);
    _.forEach(groupIds, function(groupId) {
      var groupInfo = { uid: groupId, firstName: groupId };
      var groupPromise = gamification.registerPlayer({ player: groupInfo });
      groupCreationPromises.push(groupPromise);
    });

    // wait for all group creations to be completed
    when.all(registrationPromises)
      .then(function(playersCreated) {
        // wait for all player registrations to be completed
        when.all(groupCreationPromises)
          .then(function(groupsCreated) {
            var followingPromises = [];
            // add players to groups
            _.forEach(groupAffiliations, function(affiliation) {
              followingPromises.push(addPlayerToGroup(affiliation.group, affiliation.player));
            });

            // wait for all following request to be completed
            when.all(followingPromises)
              .then(function(results) {
                deferred.resolve({ players: playersCreated, groups: groupsCreated });
              }, errorHandler);
          }, errorHandler);
      }, errorHandler);

    return deferred.promise;
  }

  /**
   * Helper Function for adding a player to a group in the Gamification Service.
   * NOTE: the Gamification service doesn't have the concept of a group. For this
   * reason the "addition to the group" is done by making the player that matches
   * the playerId "follow" a player that represents the group.
   *
   *
   * @param {String} playerId - the player ID
   * @param {String} groupId - the group ID
   * @return {Promise} - A promise of the result of the addtion which has the form
   *                     { added: String, to: String }. where "added" is the 
   *                     playerId and "to" the groupId
   */
   function addPlayerToGroup(groupId, playerId) {
    var deferred = when.defer();
    var errorHandler = function(err) { deferred.reject(new Error(err)); };

    gamification.getPlayerById({ uid: groupId })
      .then(function(group) {
        if(!group) {
          // Groups are represented a player that can be followed
          var groupInfo = { uid: groupId, name: groupId };
          gamification.registerPlayer({ player: groupInfo })
            .then(function(groupCreated) {
              // check the group was created as expected
              makePlayerJoinGroup(playerId, groupCreated.uid)
                .then(function(result) {
                  deferred.resolve(result);
                }, errorHandler);
            }, errorHandler);
        } else {
          makePlayerJoinGroup(playerId, group.uid)
            .then(function(result) {
              deferred.resolve(result);
            }, errorHandler);
        }
      }, errorHandler); 

    return deferred.promise;
  }

  /**
   * Helper function for force accepting the follow request of a new
   * group member. Note: see addPlayerToGroup(groupId, playerId) 
   *
   * @param {String} playerId - the player ID
   * @param {String} groupId - the group ID
   * @return {Promise} - A promise of the result of the addtion which has the form
   *                     { added: String, to: String }. where "added" is the 
   *                     playerId and "to" the groupId
   */
  function makePlayerJoinGroup(playerId, groupId) {
    var deferred = when.defer();
    var errorHandler = function(err) { deferred.reject(new Error(err)); };

    gamification.requestFollow({ followerId: playerId, followeeId: groupId })
      .then(function(result) {
        if(result.state === "requested") {
          gamification.updateFollowRequestState({ 
            followerId: playerId, 
            followeeId: groupId, 
            state: "accepted"})
            .then(function(result) {
              if(result.state === "accepted") {
                deferred.resolve({ added: playerId, to: groupId });
              } else {
                deferred.reject(new Error('Unable to accept playerId ' + playerId + ' request to join groupId ' + groupId));
              }
            }, errorHandler);
        } else if(result.state === "accepted") {
          deferred.resolve({ followerId: playerId, followeeId: groupId, state: "accepted"});
        } else {
          deferred.reject(new Error('Unable send playerId ' + playerId + ' request to join groupId ' + groupId));
        }
      }, errorHandler);

    return deferred.promise;
  }

  /**
   * Helper function for deleting player and group records from the Gamificaition Service
   *
   * @param {Array.<Object>} players - an array with the data for the player that 
   *                         will be deleted. Each player should be of the form: 
   *                         {"id": String (required), "groupId": String (optional) }.
   *                         NOTE: All group listed the groupId attribute will be deleted.
   * @return {Promise} - a promise of the deletion result which will have a this form:
   *                     { "players": [String], "group": [String] }. Both attribute will 
   *                     be arrays with the respect id of players and groupds deleted. 
   */
  function deregisterPlayers(players) {
    var deferred = when.defer();
    var registrationPromises = [];
    var groupIds = [];
    var playerIds = [];


    _.forEach(players, function(player) {
      var playerPromise = gamification.deletePlayer({ uid: player.id });
      registrationPromises.push(playerPromise);
      playerIds.push(player.id);
      
      if(player.groupId) {
        groupIds.push(player.groupId);
      }
    });

    groupIds = _.uniq(groupIds);
    _.forEach(groupIds, function(groupId) {
      var groupPromise = gamification.deletePlayer({ uid: groupId });
      registrationPromises.push(groupPromise);
    });

    when.all(registrationPromises)
      .then(function(results) {
        deferred.resolve({players: playerIds, groups: groupIds });
      }, function(err) {
        deferred.reject(new Error(err));
      });

    return deferred.promise;
  }

  return ctrl;
};