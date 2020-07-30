//
//  ViewController.swift
//  HackProj
//
//  Created by Ashish on 27/07/20.
//  Copyright © 2020 Ashish. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var button: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        button = UIButton(type: .system)
        button.setTitle("Push", for: .normal)
        button.addTarget(self, action: #selector(showWebView), for: .touchUpInside)
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    @objc func showWebView() {
        let viewController = WebViewController1()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}
