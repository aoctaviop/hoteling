//
//  Desk.swift
//  Hoteling
//
//  Created by Andrés Padilla on 4/2/18.
//  Copyright © 2018 Growth Acceleration Partners. All rights reserved.
//

import UIKit

struct DeskKey {
    static let IsBooked = "isBooked"
    static let ReservationUser = "reservationUser"
}

class Desk: Reservation {
    
    var isBooked: Bool
    var reservationUser: String?
    
    override init() {
        isBooked = false
        reservationUser = ""
        super.init()
    }
    
    override init(params: [String: Any]) {
        if let temp = params[DeskKey.IsBooked] {
            isBooked = temp as! Bool
        } else {
            isBooked = true
        }
        reservationUser = params[DeskKey.ReservationUser] as? String
        super.init(params: params)
    }
    
    
    
}
