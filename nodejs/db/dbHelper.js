/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
'use strict';

var _           = require('lodash');
var ssh         = require('./sshTunnel');
var rethinkdb   = require('./rethinkdb');
var r           = require('rethinkdb');
var when        = require('when');

var helper = {};

/**
 * table names
 */
helper.APP_REVS_TABLE = "apps_data";
helper.BLOBS_TABLE = "blobs";
helper.POIS_TABLE = "pois";
helper.USERS_TABLE = "users";

helper.insert = function(tableName, entry) {
  var deferred = when.defer();

  connectToDb(function(conn) {
    withValidTable(tableName, conn, function() {
      insertRecordToTable(tableName, entry, conn)
        .then(function(entrySaved) {
          if(entrySaved.inserted == 1) {
            deferred.resolve(entrySaved.changes[0].new_val);
          } else {
            deferred.reject('unexpected insertion result ' + entrySaved);
          }
        });
      });
  });

  return deferred.promise;
};


helper.getEntryById = function(tableName, entryId) {
  var deferred = when.defer();

  connectToDb(function(conn) {
    withValidTable(tableName, conn, function() {
      r.table(tableName)
       .get(entryId)
       .run(conn, function(err, result) {
        if(err) {
          return deferred.reject(err);
        }

        conn.close()
          .then(function() {
            deferred.resolve(result);
          });
      });
    });
  });

  return deferred.promise;
};

helper.getFilteredEntries = function(tableName, filterPredicate) {
var deferred = when.defer();
  
  connectToDb(function(conn) {
    withValidTable(tableName, conn, function() {
      r.table(tableName)
       .filter(filterPredicate)
       .run(conn, function(err, result) {
        if(err) {
          return deferred.reject(err);
        }

        var filteredEntries = result._responses[0] ? result._responses[0].r : [];

        conn.close()
          .then(function() {
            deferred.resolve(filteredEntries);
          });
      });
    });
  });

  return deferred.promise;
};

helper.getAllEntries = function(tableName) {
  var deferred = when.defer();


  connectToDb(function(conn) {
    withValidTable(tableName, conn, function() {
      r.table(tableName)
       .run(conn, function(err, result) {
          if(err) {
            return deferred.reject(err);
          }

          var entries =  result && result._responses && result._responses.length > 0 ? 
            result._responses[0].r : [];

          conn.close()
            .then(function() {
              deferred.resolve(entries);
            });
      });
    });

  }); 

  return deferred.promise;
};

helper.updateEntry = function(tableName, entryId, updates) {
  var deferred = when.defer();

  connectToDb(function(conn) {
    withValidTable(tableName, conn, function() {
      r.table(tableName)
        .get(entryId)
        .update(updates, { returnChanges: true })
        .run(conn, function(err, result) {
          if(err) {
            return deferred.reject(err);
          }

          var updatedEntry = result.changes[0] ? result.changes[0].new_val : {};

          conn.close()
            .then(function() {
              deferred.resolve(updatedEntry);
            });
        });
    });
  });

  return deferred.promise;
};

module.exports = helper;

/* ----------------------------------------------------
 * Private functions 
 * ----------------------------------------------------*/


function connectToDb(callback) {
  ssh.withValidTunnel(function(host, port){
    rethinkdb.connect(host, port)
      .then(function(conn) {
        callback(conn);
      }, function(err) {
        throw new Error('Error Conencting to Rethinkdb: ' + err);
      });
  });
}

function withValidTable(tableName, conn, callback) {
  isTableCreated(tableName, conn)
    .then(function(isTableCreated) {
      if(!isTableCreated) {
        createTable(tableName, conn)
          .then(function() {
              callback();
          });
      } else {
        callback();
      }
    });
}

function createTable(tablenName, conn) {
  var deferred = when.defer();
  
  r.tableCreate(tablenName, { primaryKey: 'id'})
   .run(conn)
   .then(function(result) {
      deferred.resolve(result);
    })
    .error(function(err) {
      deferred.reject(new Error('Error creating table: ' + tablenName));
    });

  return deferred.promise;
}

function isTableCreated(tableName, conn) {
  var deferred = when.defer();

  r.tableList().run(conn)
    .then(function(currentTables) {
      deferred.resolve(_.includes(currentTables, tableName));
    })
    .error(function(err) {
      deferred.reject(new Error('Error checking the database tables'));
    });

  return deferred.promise;
}

function insertRecordToTable(tableName, entry, conn) {
  var deferred = when.defer();

  r.table(tableName)
   .insert(entry, { returnChanges: true })
   .run(conn, function(err, result) {
      if(err) {
        return deferred.reject(err);
      }

      conn.close()
        .then(function() {
          deferred.resolve(result);
        });
  }); 

  return deferred.promise;
} 