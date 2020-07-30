//
//  ArrayExtension.swift
//  WebViewDebugger
//
//  Created by Ashish on 30/07/20.
//  Copyright © 2020 Microsoft Corporation. All rights reserved.
//

import Foundation

extension Array {
    
    subscript (safe index: Int) -> Element? {
        get {
            return indices ~= index ? self[index] : nil
        }
        set (value) {
            guard let value = value
                else {
                    return
            }
            
            guard !(indices ~= index)
                else {
                    return
            }
            
            self[index] = value
        }
    }
    
}
