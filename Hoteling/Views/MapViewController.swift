//
//  MapViewController.swift
//  Hoteling
//
//  Created by Andres Padilla on 4/17/18.
//  Copyright © 2018 Growth Acceleration Partners. All rights reserved.
//

import UIKit
import WebKit
import PKHUD
import Crashlytics

class MapViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {
    
    weak var delegate: AvailableDesksDelegate?
    
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        HUD.show(.progress)
        
        let contentController = WKUserContentController();
        contentController.add(
            self,
            name: "Hoteling"
        )
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        webView = WKWebView(frame: CGRect.zero, configuration: config)
        webView!.navigationDelegate = self
        view = webView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let url = Bundle.main.url(forResource: "map_test", withExtension: "html")
        
        //let url = URL(string: "http://migrationsmap.net/")!
        webView.load(URLRequest(url: url!))
        webView.allowsBackForwardNavigationGestures = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        HUD.show(.progress)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        HUD.hide()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        HUD.hide()
    }
    
    // MARK: - WKScriptMessageHandler

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            CLSNSLogv("%@, URL: %@", getVaList([#function, (navigationAction.request.url?.absoluteString)!]))
            showOKAlertController(text: (navigationAction.request.url?.lastPathComponent)!)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        CLSNSLogv("%@, Message: %@", getVaList([#function, message.name]))
    }

}
