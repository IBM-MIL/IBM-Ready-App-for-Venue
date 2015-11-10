/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
'use strict';

var _     = require('lodash');
var r     = require('rethinkdb');
var when  = require('when');
var fs    = require('fs');
var path  = require('path');

var db = {};
var tables = [];

/**
 * Function to setup rethinkDB for the app. This creates an
 * ssh tunnel to connect to the app's database and setups up
 * the application database if it is not already in the 
 * rethinkDB instance.
 *
 * @return promise of a rethinkdb connection
 */
db.setup = function(host, port) {
  var deferred = when.defer();
  
  setupRethinkDB(host, port)
    .then(function(tables) {
      // only log the start of the server when not in test mode
      if(process.env.NODE_ENV !== 'test') {
        console.log('rethinkDB setup with tables: '); 
        console.log(tables);
      }

      deferred.resolve();
    });

  return deferred.promise;
};

/**
 * Wrap rethinkdb's module connect to keep connections 
 * params only in this file.
 *
 * @return promise of a rethinkdb connection
 */
db.connect = function() {
  var deferred = when.defer();

  // load cacert file
  var caCert = fs.readFileSync(path.join(__dirname, '../', 'cacert'));
  
  return r.connect({
      host:     process.env.RETHINKDB_HOST,
      port:     process.env.RETHINKDB_PORT,
      authKey:  process.env.RETHINKDB_AUTH_KEY,
      db:       process.env.RETHINKDB_DB_NAME,
      ssl: {
        ca: caCert
      }
    });
};

module.exports = db;

/* ----------------------------------------------------
 * Private functions 
 */
function setupRethinkDB(host, port) {
  var deferred = when.defer();

  // connect to rethink
  db.connect(host, port)
    .then(function(conn) {
      isDatabaseCreated(conn)
        .then(setupAppDB)
        .then(checkTables)
        .then(setupTables)
        .then(function (tables) {
          conn.close()
            .then(function() {
              deferred.resolve(tables);
            })
            .error(function(err) {
              deferred.reject(new Error('Error closing rethinkdb connection'));
            });
        });
    })
    .error(function(err) {
      console.log('Error while connecting to rethinkDB');
      throw err;
    });

  return deferred.promise;
}

function isDatabaseCreated(conn) {
    var deferred = when.defer();

    r.dbList().run(conn)
      .then(function(dbs) {
        deferred.resolve({ 
          conn: conn,
          isDbCreated: _.includes(dbs, process.env.RETHINKDB_DB_NAME)
        });
      })
      .error(function(err) {
        deferred.reject(new Error('Error when check the databases on rethinkDB'));
      });

    return deferred.promise;
}

function setupAppDB(args) {
  var deferred = when.defer();

  if (!args.isDbCreated) {    
    r.dbCreate(process.env.RETHINKDB_DB_NAME).run(args.conn)
      .then(function(result) {
        args.conn.use(process.env.RETHINKDB_DB_NAME); 
        deferred.resolve(args.conn);
      })
      .error(function(err) {
        deferred.reject(new Error('Error creating app database rethinkDB'));
      });
  } else {
    args.conn.use(process.env.RETHINKDB_DB_NAME); 
    deferred.resolve(args.conn);
  }
  
  return deferred.promise;
}

function checkTables(conn) {
  var deferred = when.defer();

  r.tableList().run(conn)
    .then(function(currentTables) {
      var tablesNotCreated =  [];
      var tablesCreated = [];

      _.forEach(tables, function(table) {
        if (_.includes(currentTables, table)) {
          tablesCreated.push(table);
        } else {
          tablesNotCreated.push(table);
        }
      });

      deferred.resolve({
        conn: conn,
        tablesNotCreated: tablesNotCreated,
        tablesCreated: tablesCreated
      });
    })
    .error(function(err) {
      deferred.reject(new Error('Error checking the database tables'));
    });

  return deferred.promise;
}

function setupTables(args) {
  var deferred = when.defer();
  var requests = [];

  _.forEach(args.tablesNotCreated, function(table) {
    requests.push(createTable({ tableName: table, conn: args.conn }));
  });

  when.all(requests)
    .then(function(results) {
      var tablesJustCreated = [];
      _.forEach(results, function(tableCreationResult) {
        var newTableName = tableCreationResult.config_changes[0].name;
        tablesJustCreated.push(newTableName);
      });

      deferred.resolve(_.union(args.tablesCreated, tablesJustCreated));
    });

  return deferred.promise;
}

function createTable(args) {
  var deferred = when.defer();

  r.tableCreate(args.tableName).run(args.conn)
    .then(function(result) {
      deferred.resolve(result);
    })
    .error(function(err) {
      deferred.reject(new Error('Error creating table: ' + args.tableName));
    });

  return deferred.promise;
}
