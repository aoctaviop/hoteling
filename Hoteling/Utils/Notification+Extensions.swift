//
//  Notification+Extensions.swift
//  Hoteling
//
//  Created by Andrés Padilla on 2/11/19.
//  Copyright © 2019 Growth Acceleration Partners. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let BadgeHasChanged = Notification.Name("BadgeHasChanged")
    static let InternetConnectionUnavailable = Notification.Name("InternetConnectionUnavailable")
    static let InternetConnectionAvailable = Notification.Name("InternetConnectionAvailable")
    static let ReservationsChanged = Notification.Name("ReservationsChanged")
    static let ReservationsCanceled = Notification.Name("ReservationsCanceled")
    static let LogoutWasPerformed = Notification.Name("LogoutWasPerformed")
    static let GoToHome = Notification.Name("GoToHome")
}

