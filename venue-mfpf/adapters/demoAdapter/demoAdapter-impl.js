/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
'use strict';

/**
 * @module mfpDemoAdapter
 * @description This adapter provides procedure to interact with the demo data
 * 				and application setup required for the iOS client.
 */

/**
 * @function updateCheck
 * @description This procedure is a pass trough to the nodeJS endpoint
 * 				GET /api/demo/blob/update.
 *
 * @param {String} appVersion - the current version of the iOS client in the
 * 								iOS client
 * @param {Number} revision - the revision of the demo data currently in the 
 * 							  local storage of the iOS client.
 * @returns {mfpResponse} - An MFP response wrapping the data received from
 * 							the endpoint
 */
function updateCheck(appVersion, revision) {
	var path = '/api/demo/blob/update?appVersion=' + appVersion + '&revision=' + 
				revision, 
		request = {
		method : 'GET',
		path : path,
		returnedContentType : 'json'
	};

	return invokeHttpServer(request);
}

/**
 * @function getBlobsAndMatches
 * @description This procedure is a pass trough to the nodeJS endpoint
 * 				GET /api/demo/blob.
 * 
 * @returns {mfpResponse} - An MFP response wrapping the data received from
 * 							the endpoint
 */
function getBlobsAndMatches() {
	var path = '/api/demo/blob/', 
	request = {
		method : 'GET',
		path : path,
		returnedContentType : 'json'
	};

	return invokeHttpServer(request);
}

/**
 * @function insertBlob
 * @description This procedure is a pass trough to the nodeJS endpoint
 * 				POST /api/demo/blob.
 * 
 * @param {String} appVersion - the current version of the iOS client in the
 * 								iOS client
 * @param {Number} revision - the revision of the demo data currently in the 
 * 							  local storage of the iOS client
 * @param {Object} blob - the demo data to be store 
 * @returns {mfpResponse} - An MFP response wrapping the data received from
 * 							the endpoint
 */
function insertBlob(appVersion, revision, blob) {
	var data = {
		appVersion : appVersion,
		revision : revision,
		blob : blob
	}, path = '/api/demo/blob/', request = {
		method : 'POST',
		path : path,
		returnedContentType : 'json',
		body : {
			contentType : 'application/json',
			content : data
		}
	};

	return invokeHttpServer(request);
}

/**
 * @function setupGameplan
 * @description This procedure is a pass trough to the nodeJS endpoint
 * 				POST /api/demo/gameplan.
 * 
 * @param {Object} gameplanData - the data for the gameplan it should look similar to this 
 * 					 {@link https://hub.jazz.net/project/milbuild/Ready%20App%20Venue/overview#https://hub.jazz.net/git/milbuild%252FReady.App.Venue/contents/master/nodejs/test/unit/demo/data/gameplan.js| example}
 * @returns {mfpResponse} - An MFP response wrapping the data received from
 * 							the endpoint.
 */
function setupGameplan(gameplanData) {
	var path = '/api/demo/gameplan/', 
	request = {
		method : 'POST',
		path : path,
		returnedContentType : 'json',
		body : {
			contentType : 'application/json',
			content : gameplanData
		}
	};

	return invokeHttpServer(request);
}

/**
 * @function getCurrentGamePlan
 * @description This procedure is a pass trough to the nodeJS endpoint
 * 				GET /api/demo/gameplan.
 * 
 * @param {String} planName - the name of the game plan as shown on the gamification 
 * 							  service dashboard.
 * @param {String} key - the key of the game plan as shown on the gamification 
 * 					     service dashboard.
 * @returns {mfpResponse} - An MFP response wrapping the data received from
 * 							the endpoint.
 */
function getCurrentGamePlan(planName, key) {
	var path = '/api/demo/gameplan?planName=' + planName + '&key=' + key, 
	request = {
		method : 'GET',
		path : path,
		returnedContentType : 'json'
	};

	return invokeHttpServer(request);
}

/**
 * @function clearGameplan
 * @description This procedure is a pass trough to the nodeJS endpoint
 * 				POST /api/demo/gameplan/clear.
 *
 * @param {Object} - the data for the gameplan it should look similar to this 
 * 					 {@link https://hub.jazz.net/project/milbuild/Ready%20App%20Venue/overview#https://hub.jazz.net/git/milbuild%252FReady.App.Venue/contents/master/nodejs/test/unit/demo/data/gameplan.js| example}
 * @returns {mfpResponse} - An MFP response wrapping the data received from
 * 							the endpoint.
 */
function clearGameplan(gameplanData) {
	var path = '/api/demo/gameplan/clear', 
	request = {
		method : 'POST',
		path : path,
		returnedContentType : 'json',
		body : {
			contentType : 'application/json',
			content : gameplanData
		}
	};

	return invokeHttpServer(request);
}

/**
 * @function setupGamePlayers
 * @description This procedure is a pass trough to the nodeJS endpoint
 * 				POST /api/demo/gameplan/users.
 * 
 * @param {Object} playersData - the data for the user which should look like this 
 * 					 {@link https://hub.jazz.net/project/milbuild/Ready%20App%20Venue/overview#https://hub.jazz.net/git/milbuild%252FReady.App.Venue/contents/master/nodejs/test/unit/demo/data/users.js| example}
 * @returns {mfpResponse} - An MFP response wrapping the data received from
 * 							the endpoint.
 */
function setupGamePlayers(playersData) {
	var path = '/api/demo/gameplan/users', 
	request = {
		method : 'POST',
		path : path,
		returnedContentType : 'json',
		body : {
			contentType : 'application/json',
			content : playersData
		}
	};

	return invokeHttpServer(request);
}

/**
 * @function deleteGamePlayers
 * @description This procedure is a pass trough to the nodeJS endpoint
 * 				DELETE /api/demo/gameplan/users.
 *
 * @param {Array.<Object>} players - an array with the data for the player that 
 *                          will be deleted. Each player should be of the form: 
 *                        	{"id": String (required), "groupId": String (optional) }.
 * @returns {mfpResponse} - An MFP response wrapping the data received from
 * 							the endpoint.
 */
function deleteGamePlayers(usersData) {
	var path = '/api/demo/gameplan/users', 
	request = {
		method : 'DELETE',
		path : path,
		returnedContentType : 'json',
		body : {
			contentType : 'application/json',
			content : usersData
		}
	};

	return invokeHttpServer(request);
}

/**
 * @ignore
 * This method processes the JSON response and sets the isSuccessful flag to
 * false if the server responded with code that is not a 200 or 300. By default,
 * the isSuccessful flag is set to false only if the HTTP host is not reachable
 * or invalid HTTP request timed out. Hence, the need for this method. For
 * further details, see:
 * https://www.ibm.com/developerworks/community/blogs/worklight/entry/handling_backend_responses_in_adapters?lang=en
 * 
 * @param response
 */
function handleResponse(response) {
	// Is MFP assumes isSuccessful to be true but the response status code is
	// not a 200 or 300
	// then change the isSuccessful to be false.
	if (response && response.isSuccessful && 
		(response.statusCode > 399 || response.statusCode < 200)) {
		response.isSuccessful = false;
	}
	return response;
}

function invokeHttpServer(input) {
	// appropriately set the isSuccessful flag of the response
	var response = handleResponse(WL.Server.invokeHttp(input));

	// remove extra content on the Node response
	return response.isSuccessful ? {
		data : response.data,
		isSuccessful : response.isSuccessful
	} : {
		error : response.error ? response.error : response.errors,
		statusCode : response.statusCode,
		isSuccessful : response.isSuccessful
	};
}