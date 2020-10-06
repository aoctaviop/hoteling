//
//  NetworkingManager.swift
//  Hoteling
//
//  Created by Andrés Padilla on 3/28/18.
//  Copyright © 2018 Growth Acceleration Partners. All rights reserved.
//

import UIKit
import Alamofire
import Crashlytics

struct API {
    struct URL {
        static let Base = "https://dev-hoteling.wearegap.com/api/"
        static let TokenValidation = "auth/isValidToken"
        static let Booking = "booking"
        static let Maps = "uploads/"
        static let Sites = "sites"
        static let Rooms = "rooms"
        static let Desks = "desks"
        static let Desk = "booking/desk"
        static let Logout = "auth/logout"
        static let Reservations = "reports/getReservationsByDate?from=%@&to=%@&site=%@&room=%@"
        static let AllDesks = "desks"
        static let Assets = "assets"
        static let AddRooms = "rooms/add"
        static let AddDesks = "desks/add"
    }
    struct Key {
        static let APIKey = "X-API-KEY"
        static let ContentType = "ContentType"
        static let SiteID = "siteId"
        static let RoomID = "roomId"
        static let Date = "date"
        static let DeskID = "deskId"
        static let Repeat = "repeat"
        static let Sites = "sites"
        static let Rooms = "rooms"
        static let Desks = "desks"
        static let Message = "message"
        static let Token = "token"
        static let Reservation = "reservation"
        static let Assets = "assets"
        static let Name = "name"
    }
}

class NetworkingManager: NSObject {
    
    static let sharedInstance = NetworkingManager()
    
    //This prevents others from using the default '()' initializer for this class.
    private override init() {}
    
    private func urlForEndpoint(endpoint: String) -> String {
        return API.URL.Base + endpoint
    }
    
    //MARK: - Base
    
    private func baseGETRequest(url: String, params: [String: Any], success: @escaping ([String: AnyObject]) -> Void, failure: @escaping (Error) -> Void) {
        let headers: HTTPHeaders = [
            API.Key.APIKey: UserDefaults.standard.string(forKey: Constants.Key.TokenID)!,
            API.Key.ContentType: "application/json"
        ]
        
        Alamofire.request(url, method: HTTPMethod.get, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success:
                success(response.result.value as! [String : AnyObject])
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    ReachabilityManager.sharedInstance.checkInternetConnection()
                }
                failure(error)
            }
        }
    }
    
    private func basePOSTRequest(url: String, params: [String: Any], success: @escaping ([String: AnyObject]) -> Void, failure: @escaping (Error) -> Void) {
        let headers: HTTPHeaders = [
            API.Key.APIKey: UserDefaults.standard.string(forKey: Constants.Key.TokenID)!,
            API.Key.ContentType: "application/json"
        ]
        
        Alamofire.request(url, method: HTTPMethod.post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success:
                success(response.result.value as! [String : AnyObject])
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    ReachabilityManager.sharedInstance.checkInternetConnection()
                }
                failure(error)
            }
        }
    }
    
    private func baseDELETERequest(url: String, params: [String: Any], success: @escaping ([String: AnyObject]) -> Void, failure: @escaping (Error) -> Void) {
        let headers: HTTPHeaders = [
            API.Key.APIKey: UserDefaults.standard.string(forKey: Constants.Key.TokenID)!,
            API.Key.ContentType: "application/json"
        ]
        
        Alamofire.request(url, method: HTTPMethod.delete, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success:
                success(response.result.value as! [String : AnyObject])
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    ReachabilityManager.sharedInstance.checkInternetConnection()
                }
                failure(error)
            }
        }
    }
    
    private func basePUTRequest(url: String, params: [String: Any], success: @escaping ([String: AnyObject]) -> Void, failure: @escaping (Error) -> Void) {
        let headers: HTTPHeaders = [
            API.Key.APIKey: UserDefaults.standard.string(forKey: Constants.Key.TokenID)!,
            API.Key.ContentType: "application/json"
        ]
        
        Alamofire.request(url, method: HTTPMethod.put, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success:
                success(response.result.value as! [String : AnyObject])
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    ReachabilityManager.sharedInstance.checkInternetConnection()
                }
                failure(error)
            }
        }
    }
    
    private func basePOSTRequestWithoutAPIKey(token: String, url: String, params: [String: Any], success: @escaping ([String: AnyObject]) -> Void, failure: @escaping (Error) -> Void) {
        let headers: HTTPHeaders = [
            API.Key.APIKey: token,
            API.Key.ContentType: "application/json"
        ]
        
        Alamofire.request(url, method: HTTPMethod.post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success:
                success(response.result.value as! [String : AnyObject])
            case .failure(let error):
                failure(error)
            }
        }
    }
    
    //MARK: - Methods
    
    func validateToken(token: String, success: @escaping ([String: Any]) -> Void, failure: @escaping (Error) -> Void) {
        
        basePOSTRequestWithoutAPIKey(token: token, url: urlForEndpoint(endpoint: API.URL.TokenValidation), params: ["token": token], success: { (response) in
            print(response)
            success(response)
        }) { (error) in
            print(error)
            failure(error)
        }
    }
    
    func getReservations(success: @escaping ([Any]) -> Void, failure: @escaping (Error) -> Void) {
        baseGETRequest(url: urlForEndpoint(endpoint: API.URL.Booking), params: [:], success: { response in
            if let reservations = response[API.Key.Desks] {
                CLSNSLogv("%@, Reservations: %@", getVaList([#function, reservations as! [Any]]))
                success(reservations as! [Any])
            } else {
                success([])
            }
        }) { error in
            CLSNSLogv("%@, Error: %@", getVaList([#function, error.localizedDescription]))
            failure(error)
        }
    }
    
    func deleteReservation(reservation: Reservation, success: @escaping (String) -> Void, failure: @escaping (Error) -> Void) {
        let params: [String: Any] = [ReservationKey.DeskID: reservation.deskID, ReservationKey.ReservationID: reservation.reservationID!]
        
        baseDELETERequest(url: urlForEndpoint(endpoint: API.URL.Booking), params: [API.Key.Reservation: params], success: { response in
            let message: String = response[API.Key.Message] as! String
            CLSNSLogv("%@, Message: %@", getVaList([#function, message]))
            success(message)
        }) { error in
            CLSNSLogv("%@, Error: %@", getVaList([#function, error.localizedDescription]))
            failure(error)
        }
    }
    
    func deleteAllReservations(reservations: [Reservation], success: @escaping (String) -> Void, failure: @escaping (Error) -> Void) {
        var resParams: [Any] = []
        
        for current in reservations {
            resParams.append([ReservationKey.DeskID: current.deskID, ReservationKey.ReservationID: current.reservationID!])
        }
        
        let params: [String: Any] = [API.Key.Reservation: resParams]
        
        baseDELETERequest(url: urlForEndpoint(endpoint: API.URL.Booking), params: params, success: { response in
            if let message = response[API.Key.Message] {
                CLSNSLogv("%@, Message: %@", getVaList([#function, message as! CVarArg]))
                success(message as! String)
            } else {
                success("")
            }
        }) { error in
            CLSNSLogv("%@, Error: %@", getVaList([#function, error.localizedDescription]))
            failure(error)
        }
    }
    
    func getSites(success: @escaping ([Any]) -> Void, failure: @escaping (Error) -> Void) {
        baseGETRequest(url: urlForEndpoint(endpoint: API.URL.Sites), params: [:], success: { response in
            let sites: [Any] = response[API.Key.Sites] as! [Any]
            CLSNSLogv("%@, Sites: %@", getVaList([#function, sites]))
            success(sites)
        }) { error in
            CLSNSLogv("%@, Error: %@", getVaList([#function, error.localizedDescription]))
            failure(error)
        }
    }
    
    func getRoomsForSite(siteID: String, success: @escaping ([Any]) -> Void, failure: @escaping (Error) -> Void) {
        let url = urlForEndpoint(endpoint: API.URL.Sites) + "/" + siteID + "/" + API.URL.Rooms;
        baseGETRequest(url: url, params: [:], success: { response in
            let rooms: [Any] = response[API.Key.Rooms] as! [Any]
            CLSNSLogv("%@, Rooms: %@", getVaList([#function, rooms]))
            success(rooms)
        }) { error in
            CLSNSLogv("%@, Error: %@", getVaList([#function, error.localizedDescription]))
            failure(error)
        }
    }
    
    func getDesks(siteID: String, roomID: String, date: String, success: @escaping ([Any]) -> Void, failure: @escaping (Error) -> Void) {
        let params = [API.Key.SiteID: siteID,
                      API.Key.RoomID: roomID,
                      API.Key.Date: date]
        
        self.baseGETRequest(url: urlForEndpoint(endpoint: API.URL.Desks), params: params, success: { (response) in
            if let desks = response[API.Key.Desks] {
                CLSNSLogv("%@, Desks: %@", getVaList([#function, desks as! [Any]]))
                success(desks as! [Any])
            } else {
                success([])
            }
        }) { (error) in
            CLSNSLogv("%@, Error: %@", getVaList([#function, error.localizedDescription]))
            failure(error)
        }
    }
    
    func getDeskAvailability(desk: Desk, date: String, shouldRepeat: Bool, success: @escaping ([Any]) -> Void, failure: @escaping (Error) -> Void) {
        let params: [String: Any] = [API.Key.DeskID: desk.deskID,
                                     API.Key.Date: date,
                                     API.Key.Repeat: shouldRepeat ? "1" : "0"]
        
        self.basePOSTRequest(url: urlForEndpoint(endpoint: API.URL.Desk), params: params, success: { response in
            let dates = response["dates"]!["available"] as! [Any]
            CLSNSLogv("%@, Dates: %@", getVaList([#function, dates]))
            success(dates)
        }) { error in
            CLSNSLogv("%@, Error: %@", getVaList([#function, error.localizedDescription]))
            failure(error)
        }
    }
    
    func reserveDesk(desk: Desk, date: String, shouldRepeat: Bool, success: @escaping (String) -> Void, failure: @escaping (Error) -> Void) {
        let params: [String: Any] = [API.Key.DeskID: desk.deskID,
                      API.Key.Date: date,
                      API.Key.Repeat: shouldRepeat ? "1" : "0"]
        
        self.basePOSTRequest(url: urlForEndpoint(endpoint: API.URL.Booking), params: params, success: { response in
            let message: String = response[API.Key.Message] as! String
            CLSNSLogv("%@, Message: %@", getVaList([#function, message]))
            success(message)
        }) { error in
            CLSNSLogv("%@, Error: %@", getVaList([#function, error.localizedDescription]))
            failure(error)
        }
    }
    
    func logout(success: @escaping (String) -> Void, failure: @escaping (Error) -> Void) {
        let params: [String: String] = [API.Key.Token: UserDefaults.standard.string(forKey: Constants.Key.TokenID)!]
        self.basePOSTRequest(url: urlForEndpoint(endpoint: API.URL.Logout), params: params, success: { (response) in
            if let message = response[API.Key.Message] {
                CLSNSLogv("%@, Message: %@", getVaList([#function, message as! CVarArg]))
                success(message as! String)
            } else {
                success("")
            }
        }) { (error) in
            CLSNSLogv("%@, Error: %@", getVaList([#function, error.localizedDescription]))
            failure(error)
        }
    }

    func getReservations(fromDate: String, toDate: String, siteID: String, roomID: String, success: @escaping ([[String: String]]) -> Void, failure: @escaping (Error) -> Void) {
        let endpoint = String(format: API.URL.Reservations, fromDate, toDate, siteID, roomID)
        
        self.baseGETRequest(url: urlForEndpoint(endpoint: endpoint), params: [:], success: { (response) in
            let desks: [Any] = response[API.Key.Desks] as! [Any]
            CLSNSLogv("%@, Desks: %@", getVaList([#function, desks]))
            success(desks as! [[String : String]])
        }) { (error) in
            CLSNSLogv("%@, Error: %@", getVaList([#function, error.localizedDescription]))
            failure(error)
        }
    }
    
    func getAllRooms(success: @escaping ([Any]) -> Void, failure: @escaping (Error) -> Void) {
        let url = urlForEndpoint(endpoint: API.URL.Rooms);
        baseGETRequest(url: url, params: [:], success: { response in
            let rooms: [Any] = response[API.Key.Rooms] as! [Any]
            CLSNSLogv("%@, Rooms: %@", getVaList([#function, rooms]))
            success(rooms)
        }) { error in
            CLSNSLogv("%@, Error: %@", getVaList([#function, error.localizedDescription]))
            failure(error)
        }
    }
    
    func getAllDesks(success: @escaping ([Any]) -> Void, failure: @escaping (Error) -> Void) {
        let url = urlForEndpoint(endpoint: API.URL.AllDesks);
        baseGETRequest(url: url, params: [:], success: { response in
            let desks: [Any] = response[API.Key.Desks] as! [Any]
            CLSNSLogv("%@, Desks: %@", getVaList([#function, desks]))
            success(desks)
        }) { error in
            CLSNSLogv("%@, Error: %@", getVaList([#function, error.localizedDescription]))
            failure(error)
        }
    }
    
    func getAssets(success: @escaping ([Any]) -> Void, failure: @escaping (Error) -> Void) {
        let url = urlForEndpoint(endpoint: API.URL.Assets);
        baseGETRequest(url: url, params: [:], success: { response in
            let assets: [Any] = response[API.Key.Assets] as! [Any]
            CLSNSLogv("%@, Assets: %@", getVaList([#function, assets]))
            success(assets)
        }) { error in
            CLSNSLogv("%@, Error: %@", getVaList([#function, error.localizedDescription]))
            failure(error)
        }
    }
    
    func addRoom(room: Room, success: @escaping (String) -> Void, failure: @escaping (Error) -> Void) {
        let url = urlForEndpoint(endpoint: API.URL.AddRooms)
        
        let params = [API.Key.Name: room.name, API.Key.SiteID: room.site.siteID]
        
        basePOSTRequest(url: url, params: params, success: { response in
            if let message = response[API.Key.Message] {
                CLSNSLogv("%@, Message: %@", getVaList([#function, message as! CVarArg]))
                success(message as! String)
            } else {
                success("")
            }
        }) { error in
            CLSNSLogv("%@, Error: %@", getVaList([#function, error.localizedDescription]))
            failure(error)
        }
    }
    
    func updateRoom(room: Room, success: @escaping (String) -> Void, failure: @escaping (Error) -> Void) {
        let url = urlForEndpoint(endpoint: API.URL.Rooms) + "/" + room.roomID
        
        let params = [API.Key.Name: room.name, API.Key.SiteID: room.site.siteID]
        
        basePUTRequest(url: url, params: params, success: { response in
            if let message = response[API.Key.Message] {
                CLSNSLogv("%@, Message: %@", getVaList([#function, message as! CVarArg]))
                success(message as! String)
            } else {
                success("")
            }
        }) { error in
            CLSNSLogv("%@, Error: %@", getVaList([#function, error.localizedDescription]))
            failure(error)
        }
    }
    
    func deleteRoom(roomID: String, success: @escaping (String) -> Void, failure: @escaping (Error) -> Void) {
        let url = urlForEndpoint(endpoint: API.URL.Rooms) + "/" + roomID
        baseDELETERequest(url: url, params: [:], success: { response in
            if let message = response[API.Key.Message] {
                CLSNSLogv("%@, Message: %@", getVaList([#function, message as! CVarArg]))
                success(message as! String)
            } else {
                success("")
            }
        }) { error in
            CLSNSLogv("%@, Error: %@", getVaList([#function, error.localizedDescription]))
            failure(error)
        }
    }
    
    func addDesk(desk: Desk, success: @escaping (String) -> Void, failure: @escaping (Error) -> Void) {
        let url = urlForEndpoint(endpoint: API.URL.AddDesks)
        
        let params = [API.Key.Name: desk.deskName, API.Key.SiteID: desk.siteID, API.Key.RoomID: desk.roomID]
        
        basePOSTRequest(url: url, params: params, success: { response in
            if let message = response[API.Key.Message] {
                CLSNSLogv("%@, Message: %@", getVaList([#function, message as! CVarArg]))
                success(message as! String)
            } else {
                success("")
            }
        }) { error in
            CLSNSLogv("%@, Error: %@", getVaList([#function, error.localizedDescription]))
            failure(error)
        }
    }
    
    func updateDesk(desk: Desk, success: @escaping (String) -> Void, failure: @escaping (Error) -> Void) {
        let url = urlForEndpoint(endpoint: API.URL.Desks) + "/" + desk.deskID
        
        let params = [API.Key.Name: desk.deskName, API.Key.SiteID: desk.siteID, API.Key.RoomID: desk.roomID]
        
        basePUTRequest(url: url, params: params, success: { response in
            if let message = response[API.Key.Message] {
                CLSNSLogv("%@, Message: %@", getVaList([#function, message as! CVarArg]))
                success(message as! String)
            } else {
                success("")
            }
        }) { error in
            CLSNSLogv("%@, Error: %@", getVaList([#function, error.localizedDescription]))
            failure(error)
        }
    }
    
    func deleteDesk(deskID: String, success: @escaping (String) -> Void, failure: @escaping (Error) -> Void) {
        let url = urlForEndpoint(endpoint: API.URL.Desks) + "/" + deskID
        baseDELETERequest(url: url, params: [:], success: { response in
            if let message = response[API.Key.Message] {
                CLSNSLogv("%@, Message: %@", getVaList([#function, message as! CVarArg]))
                success(message as! String)
            } else {
                success("")
            }
        }) { error in
            CLSNSLogv("%@, Error: %@", getVaList([#function, error.localizedDescription]))
            failure(error)
        }
    }
    
    func addAsset(asset: Asset, success: @escaping (String) -> Void, failure: @escaping (Error) -> Void) {
        let url = urlForEndpoint(endpoint: API.URL.Assets);
        
        let params = [
            AssetKey.GAPID: asset.GAPID,
            AssetKey.Accesories: asset.accesories,
            AssetKey.Brand: asset.brand,
            AssetKey.Serial: asset.serial,
            AssetKey.Type_: asset.type?.uppercased(),
            "location": [
                "site": ["id": asset.siteID, "name": asset.siteName],
                "room": ["id": asset.roomID, "name": asset.roomName],
                "desk": ["id": asset.deskID, "name": asset.deskName],
            ]
            ] as [String : Any?]
        
        basePOSTRequest(url: url, params: params as [String : Any], success: { response in
            if let message = response[API.Key.Message] {
                CLSNSLogv("%@, Message: %@", getVaList([#function, message as! CVarArg]))
                success(message as! String)
            } else {
                success("")
            }
        }) { error in
            CLSNSLogv("%@, Error: %@", getVaList([#function, error.localizedDescription]))
            failure(error)
        }
    }
    
    func updateAsset(asset: Asset, success: @escaping (String) -> Void, failure: @escaping (Error) -> Void) {
        let url = urlForEndpoint(endpoint: API.URL.Assets) + "/" + asset.assetID!
        
        let params = [
            AssetKey.GAPID: asset.GAPID,
            AssetKey.Accesories: asset.accesories,
            AssetKey.Brand: asset.brand,
            AssetKey.Serial: asset.serial,
            AssetKey.Type_: asset.type?.uppercased(),
            "location": [
                "site": ["id": asset.siteID, "name": asset.siteName],
                "room": ["id": asset.roomID, "name": asset.roomName],
                "desk": ["id": asset.deskID, "name": asset.deskName],
            ]
            ] as [String : Any?]
        
        basePUTRequest(url: url, params: params as [String : Any], success: { response in
            if let message = response[API.Key.Message] {
                CLSNSLogv("%@, Message: %@", getVaList([#function, message as! CVarArg]))
                success(message as! String)
            } else {
                success("")
            }
        }) { error in
            CLSNSLogv("%@, Error: %@", getVaList([#function, error.localizedDescription]))
            failure(error)
        }
    }
    
    func deleteAsset(assetID: String, success: @escaping (String) -> Void, failure: @escaping (Error) -> Void) {
        let url = urlForEndpoint(endpoint: API.URL.Assets) + "/" + assetID
        baseDELETERequest(url: url, params: [:], success: { response in
            if let message = response[API.Key.Message] {
                CLSNSLogv("%@, Message: %@", getVaList([#function, message as! CVarArg]))
                success(message as! String)
            } else {
                success("")
            }
        }) { error in
            CLSNSLogv("%@, Error: %@", getVaList([#function, error.localizedDescription]))
            failure(error)
        }
    }
    
}
