//
//  DateExtension.swift
//  HackProj
//
//  Created by Ashish on 28/07/20.
//  Copyright © 2020 Ashish. All rights reserved.
//

import Foundation

let dateFormatter = DateFormatter()

extension Date {
    func toString() -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: self)
    }
}
