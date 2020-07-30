//
//  NetworkRequest.swift
//  WebViewDebugger
//
//  Created by Ashish on 30/07/20.
//  Copyright © 2020 Microsoft Corporation. All rights reserved.
//

import UIKit

struct NetworkRequest {
    
    private class Constants {
        static let status = "status"
        static let responseURL = "responseURL"
        static let response = "response"
    }
    
    let status: Int?
    let responseURL: String?
    let response: Any?
    
    init(_ dict: [String: Any]) {
        status = dict[Constants.status] as? Int
        responseURL = dict[Constants.responseURL] as? String
        response = dict[Constants.response]
    }
    
}

extension NetworkRequest: CustomStringConvertible {
    
    var description: String {
        return """
        Status      : \(status?.description ?? "-")
        responseURL : \(responseURL ?? "-")
        response    : \(response ?? "-")
        """
    }
    
}
