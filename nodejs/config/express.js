/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
'use strict';

var bodyParser  = require('body-parser');
var morgan      = require('morgan');

/*
 * This file centralizes the configuration for the expressJS server.
 */
module.exports = function(app) {
  app.use(bodyParser.json()); 
  app.use(bodyParser.urlencoded({ extended: true }));

  if(process.env.NODE_ENV === 'dev') {
    app.use(morgan('dev'));
  }
};