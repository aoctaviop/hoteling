//
//  Reservation.swift
//  Hoteling
//
//  Created by Andrés Padilla on 3/28/18.
//  Copyright © 2018 Growth Acceleration Partners. All rights reserved.
//

import UIKit

struct ReservationKey {
    static let ReservationID = "reservationId"
    static let ReservationDate = "reservationDate"
    static let DeskID = "deskId"
    static let DeskName = "deskName"
    static let RoomID = "roomId"
    static let RoomName = "roomName"
    static let SiteID = "siteId"
    static let SiteName = "siteName"
    static let RoomMap = "roomMap"
}

class Reservation: NSObject {
    
    var reservationID: String?
    var reservationDate: String?
    var deskID: String
    var deskName: String
    var roomID: String
    var roomName: String
    var siteID: String
    var siteName: String
    var roomMap: String?

    override init() {
        reservationID = ""
        reservationDate = ""
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
        reservationID = params[ReservationKey.ReservationID] as? String
        reservationDate = params[ReservationKey.ReservationDate] as? String
        deskID = params[ReservationKey.DeskID] as! String
        deskName = params[ReservationKey.DeskName] as! String
        roomID = params[ReservationKey.RoomID] as! String
        if let temp = params[ReservationKey.RoomName] {
            roomName = temp as! String
        } else if let temp = params["room"] {
            roomName = temp as! String
        } else {
            roomName = ""
        }
        siteID = params[ReservationKey.SiteID] as! String
        if let temp = params[ReservationKey.SiteName] {
            siteName = temp as! String
        } else if let temp = params["site"] {
            siteName = temp as! String
        } else {
            siteName = ""
        }
        if (params[ReservationKey.RoomMap] != nil) {
            roomMap = params[ReservationKey.RoomMap] as? String
        }
    }
    
}
