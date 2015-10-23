/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
'use strict';

/**
 * @module mfpUserAdapter
 * @description This adapter provides procedure to interact with the users data
 * 				and application setup required for the iOS client.
 */

/**
 * @function getAllUsers
 * @description This procedure is a pass trough to the nodeJS endpoint
 * 				GET /api/users
 *
 * @returns {mfpResponse} - An MFP response wrapping the data received from
 * 							the endpoint
 */
function getAllUsers() {
	var path = '/api/users', 
		request = {
			method : 'GET',
			path : path,
			returnedContentType : 'json'
		};

	return invokeHttpServer(request);
}

/**
 * @function insertUser
 * @description This procedure is a pass trough to the nodeJS endpoint
 * 				POST /api/users
 *
 * @param {User} user - the user to be created
 * @returns {mfpResponse} - An MFP response wrapping the data received from
 * 							the endpoint
 */
function insertUser(user) {
	var data = {
		user : user
	}, path = '/api/users/', request = {
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
 * @function getUser
 * @description This procedure is a pass trough to the nodeJS endpoint
 * 				GET /api/users/user/{userId}
 *
 * @param {String} userId - the user ID
 * @returns {mfpResponse} - An MFP response wrapping the data received from
 * 							the endpoint
 */
function getUser(userId) {
	var path = '/api/users/user/' + userId, 
		request = {
			method : 'GET',
			path : path,
			returnedContentType : 'json'
		};

	return invokeHttpServer(request);
}

/**
 * @function getGroup
 * @description This procedure is a pass trough to the nodeJS endpoint
 * 				GET /api/users/group/{groupId}
 * 
 * @param {String} groupId - the group ID
 * @returns {mfpResponse} - An MFP response wrapping the data received from
 * 							the endpoint
 */
function getGroup(groupId) {
	var path = '/api/users/group/' + groupId, 
		request = {
			method : 'GET',
			path : path,
			returnedContentType : 'json'
		};

	return invokeHttpServer(request);
}

/**
 * @ignore
 * This method processes the JSON response and sets the isSuccessful flag to
 * false if the server responded with code that is not a 200 or 300. By default, the
 * isSuccessful flag is set to false only if the HTTP host is not reachable or
 * invalid HTTP request timed out. Hence, the need for this method. For further details, see:
 * https://www.ibm.com/developerworks/community/blogs/worklight/entry/handling_backend_responses_in_adapters?lang=en
 * 
 * @param response
 */
function handleResponse(response) {
	// Is MFP assumes isSuccessful to be true but the response status code is not a 200 or 300 
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