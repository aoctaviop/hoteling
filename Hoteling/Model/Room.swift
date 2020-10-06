//
//  Room.swift
//  Hoteling
//
//  Created by Andrés Padilla on 2/11/19.
//  Copyright © 2019 Growth Acceleration Partners. All rights reserved.
//

import UIKit

struct RoomKey {
    static let Site = "site"
}

class Room: NSObject {
    
    var location: String
    var name: String
    var roomID: String
    
    var site: Site
    
    override init() {
        site = Site()
        location = ""
        name = ""
        roomID = ""
        super.init()
    }
    
    init(location: String, name: String, roomID: String, site: [String: Any]) {
        self.location = location
        self.name = name
        self.roomID = roomID
        self.site = Site(params: site)
        super.init()
    }
    
    init(params: [String: Any], fullObject: Bool) {
        if let temp = params[SiteKey.Location] {
            location = temp as! String
        } else {
            location = ""
        }
        name = params[SiteKey.Name] as! String
        roomID = params[SiteKey.SiteID] as! String
        
        print(params)
        
        if fullObject {
            self.site = Site(params: params[RoomKey.Site] as! [String : Any])
        } else {
            self.site = Site(location: "", name: "", siteID: params[RoomKey.Site] as! String)
        }
        
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
}
