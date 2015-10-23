/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
'use strict';

var express   = require('express');
var gamification = require('../../libs/games-as-promised');
var gamificationCtrl  = require('../gamification/gamification.controller');
var gameCtrl = require('./gamification.controller')({
  gamification: gamification
});


/**
 * @module Gamification Router
 * @description This is router for the endpoints related to gamification
 * it contains the logic for 
 * POST     /gamification/user, 
 * GET      /gamification/user/{userId}, 
 * DELETE   /gamification/user/{userId},
 * POST     /gamification/join/{groupId},
 * GET      /gamification/group/{groupId},
 * GET      /gamification/group/{groupId}/leaderboard,
 * GET      /gamification/badge,
 * GET      /gamification/badge/{badgeName},
 * GET      /gamification/user/{userID}/badges,
 * POST     /gamification/event/fire
 */
var router = express.Router();

// user routes
router.post('/user', registerUser);
router.get('/user/:userId', getPlayer);
router.delete('/user/:userId', deleteUser);
// Group routes
router.post('/join/group/:groupId', addUserToGroup);
router.get('/group/:groupId', getGroup); 
router.get('/group/:groupId/leaderboard', getGroupLeaderboard); 
// Badges routes 
router.get('/badge', getAllBadges); 
router.get('/badge/:bagdeName', getBadge); 
router.get('/user/:userId/badges', getPlayerBadges);
router.post('/badge/step/complete', completeStep);
// router.post('/award/:bagdeName', awardBadge); 

module.exports = router;

function registerUser(req, res) {
  var userData = req.body;

  if(!userData || userData.id === undefined || userData.name === undefined) {
    return res
            .status(400)
            .json({ err: 'request body must have id and name attributes' });
  }

  gameCtrl.registerPlayer(userData)
    .then(function(registeredUser) {
        res.json({ data: registeredUser });
    }).otherwise(function(err) {
      res.status(500).json({ error: err });
    }); 
}

function getPlayer(req, res) {
  var userId = req.params.userId;
  var errorHandler = getErrorHandler(res);

  if(!userId) {
    return res
            .status(400)
            .json({ err: 'userId required' });
  }

  gameCtrl.getPlayer(userId)
    .then(
      function(user) {
        res.json({ data: user });
      },
      errorHandler);
}

function deleteUser(req, res) {
  var userId = req.params.userId;
  var errorHandler = getErrorHandler(res);

  if(!userId) {
    return res
            .status(400)
            .json({ err: 'userId required' });
  }

  gameCtrl.deletePlayer(userId)
    .then(
      function(registeredUser) {
        res.json({ data: registeredUser });
      },
      errorHandler);
}

function addUserToGroup(req, res) {
  var groupId = req.params.groupId;
  var userId = req.body.userId;
  var errorHandler = getErrorHandler(res);

  if(userId === undefined || groupId  === undefined) {
    return res
            .status(400)
            .json({ err: 'groupId is required and request body must have id, and name attributes' });
  }

  gameCtrl.addPlayerToGroup(groupId, userId)
    .then(
      function(result) {
        res.json({ data: result });
      },
      errorHandler);
}

function getGroup(req, res) {
  var groupId = req.params.groupId;
  var errorHandler = getErrorHandler(res);

  if(!groupId) {
    return res
            .status(400)
            .json({ err: 'groupId is required' });
  }

  gameCtrl.getGroup(groupId)
    .then(
      function(group) {
        res.json({ data: group });
      },
      errorHandler);
}

function getGroupLeaderboard(req, res) {
  var groupId = req.params.groupId;

  if(!groupId) {
    return res
            .status(400)
            .json({ err: 'groupId is required' });
  }

  gameCtrl.getGroupLeaderboard(groupId)
    .then(function(leaderboard) {
        res.json({ data: leaderboard });
    })
    .otherwise(function(err) {
      res.status(500).json({ error : err});
    });
}

function getAllBadges(req, res) {
  gameCtrl.getAllBadges()
    .then(function(badges) {
        res.json({ data: badges });
      })
    .otherwise(function(err) {
      res.status(500).json({ error: err.message });
    });
}

function getBadge(req, res) {
  var bagdeName = req.params.bagdeName;
  var userData = req.body;
  var errorHandler = getErrorHandler(res);

  if(!bagdeName) {
    return res
            .status(400)
            .json({ err: 'badge name required' });
  }

  gameCtrl.getBadge(bagdeName)
    .then(function(badge) {
        res.json({ data: badge });
      })
    .otherwise(function(err) {
      res.status(500).json({ error: err.message });
    });
}

function getPlayerBadges(req, res) {
  var userId = req.params.userId;
  var errorHandler = getErrorHandler(res);

  if(!userId) {
    return res
            .status(400)
            .json({ err: 'userId required' });
  }

  gameCtrl.getPlayerBadges(userId)
    .then(function(badges) {
        res.json({ data: badges });
    })
    .otherwise(function(err) {
      res.status(500).json({ error: err.message });
    });
}

function completeStep(req, res) {
  var stepName = req.body.stepName;
  var userId = req.body.userId;

  var errorHandler = getErrorHandler(res);

  if(!stepName || !userId) {
    return res
            .status(400)
            .json({ err: 'eventName and badgeName are required in request body' });
  }

  gameCtrl.completeStep(stepName, userId)
    .then(function(result) {
        res.json({ data: result });
    })
    .otherwise(function(err) {
      res.status(500).json({ error: err.message });
    });
}

// function awardBadge(req, res) {
//   var bagdeName = req.params.bagdeName;
//   var userData = req.body;
//   var errorHandler = getErrorHandler(res);

//   if(!bagdeName || !userData || !userData.id) {
//     return res
//             .status(400)
//             .json({ err: 'bagde name is required and request body must have id attribute' });
//   }

//   gameCtrl.awardBadge(bagdeName, userData.id)
//     .then(function(registeredUser) {
//         res.json({ data: registeredUser });
//       })
//     .otherwise(function(err) {
//       res.status(500).json({ error: err.message });
//     });
// }


/* ----------------------------------------------------
 * Helper Functions
 * ----------------------------------------------------*/

/**
 * @ignore
 * Helper function for  creating error hander for responses
 */
function getErrorHandler(res) {
  return function(err) {
    return res
            .status(500)
            .json({ error: err.message });
  };
}