//
//  Utils.swift
//  Hoteling
//
//  Created by Andres Padilla on 2/7/19.
//  Copyright © 2019 Growth Acceleration Partners. All rights reserved.
//

import UIKit

class Utils: NSObject {
    
    static let sharedInstance = Utils()
    
    //This prevents others from using the default '()' initializer for this class.
    private override init() {}
    
    func isAdmin() -> Bool {
        return UserDefaults.standard.bool(forKey: Constants.Key.IsAdmin)
    }
    
    func getStyoryboard(id: String) -> UIStoryboard {
        return UIStoryboard.init(name: id, bundle: nil)
    }
    
    func getView(id: String) -> UIViewController {
        return getStyoryboard(id: "Main").instantiateViewController(withIdentifier: id)
    }

}
