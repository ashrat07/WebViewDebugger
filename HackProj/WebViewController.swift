//
//  WebViewController1.swift
//  HackProj
//
//  Created by Ashish on 29/07/20.
//  Copyright © 2020 Ashish. All rights reserved.
//

import UIKit
import WebKit
import WebViewDebugger

class WebViewController1: UIViewController {
    
    class Constants {
        static let pageURL = "https://www.apple.com/"
    }
    
    private var webView: WKWebView!
    private var webViewDebugger: WebViewDebugger!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView(frame: .zero)
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        webViewDebugger = WebViewDebugger(webView: webView)
        
        loadPage(Constants.pageURL)
        webViewDebugger.showDebugOptions()
        webViewDebugger.startTracking()
    }
    
    func loadPage(_ url: String) {
        guard let url = URL(string: url) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    @objc func action() {
        webViewDebugger.action(in: self)
    }
    
}
