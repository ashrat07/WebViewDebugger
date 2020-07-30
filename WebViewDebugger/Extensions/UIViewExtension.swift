//
//  UIViewExtension.swift
//  WebViewDebugger
//
//  Created by Ashish on 30/07/20.
//  Copyright © 2020 Microsoft Corporation. All rights reserved.
//

import UIKit

extension UIView {
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
}

