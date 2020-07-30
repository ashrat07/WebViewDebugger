//
//  UIColorExtension.swift
//  WebViewDebugger
//
//  Created by Ashish on 30/07/20.
//  Copyright © 2020 Microsoft Corporation. All rights reserved.
//

import UIKit

extension UIColor {
    
    static let lightYellow = UIColor(red: 255 / 255, green: 240 / 255, blue: 189 / 255, alpha: 1)
    
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
}
