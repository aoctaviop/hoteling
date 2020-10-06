//
//  Site.swift
//  Hoteling
//
//  Created by Andrés Padilla on 4/2/18.
//  Copyright © 2018 Growth Acceleration Partners. All rights reserved.
//

import UIKit

struct SiteKey {
    static let Location = "location"
    static let Name = "name"
    static let SiteID = "_id"
}

class Site: Codable {

    var location: String
    var name: String
    var siteID: String
    
    init() {
        location = ""
        name = ""
        siteID = ""
    }
    
    init(location: String, name: String, siteID: String) {
        self.location = location
        self.name = name
        self.siteID = siteID
    }
    
    init(params: [String: Any]) {
        if let temp = params[SiteKey.Location] {
            location = temp as! String
        } else {
            location = ""
        }
        name = params[SiteKey.Name] as! String
        siteID = params[SiteKey.SiteID] as! String
    }
    
}
