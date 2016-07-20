//
//  ResourceOperationTests.swift
//  LoadIt
//
//  Created by Luciano Marisi on 20/07/2016.
//  Copyright © 2016 Luciano Marisi. All rights reserved.
//

import XCTest
@testable import LoadIt

class ResourceOperationTests: XCTestCase {
  
  var mockResource: MockResource!
  
  override func setUp() {
    super.setUp()
    mockResource = MockResource()
  }
  
  func test_didFinishFetchingResource_calledWithCorrectResult() {
    let expectation = self.expectation(withDescription: "didFinishFetchingResourceCallback expectation")
    let didFinishFetchingResourceCallback: (ResourceOperation<MockResourceService>, Result<String>) -> Void = { (operation, result) in
      XCTAssertEqual(result.successResult(), "success")
      expectation.fulfill()
    }
    let resourceOperation = ResourceOperation<MockResourceService>(resource: mockResource, didFinishFetchingResourceCallback: didFinishFetchingResourceCallback)
    resourceOperation.didFinishFetchingResource(result: .success("success"))
    waitForExpectations(withTimeout: 1, handler: nil)
  }
  
}
