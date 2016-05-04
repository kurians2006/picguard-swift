//
// Base64ImageEncoderSpec.swift
//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
// Licensed under the MIT License.
//

import Nimble
import Quick
import Picguard

final class APIClientSpec: QuickSpec {

	override func spec() {

		var sut: APIClient!
		var mockSession: MockURLSession!

		beforeEach {
			mockSession = MockURLSession()
			sut = APIClient(APIKey: "fixtureAPIKey", encoder: MockImageEncoder(), session: mockSession)
		}

		afterEach {
			sut = nil
		}

		describe("perform request") {

			var annotationResult: AnnotationResult!

			beforeEach {
				let features = Set([AnnotationRequest.Feature.Label(maxResults: 1)])
				let image = AnnotationRequest.Image.Image(UIImage())
				let request = try! AnnotationRequest.init(features: features, image: image)
				try! sut.perform(request: request) { result in
					annotationResult = result
				}
			}

			describe("created data task") {

				var mockDataTask: MockURLSessionDataTask!

				beforeEach {
					mockDataTask = mockSession.lastCreatedDataTask
				}

				it("should be resumed") {
					expect(mockDataTask.hasBeenResumed).to(beTruthy())
				}
			}

			describe("data task request") {

				var dataTaskRequest: NSURLRequest!

				beforeEach {
					dataTaskRequest = mockSession.dataTaskRequest
				}

				it("should have proper URL") {
					expect(dataTaskRequest.URL).to(equal(NSURL(string: "https://vision.googleapis.com/v1/images:annotate?key=fixtureAPIKey")))
				}

				it("should have POST HTTP method") {
					expect(dataTaskRequest.HTTPMethod).to(equal("POST"))
				}

				it("should have proper HTTP header fields") {
					expect(dataTaskRequest.allHTTPHeaderFields).to(equal(["Content-Type": "application/json"]))
				}
			}

			describe("data task completion") {

				var dataTaskCompletionHandler: ((NSData?, NSURLResponse?, NSError?) -> Void)!

				beforeEach {
					dataTaskCompletionHandler = mockSession.dataTaskCompletionHandler
				}

				context("when response status code is not 200") {

					var response: NSHTTPURLResponse!

					beforeEach {
						response = NSHTTPURLResponse(URL: NSURL(), statusCode: 500, HTTPVersion: nil, headerFields: nil)
						dataTaskCompletionHandler(nil, response, nil)
					}

					it("should return result with error BadResponse") {
						var returnedResponse: NSHTTPURLResponse!
						switch annotationResult! {
						case .Error(let error): let returnedError = error as! APIClientError
							switch returnedError {
							case .BadResponse(let response): returnedResponse = response
							}
						default: break
						}
						expect(returnedResponse).to(equal(response))
					}
				}

				context("when there is an error") {

					var error: NSError!

					beforeEach {
						let response = NSHTTPURLResponse(URL: NSURL(), statusCode: 200, HTTPVersion: nil, headerFields: nil)
						error = NSError(domain: "", code: 1, userInfo: nil)
						dataTaskCompletionHandler(nil, response, error)
					}

					it("should return error result with given error") {
						var returnedError: NSError!
						switch annotationResult! {
						case .Error(let error): returnedError = error as NSError
						default: break
						}
						expect(returnedError).to(equal(error))
					}
				}

				context("when there is no error") {

					var data: NSData!
					var response: NSHTTPURLResponse!

					beforeEach {
						response = NSHTTPURLResponse(URL: NSURL(), statusCode: 200, HTTPVersion: nil, headerFields: nil)
					}

					context("when data cannot be parsed") {

						beforeEach {
							data = NSData()
							dataTaskCompletionHandler(data, response, nil)
						}

						it("should return error result containing thrown error") {
							var returnedError: ErrorType!
							switch annotationResult! {
							case .Error(let error): returnedError = error
							default: break
							}
							expect(returnedError).toNot(beNil())
						}
					}

					context("when data can be parsed") {

						beforeEach {
							let bundle = NSBundle(forClass: AnnotationResponseSpec.self)
							let dataURL = bundle.URLForResource("label_response", withExtension: ".json")
							let data = NSData(contentsOfURL: dataURL!)
							dataTaskCompletionHandler(data, response, nil)
						}

						it("should return success result containing response") {
							var returnedResponse: AnnotationResponse!
							switch annotationResult! {
							case .Success(let response): returnedResponse = response
							default: break
							}
							expect(returnedResponse).toNot(beNil())
						}
					}
				}
			}
		}
	}
}

private final class MockURLSession: NSURLSession {

	var lastCreatedDataTask: MockURLSessionDataTask!
	var dataTaskRequest: NSURLRequest!
	var dataTaskCompletionHandler: ((NSData?, NSURLResponse?, NSError?) -> Void)!

	override func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
			dataTaskRequest = request
			dataTaskCompletionHandler = completionHandler
			lastCreatedDataTask = MockURLSessionDataTask()
			return lastCreatedDataTask
	}
}

private final class MockURLSessionDataTask: NSURLSessionDataTask {

	var hasBeenResumed = false

	override func resume() {
		hasBeenResumed = true
	}
}
