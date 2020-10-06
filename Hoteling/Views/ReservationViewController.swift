//
//  ReservationViewController.swift
//  Hoteling
//
//  Created by Andres Padilla on 3/22/18.
//  Copyright © 2018 Growth Acceleration Partners. All rights reserved.
//

import UIKit
import PKHUD
import SwiftDate

enum PickerMode {
    case Site
    case Room
}

class ReservationViewController: BadgeViewController, UISearchResultsUpdating, UITabBarDelegate, DatePickingDelegate, AvailableDesksDelegate {
    
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var siteButton: UIButton!
    @IBOutlet weak var roomButton: UIButton!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topViewBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var pagerView: UIView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var sortButton: UIBarButtonItem!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    private let availableCellHeight:CGFloat = 134.0
    private let bookedCellHeight:CGFloat = 150.0
    
    var currentPickerMode:PickerMode = .Site
    var currentSortType: SortType = .Free
    
    var sites: [Site] = []
    var rooms: [String: [Site]] = [:]
    var currentSite: Site?
    var currentRoom: Site = Site(location: "", name: "All Rooms", siteID: "-1")
    var date: Date = Date()
    var comesFromHome = false
    var validDates: [String] = []
    
    let pageViewController: PageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PageViewController") as! PageViewController
    var listView: ListViewController?
    var mapView: MapViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Reserve a Desk", comment: "")
        
        self.addSearchbar()
        self.addPageController()
        
        tabBar.selectedItem = tabBar.items?[0]
        
        self.rooms["All Sites"] = [Site(location: "", name: "All Rooms", siteID: "-1")]
        
        self.dateButton.setTitle(date.string(format: DateFormat.custom(Constants.DateFormat.ShortForService)), for: UIControl.State.normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.downloadSites()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.PickDateSegue {
            let navCon = segue.destination as! UINavigationController
            (navCon.topViewController as! DatePickerViewController).delegate = self
        }
    }
    
    // MARK: UI Setup
    
    func addSearchbar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            self.topViewHeightConstraint.constant = 0.0
            self.topViewBottomSpaceConstraint.constant = 8
        } else {
            // Fallback on earlier versions
            self.topView.addSubview(searchController.searchBar)
        }
        definesPresentationContext = true
    }
    
    // Set views delegate
    func addPageController() {
        
        self.listView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.ViewIdentifier.List) as? ListViewController
        self.listView?.delegate = self
        self.mapView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.ViewIdentifier.Map) as? MapViewController
        self.mapView?.delegate = self
        
        //TODO: uncomment the map view once it's implemented
        self.pageViewController.subViewControllers = [self.listView/*, self.mapView*/] as! [UIViewController]
        self.pageViewController.updateViews()
        self.pageViewController.view.frame = CGRect(x: 0.0, y: 0.0, width: self.pagerView.frame.width, height: self.pagerView.frame.height)
        
        self.pagerView.addSubview(self.pageViewController.view)
    }
    
    // MARK: Data downloading
    
    func downloadDesks() {
        listView?.downloadDesks()
    }
    
    func showActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet);
        
        let collection = self.currentPickerMode == .Site ? sites : rooms[(currentSite?.name)!]!;
        
        for current:Site in collection {
            let currentAction = UIAlertAction(title: current.name, style: .default, handler: { (action) in
                self.handleActionForOption(option: current)
            })
            actionSheet.addAction(currentAction)
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        actionSheet.addAction(cancelAction)
        
        if let popoverController = actionSheet.popoverPresentationController {
            let originView: UIView = self.currentPickerMode == .Site ? siteButton : roomButton
            popoverController.sourceView = originView
            popoverController.sourceRect = CGRect(x: originView.bounds.midX, y: originView.bounds.midY, width: 0, height: 0)
        }
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func handleActionForOption(option: Site) {
        if self.currentPickerMode == .Site {
            self.siteHasChanged(site: option)
        } else {
            self.roomHasChanged(room: option)
        }
    }
    
    func siteHasChanged(site: Site) {
        if site.name != currentSite?.name {
            UserDefaults.standard.removeObject(forKey: Constants.Key.PreferedRoom)
            self.currentRoom = Site(location: "", name: "All Rooms", siteID: "-1")
            self.roomButton.setTitle(self.currentRoom.name, for: .normal)
        }
        
        self.currentSite = site
        
        if let encoded = try? JSONEncoder().encode(site) {
            UserDefaults.standard.set(encoded, forKey: Constants.Key.PreferedSite)
        }
        
        self.siteButton.setTitle(site.name, for: .normal)
        if site.siteID == "-1" {
            self.currentRoom = Site(location: "", name: "All Rooms", siteID: "-1")
            self.roomButton.setTitle(self.currentRoom.name, for: .normal)
        } else {
            if rooms[(self.currentSite?.name)!] == nil {
                self.downloadRoomsForSite(site: site)
            }
        }
        self.downloadDesks()
    }
    
    func roomHasChanged(room: Site) {
        self.currentRoom = room
        
        if let encoded = try? JSONEncoder().encode(room) {
            UserDefaults.standard.set(encoded, forKey: Constants.Key.PreferedRoom)
        }
        
        self.roomButton.setTitle(room.name, for: .normal)
        self.downloadDesks()
    }
    
    // MARK: - Button Actions
    
    @IBAction func dateButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func siteButtonPressed(_ sender: UIButton) {
        self.currentPickerMode = .Site
        self.showActionSheet()
    }
    
    @IBAction func roomButtonPressed(_ sender: UIButton) {
        self.currentPickerMode = .Room
        self.showActionSheet()
    }
    
    @IBAction func sortButtonPressed(_ sender: UIBarButtonItem) {
        UIAlertController.showAlert(
            in: self,
            withTitle: NSLocalizedString("Sort by:", comment: ""),
            message: nil,
            cancelButtonTitle: NSLocalizedString("Cancel", comment: ""),
            destructiveButtonTitle: nil,
            otherButtonTitles: [NSLocalizedString("Free", comment: ""),
                                NSLocalizedString("Booked", comment: ""),
                                NSLocalizedString("Desk number", comment: "")],
            tap: {(controller, action, buttonIndex) in
                if (buttonIndex >= controller.firstOtherButtonIndex) {
                    self.currentSortType = SortType(rawValue: buttonIndex - 2)!
                    self.listView?.sortDesks()
                }
        }
        )
    }
    
    //MARK: - DatePickingDelegate
    func dateChanged(_ date: Date) {
        self.date = date
        self.dateButton.setTitle(date.string(format: DateFormat.custom(Constants.DateFormat.ShortForUI)), for: UIControl.State.normal)
        self.downloadDesks()
    }
    
    // MARK: - UISearchResultsUpdatingDelegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        listView?.filterDesksUsingText(searchText: searchText)
    }
    
    // MARK: - ReservationsDelegate
    
    func reservationsHadChanged() {
        
    }
    
    // MARK: - UITabBarDelegate
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController?.isActive = false
        } else {
            // Fallback on earlier versions
        };
        self.searchController.isActive = false
        
        DispatchQueue.main.async {
            self.searchController.dismiss(animated: false, completion: nil)
        }
        let index = (tabBar.items?.index(of: item))!
        
        self.pageViewController.moveToViewAtIndex(index: (tabBar.items?.index(of: item))!)
        
        if index == 1 {
            searchController.searchBar.isUserInteractionEnabled = false
            self.navigationItem.rightBarButtonItem = nil;
        } else {
            searchController.searchBar.isUserInteractionEnabled = true
            self.navigationController?.navigationItem.rightBarButtonItem = sortButton;
        }
    }
    
    // MARK: - AvailableDesksDelegate
    
    func bookDesk(desk: Desk) {
        if Int(UserDefaults.standard.string(forKey: Constants.Key.RemainingReservations)!) == 0 {
            showOKAlertController(text: NSLocalizedString("You already reached the max number of reservations", comment: ""))
        } else if hasReservationOnCurrentDate() {
            showOKAlertController(text: NSLocalizedString("You already have another reservation for the same day.", comment: ""))
        } else {
            let message = NSLocalizedString("Do you want to book the desk ", comment: "") + desk.deskName + NSLocalizedString(", located at room ", comment: "") + desk.roomName + NSLocalizedString(" in ", comment: "") + desk.siteName + "?"
            showYesNoAlertController(text: message) {
                self.askRepeating(desk: desk)
            }
        }
    }
    
    func hasReservationOnCurrentDate() -> Bool {
        let dates: [String] = UserDefaults.standard.stringArray(forKey: Constants.Key.ReservedDates)  ?? [String]()
        
        let selectedDate = date.string(format: DateFormat.custom(Constants.DateFormat.ShortForUI))
        
        return dates.contains(selectedDate)
    }
    
    func hasReservationOnNextWeekDate() -> Bool {
        let dates: [String] = UserDefaults.standard.stringArray(forKey: Constants.Key.ReservedDates)  ?? [String]()
        
        let selectedDate = (date + 1.week).string(format: DateFormat.custom(Constants.DateFormat.ShortForUI))
        
        return dates.contains(selectedDate)
    }
    
    func askRepeating(desk: Desk) {
        let message = NSLocalizedString("Would you like to repeat the reservation of this desk (same day: ", comment: "") + self.date.weekdayName + NSLocalizedString("), besides the already selected date?", comment: "")
        showYesNoAlertController(text: message, actionBlock: {
            if self.hasReservationOnNextWeekDate() {
                self.showOKAlertController(text: NSLocalizedString("You already have another reservation for the same day of the next week.", comment: ""))
            } else {
                self.validateDatesForDesk(desk: desk, shouldRepeat: true)
            }
        }, cancelBlock: {
            self.validateDatesForDesk(desk: desk, shouldRepeat: false)
        })
    }
    
    func showDeskLocation(desk: Desk) {
        let locationVC: LocationViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.ViewIdentifier.Location) as! LocationViewController
        locationVC.imagePath = desk.roomMap
        
        self.navigationController?.pushViewController(locationVC, animated: true)
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func selectedDate() -> String {
        return date.string(format: DateFormat.custom(Constants.DateFormat.ShortForService))
    }
    
    func site() -> String {
        return self.currentSite?.siteID ?? "-1"
    }
    
    func room() -> String {
        return self.currentRoom.siteID
    }
    
    func sortType() -> SortType {
        return self.currentSortType
    }
    
    func updateFilteringIfNeeded() {
        if self.searchController.isActive {
            self.searchController.searchBar.resignFirstResponder()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.searchController.searchBar.becomeFirstResponder()
            }
        }
    }
    
    func firstDateOfTheWeek () -> String {
        return date.startOf(component: .weekOfYear).string(format: DateFormat.custom(Constants.DateFormat.ShortForService))
    }
    
    func lastDateOfTheWeek () -> String {
        return (date.startOf(component: .weekOfYear) + 7.days).string(format: DateFormat.custom(Constants.DateFormat.ShortForService))
    }
    
    // MARK: API Calls
    
    func downloadSites() {
        HUD.show(.progress)
        NetworkingManager.sharedInstance.getSites(success: { (response) in
            self.sites.removeAll()
            self.sites.append(Site(location: "", name: "All Sites", siteID: "-1"))
            
            if let userData = UserDefaults.standard.data(forKey: Constants.Key.PreferedSite),
                let site = try? JSONDecoder().decode(Site.self, from: userData) {
                self.currentSite = site
                self.siteButton.setTitle(self.currentSite?.name, for: .normal)
                self.siteHasChanged(site: self.currentSite!)
            } else {
                self.currentSite = self.sites[0]
            }
            
            for current: Any in response {
                self.sites.append(Site(params: current as! [String: Any]))
            }
            self.downloadDesks()
        }) { (error) in
            HUD.hide()
            self.showOKAlertController(text: error.localizedDescription)
        }
    }
    
    func downloadRoomsForSite(site: Site) {
        HUD.show(.progress)
        NetworkingManager.sharedInstance.getRoomsForSite(siteID: site.siteID, success: { (response) in
            HUD.hide()
            var newRooms = [Site(location: "", name: "All Rooms", siteID: "-1")]
            for current: Any in response {
                newRooms.append(Site(params: current as! [String: Any]))
            }
            self.rooms[(self.currentSite?.name)!] = newRooms
            
            if let userData = UserDefaults.standard.data(forKey: Constants.Key.PreferedSite),
                let tempSite = try? JSONDecoder().decode(Site.self, from: userData) {
                if site.name == tempSite.name {
                    if let userData = UserDefaults.standard.data(forKey: Constants.Key.PreferedRoom),
                        let room = try? JSONDecoder().decode(Site.self, from: userData) {
                        self.currentRoom = room
                        self.roomButton.setTitle(self.currentSite?.name, for: .normal)
                        self.roomHasChanged(room: room)
                    } else {
                        self.currentRoom = newRooms[0]
                    }
                } else {
                    self.currentRoom = newRooms[0]
                }
            } else {
                self.currentRoom = newRooms[0]
            }
            
        }) { (error) in
            HUD.hide()
            self.showOKAlertController(text: error.localizedDescription)
        }
    }
    
    func reserveDesk(desk: Desk, shouldRepeat: Bool) {
        let date = self.date.string(format: DateFormat.custom(Constants.DateFormat.ShortForService))
        
        NetworkingManager.sharedInstance.reserveDesk(desk: desk, date: date, shouldRepeat: shouldRepeat, success: { (message) in
            HUD.hide()
            self.showOKAlertController(text: message, actionBlock: {
                NotificationCenter.default.post(name: .ReservationsChanged, object: nil)
                self.downloadDesks()
            })
        }) { (error) in
            HUD.hide()
            self.showOKAlertController(text: error.localizedDescription)
        }
    }
    
    func validateDatesForDesk(desk: Desk, shouldRepeat: Bool) {
        let date = self.date.string(format: DateFormat.custom(Constants.DateFormat.ShortForService))
        validDates = []
        HUD.show(.progress)
        NetworkingManager.sharedInstance.getDeskAvailability(desk: desk, date: date, shouldRepeat: true, success: { (response) in
            self.validDates = response as! [String]
            
            let originalDate = (self.date + 6.hours).string(format: DateFormat.custom(Constants.DateFormat.LongFormat))
            let repeatDate = (self.date + 7.days + 6.hours).string(format: DateFormat.custom(Constants.DateFormat.LongFormat))
            
            var canMakeReservation = false
            var message = NSLocalizedString("You already have another reservation for the same day.", comment: "")
            
            if shouldRepeat {
                canMakeReservation = self.validDates.contains(originalDate) && self.validDates.contains(repeatDate)
                if !self.validDates.contains(repeatDate) {
                    message = NSLocalizedString("You already have another reservation for the same day of the next week.", comment: "")
                }
            } else {
                canMakeReservation = self.validDates.contains(originalDate)
            }
            
            if canMakeReservation {
                self.reserveDesk(desk: desk, shouldRepeat: shouldRepeat)
            } else {
                HUD.hide()
                self.showOKAlertController(text: message, actionBlock: {
                    self.downloadDesks()
                })
            }
        }) { (error) in
            HUD.hide()
            self.showOKAlertController(text: error.localizedDescription)
        }
    }
    
    // MARK: - Internet Connection
    
    override func performConnectionUnavailableActions() {
        showIternetConnectionWarning {
            if self.comesFromHome {
                self.navigationController?.popViewController(animated: true)
            } else {
                NotificationCenter.default.post(name: .GoToHome, object: nil)
            }
        }
    }
    
}
