/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
'use strict';

var express  = require('express');
var dbHelper = require('../../db/dbHelper');
var gamification = require('../../libs/games-as-promised');
var gamificationCtrl  = require('../gamification/gamification.controller')({
  gamification: gamification
});
var userCtrl = require('./user.controller')({
  gamificationCtrl: gamificationCtrl,
  dbHelper: dbHelper
});

/**
 * @module User Router
 * @description This is router for the endpoints related to user
 * it contains the logic for GET /users/, POST /users/user, 
 * GET /users/user/{userId}, GET users/group/{groupId}
 */
var router = express.Router();

router.get('/', getAllUsers);
router.post('/user/', insertUser);
router.get('/user/:userId', getUser);

router.get('/group/:groupId', getGroup);

module.exports = router; 

function insertUser(req, res) {
  var user = req.body.user;

  if(!user) {
    return res
      .status(400)
      .json({ error: 'user object is required in the request body' });
  }

  userCtrl.insertUser(user)
    .then(function(savedUser) {
      res.json({ data: savedUser });
    }, function(err) {
      res.status(500).json({ error: err});
    });
}

function getUser(req, res) {
  var userId = req.params.userId;

  if(userId === undefined) {
    return res
      .status(400)
      .json({ error: 'userId required' });
  }

  userCtrl.getGroup(userId)
    .then(function(user) {
      res.json({data: user });
    }, function(err) {
      res.status(500).json({ error: err});
    });
}

function getAllUsers(req, res) {
  userCtrl.getAllUsers()
    .then(function(users) {
      res.json({ data: users });
    }, function(err) {
      res.status(500).json({ error: err});
    });
}

function getGroup(req, res) {
  var groupId = req.params.groupId;

  if(groupId === undefined) {
    return res
      .status(400)
      .json({ error: 'group ID required' });
  }

  userCtrl.getGroup(groupId)
    .then(function(group) {
      res.json({ data: group });
    }, function(err) {
      res.status(500).json({ error: err});
    });
}