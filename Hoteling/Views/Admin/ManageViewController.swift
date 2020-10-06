//
//  ManageViewController.swift
//  Hoteling
//
//  Created by Andres Padilla on 2/7/19.
//  Copyright © 2019 Growth Acceleration Partners. All rights reserved.
//

import UIKit

class ManageViewController: UIViewController, AdminNavControllerProtocol {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for current in self.children {
            if current.isKind(of: ManageTabBarController.classForCoder()) {
                (current as! ManageTabBarController).setNavigationDelegate(delegate: self)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        for current in self.children {
            if current.isKind(of: ManageTabBarController.classForCoder()) {
                (current as! ManageTabBarController).addButtonPressed()
            }
        }
    }
    
    //MARK: - AdminNavControllerProtocdol
    
    func push(v: UIViewController) {
        self.navigationController?.pushViewController(v, animated: true)
    }
    
    func pop() {
        self.navigationController?.popViewController(animated: true)
    }
    
}
