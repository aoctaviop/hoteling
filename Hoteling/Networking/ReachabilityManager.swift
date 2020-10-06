//
//  ReachabilityManager.swift
//  Hoteling
//
//  Created by Andrés Padilla on 6/6/18.
//  Copyright © 2018 Growth Acceleration Partners. All rights reserved.
//

import UIKit
import Reachability
import Foundation
import SystemConfiguration
import PKHUD

class ReachabilityManager: NSObject {

    let pingURL = "http://google.com/"
    
    var reachability: Reachability!
    var isConnectedToInternet = true
    var isConnectedToNetwork = true
    weak var timer: Timer?
    
    // Create a singleton instance
    static let sharedInstance: ReachabilityManager = { return ReachabilityManager() }()
    
    override init() {
        super.init()
        
        // Initialise reachability
        reachability = Reachability()!
        
        // Register an observer for the network status
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged(_:)),
            name: .reachabilityChanged,
            object: reachability
        )
        
        do {
            // Start the network status notifier
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
        startTimer()
    }
    
    @objc func networkStatusChanged(_ notification: Notification) {
        print(#function)
        if (ReachabilityManager.sharedInstance.reachability).connection == .none {
            stopTimer()
            isConnectedToNetwork = false
        } else if (ReachabilityManager.sharedInstance.reachability).connection == .wifi || (ReachabilityManager.sharedInstance.reachability).connection == .cellular {
            startTimer()
            isConnectedToNetwork = true
        }
    }
    
    func checkInternetConnection() {
        print(#function)
        let url = NSURL(string: pingURL)
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "HEAD"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10.0
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            if (error != nil) {
                self.isConnectedToInternet = false
                NotificationCenter.default.post(name: .InternetConnectionUnavailable, object: nil)
            } else {
                self.isConnectedToInternet = true
                NotificationCenter.default.post(name: .InternetConnectionAvailable, object: nil)
            }
        })
        
        task.resume()
    }
    
    func checkInternetConnection(availableBlock: @escaping () -> Void, unavailableBlock: @escaping () -> Void) {
        let url = NSURL(string: pingURL)
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "HEAD"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10.0
        
        let session = URLSession.shared
        
        HUD.show(.progress)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            HUD.hide()
            if (error != nil) {
                self.isConnectedToInternet = false
                NotificationCenter.default.post(name: .InternetConnectionUnavailable, object: nil)
                unavailableBlock()
            } else {
                self.isConnectedToInternet = true
                NotificationCenter.default.post(name: .InternetConnectionAvailable, object: nil)
                availableBlock()
            }
        })
        
        task.resume()
    }
    
    static func stopNotifier() -> Void {
        do {
            // Stop the network status notifier
            try (ReachabilityManager.sharedInstance.reachability).startNotifier()
        } catch {
            print("Error stopping notifier")
        }
    }
    
    // Network is reachable
    static func isReachable(completed: @escaping (ReachabilityManager) -> Void) {
        if (ReachabilityManager.sharedInstance.reachability).connection != .none {
            completed(ReachabilityManager.sharedInstance)
        }
    }
    
    // Network is unreachable
    static func isUnreachable(completed: @escaping (ReachabilityManager) -> Void) {
        if (ReachabilityManager.sharedInstance.reachability).connection == .none {
            completed(ReachabilityManager.sharedInstance)
        }
    }
    
    // Network is reachable via WWAN/Cellular
    static func isReachableViaWWAN(completed: @escaping (ReachabilityManager) -> Void) {
        if (ReachabilityManager.sharedInstance.reachability).connection == .cellular {
            completed(ReachabilityManager.sharedInstance)
        }
    }
    
    // Network is reachable via WiFi
    static func isReachableViaWiFi(completed: @escaping (ReachabilityManager) -> Void) {
        if (ReachabilityManager.sharedInstance.reachability).connection == .wifi {
            completed(ReachabilityManager.sharedInstance)
        }
    }

    //MARK: - Internet Connection
    
    func startTimer() {
        print(#function)
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.checkInternetConnection()
        }
    }
    
    func stopTimer() {
        print(#function)
        timer?.invalidate()
    }
}
