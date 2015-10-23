/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
module.exports = function(grunt) {
  // load plugins in a just in time fashion
  require('jit-grunt')(grunt, {
    env: 'grunt-env',
    express: 'grunt-express-server',
    jshint: 'grunt-contrib-jshint',
    mochaTest: 'grunt-mocha-test',
    watch: 'grunt-contrib-watch',
    jsdoc: 'grunt-jsdoc'
  });

  // Time recording for tasks ran
  require('time-grunt')(grunt);

  // Load local environment configurations
  var localEnv;
  try {
    localEnv = require('./config/localEnv.js');
  } catch(e) {
    localEnv = {};
  }

  var testConfig;
  try {
    testConfig = require('./config/testEnv.js');
  } catch(e) {
    testConfig = {};
  }

  var projectFiles = [
    '../venue-mfpf/adapters/*/*-impl.js', //mfp adapter files
    './api/*/*.js',
    './config/*.js', 
    './db/*.js', 
    './libs/games-as-promised/*.js',
    './libs/games-as-promised/*/*.js',
    './*.js'
  ];   

  var coreProjectFiles = [
    '../venue-mfpf/adapters/*/*-impl.js', //mfp adapter files
    './api/*/*.js',
    './config/*.js', 
    './db/*.js', 
    './*.js'
  ];

  var unitTestFiles = ['./test/unit/*/*.spec.js']; 
  var integrationTestFiles = ['./test/integration/*.spec.js'];
  var testFiles = ['./test/unit/*/*.spec.js', './test/integration/*.spec.js'];

  // project configuration
  grunt.initConfig({
    env: {
      dev: localEnv,
      test: testConfig
    },
    express: {
      dev: {
        options: {
          script: './app.js'
        }
      },
      options: {
        port: process.env.PORT || 8080
      }
    },
    jshint: {
      build: {
        options: {
          jshintrc: './.jshintrc',
          reporter: require("jshint-junit-reporter"),
          // when reporterOutput is present output of the reporter will go to 
          // file specified instead of std output
          reporterOutput: './jshintOutput.xml' 
        },
        src: projectFiles
      },
      dev: {
        options: {
          jshintrc: './.jshintrc',
          reporter: require('jshint-stylish')
        },
        src: projectFiles
      },
      unitTests: {
        options: {
          jshintrc: './.jshintrc',
          reporter: require('jshint-stylish')
        },
        src: unitTestFiles
      }
    },
    mochaTest: {
      build: {
        options: {
          reporter: 'xunit',
          captureFile: './testResults.xml'
        },
        src: testFiles
      },
      unit: {
        options: {
          reporter: 'spec'
        },
        src: unitTestFiles
      },
      integration: {
        options: {
          reporter: 'spec'
        },
        src: integrationTestFiles
      },
      full: {
        options: {
          reporter: 'spec'
        },
        src: testFiles
      }
    },
    jsdoc: {
      dist: {
        src: coreProjectFiles,
        dest: './docs'
      }
    },
    watch: {
      express: {
        files: projectFiles,
        tasks:  [ 'serve' ],
        options: {
          spawn: false 
        }
      }
    }
  });

  /*
   * This task has 4 steps:
   * 1. It runs jshint on the code base.
   * 2. Setups environments variables for the server process.
   * 3. Starts the express server.
   * 4. Keeps the express server running while watching any changes on the server files.
   */
  grunt.registerTask('serve', ['jshint:dev', 'env:dev', 'express:dev', 'watch']);

  /*
   * This task has 3 steps:
   * 1. It runs jshint on the code base.
   * 2. Setups environments variables for the server process.
   * 3. Run the mocha tests.
   */
  grunt.registerTask('unit-test', ['jshint:dev', 'jshint:unitTests','env:test', 'mochaTest:unit']);

  /*
   * This task has 3 steps:
   * 1. It runs jshint on the code base.
   * 2. Setups environments variables for the server process.
   * 3. Run the mocha tests.
   */
  grunt.registerTask('integration-test', ['jshint:dev', 'env:test', 'mochaTest:integration']);

  /*
   * This task has 3 steps:
   * 1. It runs jshint on the code base.
   * 2. Setups environments variables for the server process.
   * 3. Run the mocha tests.
   */
  grunt.registerTask('full-test', ['jshint:dev', 'env:test', 'mochaTest:full']);

  /*
   * This task has 3 steps:
   * 1. It runs jshint on the code base. The analysis out will be in the 
   *    'jshintOutput' in the root of the project.
   * 2. Setups environments variables for the server process.
   * 3. Run the mocha tests. The result wil be output to the 'testResults.txt' 
   *    file in the root of the project
   */
  grunt.registerTask('build', ['jshint:build', 'env:test', 'mochaTest:build']);
};