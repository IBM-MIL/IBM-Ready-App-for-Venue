/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
 'use strict';

var expect = require('chai').expect;
var sinon = require('sinon');
// add sinon capabilities for promises 
require('sinon-as-promised');

describe('User Controller Unit Tests', function() {  
  var UserController = require('../../../api/users/user.controller');
  var testUser = { 
    "id": "19",
    "group": "501", 
    "first_name": "Rex",
    "last_name": "CT",
    "pictureUrl": "www.img.url.com/profilePic",
    "phone_number": "(555) 555-5555",
    "email": "email@domain.co",
    "totalPoints": 9001,
    "achievements": [ "MileHighClub", "CoasterChamp" ],
    "favorites":  [ 3, 2, 1, 0 ],
    "notifications_recieved":  [ 0, 1, 2, 3 ]
  };

  describe('insertUser(user)', function() {
    it('should reject the promise when no user is provided', function(done) {
      // Align
      var expectedErrorMsg = 'user is required';

      // Action
      var ctrl = new UserController({});
      ctrl.insertUser()
        .otherwise(function(err) {
          // Assert
          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    });
    
    it('should reject when there is an error saving to database', function(done) {
      // Align
      var expectedErrorMsg = 'DB Error';

      var insertStub = sinon.stub();
      insertStub.rejects(expectedErrorMsg);
      var dbHelperMock = { insert: insertStub };

      // Action
      var ctrl = new UserController({ dbHelper: dbHelperMock });
      ctrl.insertUser(testUser)
        .otherwise(function(err) {
          // Assert
          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    });

    it('should reject when there is an error saving to the Gamification Service', function(done) {
      // Align
      var expectedErrorMsg = 'Gamification Error';

      var insertStub = sinon.stub();
      insertStub.resolves(testUser);
      var dbHelperMock = { insert: insertStub };


      var registerPlayerStub = sinon.stub();
      registerPlayerStub.rejects(expectedErrorMsg);
      var GameCtrlMock = { registerPlayer: registerPlayerStub };

      // Action
      var ctrl = new UserController({ dbHelper: dbHelperMock, gamificationCtrl: GameCtrlMock });
      ctrl.insertUser(testUser)
        .otherwise(function(err) {
          // Assert
          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    });


    it('should save user to db and create gamification player when valid user is given', function(done){
      // Align
      var expectedId = '19';
      var expectedUser = shallowCopy(testUser);

      var insertStub = sinon.stub();
      var userRecord = shallowCopy(testUser);
      userRecord.id = expectedId;
      insertStub.resolves(userRecord);
      var dbHelperMock = { insert: insertStub };

      var registerPlayerStub = sinon.stub();
      registerPlayerStub.resolves();
      var GameCtrlMock = { registerPlayer: registerPlayerStub };

      // Action
      var ctrl = new UserController({ dbHelper: dbHelperMock, gamificationCtrl: GameCtrlMock });
      ctrl.insertUser(expectedUser) 
        .then(function(insertedUser) {
          // Assert
          expectedUser.id = expectedId;

          // call to gamification
          var playerSent = registerPlayerStub.getCall(0).args[0];
          expect(playerSent.id).to.be.equal(expectedUser.id);
          expect(playerSent.name).to.be.equal(expectedUser.first_name);
          expect(playerSent.groupId).to.be.equal(expectedUser.group);

          // final result
          expectUsersToBeEqual(insertedUser, expectedUser);
          done();
        });
    });
  });

  describe('getUser(userId)', function() {
    it('should reject the promise when no userId is provided', function(done) {
      // Align
      var expectedErrorMsg = 'userId required';

      // Action
      var ctrl = new UserController({});
      ctrl.getUser()
        .otherwise(function(err) {
          // Assert
          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    });

    it('should reject when there is an error fetching from the database', function(done) {
      // Align
      var expectedErrorMsg = 'DB Error';

      var getEntryByIdStub = sinon.stub();
      getEntryByIdStub.rejects(expectedErrorMsg);
      var dbHelperMock = { getEntryById: getEntryByIdStub };

      // Action
      var ctrl = new UserController({ dbHelper: dbHelperMock });
      ctrl.getUser("19")
        .otherwise(function(err) {
          // Assert
          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    });

    it('should fetch the appropiate user giving a userId', function(done) {
      // Align
      var expectedTableName = "myTestTable";
      var expectedId = "19";

      var getUserStub = sinon.stub();
      getUserStub.resolves(testUser);
      var dbHelperMock = { USERS_TABLE: expectedTableName, getEntryById: getUserStub };

      // Action
      var ctrl = new UserController({ dbHelper: dbHelperMock });
      ctrl.getUser(expectedId)
        .then(function(user) {
          // Assert

          // db call
          var queriedTable = getUserStub.getCall(0).args[0];          
          var queriedId = getUserStub.getCall(0).args[1];
          expect(queriedTable).to.be.equal(expectedTableName);
          expect(queriedId).to.be.equal(expectedId);

          // final result
          expectUsersToBeEqual(user, testUser);
          done();
        });
    });
  });
  
  describe('getAllUsers()', function() {
      it('should reject when there is an error fetching from the database', function(done) {
      // Align
      var expectedErrorMsg = 'DB Error';

      var getAllEntriesStub = sinon.stub();
      getAllEntriesStub.rejects(expectedErrorMsg);
      var dbHelperMock = { getAllEntries: getAllEntriesStub };

      // Action
      var ctrl = new UserController({ dbHelper: dbHelperMock });
      ctrl.getAllUsers()
        .otherwise(function(err) {
          // Assert
          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    });

    it('should fetch all the users in the database', function(done) {
      // Align
      var expectedTableName = "myTestTable";
      var expectedUsers = [testUser, testUser, testUser];

      var getAllEntriesStub = sinon.stub();
      getAllEntriesStub.resolves([testUser, testUser, testUser]);
      var dbHelperMock = { USERS_TABLE: expectedTableName, getAllEntries: getAllEntriesStub };

      // Action
      var ctrl = new UserController({ dbHelper: dbHelperMock });
      ctrl.getAllUsers()
        .then(function(users) {
          // Assert

          // db call
          var queriedTable = getAllEntriesStub.getCall(0).args[0];   
          expect(queriedTable).to.be.equal(expectedTableName);

          // final result
          expect(users.length).to.be.equal(expectedUsers.length);
          expectUsersToBeEqual(users[0], expectedUsers[0]);
          expectUsersToBeEqual(users[1], expectedUsers[1]);
          expectUsersToBeEqual(users[2], expectedUsers[2]);

          done();
        });
    });
  });

  describe('getGroup(groupId)', function() {
    it('should reject the promise when no groupId is provided', function(done) {
      // Align
      var expectedErrorMsg = 'groupId required';

      // Action
      var ctrl = new UserController({});
      ctrl.getGroup()
        .otherwise(function(err) {
          // Assert
          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    });

    it('should reject when there is an error fetching from the database', function(done) {
      // Align
      var expectedErrorMsg = 'DB Error';

      var getFilteredEntriesStub = sinon.stub();
      getFilteredEntriesStub.rejects(expectedErrorMsg);
      var dbHelperMock = { getFilteredEntries: getFilteredEntriesStub };

      // Action
      var ctrl = new UserController({ dbHelper: dbHelperMock });
      ctrl.getGroup("501")
        .otherwise(function(err) {
          // Assert
          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    });

    it('should fetch the appropiate users giving a groupId', function(done) {
      // Align
      var expectedTableName = "myTestTable";
      var expectedGroupId = 501;
      var expectedUsers = [testUser, testUser, testUser];

      var getFilteredEntriesStub = sinon.stub();
      getFilteredEntriesStub.resolves([testUser, testUser, testUser]);
      var dbHelperMock = { 
        USERS_TABLE: expectedTableName, 
        getFilteredEntries: getFilteredEntriesStub 
      };

      // Action
      var ctrl = new UserController({ dbHelper: dbHelperMock });
      ctrl.getGroup("501")
        .then(function(groupUsers) {
          // Assert

          // db call
          var queriedTable = getFilteredEntriesStub.getCall(0).args[0];          
          var filter = getFilteredEntriesStub.getCall(0).args[1];
          expect(queriedTable).to.be.equal(expectedTableName);
          expect(filter.group).to.be.equal(expectedGroupId);

          // final result
          expect(groupUsers.length).to.be.equal(expectedUsers.length);
          expectUsersToBeEqual(groupUsers[0], expectedUsers[0]);
          expectUsersToBeEqual(groupUsers[1], expectedUsers[1]);
          expectUsersToBeEqual(groupUsers[2], expectedUsers[2]);
          done();
        });
    });
  });

  /**
   * Helper function to create a shallow copy of an object
   *
   * @parm obj: a javascript object
   * @return    a shallow copy of the json passed in
   */
   function shallowCopy(obj) {
    var copy = {};

    if (obj instanceof Object) {
        copy = {};
        for (var attr in obj) {
            if (obj.hasOwnProperty(attr)) copy[attr] = obj[attr];
        }
        return copy;
    }
  }

  /** 
   * Helper function for comparing a produce user to a expected user
   *
   * @param  
   */
   function expectUsersToBeEqual(receivedUser, expectedUser) {
    expect(receivedUser.id).to.be.equal(expectedUser.id);
    expect(receivedUser.group).to.be.equal(expectedUser.group);
    expect(receivedUser.first_name).to.be.equal(expectedUser.first_name);
    expect(receivedUser.last_name).to.be.equal(expectedUser.last_name);
    expect(receivedUser.pictureUrl).to.be.equal(expectedUser.pictureUrl);
    expect(receivedUser.phone_number).to.be.equal(expectedUser.phone_number);
    expect(receivedUser.email).to.be.equal(expectedUser.email);
    expect(receivedUser.totalPoints).to.be.equal(expectedUser.totalPoints);
    expect(receivedUser.achievements).to.be.equal(expectedUser.achievements);
    expect(receivedUser.favorites).to.be.equal(expectedUser.favorites);
    expect(receivedUser.notifications_recieved).to.be.equal(expectedUser.notifications_recieved);
  }
});