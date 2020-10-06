//
//  Asset.swift
//  Hoteling
//
//  Created by Andrés Padilla on 2/11/19.
//  Copyright © 2019 Growth Acceleration Partners. All rights reserved.
//

import UIKit

struct AssetKey {
    static let AssetID = "_id"
    static let GAPID = "assetId"
    static let Type_ = "type"
    static let Brand = "brand"
    static let Serial = "serial"
    static let Accesories = "accessories"
    static let CreatedAt = "createdAt"
    static let DeskID = "id"
    static let DeskName = "name"
    static let RoomID = "id"
    static let RoomName = "name"
    static let SiteID = "id"
    static let SiteName = "name"
    static let RoomMap = "roomMap"
}

class Asset: NSObject {
    
    var assetID: String?
    var GAPID: String?
    var type: String?
    var brand: String?
    var serial: String?
    var accesories: String?
    var createdAt: String?
    var deskID: String
    var deskName: String
    var roomID: String
    var roomName: String
    var siteID: String
    var siteName: String
    var roomMap: String?
    
    override init() {
        assetID = ""
        GAPID = ""
        type = ""
        brand = ""
        serial = ""
        accesories = ""
        createdAt = ""
        deskID = ""
        deskName = ""
        roomID = ""
        roomName = ""
        siteID = ""
        siteName = ""
        roomMap = ""
        super.init()
    }
    
    init(params: [String: Any]) {
        type = params[AssetKey.Type_] as? String
        GAPID = params[AssetKey.GAPID] as? String
        brand = params[AssetKey.Brand] as? String
        serial = params[AssetKey.Serial] as? String
        accesories = params[AssetKey.Accesories] as? String
        
        createdAt = params[AssetKey.CreatedAt] as? String
        assetID = params[AssetKey.AssetID] as? String
        
        if let location = params["location"] {
            let dict = location as! [String: Any]
            
            if let temp: [String: String] = dict["site"] as? [String : String] {
                siteID = temp[AssetKey.SiteID]!
                siteName = temp[AssetKey.SiteName]!
            } else {
                siteID = ""
                siteName = ""
            }
            
            if let temp: [String: String] = dict["room"] as? [String : String] {
                roomID = temp[AssetKey.RoomID]!
                roomName = temp[AssetKey.RoomName]!
            } else {
                roomID = ""
                roomName = ""
            }
            
            if let temp: [String: String] = dict["desk"] as? [String : String] {
                deskID = temp[AssetKey.DeskID]!
                deskName = temp[AssetKey.DeskName]!
            } else {
                deskID = ""
                deskName = ""
            }
        } else {
            siteID = ""
            siteName = ""
            
            roomID = ""
            roomName = ""
            
            deskID = ""
            deskName = ""
        }
    }
    
}
