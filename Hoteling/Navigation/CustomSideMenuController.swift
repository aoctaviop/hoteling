//
//  CustomSideMenuController.swift
//  Hoteling
//
//  Created by Andrés Padilla on 5/8/18.
//  Copyright © 2018 Growth Acceleration Partners. All rights reserved.
//

import UIKit
import SideMenuController

class CustomSideMenuController: SideMenuController {

    override func viewDidLoad() {
        super.viewDidLoad()

        performSegue(withIdentifier: Constants.Segue.ToMenuViewController, sender: nil)
        let home = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.ViewIdentifier.Home)
        sideMenuController?.embed(centerViewController: home, cacheIdentifier: Constants.ViewIdentifier.Home)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
