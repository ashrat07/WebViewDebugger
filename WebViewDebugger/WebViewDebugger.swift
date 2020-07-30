//
//  WebViewDebugger.swift
//  WebViewDebugger
//
//  Created by Ashish on 29/07/20.
//  Copyright © 2020 Microsoft Corporation. All rights reserved.
//

import UIKit
import WebKit
import MessageUI

public class WebViewDebugger: NSObject {
    
    private class Constants {
        static let webConsoleLogHandlerName = "logHandler"
        static let webNetworkHandlerName = "networkHandler"
        
        static let cookies = "Cookies"
        static let localStorage = "LocalStorage"
        static let sessionStorage = "SessionStorage"
        
        static let html = "html"
        static let network = "network"
        static let sources = "sources"
        static let storage = "storage"
        static let console = "console"
    }
    
    private var webView: WKWebView!
    private var floatingView: FloatingView?
    
    private let dispatchGroup = DispatchGroup()
    private let bundle = Bundle(for: WebViewDebugger.self)
    private var isPaused = false
    
    private var html: String?
    private var networkRequests: [Any]?
    private var sources: [String: Any]?
    private var storage: [(String, Any)]?
    private var consoleLogs: [String]?
    
    var composeAction: ((String) -> Void)?
    
    public init(webView: WKWebView) {
        self.webView = webView
        super.init()
        
        let weakScriptMessageHandler = WeakScriptMessageHandler(self)
        webView.configuration.userContentController.add(weakScriptMessageHandler, name: Constants.webConsoleLogHandlerName)
        webView.configuration.userContentController.add(weakScriptMessageHandler, name: Constants.webNetworkHandlerName)
    }
    
    public func showDebugOptions() {
        floatingView = FloatingView()
        floatingView?.startActionHandler = { [weak self] in
            self?.startTracking()
        }
        floatingView?.pauseActionHandler = { [weak self] in
            self?.pauseTracking()
        }
        floatingView?.stopActionHandler = { [weak self] in
            self?.stopTracking()
        }
        UIApplication.shared.windows.first?.addSubview(floatingView!)
    }
    
    public func hideDebugOptions() {
        floatingView?.removeFromSuperview()
        floatingView = nil
    }
    
    public func startTracking() {
        startRecordingConsoleLogs()
        startRecordingNetworkTraffic()
        isPaused = false
        floatingView?.startAction()
    }
    
    public func pauseTracking() {
        action(in: webView.parentViewController) { [weak self] in
            self?.isPaused = true
        }
    }
    
    public func stopTracking() {
        action(in: webView.parentViewController) { [weak self] in
            guard let self = self else { return }
            
            self.isPaused = false
            self.stopRecordingConsoleLogs()
            self.stopRecordingNetworkTraffic()
            self.webView.configuration.userContentController.removeAllUserScripts()
        }
    }
    
    public func action(in viewController: UIViewController?, completion: (() -> Void)? = nil) {
        getHTML()
        getDataStore()
        getSources()
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.showActionResult(in: viewController)
            completion?()
        }
    }
    
    private func getHTML() {
        dispatchGroup.enter()
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { [weak self, dispatchGroup] html, error in
            dispatchGroup.leave()
            
            self?.html = html as? String
        }
    }
    
    private func getDataStore() {
        self.storage = []
        
        getCookies()
        getLocalStorage()
        getSessionStorage()
    }
    
    private func getCookies() {
        dispatchGroup.enter()
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { [dispatchGroup] cookies in
            dispatchGroup.leave()
            
            let _cookies = cookies.map({ $0.description })
            self.storage?.append((Constants.cookies, _cookies))
        }
    }
    
    private func getLocalStorage() {
        guard let localStorageJSURL = bundle.url(forResource: "localStorage", withExtension: "js"),
            let localStorageJS = try? String(contentsOf: localStorageJSURL) else {
                return
        }
        
        dispatchGroup.enter()
        webView.evaluateJavaScript(localStorageJS) { [dispatchGroup] (result, error) in
            dispatchGroup.leave()
            
            let localStorage = result as? [String: Any] ?? [:]
            self.storage?.append((Constants.localStorage, localStorage))
        }
    }
    
    private func getSessionStorage() {
        guard let sessionStorageJSURL = bundle.url(forResource: "sessionStorage", withExtension: "js"),
            let sessionStorageJS = try? String(contentsOf: sessionStorageJSURL) else {
                return
        }
        dispatchGroup.enter()
        webView.evaluateJavaScript(sessionStorageJS) { [dispatchGroup] (result, error) in
            dispatchGroup.leave()
            
            let sessionStorage = result as? [String: Any] ?? [:]
            self.storage?.append((Constants.sessionStorage, sessionStorage))
        }
    }
    
    private func startRecordingConsoleLogs() {
        if !isPaused {
            consoleLogs = []
        }
        guard let consoleLogJSURL = bundle.url(forResource: "consoleLog", withExtension: "js"),
            let consoleLogJS = try? String(contentsOf: consoleLogJSURL) else {
                return
        }
        let script = WKUserScript(source: consoleLogJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        webView.configuration.userContentController.addUserScript(script)
    }
    
    private func stopRecordingConsoleLogs() {
        consoleLogs = nil
    }
    
    private func startRecordingNetworkTraffic() {
        if !isPaused {
            networkRequests = []
        }
        guard let networkTrafficJSURL = bundle.url(forResource: "networkTraffic", withExtension: "js"),
            let networkTrafficJS = try? String(contentsOf: networkTrafficJSURL) else {
                return
        }
        let script = WKUserScript(source: networkTrafficJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        webView.configuration.userContentController.addUserScript(script)
    }
    
    private func stopRecordingNetworkTraffic() {
        networkRequests = nil
    }
    
    private func getSources() {
        // TODO: get sources
    }
    
    private func showActionResult(in viewController: UIViewController?) {
        let result: [(String, Any)] = [
            (Constants.html, html ?? ""),
            (Constants.network, networkRequests ?? [:]),
            (Constants.storage, storage ?? [:]),
            (Constants.console, consoleLogs ?? []),
            (Constants.sources, sources ?? [:]),
        ]
        let jsonText = getJSONText()
        
        let pageTabViewController = PageTabViewController(result: result)
        let navigationController = UINavigationController(rootViewController: pageTabViewController)
        if let composeAction = composeAction {
            pageTabViewController.composeAction = { [jsonText] in
                composeAction(jsonText)
            }
        }
        else {
            pageTabViewController.composeAction = { [jsonText, weak navigationController, weak self] in
                guard let self = self,
                    let viewController = navigationController else {
                        return
                }
                
                self.defaultComposeAction(text: jsonText, in: viewController)
            }
        }
        viewController?.present(navigationController, animated: true, completion: nil)
    }
    
    private func getJSONText() -> String {
        let result: [String: Any] = [
            Constants.html: html ?? "",
            Constants.network: networkRequests ?? [:],
            Constants.storage: storage?.reduce(into: [:]) { $0[$1.0] = $1.1 } ?? [:],
            Constants.console: consoleLogs ?? [],
            Constants.sources: sources ?? [:],
        ]
        
        guard let data = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted),
            let text = String(data: data, encoding: .utf8) else {
            return "nil"
        }
        
        return text
    }
    
    private func defaultComposeAction(text: String, in viewController: UIViewController) {
        guard MFMailComposeViewController.canSendMail() else { return }
        
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        mailVC.setToRecipients([])
        mailVC.setSubject("Subject for email")
        mailVC.setMessageBody(text, isHTML: false)
        
        viewController.present(mailVC, animated: true, completion: nil)
    }
    
    deinit {
        hideDebugOptions()
        webView.configuration.userContentController.removeScriptMessageHandler(forName: Constants.webConsoleLogHandlerName)
        webView.configuration.userContentController.removeScriptMessageHandler(forName: Constants.webNetworkHandlerName)
    }
    
}

extension WebViewDebugger: WKScriptMessageHandler {
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == Constants.webConsoleLogHandlerName {
            if !isPaused,
                let log = message.body as? String {
                consoleLogs?.append(log)
            }
        }
        else if message.name == Constants.webNetworkHandlerName {
            if !isPaused,
                let dict = message.body as? [String: Any] {
                let networkRequest = NetworkRequest(dict)
                networkRequests?.append(networkRequest.description)
            }
        }
    }
    
}

extension WebViewDebugger: MFMailComposeViewControllerDelegate {
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        webView.parentViewController?.dismiss(animated: true, completion: nil)
    }
}
