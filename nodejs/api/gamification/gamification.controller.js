/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
'use strict';

var _            = require('lodash');
var utils        = require('../../utils'); 
var when         = require('when');

/**
 * @constructor GamificationController
 * @description Constructor
 *
 * @param {Object} depencies - a json with the attribute gamification 
 *                             with a client to the Gamification Service SDK.
 */
module.exports =  function(dependencies) {
  var gamification = dependencies.gamification;
  var ctrl = {};

  // setup the gamification client
  gamification.configure(utils.getGamificationConfig());

  /**
   * @typedef {Object} BadgeStep 
   * 
   * @property {String} name - the name of the step
   * @property {Number} reqCount - the number of required 
   *                    times that the step must be performed
   */

  /**
   * @typedef {Object} Badge 
   * 
   * @property {String} id - the badge id usually the name with spaces and camelcased
   * @property {String} description - the badge's description
   * @property {String} name - the badge's name
   * @property {String} thumbnail_url - the url to the badge's icon
   * @property {Array.<BadgeStep>} steps - The steps required to obtain the badge
   * @property {Numbers} points - The points awarded with the badge
   */

   /**
   * @typedef {Object} UserBadgeStep 
   * 
   * @property {String} name - the name of the step
   * @property {Number} reqCount - the number of required 
   *                    times that the step must be performed
   * @property {Number} playerCount - the number of times the 
   *                    user has performed this step.
   */

  /**
   * @typedef {Object} UserBadge 
   * 
   * @property {String} id - the badge id usually the name with spaces and camelcased
   * @property {String} description - the badge's description
   * @property {String} name - the badge's name
   * @property {Boolena} isEarned - flag to mark if the user has earned this badge or not.
   * @property {String} thumbnail_url - the url to the badge's icon
   * @property {Array.<UserBadgeStep>} steps - The steps required to obtain the badge
   * @property {Numbers} points - The points awarded with the badge
   */

  /**
   * @method registerPlayer
   * @memberof GamificationController
   * @instance
   * @description Creates a player entry in the gamification service
   * 
   * @param {Object} player - the player to be save and it should have the form
   *                        {
   *                          id: {Number} (required),
   *                          name: {String} (optional),
   *                          groupId: {Number} (optional)
   *                        }
   * @return {Promised} - a promise of the player entry created with the groupId 
   *                      (if passed) in appended. The Gamification docs describe 
   *                      player entries here: http://gs.ng.bluemix.net/index.html#User
   */
  ctrl.registerPlayer = function(player) {
    var deferred = when.defer();

    // Parameter validation
    if(player.id === undefined) {
      deferred.reject(new Error('Player must have an id'));
      return deferred.promise;
    }

    var errorHandler = function(err) { deferred.reject(err); }; 
    var gamePlayer = {
      uid:        player.id,
      // when no name then use the id as the name
      firstName:  player.name || player.id
    };

    gamification.registerPlayer({ player: gamePlayer })
      .then(
        function(registeredPlayer) {
          if(player.group !== undefined) {
            ctrl.addPlayerToGroup(player.group, player.id)
              .then(function(addedPlayer) {
                // append the groupId to gamification player data
                registeredPlayer.group = player.group;
                deferred.resolve(registeredPlayer);
              }, errorHandler);
          } else {
            deferred.resolve(registeredPlayer);
          }
        }, errorHandler);

    return deferred.promise;
  };

  /**
   * @method getPlayer
   * @memberof GamificationController
   * @instance
   * @description Fetches a player entry in the gamification service
   * 
   * @param {Number} playerId - the playerId of the desired record 
   * @return {Promised} - a promise of the player entry as the Gamification docs 
   *                      describe here: http://gs.ng.bluemix.net/index.html#User
   */
  ctrl.getPlayer = function(playerId) {
    var deferred = when.defer();

    if(!playerId) {
      deferred.reject(new Error('playerId is required'));
      return deferred.promise;
    }

    gamification.getPlayerById({ uid: parseInt(playerId) })
      .then(
        function(player) {
          deferred.resolve(player);
        }, function(err) {
          deferred.reject(err);
        });

    return deferred.promise;
  };

  /**
   * @method deletePlayer
   * @memberof GamificationController
   * @instance
   * @description Fetches a player entry in the gamification service
   * 
   * @param {Number} playerId - the playerId of the desired record 
   * @return {Promised} - of a json containing the the id of the 
   *                      player record deleted
   */
  ctrl.deletePlayer = function(playerId) {
    var deferred = when.defer();
    if(!playerId) {
      deferred.reject(new Error('playerId is required'));
      return deferred.promise;
    }

    gamification.deletePlayer({ uid: playerId })
      .then(
        function(deletedPlayer) {
          deferred.resolve({ id: playerId});
        }, 
        function(err) {
          deferred.reject(err);
        });

    return deferred.promise;
  };


  /**
   * @method addPlayerToGroup
   * @memberof GamificationController
   * @instance
   * @description Fetches a player entry in the gamification service
   * 
   * @param {Number} groupId - the groupId to add the player to
   * @param {Number} playerId - the playerId to be added
   *
   * @return {Promised} - of a json with the player and group ids 
   *                      of the form
   *                      { user: 19, group: 15 }
   */
  ctrl.addPlayerToGroup = function(groupId, playerId) {
    var deferred = when.defer();
    var errorHandler = function(err) { deferred.reject(err); };

    if(!groupId) {
      deferred.reject(new Error('groupId is required'));
      return deferred.promise;
    }

    if(!playerId) {
      deferred.reject(new Error('playerId is required'));
      return deferred.promise;
    }

    gamification.getPlayerById({ uid: groupId })
      .then(function(group) {
        if(!group) {
          // Groups are represented a player that can be followed
          ctrl.registerPlayer({ id: groupId })
            .then(function(groupCreated) {
              // check the group was created as expected
              makePlayerJoinGroup(playerId, groupCreated.uid)
                .then(function(result) {
                  deferred.resolve({ user: playerId, group: groupCreated.uid });
                }, errorHandler);
            }, errorHandler);
        } else {
          makePlayerJoinGroup(playerId, group.uid)
            .then(function(result) {
              deferred.resolve({ user: playerId, group: group.uid });
            }, errorHandler);
        }
      }); 

    return deferred.promise;
  };

  /**
   * @method getGroup
   * @memberof GamificationController
   * @instance
   * @description Fetches a gamification information of players in a 
   * 
   * @param {Number} - the group id of the desired group
   * @return {Promise} - the members of group as followers of the group user
   *                     as described in http://gs.ng.bluemix.net/index.html#Following 
   */
  ctrl.getGroup = function(groupId) {
    var deferred = when.defer();

    if(!groupId) {
      deferred.reject(new Error('groupId is required'));
      return deferred.promise;
    }

    gamification.getFollowers({ followeeId: groupId })
      .then(function(result) {
        deferred.resolve(result);
      }, function(err) {
        deferred.reject(err);
      });

    return deferred.promise;
  };

  /**
   * @method getGroupLeaderboard
   * @memberof GamificationController
   * @instance
   * @description Fetches the leaderboard for a giving group
   * 
   * @param {Number} - the group id of the desired group
   * @return {Promise} - with a json array of the following 
   *                      form. Note: the array is sorted in
   *                      decreasing order of 'total_points'
   *                     [
   *                       { 
   *                         id: 21,
   *                         groupId: 15,
   *                         name: 'player3',
   *                         total_points: 500,
   *                         timeline_achievements: [] 
   *                       },
   *                       ...
   *                     ]   
   */
  ctrl.getGroupLeaderboard = function(groupId) {
    var deferred = when.defer();
    var errorHandler = function(err) { deferred.reject(err); };

    if(!groupId) {
      deferred.reject(new Error('groupId is required'));
      return deferred.promise;
    }

    ctrl.getGroup(groupId)
      .then(function(groupPlayers) {
        var playerPromises = [];
        groupPlayers = groupPlayers || [];

        _.forEach(groupPlayers, function(groupPlayer) {
          playerPromises.push(ctrl.getPlayer(groupPlayer.follower.uid));
        });

        when.all(playerPromises)
          .then(function(playersDetails) {
            var sortedPlayers;
            var cleanedPlayers = [];

            _.forEach(playersDetails, function(playerDetails) {
              var badges = [];
              var points;

              _.forEach(playerDetails.userDeeds, function(deed) {
                badges.push(deed.deedName);
              });

              _.forOwn(playerDetails.varValues, function(userVar, key) {
                if(userVar.varName === "xp") {
                  points = userVar.value;
                }
              });

              cleanedPlayers.push({
                id: playerDetails.uid,
                groupId: groupId,
                name: playerDetails.firstName,
                total_points: points,
                timeline_achievements: badges
              });
            });

            // avoided use of lodash for sorting due to this results
            // http://jsperf.com/array-sort-vs-lodash-sort/2
            cleanedPlayers.sort(function compare(player1, player2) {
              var comparison = 0;
              if (player1.total_points > player2.total_points) {
                comparison = -1;
              } else if (player1.total_points < player2.total_points) {
                comparison = 1;
              }

              return comparison;
            });

            deferred.resolve(cleanedPlayers);
          });
      })
      .otherwise(errorHandler);

    return deferred.promise;
  };

  /**
   * @method getAllBadges
   * @memberof GamificationController
   * @instance
   * @description Retrieves all the badges in the app.
   *
   * @return {Promise.<Array.<Badge>>} - A promise of an Array 
   *         with all the badges in the app.
   */
  ctrl.getAllBadges = function() {
    var deferred = when.defer();

    gamification.getPlanInfo({
        planName: process.env.GAME_PLAN,
        key:      process.env.GAME_KEY
      }).then(function(plan) {
        var badges = [];

        _.forEach(plan.deeds, function(deed) {
          var mission = _.find(plan.missions, function(msn) {
            return msn.name === deed.name + "Mission";
          });

          badges.push(getBadgeInfo(deed, mission));
        });

        deferred.resolve(badges);
      }, function(err) {
        deferred.reject(err);
      });

    return deferred.promise;
  };

  /**
   * @method getBadge
   * @memberof GamificationController
   * @instance
   * @description Retrieves the specified badge.
   *
   * @param {String} badgeId - the id of the badge to be lookedup 
   * @return {Promise.<Badge>} - the badge that matches the name passed in.
   */
  ctrl.getBadge = function(badgeId) {
    var deferred = when.defer();
    var promises = [];

    if(!badgeId) {
      deferred.reject(new Error('badgeName is required'));
      return deferred.promise;
    }

    // A badge in our app is represented as the combiantion of a deeds
    // with a mission completed. This way we get the badge description 
    // (from the deed) as well as the effects of getting the badge 
    // (from the mission)
    promises.push(gamification.getDeedByName({ deedName: badgeId}));
    promises.push(gamification.getMissionByName({ missionName: badgeId + "Mission" }));

    when.all(promises)
      .then(function(results) {
        var deed = results[0];
        var mission = results[1];

        deferred.resolve(getBadgeInfo(deed, mission));
      })
      .otherwise(function(err) {
        deferred.reject(err);
      });

    return deferred.promise;
  };

  /**
   * @method getPlayerBadges
   * @memberof GamificationController
   * @instance
   * @description Retrieves all the badges for a specific user. This includes 
   *              all the badges in the app with the proper steps count and 
   *              the isEarned flag for each flag.
   *
   * @param <String> playerId - The id of the player 
   * @return {Promise.<Array.<UserBadge>>} - A promise of an Array 
   *         with all the badges for the user.
   */
  ctrl.getPlayerBadges = function(playerId) {
    var deferred = when.defer();

    if(!playerId) {
      deferred.reject(new Error('playerId is required'));
      return deferred.promise;
    }

    var promises =[];
    promises.push(ctrl.getAllBadges());
    promises.push(gamification.getEventHistory({}));
    
    when.all(promises)
      .then(function(results) {
        var badges = results[0];
        var eventHistory = results[1];

        // filter events for the player
        var playerHistory = [];
        _.forEach(eventHistory, function(event) {
          if(_.includes(event.eventSource, (','+playerId))) {
            playerHistory.push(event);
          }
        });

        // init badges for player
        _.forEach(badges, function(badge) {
          _.forEach(badge.steps, function(step) {
            step.playerCount = 0;
          });
        });

        // associate events with the appropiate badge(s)
        _.forEach(playerHistory, function(event) {
          var stepName = event.eventSource.split(',')[1];
          _.forEach(badges, function(badge) {
            var step = _.find(badge.steps, 'name' ,stepName);
            if(step) {
               ++step.playerCount;
            }
          });
        });

        _.forEach(badges, function(badge) {
          var isEarned = true;
          _.forEach(badge.steps, function(step) {
            isEarned =  isEarned && (step.playerCount >= step.reqCount);
          });

          badge.isEarned = isEarned;
        });

        deferred.resolve(badges);
      })
      .otherwise(function(err) {
        deferred.reject(err);
      });

    return deferred.promise;
  };

  /**
   * @method fireEvent
   * @memberof GamificationController
   * @instance
   * @description - Increses the completed count for a specific step 
   *                for a specific user.
   *
   * @param {String} stepName - the name of the step to be 
   *                 marked as completed.
   * @param {String} playerId - the id of the player that 
   *                 completed the step
   * @return {Promise} - A promise with the result of the form
   *                    { event: String, for: String }. Where
   *                    'event' is the event name and 'for' is 
   *                     the player ID
   */
  ctrl.completeStep = function(stepName, playerId) {
    var deferred = when.defer();

    if(!stepName) {
      deferred.reject(new Error('eventName is required'));
      return deferred.promise;
    }

    if(!playerId) {
      deferred.reject(new Error('playerId is required'));
      return deferred.promise;
    }

    var eventSrc = 'server,' + stepName + ',' + playerId;
    gamification.fireEvent({ eventName: stepName, eventSource: eventSrc, uid: playerId })
      .then(function(result) {
        deferred.resolve({ event: stepName, for: playerId });
      }, function(err) {
        deferred.reject(err);
      });

    return deferred.promise;
  };

  // ctrl.awardBadge = function(badgeName, receiverId) {
  //   var deferred = when.defer();
  //   var giving = {
  //     // Application convention is to create the 1-to-1
  //     // relation of missions and deed by naming missions
  //     // with the same name of the deed with the suffix
  //     // 'Mission'. NOTE: deeds represent badges in gamification.
  //     missionName: badgeName + "Mission",
  //     uid: receiverId
  //   };
  //   var successHandler = function(result) {
  //     var badgeAwarded = result.label.replace("Mission", "");
  //     deferred.resolve({to: receiverId, achievement: badgeAwarded});
  //   };
  //   var errorHandler = function(err) {
  //     try {
  //       err = JSON.parse(err);
  //       // is the mission is not activited for this user
  //       // for created and then award the completition
  //       if(_.includes(err.message, "There is no ongoing mission")) {
  //         gamification.startMission(giving)
  //           .then(function() {
  //             gamification.completeMission(giving)
  //               .then(successHandler)
  //               .otherwise(errorHandler);
  //           }, errorHandler);
  //       } else {
  //         deferred.reject(err); 
  //       }
  //     } catch (e) {
  //       deferred.reject(err);
  //     }
  //   };

    
  //   gamification.completeMission(giving)
  //     .then(successHandler)
  //     .otherwise(errorHandler);

  //   return deferred.promise;
  // };

  /* ----------------------------------------------------
   * Private functions 
   * ----------------------------------------------------*/

  /**
   * Helper function for 'adding' a player to a group.
   * This is achieved by making a player follow a user 
   * that represents the group.
   */
  function makePlayerJoinGroup(playerId, groupId) {
    var deferred = when.defer();
    var errorHandler = function(err) { deferred.reject(err); };

    gamification.requestFollow({ followerId: playerId, followeeId: groupId })
      .then(function(result) {
        if(result.state === "requested") {
          
          gamification.updateFollowRequestState({ 
            followerId: playerId, 
            followeeId: groupId, 
            state: "accepted"})
            .then(function(result) {
        
              if(result.state === "accepted") {
                deferred.resolve(result);
              } else {
                deferred.reject(new Error('Unable to accept playerId ' + playerId + ' request to join groupId ' + groupId));
              }
            });
        } else {
          deferred.reject(new Error('Unable send playerId ' + playerId + ' request to join groupId ' + groupId));
        }
      }, errorHandler);

    return deferred.promise;
  }

  /** 
   * Helper method for creating a Venue badge out of a deed 
   * and a mission from the gamification service.
   */
  function getBadgeInfo(deed, mission) {
    var completedEvent = _.find(mission.events, function(event) {
      return event.name === "completed";
    });
    var xpImpact = _.find(completedEvent.impacts, function(impact) {
      return impact.target === "vars.xp.value";
    });

    // this expects that the mission impact on xp has a formula of 
    // the form 'vars.xp.value+480'.
    var points = parseInt(xpImpact.formula.split('+')[1]);

    // expects steps as a string of the format 
    // "events.brickBlaster.counts>=1&&events.dustyTrail.counts>=1&&events.alpineAdventure.counts>=1"
    var steps = [];
    var stepStrings = mission.goalCriteria.split('&&');
    _.forEach(stepStrings, function(s) {
      var stepName = s.split('.')[1];
      var reqCount = parseInt(s.split('>=')[1]);
      steps.push({ name: stepName, reqCount: reqCount });
    });

    return  {
      id: deed.name,
      description: deed.description,
      name: deed.label,
      thumbnail_url: deed.imageUrl ? deed.imageUrl : "",
      steps: steps,
      points: points
    };
  } 

  return ctrl;
};