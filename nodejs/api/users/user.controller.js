/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
'use strict';


var when = require('when');

/**
 * @constructor UserController
 * @description Constructor
 *
 * @param {Object} depencies - a json with the attributes dbHelper and 
 *                           gamificationCtrl with the appropiate objects. 
 */
module.exports = function(dependencies) {
  var dbHelper = dependencies.dbHelper;
  var gamificationCtrl  = dependencies.gamificationCtrl;
  var ctrl = {};


  /**
   * @typedef {Object} User 
   * 
   * @property {String} id - The user's id
   * @property {String} group - The user's group id
   * @property {String} first_name - The user's first name
   * @property {String} last_name - The user's last name
   * @property {String} pictureUrl - The user's profile picture url
   * @property {String} phone_number -The user's phone number
   * @property {String} email - The user's email address
   * @property {Number} totalPoints - The user total points
   * @property {Array.<Achievement>} achievements - The user achievements (earned or not) with current status
   * @property {Array.<Number>} favorites - The user favorited or added to plan POI ids
   * @property {Array.<Number>} notifications_recieved - The ids of the notification received by the user
   */


  /**
   * @method insertUser
   * @memberof UserController
   * @instance
   *
   * @description Saves a user record to the database and creates a player 
   * entry for the created user in the gamification service.
   *
   * @param {User} user - The user to be inserted. NOTE: if it has an id 
   *                      attribute this will be ignore and a new id will 
   *                      be generated as part of the registration process.
   * @return {Promise.<User>} - Promise of the User inserted (with also an "id" attribute).
   */
  ctrl.insertUser = function(user) {
    var deferred = when.defer();
    var errorHandler = function(err) {
      deferred.reject(err);
    };

    if(!user) {
      deferred.reject(new Error('user is required'));
    } else {
      if(user.id) {
        delete user.id;
      }

      dbHelper.insert(dbHelper.USERS_TABLE, user)
      .then(function(savedUser) {
        // user as a player in the gamification service
        gamificationCtrl.registerPlayer({
            id: savedUser.id,
            name: user.first_name,
            groupId: user.group
          }).then(function() {
            deferred.resolve(user);
          }, errorHandler);
      }, errorHandler);
    }

    return deferred.promise;
  };

  /**
   * @method getUser
   * @memberof UserController
   * @instance
   *
   * @description Retrives a user form the database 
   * 
   * @param {String} userId - a string with the userId of the desired user
   * @return {Promise.<User>} - promise of the User looked up. NOTE: it will undefined if no user is found.
   */
  ctrl.getUser = function(userId) {
    var deferred = when.defer();

    if(userId === undefined) {
      deferred.reject(new Error('userId required'));
    } else {
      dbHelper.getEntryById(dbHelper.USERS_TABLE, userId)
      .then(function(user) {
        deferred.resolve(user);
      }, function(err) {
        deferred.reject(err);
      });
    }

    return deferred.promise;
  };
  
  /**
   * @method getAllUsers
   * @memberof UserController
   * @instance
   *
   * @description Retrives all users in the database 
   *
   * @return {Promise.<Array.<User>>} - A promise of an array with all the users
   */
  ctrl.getAllUsers = function() {
    var deferred = when.defer();

    dbHelper.getAllEntries(dbHelper.USERS_TABLE)
      .then(function(users) {
        deferred.resolve(users);
      }, function(err) {
        deferred.reject(err);
      });

    return deferred.promise;
  };

  /**
   * @method getGroup
   * @memberof UserController
   * @instance
   *
   * @description Retrives all users in the desired group
   *
   * @param {Number} groupId - the group id of the desired group
   * @return {Promise.<Array.<User>>} - A promise of an array with the users in the group
   */
  ctrl.getGroup = function(groupId) {
    var deferred = when.defer();
    
    if(groupId === undefined) {
      deferred.reject(new Error('groupId required'));
    } else {
      groupId = parseInt(groupId);

      dbHelper.getFilteredEntries(dbHelper.USERS_TABLE, { "group": groupId})
      .then(function(groupUsers) {
        deferred.resolve(groupUsers);
      }, function(err) {
        deferred.reject(err);
      });
    }

    return deferred.promise;
  };

  return ctrl;
};