//
//  MockNetworkJSONResource.swift
//  LoadIt
//
//  Created by Luciano Marisi on 20/07/2016.
//  Copyright © 2016 Luciano Marisi. All rights reserved.
//

import Foundation
@testable import LoadIt

struct MockNetworkJSONResource: NetworkJSONResourceType {
  typealias Model = String
  
  let url: URL
  let HTTPRequestMethod: HTTPMethod
  let HTTPHeaderFields: [String: String]?
  let JSONBody: AnyObject?
  let queryItems: [URLQueryItem]?
  
  init(url: URL, HTTPRequestMethod: HTTPMethod = .GET, HTTPHeaderFields: [String : String]? = nil, JSONBody: AnyObject? = nil, queryItems: [URLQueryItem]? = nil) {
    self.url = url
    self.HTTPRequestMethod = HTTPRequestMethod
    self.HTTPHeaderFields = HTTPHeaderFields
    self.JSONBody = JSONBody
    self.queryItems = queryItems
  }
  
}
