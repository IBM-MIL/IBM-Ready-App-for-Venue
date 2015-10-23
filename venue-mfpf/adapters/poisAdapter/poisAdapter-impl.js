/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
'use strict';

/**
 * @module mfpPoisAdapter
 * @description This adapter provides procedure to interact with the POIs data
 * 				and application setup required for the iOS client.
 */

/**
 * @function getAllPOIs
 * @description This procedure is a pass trough to the nodeJS endpoint
 * 				GET /api/pois
 *
 * @returns {mfpResponse} - An MFP response wrapping the data received from
 * 							the endpoint
 */
function getAllPOIs() {
	var path = '/api/pois', 
		request = {
			method : 'GET',
			path : path,
			returnedContentType : 'json'
		};

	return invokeHttpServer(request);
}

/**
 * @function getAllPOIsForAPark
 * @description This procedure is a pass trough to the nodeJS endpoint
 * 				GET /api/pois
 *
 * @param {String} parkId - the park ID
 * @returns {mfpResponse} - An MFP response wrapping the data received from
 * 							the endpoint
 */
function getAllPOIsForAPark(parkId) {
	var path = '/api/pois/' + parkId, request = {
		method : 'GET',
		path : path,
		returnedContentType : 'json'
	};

	return invokeHttpServer(request);
}

/**
 * @function insertPOI
 * @description This procedure is a pass trough to the nodeJS endpoint
 * 				GET /api/pois
 *
 * @param {Poi} poi - the poi to be saved
 * @returns {mfpResponse} - An MFP response wrapping the data received from
 * 							the endpoint
 */
function insertPOI(poi) {
	var data = {
		poi : poi
	}, path = '/api/pois', request = {
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