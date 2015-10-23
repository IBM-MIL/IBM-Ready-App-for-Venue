/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
'use strict';

/* This files provides a central place to append routes to the 
 * application. Each set of features provides its own router 
 * an
 */
module.exports = function(app) {
  /* ----------------------------------
   * Beginning of Test Setup Routes
   * ---------------------------------- */
  // example GET route returning a json
  app.get('/', function(req, res) {
    res.json({data: { msg: 'Aloha :)'}});
  });

  // example route for recieving post data
  app.post('/send', function(req, res) {
    res.json({ data: { msg: 'Aloha :)', to: req.body.phone} });
  });  

  /* ----------------------------------
   * End of Test Setup Routes
   * ---------------------------------- */
  app.use('/api/demo', require('./api/demo'));
  
  app.use('/api/gamification', require('./api/gamification'));
  app.use('/api/pois', require('./api/pois'));
  app.use('/api/users', require('./api/users'));
};