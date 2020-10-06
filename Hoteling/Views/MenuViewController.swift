//
//  MenuViewController.swift
//  Hoteling
//
//  Created by Andrés Padilla on 3/26/18.
//  Copyright © 2018 Growth Acceleration Partners. All rights reserved.
//

import UIKit
import GoogleSignIn
import Alamofire
import AlamofireImage
import PKHUD
import BadgeSwift
import SideMenuController

enum MenuCells: Int {
    case MyReservations
    case ReserveADesk
    case CalendarView
    case Manage
    case Report
    case Logout
    case Count
}

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let cellHeight: CGFloat = 54.0
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var badgeView: BadgeSwift!
    
    let cellTitles: [Int: String] = [
        MenuCells.MyReservations.rawValue: NSLocalizedString("My Reservations", comment: ""),
        MenuCells.ReserveADesk.rawValue: NSLocalizedString("Reserve a Desk", comment: ""),
        MenuCells.CalendarView.rawValue: NSLocalizedString("Calendar View", comment: ""),
        MenuCells.Manage.rawValue: NSLocalizedString("Manage", comment: ""),
        MenuCells.Report.rawValue: NSLocalizedString("Report", comment: ""),
        MenuCells.Logout.rawValue: NSLocalizedString("Logout", comment: "")
    ]
    
    var menuOptions: [Int] = [
        MenuCells.MyReservations.rawValue,
        MenuCells.ReserveADesk.rawValue,
        MenuCells.CalendarView.rawValue,
        MenuCells.Logout.rawValue
    ]
    
    let menuIdentifiers: [String] = [
        Constants.ViewIdentifier.Home,
        Constants.ViewIdentifier.Reservations,
        Constants.ViewIdentifier.Calendar,
        Constants.ViewIdentifier.Manage,
        Constants.ViewIdentifier.Report
    ]
    
    let badge = BadgeSwift()
    
    let isAdmin = Utils.sharedInstance.isAdmin()
    
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.width / 2.0
        self.avatarImageView.clipsToBounds = true
        
        self.nameLabel.text = UserDefaults.standard.string(forKey: Constants.Key.FullName)!

        Alamofire.request(UserDefaults.standard.url(forKey: Constants.Key.Avatar)!).responseImage { response in
            self.avatarImageView.image = response.value
        }
        
        if isAdmin {
            menuOptions = [
                MenuCells.MyReservations.rawValue,
                MenuCells.ReserveADesk.rawValue,
                MenuCells.CalendarView.rawValue,
                MenuCells.Manage.rawValue,
                MenuCells.Report.rawValue,
                MenuCells.Logout.rawValue
            ]
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(badgeHasChanged), name: .BadgeHasChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(moveToHome), name: .GoToHome, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func badgeHasChanged() {
        badgeView.text = UserDefaults.standard.string(forKey: Constants.Key.RemainingReservations)
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuCells.Count.rawValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MenuTableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier.Menu) as! MenuTableViewCell
        
        cell.iconView.image = UIImage(named: cellTitles[menuOptions[indexPath.row]]!.lowercased())
        cell.captionLabel.text = cellTitles[menuOptions[indexPath.row]]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == MenuCells.Logout.rawValue {
            self.logoutAction()
        } else {
            if currentIndex != indexPath.row {
                if (indexPath.row == MenuCells.ReserveADesk.rawValue || indexPath.row == MenuCells.CalendarView.rawValue) &&
                    !(ReachabilityManager.sharedInstance.isConnectedToInternet &&
                    ReachabilityManager.sharedInstance.isConnectedToNetwork) {
                    sideMenuController?.toggle()
                    self.showIternetConnectionWarning()
                    return
                }
                switchToView(viewIdentifier: menuIdentifiers[indexPath.row])
                currentIndex = indexPath.row
            } else {
                sideMenuController?.toggle()
            }
        }
    }
    
    //MARK: - Functions
    
    func switchToView(viewIdentifier: String) {
        // Checks if the selected view controller is already chached
        if let controller = sideMenuController?.viewController(forCacheIdentifier: viewIdentifier) {
            // Sets menuButtonImage to nil to avoid overriding back buttons when it's already cached
            SideMenuController.preferences.drawing.menuButtonImage = nil
            // Updates center view controller
            sideMenuController?.embed(centerViewController: controller)
        } else {
            // Sets the menuButtonImage to allow library to set menu button
            SideMenuController.preferences.drawing.menuButtonImage = UIImage(named: "menu")
            
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewIdentifier)
            // Updates center view controller
            sideMenuController?.embed(centerViewController: viewController, cacheIdentifier: viewIdentifier)
        }
    }
    
    func logoutAction() {
        if ReachabilityManager.sharedInstance.isConnectedToNetwork && ReachabilityManager.sharedInstance.isConnectedToInternet {
            HUD.show(.progress)
            
            NetworkingManager.sharedInstance.logout(success: { (message) in
                self.performLogoutActions()
            }) { (error) in
                self.performLogoutActions()
            }
        } else {
            NotificationCenter.default.post(name: .LogoutWasPerformed, object: nil)
            
            clearUserData()
            
            sideMenuController?.viewController(forCacheIdentifier: Constants.ViewIdentifier.Home)?.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func performLogoutActions() {
        sideMenuController?.toggle()
        HUD.hide()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            GIDSignIn.sharedInstance().disconnect()
        }
    }
    
    @objc func moveToHome() {
        tableView(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
    }
    
}
