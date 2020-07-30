//
//  CookieExtension.swift
//  WebViewDebugger
//
//  Created by Ashish on 30/07/20.
//  Copyright © 2020 Microsoft Corporation. All rights reserved.
//

import Foundation

extension HTTPCookie {
    open override var description: String {
        return """
        Name    : \(name)
        Value   : \(value)
        domain  : \(domain)
        path    : \(path)
        expires : \(expiresDate?.toString() ?? "nil")
        Secure  : \(isSecure)
        HTTPOnly: \(isHTTPOnly)
        SameSite: \(sameSitePolicy == nil ? "none" : "lax")
        """
    }
}
