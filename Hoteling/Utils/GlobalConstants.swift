//
//  GlobalConstants.swift
//  Hoteling
//
//  Created by Andres Padilla on 3/27/18.
//  Copyright © 2018 Growth Acceleration Partners. All rights reserved.
//

import UIKit

struct Constants {
    
    struct ViewIdentifier {
        static let Menu = "MenuViewController"
        static let Home = "HomeViewController"
        static let Location = "LocationViewController"
        static let Settings = "SettingsViewController"
        static let Reservations = "ReservationViewController"
        static let Calendar = "CalendarViewController"
        static let List = "ListViewController"
        static let Map = "MapViewController"
        static let AccordionHeaderViewReuseIdentifier = "AccordionHeaderViewReuseIdentifier"
        static let Manage = "ManageViewController"
        static let EditRoom = "EditRoomViewController"
        static let EditDesk = "EditDeskViewController"
        static let EditAsset = "EditAssetViewController"
        static let Report = "ReservationReportViewController"
    }
    
    struct Key {
        static let UserID = "UserID"
        static let TokenID = "TokenID"
        static let FullName = "FullName"
        static let Email = "Email"
        static let Avatar = "Avatar"
        static let IsAdmin = "IsAdmin"
        static let RemainingReservations = "RemainingReservations"
        static let ReservedDates = "ReservedDates"
        static let PreferedSite = "PreferedSite"
        static let PreferedRoom = "PreferedRoom"
    }
    
    struct Segue {
        static let ShowHomeView = "ShowHomeView"
        static let PickDateSegue = "PickDateSegue"
        static let AddReservation = "AddReservation"
        static let ToHomeViewController = "ToHomeViewController"
        static let ToMenuViewController = "ToMenuViewController"
        static let ToSettingsViewController = "ToSettingsViewController"
        static let ToManageViewController = "ToManageViewController"
    }
    
    struct CellIdentifier {
        static let Menu = "MenuTableViewCell"
        static let Desk = "DeskTableViewCell"
        static let AvailableDesk = "AvailableDeskTableViewCell"
        static let BookedDesk = "BookedDeskTableViewCell"
        static let AdminRoom = "AdminRoomTableViewCell"
        static let AdminDesk = "AdminDeskTableViewCell"
        static let AdminAsset = "AdminAssetTableViewCell"
    }
    
    struct Path {
        static let Documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        static let Tmp = NSTemporaryDirectory()
    }
    
    struct DateFormat {
        static let ShortForUI = "YYYY-MM-dd"
        static let ShortForService = "MM/dd/YYYY"
        static let LongFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.000Z'"
        static let ShortForCalendar = "EE dd, MMM"
        static let DayAndDate = "EEEE dd"
    }
    
    struct Color {
        static let Jade = UIColor.init(red: 6.0/255.0, green: 177.0/255.0, blue: 190.0/255.0, alpha: 1.0)
        static let BadgeRed = UIColor(displayP3Red: 193.0/255.0, green: 0.0, blue: 22.0/255.0, alpha: 1.0)
    }
    
    struct Dimention {
        static let MenuWidth = UInt(200)
    }
    
    struct Images {
        static let DeskIconFree = "deskIconFree"
        static let DeskIconBooked = "deskIconBooked"
        static let GreenPixel = "GreenPixel"
        static let TransparentPixel = "TransparentPixel"
    }
    
}
