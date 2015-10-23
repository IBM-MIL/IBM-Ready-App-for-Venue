/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
'use strict';

var utils = {};

utils.getGamificationConfig = function() {
  var gamificationCreds;

  var services = JSON.parse(process.env.VCAP_SERVICES);
  if(!services.Gamification || !services.Gamification[0].credentials) {
    throw new Error('no gamifcation service credentials found');
  } else {
    gamificationCreds = services.Gamification[0].credentials;
  }

  return {
    gamiHost: gamificationCreds.gamiHost,
    tenantId: gamificationCreds.tenantId,
    planName: process.env.GAME_PLAN,
    key:      process.env.GAME_KEY,
    getLoginUid: function(req, resp) {
        //return the gamification uid of current login user for authorization validation
        //below code assume you store login uid in session
        return req.session === null? null: req.session.uid;
    }
  };
};

module.exports = utils;