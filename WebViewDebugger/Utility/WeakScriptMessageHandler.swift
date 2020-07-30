//
//  WeakScriptMessageHandler.swift
//  WebViewDebugger
//
//  Created by Ashish on 29/07/20.
//  Copyright © 2020 Microsoft Corporation. All rights reserved.
//

import WebKit

// `WKScriptMessageHandler` is strongly retained by `WKUserContentController`
// which in turn is strongly retained by `WKWebView`, which could cause
// retain cycles if the object (generally a view-controller) which holds
// the webview itself is the delegate.
//
// So each `addScriptMessageHandler` call should be complemented by a
// `removeScriptMessageHandler` call.
//
// However note that because of the retain cycle the dealloc/deinit methods
// are not called so calling `removeScriptMessageHandler` there doesn't help either.
//
// The workaround is to pass on WeakScriptMessageHandler(which holds a weak reference to the real message handler)
// to WKUserContentController so there's no retain cycle. Please note that we still need to call
// `removeScriptMessageHandlerForName` in the deinit/dealloc/cleanup methods.
// https://stackoverflow.com/questions/26383031/wkwebview-causes-my-view-controller-to-leak/26383032#26383032
//
@objc public class WeakScriptMessageHandler: NSObject {

    weak var scriptMessageHandler: WKScriptMessageHandler?

    @objc public init(_ scriptMessageHandler: WKScriptMessageHandler) {
        self.scriptMessageHandler = scriptMessageHandler
    }
    
}

extension WeakScriptMessageHandler: WKScriptMessageHandler {

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        scriptMessageHandler?.userContentController(userContentController, didReceive: message)
    }
    
}
