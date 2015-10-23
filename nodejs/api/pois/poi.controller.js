/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
'use strict';

var when = require('when');

/**
 * @constructor PoiController
 * @description Constructor
 *
 * @param {Object} depencies - a json with the attributes dbHelper 
 *                             with the appropiate objects. 
 */
module.exports = function(dependencies) {
  var dbHelper = dependencies.dbHelper;
  var ctrl = {};
  
  /**
   * @typedef {Object} Poi 
   * 
   * @property {String} parkId - the id of the park that the POI is in
   * @property {String} name - the POI's name
   * @property {Number} coordinate_x - the POI's x coordinate in the park's map
   * @property {Number} coordinate_y - the POI's y coordinate in the park's map
   * @property {Array.<String>} types - the types that can be associated with the POI
   * @property {String} subtitle - the POI's profile subtitle
   * @property {Number} height_requirement - The required height to ride the POI
   * @property {String} description - the POI's description
   * @property {Array.<String>} details - A list of detail description about the POI
   * @property {String} thumbnail_url - The url the POI's for thumbnail
   * @property {String} picture_url - The full 
   */

  /**
   * @function insertPOI
   * @memberof PoiController
   * @instance
   * @description Saves a Poi to the database
   * 
   * @param {Poi} user - The user to be inserted. NOTE: if it has an id 
   *                      attribute this will be ignore and a new id will 
   *                      be generated as part of the registration process.
   *
   * @return {Promise.<Poi>} - promise of the POI saved (with also an "id" attribute).
   */
  ctrl.insertPOI = function(poi) {
    var deferred = when.defer();

   if(!poi) {
      deferred.reject(new Error('poi is required'));
    } else {
      dbHelper.insert(dbHelper.POIS_TABLE, poi)
        .then(function(savedPOI) {
          deferred.resolve(savedPOI);
        }, function(err) {
          deferred.reject(err);
        });
    }
 
    return deferred.promise;
  };

  /**
   * @function getAllPOIS
   * @memberof PoiController
   * @instance
   * @description Retrives all POIs in the database 
   *
   * @return {Promise.<Poi>} - a promise of an array with all the POIs
   */
  ctrl.getAllPOIS = function() {
    var deferred = when.defer();

    dbHelper.getAllEntries(dbHelper.POIS_TABLE)
      .then(function(POIs) {
        deferred.resolve(POIs);
      }, function (err) {
        deferred.reject(err);
      });

    return deferred.promise;
  };

  /**
   * @function getPOIsOfAPark
   * @memberof PoiController
   * @instance
   * @description Retrives all POIs for a desired park. 
   *
   * @return {Promise.<Poi>} - a promise of an array with all the POIs the given park 
   */
  ctrl.getPOIsOfAPark = function(parkId) {
    var deferred = when.defer();
    
    if(!parkId) {
      deferred.reject(new Error('parkId required'));
    } else {
      dbHelper.getFilteredEntries(dbHelper.POIS_TABLE, { "parkId": parkId})
      .then(function(POIs) {
        deferred.resolve(POIs);
      }, function(err) {
        deferred.reject(err);
      });
    }

    return deferred.promise;
  };

  return ctrl;
};