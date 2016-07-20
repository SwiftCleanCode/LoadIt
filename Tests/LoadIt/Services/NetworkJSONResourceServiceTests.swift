//
//  NetworkJSONResourceServiceTests.swift
//  LoadIt
//
//  Created by Luciano Marisi on 20/07/2016.
//  Copyright © 2016 Luciano Marisi. All rights reserved.
//

import XCTest
@testable import LoadIt

private let testURL = URL(string: "http://test.com")!

class NetworkJSONResourceServiceTests: XCTestCase {
  
  var testService: NetworkJSONResourceService<MockDefaultNetworkJSONResource>!
  var mockSession: MockURLSession!
  var mockResource: MockDefaultNetworkJSONResource!
  
  let testRequest = URLRequest(url: testURL)
  
  override func setUp() {
    super.setUp()
    mockSession = MockURLSession()
    testService = NetworkJSONResourceService<MockDefaultNetworkJSONResource>(session: mockSession)
    mockResource = MockDefaultNetworkJSONResource(url: testURL)
  }
  
  override func tearDown() {
    testService = nil
    mockSession = nil
    mockResource = nil
    super.tearDown()
  }
  
  func test_fetch_callsPerformRequestOnSessionWithCorrectURLRequest() {
    testService.fetch(resource: mockResource) { _ in }
    let capturedRequest = mockSession.capturedRequest
    let expectedRequest = mockResource.urlRequest()
    XCTAssertEqual(capturedRequest, expectedRequest)
  }
  
  func test_fetch_withInvalidURLRequest_callsFailureWithCorrectError() {
    let mockInvalidURLResource = MockNilURLRequestNetworkJSONResource()
    let newTestRequestManager = NetworkJSONResourceService<MockNilURLRequestNetworkJSONResource>(session: mockSession)
    XCTAssertNil(mockInvalidURLResource.urlRequest())
    performAsyncTest() { expectation in
      newTestRequestManager.fetch(resource: mockInvalidURLResource) { result in
        expectation.fulfill()
        guard let error = result.error() else {
          XCTFail("No error found")
          return
        }
        if case NetworkServiceError.couldNotCreateURLRequest = error { return }
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func test_fetch_whenSessionCompletesWithFailureStatusCode_callsFailureWithCorrectError() {
    let handledStatusCodes = [400, 499, 500, 599]
    handledStatusCodes.forEach {
      assert_fetch_whenSessionCompletesWithHandledStatusCode_callsFailureWithCorrectError(expectedStatusCode: $0)
    }
  }
  
  private func assert_fetch_whenSessionCompletesWithHandledStatusCode_callsFailureWithCorrectError(expectedStatusCode: Int, file: StaticString = #file, lineNumber: UInt = #line) {
    let expectedError = NSError(domain: "test", code: 999, userInfo: nil)
    let mockHTTPURLResponse = HTTPURLResponse(url: URL(string: "www.test.com")!, statusCode: expectedStatusCode, httpVersion: nil, headerFields: nil)
    performAsyncTest(file: file, lineNumber: lineNumber) { expectation in
      testService.fetch(resource: mockResource) { result in
        expectation.fulfill()
        guard let error = result.error() else {
          XCTFail("No error found")
          return
        }
        
        guard case NetworkServiceError.statusCodeError(let statusCode) = error else {
          XCTFail()
          return
        }
        XCTAssert(statusCode == expectedStatusCode)
      }
      mockSession.capturedCompletion!(nil, mockHTTPURLResponse, expectedError)
    }
  }
  
  func test_fetch_whenSessionCompletesWithUnhandledStatusCode_callsFailureWithCorrectError() {
    let unhandledStatusCodes = [300, 399, 600, 601]
    unhandledStatusCodes.forEach {
      assert_fetch_whenSessionCompletesWithUnhandledStatusCode_callsFailureWithCorrectError(expectedStatusCode: $0)
    }
  }
  
  private func assert_fetch_whenSessionCompletesWithUnhandledStatusCode_callsFailureWithCorrectError(expectedStatusCode: Int, file: StaticString = #file, lineNumber: UInt = #line) {
    let expectedError = NSError(domain: "test", code: 999, userInfo: nil)
    let mockHTTPURLResponse = HTTPURLResponse(url: URL(string: "www.test.com")!, statusCode: expectedStatusCode, httpVersion: nil, headerFields: nil)
    performAsyncTest(file: file, lineNumber: lineNumber) { expectation in
      testService.fetch(resource: mockResource) { result in
        expectation.fulfill()
        guard let error = result.error() else {
          XCTFail("No error found")
          return
        }
        
        guard case NetworkServiceError.networkingError(let testError) = error else {
          XCTFail()
          return
        }
        XCTAssert(testError.domain == expectedError.domain)
      }
      mockSession.capturedCompletion!(nil, mockHTTPURLResponse, expectedError)
    }
  }
  
  func test_fetch_whenSessionCompletesWithNetworkingError_callsFailureWithCorrectError() {
    let expectedError = NSError(domain: "test", code: 999, userInfo: nil)
    
    performAsyncTest() { expectation in
      testService.fetch(resource: mockResource) { result in
        expectation.fulfill()
        guard let error = result.error() else {
          XCTFail("No error found")
          return
        }
        
        guard case NetworkServiceError.networkingError(let testError) = error else {
          XCTFail()
          return
        }
        XCTAssert(testError.domain == expectedError.domain)
      }
      mockSession.capturedCompletion!(nil, nil, expectedError)
    }
  }
  
  func test_fetch_whenSessionCompletes_WithNoData_callsFailureWithCorrectError() {
    performAsyncTest() { expectation in
      testService.fetch(resource: mockResource)  { result in
        expectation.fulfill()
        guard let error = result.error() else {
          XCTFail("No error found")
          return
        }
        if case NetworkServiceError.noData = error { return }
        XCTFail()
      }
      mockSession.capturedCompletion!(nil, nil, nil)
    }
  }
  
  func test_fetch_WhenSessionCompletes_WithInvalidJSON_callsFailureWithCorrectError() {
    performAsyncTest() { expectation in
      testService.fetch(resource: mockResource) { result in
        expectation.fulfill()
        guard let error = result.error() else {
          XCTFail("No error found")
          return
        }
        if case JSONParsingError.invalidJSONData = error { return }
        XCTFail()
      }
      mockSession.capturedCompletion!(Data(), nil, nil)
    }
  }
  
}
