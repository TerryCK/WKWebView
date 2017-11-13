//
//  ViewController.swift
//  helloWKWebView
//
//  Created by 陳 冠禎 on 13/11/2017.
//  Copyright © 2017 陳 冠禎. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    //MARK: - create a WebView
    lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = WKUserContentController()
        
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        preferences.minimumFontSize = 30.0
        configuration.preferences = preferences
        
        let myWebView = WKWebView(frame: view.frame, configuration: configuration)
        let url = URL(string: "https://powerwolf543.github.io/TestJSON/rwd.html")
        myWebView.load(URLRequest(url: url!))
        myWebView.navigationDelegate = self
        myWebView.uiDelegate = self
        return myWebView
    }()
    
    
    // MARK: - view is WebView
    override func loadView() {
        super.loadView()
        view = webView
    }
    
    
    
    // MARK: - Intercept Handler
    typealias DecisionHandler = (WKNavigationActionPolicy) -> Void
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        intercept(navigationAction, decisionHandler: decisionHandler)
    }
    
    private func intercept(_ navigationAction: WKNavigationAction, decisionHandler: DecisionHandler) {
        guard let scheme = navigationAction.request.url?.scheme?.toMyScheme else { return }
        switch scheme {
        case .nixonscheme:
            navigationAction.request.url.map(customHandler)
            decisionHandler(.cancel)
        case .other:
            decisionHandler(.allow)
            print("do something for oher scheme")
        }
    }
    
    private func customHandler(with url: URL) {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
        switch urlComponents.myHost {
        
        case .redirect(let url):
            UIApplication.shared.open(url)
            
        case .show:
            urlComponents.queryItems?.show()
            
        default:
            break
        }
    }
}


// MARK: - Showing URLComponents and queryItems
extension URLComponents {
    func show() {
        print("scheme: \(scheme ?? "")")
        print("user: \(user ?? "")")
        print("password: \(password ?? "")")
        print("host: \(host ?? "")")
        print("port: \(String(describing: port))")
        print("path: \(path)")
        print("query: \(query ?? "")")
        
    }
}

extension Collection where Element == URLQueryItem {
    func show() {
        self.enumerated().forEach { (index, queryItem) in
            print("index: \(index), queryItem name: \(queryItem.name), value: \(queryItem.value ?? "")")
        }
    }
}

extension String {
    var toURL: URL? { return URL(string: self)  }
    var toMyScheme: MyScheme { return MyScheme(str: self) }
}


enum Host {
    case redirect(URL), show, other, error(String)
    
    init(_ host: String?, url: URL? = nil) {
        guard let host = host else {
            self = .error("Host init error ")
            return
        }
        
        switch host {
        case "redirect":
            guard let url = url else {
                self = .error("Host init error with url nil")
                return
                
            }
            self = .redirect(url)
            
        case "show" :
            self = .show
            
        default:
            self = .other
        }
    }
}

enum MyScheme {
    case nixonscheme, other
    
    init(str: String?) {
        self = str == "nixonscheme" ? .nixonscheme : .other
    }
}


extension URLComponents {
    var myHost: Host { return Host(host, url: (queryItems?.first?.value?.toURL)!) }
}


