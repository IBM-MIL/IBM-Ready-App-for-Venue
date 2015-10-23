/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
'use strict';

var express  = require('express');
var dbHelper = require('../../db/dbHelper');
var poisCtrl = require('./poi.controller')({
  dbHelper: dbHelper
});

/**
 * @module POIs Router
 * @description This is router for the endpoints related to POIs
 * it contains the logic for POST /pois/, GET /pois/, 
 * GET /pois/park/{parkId}
 */
var router = express.Router();

router.post('/', insertPOI);
router.get('/', getAllPOIS);

router.get('/park/:parkId', getPOIsOfAPark);

module.exports = router;

function insertPOI(req, res) {
  var poi = req.body.poi;

  if(!poi) {
    return res
      .status(400)
      .json({ error: 'poi object is required in the request body' });
  }

  poisCtrl.insertPOI(poi)
    .then(function(savedPOI) {
        res.json({ data: savedPOI });
    }, function(err) {
      res.status(500).json({ error: err.message});
    });
}

function getAllPOIS(req, res) {
  poisCtrl.getAllPOIS()
    .then(function(POIs) {
      res.json({ data: POIs });
    }, function(err) {
      res.status(500).json({ error: err});
    });
}

function getPOIsOfAPark(req, res) {
  var parkId = req.params.parkId;

  if(!parkId) {
    return res
      .status(400)
      .json({ error: 'park ID required' });
  }

  poisCtrl.getPOIsOfAPark(parkId)
    .then(function(POIs) {
      res.json({ data: POIs });
    }, function(err) {
      res.status(500).json({ error: err});
    });
}