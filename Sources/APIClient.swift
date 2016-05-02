//
// Picguard.swift
//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
// Licensed under the MIT License.
//

import Foundation

public protocol APIClientType {

	func perform(request request: AnnotationRequest, completion: AnnotationResult -> Void) throws
}

public final class APIClient: APIClientType {

	public enum Error: ErrorType {
		case InvalidRequestParameters
		case BadServerResponse
	}

	let key: String
	let encoder: ImageEncoding
	let session: NSURLSession

	public init(key: String,
	            encoder: ImageEncoding,
	            session: NSURLSession = NSURLSession(configuration:
		NSURLSessionConfiguration.defaultSessionConfiguration())) {
		self.key = key
		self.encoder = encoder
		self.session = session
	}

	public func perform(request request: AnnotationRequest,
	                            completion: AnnotationResult -> Void) throws {

		let URLRequest = try composeURLRequest(request)
		session.dataTaskWithRequest(URLRequest) { (data, URLResponse, error) in
			guard
			let HTTPURLResponse = URLResponse as? NSHTTPURLResponse
			where HTTPURLResponse.statusCode == 200 else {
				completion(AnnotationResult.Error(Error.BadServerResponse))
				return
			}
			if let error = error {
				completion(AnnotationResult.Error(error))
			} else if let data = data {
				completion(AnnotationResult.Success(AnnotationResponse(data: data)))
			}
		}.resume()
	}
}

// MARK: - Private methods

private extension APIClient {

	func composeURLRequest(annotationRequest: AnnotationRequest) throws -> NSURLRequest {
		let requestJSONDictionary = try annotationRequest.JSONDictionaryRepresentation(encoder)
		let requestsJSONDictioanry = ["requests": [requestJSONDictionary]]
		let requestsJSONData = try NSJSONSerialization.dataWithJSONObject(requestsJSONDictioanry,
		                                                        options: [])
		let components = NSURLComponents()
		components.scheme = "https"
		components.host = "vision.googleapis.com"
		components.path = "/v1/images:annotate"
		components.queryItems = [NSURLQueryItem(name: "key", value: key)]
		guard let URL = components.URL else {
			throw Error.InvalidRequestParameters
		}
		let mutableRequest = NSMutableURLRequest(URL: URL)
		mutableRequest.HTTPMethod = "POST"
		mutableRequest.HTTPBody = requestsJSONData
		mutableRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
		guard let request = mutableRequest.copy() as? NSURLRequest else {
			throw Error.InvalidRequestParameters
		}
		return request
	}
}
