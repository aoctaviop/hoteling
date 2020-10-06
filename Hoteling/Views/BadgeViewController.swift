//
//  BadgeViewController.swift
//  Hoteling
//
//  Created by Andrés Padilla on 5/3/18.
//  Copyright © 2018 Growth Acceleration Partners. All rights reserved.
//

import UIKit
import BadgeSwift
import Crashlytics

class BadgeViewController: BaseViewController {

    let badge = BadgeSwift()
    var badgeCreated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(badgeHasChanged), name: .BadgeHasChanged, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if !self.badgeCreated {
                self.setupBadge()
                self.badgeCreated = true
            }
        }
    }
    
    @objc func badgeHasChanged() {
        badge.text = UserDefaults.standard.string(forKey: Constants.Key.RemainingReservations)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupBadge() {
        badge.frame = CGRect(x: 0.0, y: 0.0, width: 25.0, height: 25.0)
        
        // Text
        badge.text = UserDefaults.standard.string(forKey: Constants.Key.RemainingReservations)
        
        // Insets
        //badge.insets = CGSize(width: 5, height: 5)
        
        // Font
        badge.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        
        // Text color
        badge.textColor = UIColor.white
        
        // Badge color
        badge.badgeColor = Constants.Color.BadgeRed
        
        // No shadow
        badge.shadowOpacityBadge = 0
        
        let bbiBadge = UIBarButtonItem(customView: badge)
        
        self.navigationItem.rightBarButtonItems = ([self.navigationItem.rightBarButtonItem, bbiBadge] as! [UIBarButtonItem])
    }
    
}
