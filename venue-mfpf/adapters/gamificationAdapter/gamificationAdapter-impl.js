/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
'use strict';
/**
 * @module mfpGamificationAdapter
 * @description This adapter provides procedure to interact with the gamification 
 * 				data and application setup required for the iOS client.
 */

/**
 * @function insertPlayer
 * @description This procedure is a pass trough to the nodeJS endpoint
 * 				POST /api/gamification/user
 * 
 * @param {User} player - the player to be save and it should have the form
 *                        {
 *                          id: {Number} (required),
 *                          name: {String} (optional),
 *                          groupId: {Number} (optional)
 *                        }
 * @returns {mfpResponse} - An MFP response wrapping the data received from
 * 							the endpoint
 */
function insertPlayer(player) {
	var path = '/api/gamification/user', 
	request = {
		method : 'POST',
		path : path,
		returnedContentType : 'json',
		body : {
			contentType : 'application/json',
			content : player
		}
	};

	return invokeHttpServer(request);
}

/**
 * @function getPlayer
 * @description This procedure is a pass trough to the nodeJS endpoint
 * 				GET /api/gamification/user/{playerId}
 *
 * @param {String} playerId - The player ID
 * @returns {mfpResponse} - An MFP response wrapping the data received from
 * 							the endpoint
 */
function getPlayer(playerId) {
	var path = '/api/gamification/user/' + playerId, 
	request = {
		method : 'GET',
		path : path,
		returnedContentType : 'json'
	};

	return invokeHttpServer(request);
}


/**
 * @function deletePlayer
 * @description This procedure is a pass trough to the nodeJS endpoint
 * 				DELETE /api/gamification/user/{playerId}
 *
 * @param {String} playerId - The player ID
 * @returns {mfpResponse} - An MFP response wrapping the data received from
 * 							the endpoint
 */
function deletePlayer(playerId) {
	var path = '/api/gamification/user/' + playerId, 
	request = {
		method : 'DELETE',
		path : path,
		returnedContentType : 'json'
	};

	return invokeHttpServer(request);
}

/**
 * @function getBadges
 * @description This procedure is a pass trough to the nodeJS endpoint
 * 				GET /api/gamification/badge
 *
 * @returns {mfpResponse} - An MFP response wrapping the data received from
 * 							the endpoint
 */
function getBadges() {
	var path = '/api/gamification/badge', 
	request = {
		method : 'GET',
		path : path,
		returnedContentType : 'json'
	};

	return invokeHttpServer(request);
}

/**
 * @function getPlayerBadges
 * @description This procedure is a pass trough to the nodeJS endpoint
 * 				GET /api/gamification/user/{playerId}/badges
 * 
 * @param {String} playerId - The player ID
 * @returns {mfpResponse} - An MFP response wrapping the data received from
 * 							the endpoint
 */
function getPlayerBadges(playerId) {
	var path = '/api/gamification/user/' + playerId + '/badges', 
	request = {
		method : 'GET',
		path : path,
		returnedContentType : 'json'
	};

	return invokeHttpServer(request);
}

/**
 * @function addPlayerToGroup
 * @description This procedure is a pass trough to the nodeJS endpoint
 * 				POST /api/gamification/group/{groupId}
 *
 * @param {String} groupId - The group ID
 * @param {String} playerId - The player ID
 * @returns {mfpResponse} - An MFP response wrapping the data received from
 * 							the endpoint
 */
function addPlayerToGroup(groupId, playerId) {
	var path = '/api/gamification/group/' + groupId, 
	data = { id: playerId },
	request = {
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
 * @function getGroup
 * @description This procedure is a pass trough to the nodeJS endpoint
 * 				GET /api/gamification/group/{groupId}
 *
 * @param {String} groupId - The group ID
 * @returns {mfpResponse} - An MFP response wrapping the data received from
 * 							the endpoint
 */
function getGroup(groupId) {
	var path = '/api/gamification/group/' + groupId, 
	request = {
		method : 'GET',
		path : path,
		returnedContentType : 'json'
	};

	return invokeHttpServer(request);
}

/**
 * @function getGroupLeaderboard
 * @description This procedure is a pass trough to the nodeJS endpoint
 * 				GET /api/gamification/group/{groupId}/leaderboard
 *
 * @param {String} groupId - The group ID
 * @returns {mfpResponse} - An MFP response wrapping the data received from
 * 							the endpoint
 */
function getGroupLeaderboard(groupId) {
	var path = '/api/gamification/group/' + groupId + '/leaderboard', 
	request = {
		method : 'GET',
		path : path,
		returnedContentType : 'json'
	};

	return invokeHttpServer(request);
}

/**
 * @function getBadge
 * @description This procedure is a pass trough to the nodeJS endpoint
 * 				GET /api/gamification/badge/{badgeName}
 *
 * @param {String} badgeName - the badge name
 * @returns {mfpResponse} - An MFP response wrapping the data received from
 * 							the endpoint
 */
function getBadge(badgeName) {
	var path = '/api/gamification/badge/' + badgeName, 
	request = {
		method : 'GET',
		path : path,
		returnedContentType : 'json'
	};

	return invokeHttpServer(request);
}

/**
 * @function fireEvent
 * @description This procedure is a pass trough to the nodeJS endpoint
 * 				GET /api/gamification/badge/step/complete
 *
 * @param {String} eventName - the badge name
 * @param {String} playerId - the player Id
 * @returns {mfpResponse} - An MFP response wrapping the data received from
 * 							the endpoint
 */
function fireEvent(eventName, userId) {
	var path = '/api/gamification/event/fire/', 
	data = { eventName: eventName, userId: userId },
	request = {
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