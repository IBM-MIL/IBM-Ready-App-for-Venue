/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
 'use strict';

var expect = require('chai').expect;
var sinon = require('sinon');
// add sinon capabilities for promises 
require('sinon-as-promised');

describe('Gamification Controller Unit Tests', function() { 
  var GamificationController = require('../../../api/gamification/gamification.controller');

  describe('registerPlayer(player)', function() {
    it('should reject no id is provided', function(done) {
      // Align
      var expectedErrorMsg = 'Player must have an id';

      var configureStub = sinon.stub();
      var registerPlayerStub = sinon.stub();
      var gamificationMock = { configure: configureStub };

      // Action
      var ctrl = new GamificationController({ gamification: gamificationMock });
      ctrl.registerPlayer({})
        .otherwise(function(err) {
          // Assert
          expect(configureStub.called).to.be.equal(true);        
          expect(err.message).to.be.equal(expectedErrorMsg);
          done(); 
        });
    });

    it('should reject when there is an Error from the Gamification Service', function(done) {
      // Align
      var expectedErrorMsg = 'Gamification error';

      var configureStub = sinon.stub();
      var registerPlayerStub = sinon.stub();
      registerPlayerStub.rejects(expectedErrorMsg);
      var gamificationMock = { configure: configureStub, registerPlayer: registerPlayerStub };

      // Action
      var ctrl = new GamificationController({ gamification: gamificationMock});
      ctrl.registerPlayer({ id: 19 })
        .otherwise(function(err) {
          // Assert
          expect(configureStub.called).to.be.equal(true);        
          expect(err.message).to.be.equal(expectedErrorMsg);
          done(); 
        });
    });

    it('should register player that is not part of a group', function(done) {
      // Align
      var expectedGameUserData = 'gamification Data';
      var expectedPlayer =  {
        id: 19,
        name: 'horhayP',
        data: expectedGameUserData
      };

      var configureStub = sinon.stub();
      var registerPlayerStub = sinon.stub();
      registerPlayerStub.resolves(expectedPlayer);
      var gamificationMock = { configure: configureStub, registerPlayer: registerPlayerStub };

      // Action
      var ctrl = new GamificationController({ gamification: gamificationMock});
      ctrl.registerPlayer({
          id: 19,
          name: 'horhayP'
        })
        .then(function(player) {
          // Assert
          expect(configureStub.called).to.be.equal(true);        
          expect(player.id).to.be.equal(expectedPlayer.id);
          expect(player.name).to.be.equal(expectedPlayer.name);
          expect(player.data).to.be.equal(expectedGameUserData);
          done(); 
        });
    });

    it('should register player that is part of a group that exist', function(done) {
      // Align
      var expectedGameUserData = 'gamification Data';
      var expectedGroupId = 15;
      var expectedPlayer =  {
        id: 19,
        groupId: expectedGroupId,
        name: 'horhayP',
        data: expectedGameUserData
      };
      var expectedGroup = { uid: expectedGroupId };

      var configureStub = sinon.stub();
      var registerPlayerStub = sinon.stub();
      registerPlayerStub.resolves(expectedPlayer);
      var getPlayerByIdStub = sinon.stub();
      getPlayerByIdStub.resolves(expectedGroup);
      var requestFollowStub = sinon.stub();
      requestFollowStub.resolves({ state: 'requested' });
      var updateFollowRequestStateStub = sinon.stub();
      updateFollowRequestStateStub.resolves({ state: 'accepted' });
      var gamificationMock = { 
        configure: configureStub, 
        registerPlayer: registerPlayerStub, 
        getPlayerById: getPlayerByIdStub,
        requestFollow: requestFollowStub,
        updateFollowRequestState: updateFollowRequestStateStub
      };

      // Action
      var ctrl = new GamificationController({ gamification: gamificationMock});
      ctrl.registerPlayer({
          id: 19,
          name: 'horhayP',
          group: 15
        })
        .then(function(player){
          // Assert        
          expect(configureStub.called).to.be.equal(true);        
    
          var registeredPlayer = registerPlayerStub.getCall(0).args[0].player;
          expect(registeredPlayer.uid).to.be.equal(expectedPlayer.id);  
          expect(registeredPlayer.firstName).to.be.equal(expectedPlayer.name);      

          var lookedUpGroup = getPlayerByIdStub.getCall(0).args[0];
          expect(lookedUpGroup.uid).to.be.equal(expectedGroupId); 

          var joinRequest = requestFollowStub.getCall(0).args[0];
          expect(joinRequest.followerId).to.be.equal(expectedPlayer.id); 
          expect(joinRequest.followeeId).to.be.equal(expectedGroupId); 
          
          var joinConfirmation = updateFollowRequestStateStub.getCall(0).args[0];
          expect(joinConfirmation.followerId).to.be.equal(expectedPlayer.id); 
          expect(joinConfirmation.followeeId).to.be.equal(expectedGroupId);  
          expect(joinConfirmation.state).to.be.equal('accepted');      

          expect(player.id).to.be.equal(expectedPlayer.id);    
          expect(player.groupId).to.be.equal(expectedGroupId);
          expect(player.name).to.be.equal(expectedPlayer.name);
          expect(player.data).to.be.equal(expectedGameUserData);
          done(); 
        });
    });
  });


  describe('getPlayer(playerId)', function() {
      it('should reject when no id is provided', function(done) {
        // Align
        var expectedErrorMsg = 'playerId is required';

        var configureStub = sinon.stub();
        var gamificationMock = { configure: configureStub };

        // Action
        var ctrl = new GamificationController({ gamification: gamificationMock});
        ctrl.getPlayer()
          .otherwise(function(err) {
            // Assert
            expect(configureStub.called).to.be.equal(true);
            expect(err.message).to.be.equal(expectedErrorMsg);
            done();
          });
      });

      it('should reject when there is an error from the Gamification Service', function(done) {
        // Align
        var expectedErrorMsg = 'Gamification error';

        var configureStub = sinon.stub();
        var getPlayerByIdStub = sinon.stub();
        getPlayerByIdStub.rejects(expectedErrorMsg);
        var gamificationMock = {
          configure: configureStub,
          getPlayerById: getPlayerByIdStub
        };

        // Action
        var ctrl = new GamificationController({ gamification: gamificationMock});
        ctrl.getPlayer(19)
          .otherwise(function(err) {
            // Assert
            expect(configureStub.called).to.be.equal(true);
            expect(err.message).to.be.equal(expectedErrorMsg);
            done();
          });
      });

      it('should fetch player record from gamification for the given playerId', function(done) {
        // Align
        var expectedPlayer = {
          uid: 19,
          data: 'gamification data'
        };

        var configureStub = sinon.stub();
        var getPlayerByIdStub = sinon.stub();
        getPlayerByIdStub.resolves(expectedPlayer);
        var gamificationMock = {
          configure: configureStub,
          getPlayerById: getPlayerByIdStub
        };

        // Action
        var ctrl = new GamificationController({ gamification: gamificationMock});
        ctrl.getPlayer(19)
          .then(function(player) {
            // Assert
            expect(configureStub.called).to.be.equal(true);

            expect(player.uid).to.be.equal(expectedPlayer.uid);
            expect(player.data).to.be.equal(expectedPlayer.data);
            done();
          });
      });
  });

describe('deletePlayer(playerId)', function() {
      it('should reject when no id is provided', function(done) {
        // Align
        var expectedErrorMsg = 'playerId is required';

        var configureStub = sinon.stub();
        var gamificationMock = { configure: configureStub };

        // Action
        var ctrl = new GamificationController({ gamification: gamificationMock});
        ctrl.deletePlayer()
          .otherwise(function(err) {
            // Assert
            expect(configureStub.called).to.be.equal(true);
            expect(err.message).to.be.equal(expectedErrorMsg);
            done();
          });
      });

      it('should reject when there is an error from the Gamification Service', function(done) {
        // Align
        var expectedErrorMsg = 'Gamification error';

        var configureStub = sinon.stub();
        var deletePlayerStub = sinon.stub();
        deletePlayerStub.rejects(expectedErrorMsg);
        var gamificationMock = {
          configure: configureStub,
          deletePlayer: deletePlayerStub
        };

        // Action
        var ctrl = new GamificationController({ gamification: gamificationMock});
        ctrl.deletePlayer(19)
          .otherwise(function(err) {
            // Assert
            expect(configureStub.called).to.be.equal(true);
            expect(err.message).to.be.equal(expectedErrorMsg);
            done();
          });
      });

      it('should delete player record from gamification for the given playerId', function(done) {
        // Align
        var expectedPlayer = { uid: 19 };

        var configureStub = sinon.stub();
        var deletePlayerStub = sinon.stub();
        deletePlayerStub.resolves(expectedPlayer);
        var gamificationMock = {
          configure: configureStub,
          deletePlayer: deletePlayerStub
        };

        // Action
        var ctrl = new GamificationController({ gamification: gamificationMock});
        ctrl.deletePlayer(19)
          .then(function(player) {
            // Assert
            expect(configureStub.called).to.be.equal(true);
            expect(player.id).to.be.equal(expectedPlayer.uid);
            done();
          });
      });
  });

  describe('addPlayerToGroup(playerId)', function() {
    it('should reject when no group id is provided', function(done) {
      // Align
      var expectedErrorMsg = 'groupId is required';
      var configureStub = sinon.stub();
      var gamificationMock = { configure: configureStub };

      // Action
      var ctrl = new GamificationController({ gamification: gamificationMock});
      ctrl.addPlayerToGroup(undefined, 19)
        .otherwise(function(err) {
          // Assert
          expect(configureStub.called).to.be.equal(true);

          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    });

    it('should reject when no player id is provided', function(done) {
      // Align
      var expectedErrorMsg = 'playerId is required';
      var configureStub = sinon.stub();
      var gamificationMock = { configure: configureStub };

      // Action
      var ctrl = new GamificationController({ gamification: gamificationMock});
      ctrl.addPlayerToGroup(15)
        .otherwise(function(err) {
          // Assert
          expect(configureStub.called).to.be.equal(true);

          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    });

    it('should add player to group that doesn\'t exist by first creating the group', function(done) {
      // Align
      var expectedGroupId = 15;
      var expectedPlayerId = 19;
      var expectGroup = { uid: expectedGroupId };

      var configureStub = sinon.stub();
      var getPlayerByIdStub = sinon.stub();
      getPlayerByIdStub.resolves(undefined);
      var registerPlayerStub = sinon.stub();
      registerPlayerStub.resolves(expectGroup);
      var requestFollowStub = sinon.stub();
      requestFollowStub.resolves({ state: 'requested' });
      var updateFollowRequestStateStub = sinon.stub();
      updateFollowRequestStateStub.resolves({ state: 'accepted' });
      var gamificationMock = { 
        configure: configureStub,
        getPlayerById: getPlayerByIdStub,
        registerPlayer: registerPlayerStub,
        requestFollow: requestFollowStub,
        updateFollowRequestState: updateFollowRequestStateStub
      };

      // Action
      var ctrl = new GamificationController({ gamification: gamificationMock});
      ctrl.addPlayerToGroup(15, 19)
        .then(function(result) {
          // Assert
          expect(configureStub.called).to.be.equal(true);

          var groupLookedUp = getPlayerByIdStub.getCall(0).args[0];
          expect(groupLookedUp.uid).to.be.equal(expectedGroupId);

          var registeredGroup = registerPlayerStub.getCall(0).args[0].player;
          expect(registeredGroup.uid).to.be.equal(expectedGroupId);
          expect(registeredGroup.firstName).to.be.equal(expectedGroupId);

          var joinRequest = requestFollowStub.getCall(0).args[0];
          expect(joinRequest.followerId).to.be.equal(expectedPlayerId);
          expect(joinRequest.followeeId).to.be.equal(expectedGroupId);

          var joinConfirmation = updateFollowRequestStateStub.getCall(0).args[0];
          expect(joinConfirmation.followerId).to.be.equal(expectedPlayerId);
          expect(joinConfirmation.followeeId).to.be.equal(expectedGroupId);
          expect(joinConfirmation.state).to.be.equal('accepted');

          expect(result.user).to.be.equal(expectedPlayerId);
          expect(result.group).to.be.equal(expectedGroupId);

          done();
        });
    });

    it('should add player to group that exist', function(done) {
      // Align
      var expectedGroupId = 15;
      var expectedPlayerId = 19;
      var expectGroup = { uid: expectedGroupId };

      var configureStub = sinon.stub();
      var getPlayerByIdStub = sinon.stub();
      getPlayerByIdStub.resolves(expectGroup);
      var requestFollowStub = sinon.stub();
      requestFollowStub.resolves({ state: 'requested' });
      var updateFollowRequestStateStub = sinon.stub();
      updateFollowRequestStateStub.resolves({ state: 'accepted' });
      var gamificationMock = { 
        configure: configureStub,
        getPlayerById: getPlayerByIdStub,
        requestFollow: requestFollowStub,
        updateFollowRequestState: updateFollowRequestStateStub
      };

      // Action
      var ctrl = new GamificationController({ gamification: gamificationMock});
      ctrl.addPlayerToGroup(15, 19)
        .then(function(result) {
          // Assert
          expect(configureStub.called).to.be.equal(true);

          var groupLookedUp = getPlayerByIdStub.getCall(0).args[0];
          expect(groupLookedUp.uid).to.be.equal(expectedGroupId);

          var joinRequest = requestFollowStub.getCall(0).args[0];
          expect(joinRequest.followerId).to.be.equal(expectedPlayerId);
          expect(joinRequest.followeeId).to.be.equal(expectedGroupId);

          var joinConfirmation = updateFollowRequestStateStub.getCall(0).args[0];
          expect(joinConfirmation.followerId).to.be.equal(expectedPlayerId);
          expect(joinConfirmation.followeeId).to.be.equal(expectedGroupId);
          expect(joinConfirmation.state).to.be.equal('accepted');

          expect(result.user).to.be.equal(expectedPlayerId);
          expect(result.group).to.be.equal(expectedGroupId);

          done();
        });
    });
  });
  
  describe('getGroup(groupId)', function() {
    it('should reject no group id is provided', function(done) {
      // Align
      var expectedErrorMsg = 'groupId is required';
      var configureStub = sinon.stub();
      var gamificationMock = { configure: configureStub };

      // Action
      var ctrl = new GamificationController({ gamification: gamificationMock});
      ctrl.getGroup()
        .otherwise(function(err) {
          // Assert
          expect(configureStub.called).to.be.equal(true);
          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    });

    it('should reject when there is a gamification service error', function(done) {
      // Align
      var expectedErrorMsg = 'Gamification error';
      var configureStub = sinon.stub();
      var getFollowersStub = sinon.stub();
      getFollowersStub.rejects(expectedErrorMsg);
      var gamificationMock = { 
        configure: configureStub,
        getFollowers: getFollowersStub 
      };

      // Action
      var ctrl = new GamificationController({ gamification: gamificationMock});
      ctrl.getGroup(15)
        .otherwise(function(err) {
          // Assert
          expect(configureStub.called).to.be.equal(true);
          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    });

    it('should fetch the group', function(done) {
      // Align
      var expectedGroupId = 15;
      var expectedGroup = [
        {
          uid: 19,
          data: 'player 1 data'
        },
        {
          uid: 21,
          data: 'player 2 data'
        }
      ];
      var configureStub = sinon.stub();
      var getFollowersStub = sinon.stub();
      getFollowersStub.resolves(expectedGroup);
      var gamificationMock = { 
        configure: configureStub,
        getFollowers: getFollowersStub 
      };

      // Action
      var ctrl = new GamificationController({ gamification: gamificationMock});
      ctrl.getGroup(15)
        .then(function(group) {
          // Assert
          expect(configureStub.called).to.be.equal(true);

          var groupQuery = getFollowersStub.getCall(0).args[0];
          expect(groupQuery.followeeId).to.be.equal(expectedGroupId);

          expect(group.length).to.be.equal(expectedGroup.length);
          expect(group[0].id).to.be.equal(expectedGroup[0].id);
          expect(group[0].data).to.be.equal(expectedGroup[0].data);
          expect(group[1].id).to.be.equal(expectedGroup[1].id);
          expect(group[1].data).to.be.equal(expectedGroup[1].data);
          done();
        });
    });
  });
  
  describe('getGroupLeaderboard(groupId)', function() {
    it('should reject no group id is provided', function(done) {
      // Align
      var expectedErrorMsg = 'groupId is required';
      var configureStub = sinon.stub();
      var gamificationMock = { configure: configureStub };

      // Action
      var ctrl = new GamificationController({ gamification: gamificationMock});
      ctrl.getGroupLeaderboard()
        .otherwise(function(err) {
          // Assert
          expect(configureStub.called).to.be.equal(true);

          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    });

    it('should reject when there is an gamification SDK error', function(done) {
      // Align
      var expectedErrorMsg = 'Gamification error';
      var configureStub = sinon.stub();
      var getFollowersStub = sinon.stub();
      getFollowersStub.rejects(expectedErrorMsg);
      var gamificationMock = { 
        getFollowers: getFollowersStub,
        configure: configureStub
      };

      // Action
      var ctrl = new GamificationController({ 

        gamification: gamificationMock
      });
      ctrl.getGroupLeaderboard(15)
        .otherwise(function(err) {
          // Assert
          expect(configureStub.called).to.be.equal(true);

          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    });

    it('should fetch a group leaderboard', function(done) {
      // Align
      var expectedGroupId = 15;
      var expectedGroup = [
        { follower: { uid: 5, data: 'player 1 data' } },
        { follower: { uid: 19, data: 'player 2 data' } },
        { follower: { uid: 21, data: 'player 3 data' } }
      ];
      var expected3rd = { 
        uid: 21,
        firstName: 'player3',
        userDeeds: [], 
        varValues: [{varName: 'xp', value: 0 }, {varName: 'life', value: 100 }] 
      };
      var expected1st = { 
        uid: 5,
        firstName: 'player1',
        userDeeds: [{ deedName: 'deed1' }, { deedName: 'deed2' }], 
        varValues: [{varName: 'xp', value: 500 }, {varName: 'life', value: 100 }] 
      };
      var expected2nd = { 
        uid: 19,
        firstName: 'player2',
        userDeeds: [{ deedName: 'deed1' }], 
        varValues: [{varName: 'xp', value: 250 }, {varName: 'life', value: 100 }] 
      };
      var expectedLeaderboard = [expected1st, expected2nd, expected3rd];

      var configureStub = sinon.stub();
      var getFollowersStub = sinon.stub();
      getFollowersStub.resolves(expectedGroup);
      var getPlayerByIdStub = sinon.stub();
      getPlayerByIdStub.withArgs({uid: 21}).resolves(expected3rd);
      getPlayerByIdStub.withArgs({uid: 5}).resolves(expected1st);
      getPlayerByIdStub.withArgs({uid: 19}).resolves(expected2nd);
      var gamificationMock = { 
        getFollowers: getFollowersStub,
        getPlayerById: getPlayerByIdStub,
        configure: configureStub
      }; 

      // Action
      var ctrl = new GamificationController({ 

        gamification: gamificationMock
      });
      ctrl.getGroupLeaderboard(15)
        .then(function(leaderboard) {
          // Assert
          expect(configureStub.called).to.be.equal(true);

          var groupQuery = getFollowersStub.getCall(0).args[0];
          expect(groupQuery.followeeId).to.be.equal(expectedGroupId);

          expect(getPlayerByIdStub.callCount).to.be.equal(3);

          expect(leaderboard.length).to.be.equal(expectedLeaderboard.length);

          expect(leaderboard[0].id).to.be.equal(expected1st.uid);
          expect(leaderboard[0].groupId).to.be.equal(expectedGroupId);
          expect(leaderboard[0].name).to.be.equal(expected1st.firstName);
          expect(leaderboard[0].total_points).to.be.equal(expected1st.varValues[0].value);
          var achievements = leaderboard[0].timeline_achievements;
          expect(achievements.length).to.be.equal(expected1st.userDeeds.length);
          expect(achievements[0]).to.be.equal(expected1st.userDeeds[0].deedName);
          expect(achievements[1]).to.be.equal(expected1st.userDeeds[1].deedName);

          expect(leaderboard[1].id).to.be.equal(expected2nd.uid);
          expect(leaderboard[1].groupId).to.be.equal(expectedGroupId);
          expect(leaderboard[1].name).to.be.equal(expected2nd.firstName);
          expect(leaderboard[1].total_points).to.be.equal(expected2nd.varValues[0].value);
          achievements = leaderboard[1].timeline_achievements;
          expect(achievements.length).to.be.equal(expected2nd.userDeeds.length);
          expect(achievements[0]).to.be.equal(expected2nd.userDeeds[0].deedName);

          expect(leaderboard[2].id).to.be.equal(expected3rd.uid);
          expect(leaderboard[2].groupId).to.be.equal(expectedGroupId);
          expect(leaderboard[2].name).to.be.equal(expected3rd.firstName);
          expect(leaderboard[2].total_points).to.be.equal(expected3rd.varValues[0].value);
          achievements = leaderboard[2].timeline_achievements;
          expect(achievements.length).to.be.equal(expected3rd.userDeeds.length);
          done();
        });
    });
  });

  
  describe('getAllBadges()', function() {
    it('should reject when there is an error from the Gamification sdk', function(done) {
      // Align
      var expectedErrorMsg = 'Gamification error';
      var configureStub = sinon.stub();
      var getPlanInfoStub = sinon.stub();
      getPlanInfoStub.rejects(expectedErrorMsg);
      var gamificationMock = { 
        getPlanInfo: getPlanInfoStub,
        configure: configureStub
      };

      // Action
      var ctrl = new GamificationController({ gamification: gamificationMock });
      ctrl.getAllBadges()
        .otherwise(function(err) {
          // Assert
          expect(configureStub.called).to.be.equal(true);
          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    }); 

    it('should fetch the current game plan\'s badges', function(done) {
      // Align
      var testPlan = require('../demo/data/gameplan.js').plan;
      var testEnv = require('../../../config/testEnv.js');
      var expectedBadges = [
        { "id": "rideChampion", "description": "", "name": "Ride Champion",
            "thumbnail_url": "", "points": 100,
            "steps": [
              { "name": "rideCompleted", "reqCount": 5 }
            ]
        },
        { "id": "selfieSultan", "description": "", "name": "Selfie Sultan",
            "thumbnail_url": "", "points": 50,
            "steps": [
              { "name": "pictureShared", "reqCount": 3 }
            ]
        },
        { "id": "familyFun", "description": "", "name": "Family Fun",
            "thumbnail_url": "", "points": 50,
            "steps": [
              { "name": "brickBlaster", "reqCount": 1},
              { "name": "dustyTrail", "reqCount": 1 },
              { "name": "alpineAdventure", "reqCount": 1}
            ]
        }
      ];

      var configureStub = sinon.stub();
      var getPlanInfoStub = sinon.stub();
      getPlanInfoStub.resolves(testPlan);
      var gamificationMock = { 
        getPlanInfo: getPlanInfoStub,
        configure: configureStub
      };

      // Action
      var ctrl = new GamificationController({ gamification: gamificationMock });
      ctrl.getAllBadges()
        .then(function(badges) {
          // Assert
          expect(configureStub.called).to.be.equal(true);

          var planQueried = getPlanInfoStub.getCall(0).args[0];
          expect(planQueried.planName).to.be.equal(testEnv.GAME_PLAN);
          expect(planQueried.key).to.be.equal(testEnv.GAME_KEY);

          expect(badges.length).to.be.equal(expectedBadges.length);
          expect(badges[0].id).to.be.equal(expectedBadges[0].id);
          expect(badges[0].description).to.be.equal(expectedBadges[0].description);
          expect(badges[0].name).to.be.equal(expectedBadges[0].name);
          expect(badges[0].thumbnail_url).to.be.equal(expectedBadges[0].thumbnail_url);
          expect(badges[0].points).to.be.equal(expectedBadges[0].points);
          var steps = badges[0].steps;
          expect(steps.length).to.be.equal(expectedBadges[0].steps.length);
          expect(steps[0].name).to.be.equal(expectedBadges[0].steps[0].name);
          expect(steps[0].reqCount).to.be.equal(expectedBadges[0].steps[0].reqCount);

          expect(badges[1].id).to.be.equal(expectedBadges[1].id);
          expect(badges[1].description).to.be.equal(expectedBadges[1].description);
          expect(badges[1].name).to.be.equal(expectedBadges[1].name);
          expect(badges[1].thumbnail_url).to.be.equal(expectedBadges[1].thumbnail_url);
          expect(badges[1].points).to.be.equal(expectedBadges[1].points);
          steps = badges[1].steps;
          expect(steps.length).to.be.equal(expectedBadges[1].steps.length);
          expect(steps[0].name).to.be.equal(expectedBadges[1].steps[0].name);
          expect(steps[0].reqCount).to.be.equal(expectedBadges[1].steps[0].reqCount);

          expect(badges[2].id).to.be.equal(expectedBadges[2].id);
          expect(badges[2].description).to.be.equal(expectedBadges[2].description);
          expect(badges[2].name).to.be.equal(expectedBadges[2].name);
          expect(badges[2].thumbnail_url).to.be.equal(expectedBadges[2].thumbnail_url);
          expect(badges[2].points).to.be.equal(expectedBadges[2].points);
          steps = badges[2].steps;
          expect(steps.length).to.be.equal(expectedBadges[2].steps.length);
          expect(steps[0].name).to.be.equal(expectedBadges[2].steps[0].name);
          expect(steps[0].reqCount).to.be.equal(expectedBadges[2].steps[0].reqCount);
          expect(steps[1].name).to.be.equal(expectedBadges[2].steps[1].name);
          expect(steps[1].reqCount).to.be.equal(expectedBadges[2].steps[1].reqCount);
          expect(steps[2].name).to.be.equal(expectedBadges[2].steps[2].name);
          expect(steps[2].reqCount).to.be.equal(expectedBadges[2].steps[2].reqCount);
          done();
        });
    }); 
  });

 describe('getBadge(badgeName)', function() {
    it('should reject when no badgeName is provided', function(done) {
      // Align
      var expectedErrorMsg = 'badgeName is required';
      var configureStub = sinon.stub();
      var getDeedByNameStub = sinon.stub();
      getDeedByNameStub.rejects(expectedErrorMsg);
      var gamificationMock = { 
        getDeedByName: getDeedByNameStub,
        configure: configureStub
      };

      // Action
      var ctrl = new GamificationController({ gamification: gamificationMock });
      ctrl.getBadge()
        .otherwise(function(err) {
          // Assert
          expect(configureStub.called).to.be.equal(true);
          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    });

    it('should reject when there is an error from the Gamification sdk', function(done) {
      // Align
      var expectedErrorMsg = 'Gamification error';
      var configureStub = sinon.stub();
      var getDeedByNameStub = sinon.stub();
      getDeedByNameStub.rejects(expectedErrorMsg);
      var gamificationMock = { 
        getDeedByName: getDeedByNameStub,
        getMissionByName: sinon.stub(),
        configure: configureStub
      };

      // Action
      var ctrl = new GamificationController({ gamification: gamificationMock });
      ctrl.getBadge('test')
        .otherwise(function(err) {
          // Assert
          expect(configureStub.called).to.be.equal(true);
          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    });

    it('should fetch the badge for the given name', function(done) {
      // Align
      var expectedDeedName = 'test';
      var expectedMissionName = 'testMission';
      var testDeed = { "name": "test", "label": "Test Badge",
        "description": "", "type": "badge", "criteria": "deeds.familyFun", 
        "accumulative": false, "shared": false, "imageType": "default", 
        "imageBase64": "", "imageUrl": ""
      };
      var testMission = {
        "name": "testMission", "label": "Test Badge Mission",
        "description": "", "autoAccept": true, "timeBounded": false,
        "enabled": true, 
        "goalCriteria": "events.brickBlaster.counts>=1&&events.dustyTrail.counts>=5",
        "events": [
          {
            "name": "completed",
            "impacts": [
              { "target": "deeds.familyFun", "formula": "true" },
              { "target": "vars.xp.value", "formula": "vars.xp.value+50" }
            ]
          }
        ]
      };
      var expectedBadge = { id: 'test', description: '',
        name: 'Test Badge', thumbnail_url: '', points: 50,
        steps: 
         [ { name: 'brickBlaster', reqCount: 1 }, 
           { name: 'dustyTrail', reqCount: 5 } ] };

      var configureStub = sinon.stub();
      var getDeedByNameStub = sinon.stub();
      getDeedByNameStub.resolves(testDeed);
      var getMissionByNameStub = sinon.stub();
      getMissionByNameStub.resolves(testMission);
      var gamificationMock = { 
        getDeedByName: getDeedByNameStub,
        getMissionByName: getMissionByNameStub,
        configure: configureStub
      };

      // Action
      var ctrl = new GamificationController({ gamification: gamificationMock });
      ctrl.getBadge('test')
        .then(function(badge) {
          // Assert
          expect(configureStub.called).to.be.equal(true);

          var deed = getDeedByNameStub.getCall(0).args[0];
          expect(deed.deedName).to.be.equal(expectedDeedName);

          var mission = getMissionByNameStub.getCall(0).args[0];
          expect(mission.missionName).to.be.equal(expectedMissionName);

          expect(badge.id).to.be.equal(expectedBadge.id);
          expect(badge.description).to.be.equal(expectedBadge.description);
          expect(badge.name).to.be.equal(expectedBadge.name);
          expect(badge.thumbnail_url).to.be.equal(expectedBadge.thumbnail_url);
          expect(badge.points).to.be.equal(expectedBadge.points);
          expect(badge.steps.length).to.be.equal(expectedBadge.steps.length);
          expect(badge.steps[0].name).to.be.equal(expectedBadge.steps[0].name);
          expect(badge.steps[0].reqCount).to.be.equal(expectedBadge.steps[0].reqCount);
          expect(badge.steps[1].name).to.be.equal(expectedBadge.steps[1].name);
          expect(badge.steps[1].reqCount).to.be.equal(expectedBadge.steps[1].reqCount);
          done();
        });
    });
  });
  

  describe('getPlayerBadges(playerId)', function() {
    it('should reject when no player ID is provided', function(done) {
      // Align
      var expectedErrorMsg = 'playerId is required';
      var configureStub = sinon.stub();
      var gamificationMock = { configure: configureStub };

      // Action
      var ctrl = new GamificationController({ gamification: gamificationMock });
      ctrl.getPlayerBadges()
        .otherwise(function(err) {
          // Assert
          expect(configureStub.called).to.be.equal(true);
          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    }); 

    it('should reject when there is an error from the Gamification SDK', function(done) {
      // Align
      var expectedErrorMsg = 'Gamification Error';
      var configureStub = sinon.stub();
      var getPlanInfoStub = sinon.stub();
      getPlanInfoStub.rejects(expectedErrorMsg);
      var gamificationMock = { 
        configure: configureStub, 
        getPlanInfo: getPlanInfoStub,
        getEventHistory: sinon.stub()
      };

      // Action
      var ctrl = new GamificationController({ gamification: gamificationMock });
      ctrl.getPlayerBadges(19)
        .otherwise(function(err) {
          // Assert
          expect(configureStub.called).to.be.equal(true);
          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    }); 

    it('should fetch the badges for the requested user ', function(done) {
      // Align
      var testPlan = require('../demo/data/gameplan.js').plan;
      var testEventHistory = [
        { eventSource: "server,rideChampion,21" },
        { eventSource: "server,pictureShared,19" },
        { eventSource: "server,pictureShared,15" },
        { eventSource: "server,pictureShared,19" },
        { eventSource: "server,pictureShared,19" },
        { eventSource: "server,brickBlaster,19" },
        { eventSource: "server,dustyTrail,19" },
        { eventSource: "server,alpineAdventure,19" }
      ];
      var expectedBadges = [
        { 
          "id": "rideChampion", "description": "", "points": 100,
          "name": "Ride Champion", "thumbnail_url": "", "isEarned": false,
          "steps": [ { "name": "rideCompleted", "reqCount": 5, "playerCount": 0 } ]
        },
        { 
          "id": "selfieSultan", "description": "", "points": 50,
          "name": "Selfie Sultan", "thumbnail_url": "", "isEarned": true,
          "steps": [ { "name": "pictureShared", "reqCount": 3, "playerCount": 3 } ]
        },
        { 
          "id": "familyFun", "description": "", "points": 50,
          "name": "Family Fun", "thumbnail_url": "", "isEarned": true,
          "steps": [ 
            { "name": "brickBlaster", "reqCount": 1, "playerCount": 1 },
            { "name": "dustyTrail", "reqCount": 1, "playerCount": 1 },
            { "name": "alpineAdventure", "reqCount": 1, "playerCount": 1 } 
          ]
        }
      ];

      var configureStub = sinon.stub();
      var getPlanInfoStub = sinon.stub();
      getPlanInfoStub.resolves(testPlan);
      var getEventHistoryStub = sinon.stub();
      getEventHistoryStub.resolves(testEventHistory);
      var gamificationMock = { 
        getPlanInfo: getPlanInfoStub,
        getEventHistory: getEventHistoryStub,
        configure: configureStub
      };

      // Action
      var ctrl = new GamificationController({ gamification: gamificationMock });
      ctrl.getPlayerBadges(19)
        .then(function(badges) {
          // Assert
          expect(configureStub.called).to.be.equal(true);

          expect(badges.length).to.be.equal(expectedBadges.length);
          expect(badges[0].id).to.be.equal(expectedBadges[0].id);
          expect(badges[0].description).to.be.equal(expectedBadges[0].description);
          expect(badges[0].name).to.be.equal(expectedBadges[0].name);
          expect(badges[0].thumbnail_url).to.be.equal(expectedBadges[0].thumbnail_url);
          expect(badges[0].points).to.be.equal(expectedBadges[0].points);
          expect(badges[0].isEarned).to.be.equal(expectedBadges[0].isEarned);
          expect(badges[0].steps.length).to.be.equal(expectedBadges[0].steps.length);
          expect(badges[0].steps[0].name).to.be.equal(expectedBadges[0].steps[0].name);
          expect(badges[0].steps[0].reqCount).to.be.equal(expectedBadges[0].steps[0].reqCount);
          expect(badges[0].steps[0].playerCount).to.be.equal(expectedBadges[0].steps[0].playerCount);

          expect(badges[1].id).to.be.equal(expectedBadges[1].id);
          expect(badges[1].description).to.be.equal(expectedBadges[1].description);
          expect(badges[1].name).to.be.equal(expectedBadges[1].name);
          expect(badges[1].thumbnail_url).to.be.equal(expectedBadges[1].thumbnail_url);
          expect(badges[1].points).to.be.equal(expectedBadges[1].points);
          expect(badges[1].isEarned).to.be.equal(expectedBadges[1].isEarned);
          expect(badges[1].steps.length).to.be.equal(expectedBadges[1].steps.length);
          expect(badges[1].steps[0].name).to.be.equal(expectedBadges[1].steps[0].name);
          expect(badges[1].steps[0].reqCount).to.be.equal(expectedBadges[1].steps[0].reqCount);
          expect(badges[1].steps[0].playerCount).to.be.equal(expectedBadges[1].steps[0].playerCount);

          expect(badges[2].id).to.be.equal(expectedBadges[2].id);
          expect(badges[2].description).to.be.equal(expectedBadges[2].description);
          expect(badges[2].name).to.be.equal(expectedBadges[2].name);
          expect(badges[2].thumbnail_url).to.be.equal(expectedBadges[2].thumbnail_url);
          expect(badges[2].points).to.be.equal(expectedBadges[2].points);
          expect(badges[2].isEarned).to.be.equal(expectedBadges[2].isEarned);
          expect(badges[2].steps.length).to.be.equal(expectedBadges[2].steps.length);
          expect(badges[2].steps[0].name).to.be.equal(expectedBadges[2].steps[0].name);
          expect(badges[2].steps[0].reqCount).to.be.equal(expectedBadges[2].steps[0].reqCount);
          expect(badges[2].steps[0].playerCount).to.be.equal(expectedBadges[2].steps[0].playerCount);
          expect(badges[2].steps[1].name).to.be.equal(expectedBadges[2].steps[1].name);
          expect(badges[2].steps[1].reqCount).to.be.equal(expectedBadges[2].steps[1].reqCount);
          expect(badges[2].steps[1].playerCount).to.be.equal(expectedBadges[2].steps[1].playerCount);
          expect(badges[2].steps[2].name).to.be.equal(expectedBadges[2].steps[2].name);
          expect(badges[2].steps[2].reqCount).to.be.equal(expectedBadges[2].steps[2].reqCount);
          expect(badges[2].steps[2].playerCount).to.be.equal(expectedBadges[2].steps[2].playerCount);

          done();
        });
    }); 
  });

  describe('completeStep(stepName, playerId)', function() {
    it('should reject when no event name is provided', function(done) {
      // Align
      var expectedErrorMsg = 'eventName is required';
      var configureStub = sinon.stub();
      var gamificationMock = { configure: configureStub };

      // Action
      var ctrl = new GamificationController({ gamification: gamificationMock });
      ctrl.completeStep(undefined, 19)
        .otherwise(function(err) {
          // Assert
          expect(configureStub.called).to.be.equal(true);
          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    }); 

    it('should reject when no player ID is provided', function(done) {
      // Align
      var expectedErrorMsg = 'playerId is required';
      var configureStub = sinon.stub();
      var gamificationMock = { configure: configureStub };

      // Action
      var ctrl = new GamificationController({ gamification: gamificationMock });
      ctrl.completeStep('testEvent')
        .otherwise(function(err) {
          // Assert
          expect(configureStub.called).to.be.equal(true);
          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    }); 

    it('should reject when there is an error from the Gamification sdk', function(done) {
      // Align
      var expectedErrorMsg = 'Gamification error';
      var configureStub = sinon.stub();
      var fireEventStub = sinon.stub();
      fireEventStub.rejects(expectedErrorMsg);
      var gamificationMock = { 
        fireEvent: fireEventStub,
        configure: configureStub
      };

      // Action
      var ctrl = new GamificationController({ gamification: gamificationMock });
      ctrl.completeStep('testEvent', 19)
        .otherwise(function(err) {
          // Assert
          expect(configureStub.called).to.be.equal(true);
          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    }); 

    it('should fire the specifiedevent for the expecified user', function(done) {
      // Align
      var expectedEventName = 'testEvent';
      var expectedEventSrc = 'server,testEvent,19';
      var expectedUId = 19;
      var expectedFired = { event: expectedEventName, for: expectedUId};

      var configureStub = sinon.stub();
      var fireEventStub = sinon.stub();
      fireEventStub.resolves(expectedFired);
      var gamificationMock = { 
        fireEvent: fireEventStub,
        configure: configureStub
      };

      // Action
      var ctrl = new GamificationController({ gamification: gamificationMock });
      ctrl.completeStep('testEvent', 19)
        .then(function(eventFired) {
          // Assert
          expect(configureStub.called).to.be.equal(true);

          var fireParams = fireEventStub.getCall(0).args[0];
          expect(fireParams.eventName).to.be.equal(expectedEventName);
          expect(fireParams.eventSource).to.be.equal(expectedEventSrc);
          expect(fireParams.uid).to.be.equal(expectedUId);

          expect(eventFired.event).to.be.equal(expectedFired.event);
          expect(eventFired.for).to.be.equal(expectedFired.for);
          done();
        });
    }); 
  });
});