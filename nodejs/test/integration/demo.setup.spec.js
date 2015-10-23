// /*
//  *  Licensed Materials - Property of IBM
//  *  © Copyright IBM Corporation 2015. All Rights Reserved.
//  */
//  'use strict';

// var _ = require('lodash');
// var expect = require('chai').expect;
// var sinon = require('sinon');
// var when = require('when');

// // add sinon capabilities for promises 
// require('sinon-as-promised')
// var dbHelper     = require('../../db/dbHelper');
// var gamification = require('../../libs/games-as-promised');
// var utils        = require('../../utils');
// gamification.configure(utils.getGamificationConfig());

// var testGamePlanData = require('../data/gameplan');
// var demoCtrl = require('../../api/demo/demo.controller')({
//     dbHelper: dbHelper,
//     gamification: gamification
//   });

// describe('Demo Setup Integration Tests', function() {
//   after(function () {
//     // force cleanup in case of failure
//     clearPlan({ ctrl: demoCtrl, data: testGamePlanData});
//   });
  
//   it('should setup, get, and clear the plan given appropiate game plan data', function(done) {
//     // This test requires a longer timeout due to the large number of request required
//     // by the gamification API
//     this.timeout(80000);

//     // align  
//     var testGamePlan = testGamePlanData.plan;
//     // if a promise is unexpectedly rejected force false the test 
//     var errorHandler = function(err) {
//         expect(false).to.be.true;
//         done();
//     }

//     // act
//     setupPlan({ ctrl: demoCtrl, data: testGamePlanData}, errorHandler)
//       .then(getPlan, errorHandler)
//       .then(function(plan) {
//         // setup assertions
//         expect(plan.deeds.length).to.be.equal(testGamePlan.deeds.length);
//         expect(checkIfArrayHasComponent(plan.deeds, testGamePlan.deeds[0].name)).to.be.true;
//         expect(checkIfArrayHasComponent(plan.deeds, testGamePlan.deeds[1].name)).to.be.true;
//         expect(plan.events.length).to.be.equal(testGamePlan.events.length);
//         expect(checkIfArrayHasComponent(plan.events, testGamePlan.events[0].name)).to.be.true;
//         expect(checkIfArrayHasComponent(plan.events, testGamePlan.events[1].name)).to.be.true;
//         expect(plan.missions.length).to.be.equal(testGamePlan.missions.length);
//         expect(checkIfArrayHasComponent(plan.missions, testGamePlan.missions[0].name)).to.be.true;
//         expect(checkIfArrayHasComponent(plan.missions, testGamePlan.missions[1].name)).to.be.true;
//         expect(plan.variables.length).to.be.equal(testGamePlan.variables.length);
//         expect(checkIfArrayHasComponent(plan.variables, testGamePlan.variables[0].name)).to.be.true;
//         expect(checkIfArrayHasComponent(plan.variables, testGamePlan.variables[1].name)).to.be.true;

//         clearPlan({ ctrl: demoCtrl, data: testGamePlanData})
//           .then(getPlan, errorHandler)
//           .then(function(plan) {
//             // cleared assertions
//             expect(plan.deeds.length).to.be.equal(0);
//             expect(plan.events.length).to.be.equal(0);
//             expect(plan.missions.length).to.be.equal(0);
//             expect(plan.variables.length).to.be.equal(0);

//             done();
//           }, errorHandler);
//       }, errorHandler)
//   });
// });

// function setupPlan(args) {
//   var deferred = when.defer();

//   var demoCtrl = args.ctrl;
//   var gamePlanData = args.data;
//   var fakeReq = { body: gamePlanData };
//   var fakeRes = { json: function(data) {}, 
//                   status: function() { deferred.reject(); return { json: function(){} }; }};
//   var resJsonSpy = sinon.stub(fakeRes, "json", function(result) {
//     deferred.resolve({ ctrl: demoCtrl, data: gamePlanData});
//   });

//   demoCtrl.setupGamePlan(fakeReq, fakeRes);

//   return deferred.promise;
// }

// function getPlan(args) {
//   var deferred = when.defer();

//   var demoCtrl = args.ctrl;
//   var testKey = args.data.key;
//   var testPlanName = args.data.plan.name;
//   var fakeReq = { query: { planName: testPlanName, key: testKey } };
//   var fakeRes = { json: function(data) {}, 
//                   status: function() { deferred.reject(); return { json: function(){} }; }};
//   var resJsonSpy = sinon.stub(fakeRes, "json", function(plan) {
//     deferred.resolve(plan);
//   });

//   demoCtrl.getCurrentGamePlan(fakeReq, fakeRes);

//   return deferred.promise;
// }

// function clearPlan(args) {
//   var deferred = when.defer();

//   var demoCtrl = args.ctrl;
//   var gamePlanData = args.data;
//   var fakeReq = { body: testGamePlanData };
//   var fakeRes = { json: function(data) {}, 
//                   status: function() { deferred.reject(); return { json: function(){} }; }};
//   var testGamePlan = testGamePlanData.plan;
//   var resJsonSpy = sinon.stub(fakeRes, "json", function(result) {
//     deferred.resolve({ ctrl: demoCtrl, data: gamePlanData});
//   });

//   demoCtrl.clearGamePlan(fakeReq, fakeRes);

//   return deferred.promise;
// }

// function checkIfArrayHasComponent(components, componentName) {
//   var matches = _.filter(components, function(comp) {
//     return comp.name === componentName;
//   });

//   return matches.length === 1;
// }