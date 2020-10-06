//
//  ManageViewController.swift
//  Hoteling
//
//  Created by Andres Padilla on 2/7/19.
//  Copyright © 2019 Growth Acceleration Partners. All rights reserved.
//

import UIKit

class ManageTabBarController: UITabBarController {

    private var navigationDelegate: AdminNavControllerProtocol? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func addButtonPressed() {
        let viewController = self.viewControllers?[selectedIndex]
        if (viewController?.responds(to: Selector(("addButtonPressed"))))! {
            viewController?.perform(Selector(("addButtonPressed")))
        }
    }
    
    func setNavigationDelegate(delegate: AdminNavControllerProtocol) {
        navigationDelegate = delegate
        
        for current in viewControllers! {
            if current.isKind(of: AdminBaseTableViewController.classForCoder()) {
                (current as! AdminBaseTableViewController).navigationDelegate = navigationDelegate
            }
        }
    }

}
