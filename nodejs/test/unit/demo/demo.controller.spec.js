/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
 'use strict';

var _ = require('lodash');
var expect = require('chai').expect;
var sinon = require('sinon');
// add sinon capabilities for promises 
require('sinon-as-promised');

describe('Demo Controller Unit Tests', function() { 
  var DemoCtrl = require('../../../api/demo/demo.controller');
  var data = require('./data/gameplan.js');
  var testGamePlan = data.plan;
  var testKey = data.key;

  describe('setupGamePlan(plan, key)', function () {
    it('should reject when no game plan data is provided', function(done) {
      // Align
      var expectedErrorMsg = 'gamePlan is required';

      var configureStub = sinon.stub();
      var gamificationMock = { configure: configureStub };

      // Action
      var ctrl = new DemoCtrl({ gamification: gamificationMock});
      ctrl.setupGamePlan(undefined, "fakeKey")
        .otherwise(function(err) {
          // Assert
          expect(configureStub.called).to.be.equal(true);
          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    });

    it('should reject when no key is provided', function(done) {
      // Align
      var expectedErrorMsg = 'key is required';

      var configureStub = sinon.stub();
      var gamificationMock = { configure: configureStub };

      // Action
      var ctrl = new DemoCtrl({ gamification: gamificationMock});
      ctrl.setupGamePlan(testGamePlan)
        .otherwise(function(err) {
          // Assert
          expect(configureStub.called).to.be.equal(true);
          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    }); 

    it('should reject when the Gamification Service SDK throws an error', function(done) {
      // Align
      var expectedErrorMsg = 'Gamification Service Error';

      var configureStub = sinon.stub();
      var setupPlanStub = sinon.stub();
      setupPlanStub.rejects(expectedErrorMsg);
      var gamificationMock = { 
        configure: configureStub, 
        setupPlan: setupPlanStub
      };

      // Action
      var ctrl = new DemoCtrl({ gamification: gamificationMock});
      ctrl.setupGamePlan(testGamePlan, testKey)
        .otherwise(function(err) {
          // Assert
          expect(configureStub.called).to.be.equal(true);
          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    });   

    it('should setup the plan in Gamification Service given proper data', function(done) {
      // Align
      var configureStub = sinon.stub();
      var setupPlanStub = sinon.stub();
      setupPlanStub.resolves(testGamePlan);
      var gamificationMock = { 
        configure: configureStub, 
        setupPlan: setupPlanStub
      };

      // Action
      var ctrl = new DemoCtrl({ gamification: gamificationMock});
      ctrl.setupGamePlan(testGamePlan, testKey)
        .then(function(result) {
          // Assert
          expect(configureStub.called).to.be.equal(true);

          var expectedResult = getTestPlanComponents();
          expect(result.deeds.length).to.be.equal(expectedResult.deeds.length);
          expect(result.deeds[0].name).to.be.equal(expectedResult.deeds[0]);
          expect(result.deeds[1].name).to.be.equal(expectedResult.deeds[1]);
          expect(result.events.length).to.be.equal(expectedResult.events.length);
          expect(result.events[0].name).to.be.equal(expectedResult.events[0]);
          expect(result.events[1].name).to.be.equal(expectedResult.events[1]);
          expect(result.missions.length).to.be.equal(expectedResult.missions.length);
          expect(result.missions[0].name).to.be.equal(expectedResult.missions[0]);
          expect(result.missions[1].name).to.be.equal(expectedResult.missions[1]);
          expect(result.variables.length).to.be.equal(expectedResult.variables.length);
          expect(result.variables[0].name).to.be.equal(expectedResult.variables[0]);
          expect(result.variables[1].name).to.be.equal(expectedResult.variables[1]);
          done();
        });
    }); 
  });

  describe('getPlanInfo(planName, key)', function () {
    it('should reject when no plan name is provided', function(done) {
      // Align
      var expectedErrorMsg = 'planName is required';

      var configureStub = sinon.stub();
      var gamificationMock = { configure: configureStub };

      // Action
      var ctrl = new DemoCtrl({ gamification: gamificationMock});
      ctrl.getPlanInfo(undefined, "fakeKey")
        .otherwise(function(err) {
          // Assert
          expect(configureStub.called).to.be.equal(true);
          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    });

    it('should reject when no key is provided', function(done) {
      // Align
      var expectedErrorMsg = 'key is required';

      var configureStub = sinon.stub();
      var gamificationMock = { configure: configureStub };

      // Action
      var ctrl = new DemoCtrl({ gamification: gamificationMock});
      ctrl.getPlanInfo(testGamePlan)
        .otherwise(function(err) {
          // Assert
          expect(configureStub.called).to.be.equal(true);
          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    }); 

    it('should reject when the Gamification Service SDK throws an error', function(done) {
      // Align
      var expectedErrorMsg = 'Gamification Service Error';

      var configureStub = sinon.stub();
      var getPlanInfoStub = sinon.stub();
      getPlanInfoStub.rejects(expectedErrorMsg);
      var gamificationMock = { 
        configure: configureStub, 
        getPlanInfo: getPlanInfoStub
      };

      // Action
      var ctrl = new DemoCtrl({ gamification: gamificationMock});
      ctrl.getPlanInfo(testGamePlan, testKey)
        .otherwise(function(err) {
          // Assert
          expect(configureStub.called).to.be.equal(true);
          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    }); 

    it('should fetch the plan info when given valid parameters', function(done) {
      // Align
      var expectedResult = data.plan;
      var configureStub = sinon.stub();
      var getPlanInfoStub = sinon.stub();
      getPlanInfoStub.resolves(testGamePlan);
      var gamificationMock = { configure: configureStub, getPlanInfo: getPlanInfoStub };

      // Action
      var ctrl = new DemoCtrl({ gamification: gamificationMock});
      ctrl.getPlanInfo(testGamePlan, testKey)
        .then(function(result) {
          // Assert
          expect(configureStub.called).to.be.equal(true);

          expect(result.deeds.length).to.be.equal(expectedResult.deeds.length);
          expect(result.deeds[0].name).to.be.equal(expectedResult.deeds[0].name);
          expect(result.deeds[0].label).to.be.equal(expectedResult.deeds[0].label);
          expect(result.deeds[1].name).to.be.equal(expectedResult.deeds[1].name);
          expect(result.deeds[1].label).to.be.equal(expectedResult.deeds[1].label);
          expect(result.events.length).to.be.equal(expectedResult.events.length);
          expect(result.events[0].name).to.be.equal(expectedResult.events[0].name);
          expect(result.events[0].label).to.be.equal(expectedResult.events[0].label);
          expect(result.events[1].name).to.be.equal(expectedResult.events[1].name);
          expect(result.events[1].label).to.be.equal(expectedResult.events[1].label);
          expect(result.missions.length).to.be.equal(expectedResult.missions.length);
          expect(result.missions[0].name).to.be.equal(expectedResult.missions[0].name);
          expect(result.missions[0].label).to.be.equal(expectedResult.missions[0].label);
          expect(result.missions[1].name).to.be.equal(expectedResult.missions[1].name);
          expect(result.missions[1].label).to.be.equal(expectedResult.missions[1].label);
          expect(result.variables.length).to.be.equal(expectedResult.variables.length);
          expect(result.variables[0].name).to.be.equal(expectedResult.variables[0].name);
          expect(result.variables[0].label).to.be.equal(expectedResult.variables[0].label);
          expect(result.variables[1].name).to.be.equal(expectedResult.variables[1].name);
          expect(result.variables[1].label).to.be.equal(expectedResult.variables[1].label);
          done();
        });
    });
  });

  describe('clearGamePlan(plan, key)', function () {
      it('should reject when no plan name is provided', function(done) {
        // Align
        var expectedErrorMsg = 'plan is required';

        var configureStub = sinon.stub();
        var gamificationMock = { configure: configureStub };

        // Action
        var ctrl = new DemoCtrl({ gamification: gamificationMock});
        ctrl.clearGamePlan(undefined, "fakeKey")
          .otherwise(function(err) {
            // Assert
            expect(configureStub.called).to.be.equal(true);
            expect(err.message).to.be.equal(expectedErrorMsg);
            done();
          });
    });

    it('should reject when no key is provided', function(done) {
      // Align
      var expectedErrorMsg = 'key is required';

      var configureStub = sinon.stub();
      var gamificationMock = { configure: configureStub };

      // Action
      var ctrl = new DemoCtrl({ gamification: gamificationMock});
      ctrl.clearGamePlan(testGamePlan)
        .otherwise(function(err) {
          // Assert
          expect(configureStub.called).to.be.equal(true);
          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    }); 

    it('should reject when the Gamification Service SDK throws an error', function(done) {
      // Align
      var expectedErrorMsg = 'Gamification Service Error';

      var configureStub = sinon.stub();
      var clearPlanStub = sinon.stub();
      clearPlanStub.rejects(expectedErrorMsg);
      var gamificationMock = { 
        configure: configureStub, 
        clearPlan: clearPlanStub
      };

      // Action
      var ctrl = new DemoCtrl({ gamification: gamificationMock});
      ctrl.clearGamePlan(testGamePlan, testKey)
        .otherwise(function(err) {
          // Assert
          expect(configureStub.called).to.be.equal(true);
          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    }); 

    it('should setup the plan in Gamification Service given proper data', function(done) {
      // Align
      var configureStub = sinon.stub();
      var clearPlanStub = sinon.stub();
      clearPlanStub.resolves(getTestPlanComponents());
      var gamificationMock = { 
        configure: configureStub, 
        clearPlan: clearPlanStub
      };

      // Action
      var ctrl = new DemoCtrl({ gamification: gamificationMock});
      ctrl.clearGamePlan(testGamePlan, testKey)
        .then(function(result) {
          // Assert
          expect(configureStub.called).to.be.equal(true);

          expect(result.deeds.length).to.be.equal(testGamePlan.deeds.length);
          expect(result.deeds[0]).to.be.equal(testGamePlan.deeds[0].name);
          expect(result.deeds[1]).to.be.equal(testGamePlan.deeds[1].name);
          expect(result.events.length).to.be.equal(testGamePlan.events.length);
          expect(result.events[0]).to.be.equal(testGamePlan.events[0].name);
          expect(result.events[1]).to.be.equal(testGamePlan.events[1].name);
          expect(result.missions.length).to.be.equal(testGamePlan.missions.length);
          expect(result.missions[0]).to.be.equal(testGamePlan.missions[0].name);
          expect(result.missions[1]).to.be.equal(testGamePlan.missions[1].name);
          expect(result.variables.length).to.be.equal(testGamePlan.variables.length);
          expect(result.variables[0]).to.be.equal(testGamePlan.variables[0].name);
          expect(result.variables[1]).to.be.equal(testGamePlan.variables[1].name);
          done();
        });
    }); 
  });

  describe('dataBlobUpdateCheck(plan, key)', function () {
    it('should reject when no app version is provided', function(done) {
      // Align
        var expectedErrorMsg = 'appVersion is required';

        var configureStub = sinon.stub();
        var gamificationMock = { configure: configureStub };

        // Action
        var ctrl = new DemoCtrl({ gamification: gamificationMock});
        ctrl.dataBlobUpdateCheck(undefined, 19)
          .otherwise(function(err) {
            // Assert
            expect(configureStub.called).to.be.equal(true);
            expect(err.message).to.be.equal(expectedErrorMsg);
            done();
          });
    });

    it('should reject when no app version is provided', function(done) {
      // Align
        var expectedErrorMsg = 'revision is required';

        var configureStub = sinon.stub();
        var gamificationMock = { configure: configureStub };

        // Action
        var ctrl = new DemoCtrl({ gamification: gamificationMock});
        ctrl.dataBlobUpdateCheck("0.2.12154")
          .otherwise(function(err) {
            // Assert
            expect(configureStub.called).to.be.equal(true);
            expect(err.message).to.be.equal(expectedErrorMsg);
            done();
          });
    });

    it('should reject when no revision is found for appVersion', function(done) {
      // Align
        var testTable = 'my_test_table';
        var testAppVersion = '0.2.1234145';
        var expectedErrorMsg = 'no data revisions found for app verion: 0.2.1234145';

        var configureStub = sinon.stub();
        var gamificationMock = { configure: configureStub };

        var getFilteredEntriesStub = sinon.stub();
        getFilteredEntriesStub.resolves([]);
        var dbHelperMock = { 
          APP_REVS_TABLE: testTable,
          configure: configureStub, 
          getFilteredEntries: getFilteredEntriesStub 
        };

        // Action
        var ctrl = new DemoCtrl({ gamification: gamificationMock, dbHelper: dbHelperMock});
        ctrl.dataBlobUpdateCheck(testAppVersion, 19)
          .otherwise(function(err) {
            // Assert
            expect(configureStub.called).to.be.equal(true);

            var tableQueried = getFilteredEntriesStub.getCall(0).args[0];
            var filter = getFilteredEntriesStub.getCall(0).args[1];
            expect(tableQueried).to.be.equal(testTable);
            expect(filter.appVersion).to.be.equal(testAppVersion);

            expect(err.message).to.be.equal(expectedErrorMsg);
            done();
          });
    });

    it('should return isUpToDate = true when the app and revision passed in are up to date', function(done) {
      // Align
        var testAppTable = 'app_versions_table';
        var testAppVersion = '0.2.1234145';
        var currentRevision = 19;
        var revision = 19;

        var configureStub = sinon.stub();
        var gamificationMock = { configure: configureStub };

        var getFilteredEntriesStub = sinon.stub();
        getFilteredEntriesStub.resolves([{ revisionId: currentRevision }]);
        var dbHelperMock = { 
          APP_REVS_TABLE: testAppTable,
          configure: configureStub, 
          getFilteredEntries: getFilteredEntriesStub 
        };

        // Action
        var ctrl = new DemoCtrl({ gamification: gamificationMock, dbHelper: dbHelperMock});
        ctrl.dataBlobUpdateCheck(testAppVersion, revision)
          .then(function(result) {
            // Assert
            expect(configureStub.called).to.be.equal(true);

            var tableQueried = getFilteredEntriesStub.getCall(0).args[0];
            var filter = getFilteredEntriesStub.getCall(0).args[1];
            expect(tableQueried).to.be.equal(testAppTable);
            expect(filter.appVersion).to.be.equal(testAppVersion);

            expect(result.isUpToDate).to.be.equal(true);
            done();
          });
    });

    it('should return isUpToDate = false and the blob when the app and revision passed in are outdated', function(done) {
      // Align
        var testAppTable = 'app_versions_table';
        var testBlobsTable = 'blobs_table';
        var appVersion = '0.2.1234145';
        var currentRevision = 21;
        var currentRevisionId = "asdsa";
        var revision = 19;
        var testBlob = require('./data/blob.js');

        var configureStub = sinon.stub();
        var gamificationMock = { configure: configureStub };

        var getFilteredEntriesStub = sinon.stub();
        getFilteredEntriesStub.resolves([{ revision: currentRevision, revisionId: currentRevisionId }]);
        var getEntryByIdStub = sinon.stub();
        getEntryByIdStub.resolves({ someData: testBlob });
        var dbHelperMock = { 
          APP_REVS_TABLE: testAppTable,
          BLOBS_TABLE: testBlobsTable,
          configure: configureStub, 
          getFilteredEntries: getFilteredEntriesStub,
          getEntryById: getEntryByIdStub
        };

        // Action
        var ctrl = new DemoCtrl({ gamification: gamificationMock, dbHelper: dbHelperMock});
        ctrl.dataBlobUpdateCheck(appVersion, revision)
          .then(function(result) {
            // Assert
            expect(configureStub.called).to.be.equal(true);

            var appTableQueried = getFilteredEntriesStub.getCall(0).args[0];
            var filter = getFilteredEntriesStub.getCall(0).args[1];
            expect(appTableQueried).to.be.equal(testAppTable);
            expect(filter.appVersion).to.be.equal(appVersion);


            var blobTableQueried = getEntryByIdStub.getCall(0).args[0];
            var queriedBlobRev = getEntryByIdStub.getCall(0).args[1];
            expect(blobTableQueried).to.be.equal(testBlobsTable);
            expect(queriedBlobRev).to.be.equal(currentRevisionId);

            expect(result.isUpToDate).to.be.equal(false);
            expect(result.blob).to.not.be.equal(undefined);
            done();
          });
    });
  });

  describe('insertDataBlob(blob, appVersion, revision)', function () {
    it('should reject when no blob is provided', function(done) {
      // Align
        var expectedErrorMsg = 'blob is required';

        var configureStub = sinon.stub();
        var gamificationMock = { configure: configureStub };

        // Action
        var ctrl = new DemoCtrl({ gamification: gamificationMock});
        ctrl.insertDataBlob(undefined, "0.2.1241")
          .otherwise(function(err) {
            // Assert
            expect(configureStub.called).to.be.equal(true);
            expect(err.message).to.be.equal(expectedErrorMsg);
            done();
          });
    });


    it('should reject when no app version is provided', function(done) {
      // Align
        var expectedErrorMsg = 'appVersion is required';

        var configureStub = sinon.stub();
        var gamificationMock = { configure: configureStub };

        // Action
        var ctrl = new DemoCtrl({ gamification: gamificationMock});
        ctrl.insertDataBlob({})
          .otherwise(function(err) {
            // Assert
            expect(configureStub.called).to.be.equal(true);
            expect(err.message).to.be.equal(expectedErrorMsg);
            done();
          });
    });

    it('should reject if trying to insert a revision with older revision number', function(done) {
      // Align
      var expectedErrorMsg = 'new revision must be greater than current. Current revision: 5';
      var testAppTable = "app_versions_table";
      var expectedAppVersion = "0.2.1123";
      var expectedRevision = 5;

      var configureStub = sinon.stub();
      var gamificationMock = { configure: configureStub };

      var getFilteredEntriesStub = sinon.stub();
      getFilteredEntriesStub.resolves([{ revision: 5 }]);
      var dbHelperMock = { 
        APP_REVS_TABLE: testAppTable,
        configure: configureStub, 
        getFilteredEntries: getFilteredEntriesStub
      };

      // Action
      var ctrl = new DemoCtrl({ gamification: gamificationMock, dbHelper: dbHelperMock});
      ctrl.insertDataBlob({data: "some_blob_data"}, "0.2.1123", 3)
        .otherwise(function(err) {
          // Assert
          expect(configureStub.called).to.be.equal(true);

          var appTableQueried = getFilteredEntriesStub.getCall(0).args[0];
          var versionFilter = getFilteredEntriesStub.getCall(0).args[1];
          expect(appTableQueried).to.be.equal(testAppTable);
          expect(versionFilter.appVersion).to.be.equal(expectedAppVersion);

          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    });

    it('should save an app version with default revision number (1) and blob records when no app version is found in the db', function(done) {
      // Align
      var testAppTable = "app_versions_table";
      var testBlobsTable = "blobs_table";
      var configureStub = sinon.stub();
      var gamificationMock = { configure: configureStub };
      var expectedBlobId = "wdawdad";
      var expectedBlobData = "some_blob_data";
      var blobEntry = { id: expectedBlobId, data: expectedBlobData};
      var expectedAppVersion = "0.2.1123";
      var expectedRevisionId = "asdaw";
      var appBlobEntry = { appVersion: expectedAppVersion, revision: 1, revisionId: expectedRevisionId};

      var getFilteredEntriesStub = sinon.stub();
      getFilteredEntriesStub.resolves([]);
      var insertStub = sinon.stub();
      insertStub.withArgs(testBlobsTable, sinon.match.any).resolves(blobEntry);
      insertStub.withArgs(testAppTable, sinon.match.any).resolves(appBlobEntry);
      var dbHelperMock = { 
        APP_REVS_TABLE: testAppTable,
        BLOBS_TABLE: testBlobsTable,
        configure: configureStub, 
        getFilteredEntries: getFilteredEntriesStub,
        insert: insertStub
      };

      // Action
      var ctrl = new DemoCtrl({ gamification: gamificationMock, dbHelper: dbHelperMock});
      ctrl.insertDataBlob({data: "some_blob_data"}, "0.2.1123")
        .then(function(result) {
          // Assert
          expect(configureStub.called).to.be.equal(true);

          var appTableQueried = getFilteredEntriesStub.getCall(0).args[0];
          var versionFilter = getFilteredEntriesStub.getCall(0).args[1];
          expect(appTableQueried).to.be.equal(testAppTable);
          expect(versionFilter.appVersion).to.be.equal(expectedAppVersion);

          var insertedBlobTable = insertStub.getCall(0).args[0];
          var insertedBlob = insertStub.getCall(0).args[1];
          expect(insertedBlobTable).to.be.equal(testBlobsTable);
          expect(insertedBlob.data).to.be.equal(expectedBlobData);


          var insertedAppRecordTable = insertStub.getCall(1).args[0];
          var insertedAppRecord = insertStub.getCall(1).args[1];
          expect(insertedBlobTable).to.be.equal(testBlobsTable);
          expect(insertedAppRecord.appVersion).to.be.equal(expectedAppVersion);
          expect(insertedAppRecord.revision).to.be.equal(1);
          expect(insertedAppRecord.revisionId).to.be.equal(expectedBlobId);

          expect(result.appVersion).to.be.equal(expectedAppVersion);
          expect(result.revision).to.be.equal(1);
          expect(result.revisionId).to.be.equal(expectedRevisionId);

          done();
        });
    });
    
    it('should save an app version with revision passed in and blob records when no app version is found in the db', function(done) {
      // Align
      var testAppTable = "app_versions_table";
      var testBlobsTable = "blobs_table";
      var configureStub = sinon.stub();
      var gamificationMock = { configure: configureStub };
      var expectedBlobId = "wdawdad";
      var expectedBlobData = "some_blob_data";
      var blobEntry = { id: expectedBlobId, data: expectedBlobData};
      var expectedAppVersion = "0.2.1123";
      var expectedRevisionId = "asdaw";
      var expectedRevision = 5;
      var appBlobEntry = { appVersion: expectedAppVersion, revision: expectedRevision, revisionId: expectedRevisionId};

      var getFilteredEntriesStub = sinon.stub();
      getFilteredEntriesStub.resolves([]);
      var insertStub = sinon.stub();
      insertStub.withArgs(testBlobsTable, sinon.match.any).resolves(blobEntry);
      insertStub.withArgs(testAppTable, sinon.match.any).resolves(appBlobEntry);
      var dbHelperMock = { 
        APP_REVS_TABLE: testAppTable,
        BLOBS_TABLE: testBlobsTable,
        configure: configureStub, 
        getFilteredEntries: getFilteredEntriesStub,
        insert: insertStub
      };

      // Action
      var ctrl = new DemoCtrl({ gamification: gamificationMock, dbHelper: dbHelperMock});
      ctrl.insertDataBlob({data: "some_blob_data"}, "0.2.1123", 5)
        .then(function(result) {
          // Assert
          expect(configureStub.called).to.be.equal(true);

          var appTableQueried = getFilteredEntriesStub.getCall(0).args[0];
          var versionFilter = getFilteredEntriesStub.getCall(0).args[1];
          expect(appTableQueried).to.be.equal(testAppTable);
          expect(versionFilter.appVersion).to.be.equal(expectedAppVersion);

          var insertedBlobTable = insertStub.getCall(0).args[0];
          var insertedBlob = insertStub.getCall(0).args[1];
          expect(insertedBlobTable).to.be.equal(testBlobsTable);
          expect(insertedBlob.data).to.be.equal(expectedBlobData);


          var insertedAppRecordTable = insertStub.getCall(1).args[0];
          var insertedAppRecord = insertStub.getCall(1).args[1];
          expect(insertedBlobTable).to.be.equal(testBlobsTable);
          expect(insertedAppRecord.appVersion).to.be.equal(expectedAppVersion);
          expect(insertedAppRecord.revision).to.be.equal(expectedRevision);
          expect(insertedAppRecord.revisionId).to.be.equal(expectedBlobId);

          expect(result.appVersion).to.be.equal(expectedAppVersion);
          expect(result.revision).to.be.equal(expectedRevision);
          expect(result.revisionId).to.be.equal(expectedRevisionId);

          done();
        });
    });
 
    it('should save an blob and update app version entry with next revision number when no revision is provided', function(done) {
      // Align
      var testAppTable = "app_versions_table";
      var testBlobsTable = "blobs_table";
      var expectedBlobId = "wdawdad";
      var expectedBlobData = "some_blob_data";
      var blobEntry = { id: expectedBlobId, data: expectedBlobData};
      var expectedAppVersion = "0.2.1123";
      var expectedRevisionId = "asdaw";
      var expectedRevision = 6;
      var appBlobEntry = { appVersion: expectedAppVersion, revision: expectedRevision, revisionId: expectedRevisionId};

      var configureStub = sinon.stub();
      var gamificationMock = { configure: configureStub };
      var expectedAppEntryId = "svdfe";

      var getFilteredEntriesStub = sinon.stub();
      getFilteredEntriesStub.resolves([{ id: expectedAppEntryId, revision: 5 }]);
      var insertStub = sinon.stub();
      insertStub.resolves(blobEntry);
      var updateEntryStub = sinon.stub();
      updateEntryStub.resolves(appBlobEntry);
      var dbHelperMock = { 
        APP_REVS_TABLE: testAppTable,
        BLOBS_TABLE: testBlobsTable,
        configure: configureStub, 
        getFilteredEntries: getFilteredEntriesStub,
        insert: insertStub,
        updateEntry: updateEntryStub
      };

      // Action
      var ctrl = new DemoCtrl({ gamification: gamificationMock, dbHelper: dbHelperMock});
      ctrl.insertDataBlob({data: "some_blob_data"}, "0.2.1123")
        .then(function(result) {
          // Assert
          expect(configureStub.called).to.be.equal(true);

          var appTableQueried = getFilteredEntriesStub.getCall(0).args[0];
          var versionFilter = getFilteredEntriesStub.getCall(0).args[1];
          expect(appTableQueried).to.be.equal(testAppTable);
          expect(versionFilter.appVersion).to.be.equal(expectedAppVersion);

          var insertedBlobTable = insertStub.getCall(0).args[0];
          var insertedBlob = insertStub.getCall(0).args[1];
          expect(insertedBlobTable).to.be.equal(testBlobsTable);
          expect(insertedBlob.data).to.be.equal(expectedBlobData);

          var insertedAppRecordTable = updateEntryStub.getCall(0).args[0];
          var appBlobEntryId = updateEntryStub.getCall(0).args[1];
          var updatedAppEntry = updateEntryStub.getCall(0).args[2];
          expect(insertedBlobTable).to.be.equal(testBlobsTable);
          expect(appBlobEntryId).to.be.equal(expectedAppEntryId);
          expect(updatedAppEntry.revision).to.be.equal(expectedRevision);
          expect(updatedAppEntry.revisionId).to.be.equal(expectedBlobId);

          expect(result.appVersion).to.be.equal(expectedAppVersion);
          expect(result.revision).to.be.equal(expectedRevision);
          expect(result.revisionId).to.be.equal(expectedRevisionId);

          done();
        });
    });
  
    it('should save an blob and update app version entry with the revision passed in', function(done) {
      // Align
      var testAppTable = "app_versions_table";
      var testBlobsTable = "blobs_table";
      var expectedBlobId = "wdawdad";
      var expectedBlobData = "some_blob_data";
      var blobEntry = { id: expectedBlobId, data: expectedBlobData};
      var expectedAppVersion = "0.2.1123";
      var expectedRevisionId = "asdaw";
      var expectedRevision = 7;
      var appBlobEntry = { appVersion: expectedAppVersion, revision: expectedRevision, revisionId: expectedRevisionId};

      var configureStub = sinon.stub();
      var gamificationMock = { configure: configureStub };
      var expectedAppEntryId = "svdfe";

      var getFilteredEntriesStub = sinon.stub();
      getFilteredEntriesStub.resolves([{ id: expectedAppEntryId, revision: 5 }]);
      var insertStub = sinon.stub();
      insertStub.resolves(blobEntry);
      var updateEntryStub = sinon.stub();
      updateEntryStub.resolves(appBlobEntry);
      var dbHelperMock = { 
        APP_REVS_TABLE: testAppTable,
        BLOBS_TABLE: testBlobsTable,
        getFilteredEntries: getFilteredEntriesStub,
        insert: insertStub,
        updateEntry: updateEntryStub
      };

      // Action
      var ctrl = new DemoCtrl({ gamification: gamificationMock, dbHelper: dbHelperMock});
      ctrl.insertDataBlob({data: "some_blob_data"}, "0.2.1123", 7)
        .then(function(result) {
          // Assert
          expect(configureStub.called).to.be.equal(true);

          var appTableQueried = getFilteredEntriesStub.getCall(0).args[0];
          var versionFilter = getFilteredEntriesStub.getCall(0).args[1];
          expect(appTableQueried).to.be.equal(testAppTable);
          expect(versionFilter.appVersion).to.be.equal(expectedAppVersion);

          var insertedBlobTable = insertStub.getCall(0).args[0];
          var insertedBlob = insertStub.getCall(0).args[1];
          expect(insertedBlobTable).to.be.equal(testBlobsTable);
          expect(insertedBlob.data).to.be.equal(expectedBlobData);

          var insertedAppRecordTable = updateEntryStub.getCall(0).args[0];
          var appBlobEntryId = updateEntryStub.getCall(0).args[1];
          var updatedAppEntry = updateEntryStub.getCall(0).args[2];
          expect(insertedBlobTable).to.be.equal(testBlobsTable);
          expect(appBlobEntryId).to.be.equal(expectedAppEntryId);
          expect(updatedAppEntry.revision).to.be.equal(expectedRevision);
          expect(updatedAppEntry.revisionId).to.be.equal(expectedBlobId);

          expect(result.appVersion).to.be.equal(expectedAppVersion);
          expect(result.revision).to.be.equal(expectedRevision);
          expect(result.revisionId).to.be.equal(expectedRevisionId);

          done();
        });
    });
  });


  describe('getblobHistory()', function () {
    it('should reject when there is a db error', function(done) {
      // Align
      var expectedErrorMsg = 'DB error';
      var testAppTable = "app_versions_table";
      var testBlobsTable = "blobs_table";

      var configureStub = sinon.stub();
      var gamificationMock = { configure: configureStub };

      var getAllEntriesStub = sinon.stub();
      getAllEntriesStub.rejects(expectedErrorMsg);
      var dbHelperMock = { 
        APP_REVS_TABLE: testAppTable,
        BLOBS_TABLE: testBlobsTable,
        getAllEntries: getAllEntriesStub
      };


      // Action
      var ctrl = new DemoCtrl({ gamification: gamificationMock, dbHelper: dbHelperMock});
      ctrl.getblobHistory()
        .otherwise(function(err) {
          // Assert
          expect(configureStub.called).to.be.equal(true);

          expect(err.message).to.be.equal(expectedErrorMsg);
          done();
        });
    });

    it('should fetch the app version entries and blobs', function(done) {
      // Align
      var testAppTable = "app_versions_table";
      var testBlobsTable = "blobs_table";
      var expectedAppEntries = [
        { appVersion: '1.0.0', revision: 3, revisionId: 'revId3' },
        { appVersion: '0.0.1', revision: 1, revisionId: 'revId1' }
      ];
      var expectedBlobs = [
        { id: 'revId3', data: 'data for revision 3' },
        { id: 'revId2', data: 'data for revision 2' },
        { id: 'revId1', data: 'data for revision 1' },
      ];

      var configureStub = sinon.stub();
      var gamificationMock = { configure: configureStub };

      var getAllEntriesStub = sinon.stub();
      getAllEntriesStub.withArgs(testAppTable).resolves(expectedAppEntries);
      getAllEntriesStub.withArgs(testBlobsTable).resolves(expectedBlobs);
      var dbHelperMock = { 
        APP_REVS_TABLE: testAppTable,
        BLOBS_TABLE: testBlobsTable,
        getAllEntries: getAllEntriesStub
      };


      // Action
      var ctrl = new DemoCtrl({ gamification: gamificationMock, dbHelper: dbHelperMock});
      ctrl.getblobHistory()
        .then(function(result) {
          // Assert
          expect(configureStub.called).to.be.equal(true);

          var appEntries = result.appVersionMatches;
          expect(appEntries.length).to.be.equal(expectedAppEntries.length);
          expect(appEntries[0].appVersion).to.be.equal(expectedAppEntries[0].appVersion);
          expect(appEntries[0].revision).to.be.equal(expectedAppEntries[0].revision);
          expect(appEntries[0].revisionId).to.be.equal(expectedAppEntries[0].revisionId);
          expect(appEntries[1].appVersion).to.be.equal(expectedAppEntries[1].appVersion);
          expect(appEntries[1].revision).to.be.equal(expectedAppEntries[1].revision);
          expect(appEntries[1].revisionId).to.be.equal(expectedAppEntries[1].revisionId);
          var blobs = result.blobs;
          expect(blobs.length).to.be.equal(expectedBlobs.length);
          expect(blobs[0].id).to.be.equal(expectedBlobs[0].id);
          expect(blobs[0].data).to.be.equal(expectedBlobs[0].data);
          expect(blobs[1].id).to.be.equal(expectedBlobs[1].id);
          expect(blobs[1].data).to.be.equal(expectedBlobs[1].data);
          expect(blobs[2].id).to.be.equal(expectedBlobs[2].id);
          expect(blobs[2].data).to.be.equal(expectedBlobs[2].data);

          done();
        });
    });
  });


  function getTestPlanComponents() {
    var deeds = [], events = [], missions =[], variables = [];
    _.forEach(data.plan.deeds, function(deed) {
      deeds.push(deed.name);
    });
    _.forEach(data.plan.events, function(event) {
      events.push(event.name);
    });
    _.forEach(data.plan.missions, function(mission) {
      missions.push(mission.name);
    });
    _.forEach(data.plan.variables, function(variable) {
      variables.push(variable.name);
    });          

    return { 
      deeds: deeds,
      events: events,
      missions: missions,
      variables: variables
    };
  }
});












