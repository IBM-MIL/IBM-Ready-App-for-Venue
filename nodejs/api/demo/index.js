/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
'use strict';

var express   = require('express');
var dbHelper = require('../../db/dbHelper');
var gamification = require('../../libs/games-as-promised');
var demoController = require('./demo.controller')({
  dbHelper: dbHelper,
  gamification: gamification
});

/**
 * @module Demo Router
 * @description This is router for the endpoints related to POIs
 * it contains the logic for 
 * POST   /demo/gameplan, 
 * GET    /demo/gameplan, 
 * POST   /demo/gameplan/clear,
 * POST   /demo/gameplan/users,
 * DELETE /demo/gameplan/users,
 * GET    /demo/blob/update,
 * POST   /demo/blob,
 * GET    /demo/blob
 */
var router = express.Router();

router.post('/gameplan', setupGamePlan);
router.get('/gameplan', getPlanInfo);
router.post('/gameplan/clear', clearGamePlan);
router.post('/gameplan/users', createPlayers);
router.delete('/gameplan/users', deletePlayers);

// expects query params appVersion and revision
router.get('/blob/update', dataBlobUpdateCheck);
router.post('/blob', insertDataBlob);
router.get('/blob', getblobHistory);

module.exports = router;

function setupGamePlan(req, res) {
  var plan = req.body.plan;
  var key = req.body.key;

  if(!req.body.plan || !req.body.key) {
    return res.status(400).json({ error: 'plan JSON is required on the request body'});
  } 

  demoController.setupGamePlan(plan, key)
    .then(function(result) {
      res.json({ data: result });
    }, function(err) {
      res.status(500).json({ error: err.message });
    });
}

function getPlanInfo(req, res) {
  var planName = req.query.planName;
  var key = req.query.key;

  if (!planName || !key) {
      return res.status(400).json({ error: 'planName and key must be query params'});
  } 

  demoController.getPlanInfo(planName, key)
    .then(function(plan) {
      res.json({ data: plan });
    }, function(err) {
      res.status(500).json({ error: err.message });
    });
}

function clearGamePlan(req, res) {
  var plan = req.body.plan;
  var key = req.body.key;

  if(!plan || !key) {
    return res.status(400).json({ error: 'plan JSON is required on the request body'});
  } 

  demoController.clearGamePlan(plan, key)
    .then(function(result) {
      res.json({ data: result });
    }, function(err) {
      res.status(500).json({ error: err.message });
    });
}

function createPlayers(req, res) {
  var players = req.body.players;

  if(!players) {
    return res.status(400).json({ error: 'Users data must be on the request body'});
  }

  demoController.createPlayers(players)
    .then(function(createdPlayers) {
      res.json({ data: createdPlayers });
    }, function(err) {
      res.status(500).json({ error: err.message });
    });
}

function deletePlayers(req, res) {
  var players = req.body.players;

  if(!players) {
    return res.status(400).json({ error: 'Users data must be on the request body'});
  }

  demoController.deletePlayers(players)
    .then(function(createdPlayers) {
      res.json({ data: createdPlayers });
    }, function(err) {
      res.status(500).json({ error: err.message });
    });
}

function dataBlobUpdateCheck(req, res) {
  var appVersion = req.query.appVersion;
  var revision = parseInt(req.query.revision);

  if(!appVersion || revision === undefined) {
    return res.status(400).json({ error: 'appVersion and revision are required as query params'});
  } 

  demoController.dataBlobUpdateCheck(appVersion, revision)
    .then(function(result) {
      res.json({ data: result });
    }, function(err) {
      res.status(500).json({ error: err.message });
    });
}

function insertDataBlob(req, res) {
  var blob = req.body.blob;
  var appVersion = req.body.appVersion;
  var revision = req.body.revision;

  if(!blob || !appVersion) {
    return res.status(400).json({ error: 'blob and appVersion are required on the request body'});
  } 

  demoController.insertDataBlob(blob, appVersion, revision)
    .then(function(result) {
      res.json({ data: result });
    }, function(err) {
      res.status(500).json({ error: err.message });
    });
}

function getblobHistory(req, res) {
  demoController.getblobHistory()
    .then(function(result) {
      res.json({ data: result });
    }, function(err) {
      res.status(500).json({ error: err.message });
    });
}