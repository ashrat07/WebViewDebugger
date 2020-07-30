//
//  DateExtension.swift
//  WebViewDebugger
//
//  Created by Ashish on 29/07/20.
//  Copyright © 2020 Microsoft Corporation. All rights reserved.
//

import Foundation

let dateFormatter = DateFormatter()

extension Date {
    func toString() -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: self)
    }
}
