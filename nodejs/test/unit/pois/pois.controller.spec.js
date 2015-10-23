/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
 'use strict';

var expect = require('chai').expect;
var sinon = require('sinon');
// add sinon capabilities for promises 
require('sinon-as-promised');

describe('POIs Controller Unit Tests', function() { 
  var POIController = require('../../../api/pois/poi.controller');
  var testPOI = {
    "id": "asffbevwvbeGEfs",
    "parkId": "Brickland",
    "name": "Tejas Twister",
    "coordinate_x": 42,
    "coordinate_y": 42,
    "types": ["ride", "epic", "awesome"],
    "subtitle": "Thrill Level",
    "height_requirement": -1,
    "description": "the best in the park",
    "details" : ["closed captions availible"],
    "thumbnail_url":"www.img.url.com/rideThumbnail",
    "picture_url": "www.img.url.com/ridePic"
  };

  describe('insertPOI(poi)', function() {
    it('should reject the promise when no poi object is provided', function(done) {
      // Align
      var expectedErrorMsg = 'poi is required';

      // Action
      var ctrl = new POIController({});
      ctrl.insertPOI()
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
      var ctrl = new POIController({ dbHelper: dbHelperMock });
      ctrl.insertPOI(testPOI)
        .otherwise(function(err) {
          // Assert
          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    });

    it('should save db record when a proper POI is given', function(done){
      // Align
      var expectedId = 'asffbevwvbeGEfs';
      var poi = shallowCopy(testPOI);
      delete poi.id;

      var insertStub = sinon.stub();
      insertStub.resolves(testPOI);
      var dbHelperMock = { insert: insertStub };

      // Action
      var ctrl = new POIController({ dbHelper: dbHelperMock });
      ctrl.insertPOI(poi) 
        .then(function(insertedPOI) {
          // Assert
          poi.id = expectedId;

          // final result
          expectPOIsToBeEqual(insertedPOI, poi);
          done();
        });
    });
  });

  describe('getAllPOIS()', function() {
      it('should reject when there is an error fetching from the database', function(done) {
      // Align
      var expectedErrorMsg = 'DB Error';

      var getAllEntriesStub = sinon.stub();
      getAllEntriesStub.rejects(expectedErrorMsg);
      var dbHelperMock = { getAllEntries: getAllEntriesStub };

      // Action
      var ctrl = new POIController({ dbHelper: dbHelperMock });
      ctrl.getAllPOIS()
        .otherwise(function(err) {
          // Assert
          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    });

    it('should fetch all the POIs in the database', function(done) {
      // Align
      var expectedTableName = "myTestTable";
      var expectedPOIs = [testPOI, testPOI, testPOI];


      var getAllEntriesStub = sinon.stub();
      getAllEntriesStub.resolves([testPOI, testPOI, testPOI]);
      var dbHelperMock = { POIS_TABLE: expectedTableName, getAllEntries: getAllEntriesStub };
      // Action
      var ctrl = new POIController({ dbHelper: dbHelperMock });
      ctrl.getAllPOIS()
        .then(function(POIs) {
          // Assert

          // db call
          var queriedTable = getAllEntriesStub.getCall(0).args[0];   
          expect(queriedTable).to.be.equal(expectedTableName);

          // final result
          expect(POIs.length).to.be.equal(expectedPOIs.length);
          expectPOIsToBeEqual(POIs[0], expectedPOIs[0]);
          expectPOIsToBeEqual(POIs[1], expectedPOIs[1]);
          expectPOIsToBeEqual(POIs[2], expectedPOIs[2]);

          done();
        });
    });
  });

  describe('getPOIsOfAPark(parkId)', function() {
    it('should reject the promise when no groupId is provided', function(done) {
      // Align
      var expectedErrorMsg = 'parkId required';

      // Action
      var ctrl = new POIController({});
      ctrl.getPOIsOfAPark()
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
      var ctrl = new POIController({ dbHelper: dbHelperMock });
      ctrl.getPOIsOfAPark("Brickland")
        .otherwise(function(err) {
          // Assert
          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    });

    it('should fetch the appropiate users giving a groupId', function(done) {
      // Align
      var expectedTableName = "myTestTable";
      var expectedParkId = "Brickland";
      var expectedPOIs = [testPOI, testPOI, testPOI];

      var getFilteredEntriesStub = sinon.stub();
      getFilteredEntriesStub.resolves([testPOI, testPOI, testPOI]);
      var dbHelperMock = { 
        POIS_TABLE: expectedTableName, 
        getFilteredEntries: getFilteredEntriesStub 
      };

      // Action
      var ctrl = new POIController({ dbHelper: dbHelperMock });
      ctrl.getPOIsOfAPark("Brickland")
        .then(function(parkPOIs) {
          // Assert

          // db call
          var queriedTable = getFilteredEntriesStub.getCall(0).args[0];          
          var filter = getFilteredEntriesStub.getCall(0).args[1];
          expect(queriedTable).to.be.equal(expectedTableName);
          expect(filter.parkId).to.be.equal(expectedParkId);

          // final result
          expect(parkPOIs.length).to.be.equal(expectedPOIs.length);
          expectPOIsToBeEqual(parkPOIs[0], expectedPOIs[0]);
          expectPOIsToBeEqual(parkPOIs[1], expectedPOIs[1]);
          expectPOIsToBeEqual(parkPOIs[2], expectedPOIs[2]);
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
   function expectPOIsToBeEqual(receivedPOI, expectedPOI) {
    expect(receivedPOI.id).to.be.equal(expectedPOI.id);
    expect(receivedPOI.parkId).to.be.equal(expectedPOI.parkId);
    expect(receivedPOI.name).to.be.equal(expectedPOI.name);
    expect(receivedPOI.coordinate_x).to.be.equal(expectedPOI.coordinate_x);
    expect(receivedPOI.coordinate_y).to.be.equal(expectedPOI.coordinate_y);
    expect(receivedPOI.types).to.be.equal(expectedPOI.types);
    expect(receivedPOI.subtitle).to.be.equal(expectedPOI.subtitle);
    expect(receivedPOI.height_requirement).to.be.equal(expectedPOI.height_requirement);
    expect(receivedPOI.description).to.be.equal(expectedPOI.description);
    expect(receivedPOI.details).to.be.equal(expectedPOI.details);
    expect(receivedPOI.thumbnail_url).to.be.equal(expectedPOI.thumbnail_url);
    expect(receivedPOI.picture_url).to.be.equal(expectedPOI.picture_url);
   }
});