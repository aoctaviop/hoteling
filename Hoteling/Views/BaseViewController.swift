//
//  BaseViewController.swift
//  Hoteling
//
//  Created by Andrés Padilla on 6/11/18.
//  Copyright © 2018 Growth Acceleration Partners. All rights reserved.
//

import UIKit
import PKHUD
import SwiftDate

class BaseViewController: UIViewController {

    let network = ReachabilityManager.sharedInstance
    var isConnectedToInternet = true
    var isConnectedToNetwork = true
    var lastConnectionStatus = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        network.checkInternetConnection()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogout), name: .LogoutWasPerformed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleConnectionAvailableStatus), name: .InternetConnectionAvailable, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleConnectionUnavailableStatus), name: .InternetConnectionUnavailable, object: nil)
        
        ReachabilityManager.isUnreachable { (manager) in
            self.isConnectedToNetwork = false
            NotificationCenter.default.post(name: .InternetConnectionUnavailable, object: nil)
        }
        
        network.reachability.whenReachable = { _ in
            self.isConnectedToNetwork = true
            NotificationCenter.default.post(name: .InternetConnectionAvailable, object: nil)
        }
        
        network.reachability.whenUnreachable = { _ in
            self.isConnectedToNetwork = false
            NotificationCenter.default.post(name: .InternetConnectionUnavailable, object: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !internetIsReachable() {
            performConnectionUnavailableActions()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .LogoutWasPerformed, object: nil)
    }
    
    @objc func handleLogout() { }
    
    // MARK: - Internet Connection
    
    func internetIsReachable() -> Bool {
        return isConnectedToNetwork && isConnectedToInternet
    }
    
    @objc func handleConnectionUnavailableStatus() {
        if lastConnectionStatus == true { //Connection was on
            self.isConnectedToInternet = false
            self.isConnectedToNetwork = false
            self.lastConnectionStatus = false
            
            HUD.hide()
            self.performConnectionUnavailableActions()
        }
    }
    
    func performConnectionUnavailableActions() { }
    
    @objc func handleConnectionAvailableStatus() {
        if lastConnectionStatus == false { //Connection was off
            self.isConnectedToInternet = true
            self.isConnectedToNetwork = true
            self.lastConnectionStatus = true
            
            performConnectionAvailableActions()
        }
    }

    func performConnectionAvailableActions() { }
}
