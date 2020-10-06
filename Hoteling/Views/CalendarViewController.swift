//
//  CalendarViewController.swift
//  Hoteling
//
//  Created by Andres Padilla on 6/21/18.
//  Copyright © 2018 Growth Acceleration Partners. All rights reserved.
//

import UIKit
import SwiftDate
import PKHUD
import FZAccordionTableView

class CalendarViewController: BaseViewController, DatePickingDelegate, UITableViewDelegate, UITableViewDataSource, FZAccordionTableViewDelegate {

    private let bookedCellHeight:CGFloat = 125.0
    
    var currentPickerMode:PickerMode = .Site
    var currentSortType: SortType = .Free
    
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var tableView: FZAccordionTableView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var siteButton: UIButton!
    @IBOutlet weak var roomButton: UIButton!
    
    private let refreshControl = UIRefreshControl()
    
    var sites: [Site] = []
    var rooms: [String: [Site]] = [:]
    var currentSite: Site?
    var currentRoom: Site = Site(location: "", name: "All Rooms", siteID: "-1")
    var date: Date = Date()
    var reservations: [Date: [Desk]] =  [:]
    var headers: [Date] = []
    var headerViews: [Int: AccordionHeaderView] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Calendar View"
        
        tableView.allowMultipleSectionsOpen = true
        tableView.register(UINib(nibName: "AccordionHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: AccordionHeaderView.kAccordionHeaderViewReuseIdentifier)
        
        self.rooms["All Sites"] = [Site(location: "", name: "All Rooms", siteID: "-1")]
        
        updateDateButtonTitle()
        
        self.downloadSites()
        
        addPullToRefresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addPullToRefresh() {
        self.refreshControl.addTarget(self, action: #selector(self.downloadReservations), for: UIControl.Event.valueChanged)
        self.refreshControl.tintColor = Constants.Color.Jade
        self.tableView.addSubview(self.refreshControl)
    }
    
    // MARK: - <UITableViewDataSource> / <UITableViewDelegate>
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return headers.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = headers[section]
        return reservations[key]!.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return AccordionHeaderView.kDefaultAccordionHeaderViewHeight
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, heightForHeaderInSection:section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DeskTableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier.BookedDesk, for: indexPath) as! DeskTableViewCell
        cell.setupCellForCalendar(reservation: self.reservationFor(indexPath: indexPath))
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header: AccordionHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: AccordionHeaderView.kAccordionHeaderViewReuseIdentifier) as! AccordionHeaderView
        let titleLabel = header.viewWithTag(8000) as! UILabel
        titleLabel.text = headers[section].string(custom: Constants.DateFormat.DayAndDate)
        headerViews[section] = header
        return header
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.bookedCellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.bookedCellHeight
    }
    
    // MARK: - <FZAccordionTableViewDelegate>
    
    func tableView(_ tableView: FZAccordionTableView, willOpenSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
        let header = headerViews[section]
        let arrow = header?.viewWithTag(9000) as! UIImageView
        arrow.image = UIImage(named: "up")
    }
    
    func tableView(_ tableView: FZAccordionTableView, didOpenSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
        tableView.scrollToRow(at: IndexPath(row: 0, section: section), at: .top, animated: true)
    }
    
    func tableView(_ tableView: FZAccordionTableView, willCloseSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
        let header = headerViews[section]
        let arrow = header?.viewWithTag(9000) as! UIImageView
        arrow.image = UIImage(named: "down")
    }
    
    func tableView(_ tableView: FZAccordionTableView, didCloseSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
        
    }
    
    func tableView(_ tableView: FZAccordionTableView, canInteractWithHeaderAtSection section: Int) -> Bool {
        return true
    }
    
    // MARK: - API Calls
    
    func downloadSites() {
        HUD.show(.progress)
        NetworkingManager.sharedInstance.getSites(success: { (response) in
            self.sites.append(Site(location: "", name: "All Sites", siteID: "-1"))
            
            self.currentSite = self.sites[0]
            
            for current: Any in response {
                self.sites.append(Site(params: current as! [String: Any]))
            }
            self.downloadReservations()
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
            
            self.currentRoom = newRooms[0]
        }) { (error) in
            HUD.hide()
            self.showOKAlertController(text: error.localizedDescription)
        }
    }
    
    @objc func downloadReservations() {
        NetworkingManager.sharedInstance.getReservations(fromDate: firstDateOfTheWeek(), toDate: lastDateOfTheWeek(), siteID: (currentSite?.siteID)!, roomID: currentRoom.siteID, success: { (desks) in
            print(desks)
            var resDate: Date
            self.reservations =  [:]
            for current in desks {
                resDate = self.formatDate(date: current["reservationDate"]!)
                if var array: [Desk] = self.reservations[resDate] {
                    array.append(Desk(params: current))
                    self.reservations[resDate] = array
                } else {
                    self.reservations[resDate] = [Desk(params: current)]
                }
            }
            
            self.sortReservations()
            
            self.headers = Array(self.reservations.keys)
            
            self.headers.sort()
            
            self.refreshControl.endRefreshing()
            
            self.tableView.reloadData()
            
            if Array(self.reservations.keys).count > 0 {
                self.emptyLabel.isHidden = true
            } else {
                self.emptyLabel.isHidden = false
            }
            
            HUD.hide()
        }) { (error) in
            HUD.hide()
            self.showOKAlertController(text: error.localizedDescription)
        }
    }
    
    func sortReservations() {
        for key in headers {
            var array = reservations[key]
            array = array?.sorted(by: { (a, b) -> Bool in
                return a.deskName < b.deskName
            })
            reservations[key] = array
        }
    }
 
    //MARK: - DatePickingDelegate
    func dateChanged(_ date: Date) {
        self.date = date
        self.dateButton.setTitle(date.string(format: DateFormat.custom(Constants.DateFormat.ShortForUI)), for: UIControl.State.normal)
    }

    //MARK: - Dates
    
    func firstDateOfTheWeek() -> String {
        return date.startOf(component: .weekOfYear).string(format: DateFormat.custom(Constants.DateFormat.ShortForService))
    }
    
    func lastDateOfTheWeek() -> String {
        return (date.startOf(component: .weekOfYear) + 6.days).string(format: DateFormat.custom(Constants.DateFormat.ShortForService))
    }
    
    //MARK: - Picker view
    
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
            self.currentRoom = Site(location: "", name: "All Rooms", siteID: "-1")
            self.roomButton.setTitle(self.currentRoom.name, for: .normal)
        }
        
        self.currentSite = site
        
        self.siteButton.setTitle(site.name, for: .normal)
        if site.siteID == "-1" {
            self.currentRoom = Site(location: "", name: "All Rooms", siteID: "-1")
            self.roomButton.setTitle(self.currentRoom.name, for: .normal)
        } else {
            if rooms[(self.currentSite?.name)!] == nil {
                self.downloadRoomsForSite(site: site)
            }
        }
        
        HUD.show(.progress)
        self.downloadReservations()
    }
    
    func roomHasChanged(room: Site) {
        self.currentRoom = room
        
        self.roomButton.setTitle(room.name, for: .normal)
        
        HUD.show(.progress)
        self.downloadReservations()
    }
    
    // MARK: - Button Actions
    
    @IBAction func previousButtonPressed(_ sender: UIButton) {
        date = date - 1.week
        updateDateButtonTitle()
        HUD.show(.progress)
        downloadReservations()
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        date = date + 1.week
        updateDateButtonTitle()
        HUD.show(.progress)
        downloadReservations()
    }
    
    @IBAction func siteButtonPressed(_ sender: UIButton) {
        self.currentPickerMode = .Site
        self.showActionSheet()
    }
    
    @IBAction func roomButtonPressed(_ sender: UIButton) {
        self.currentPickerMode = .Room
        self.showActionSheet()
    }
    
    // MARK: - Helpers
    
    func reservationFor(indexPath: IndexPath) -> Desk {
        let key = headers[indexPath.section]
        return reservations[key]![indexPath.row]
    }
    
    func updateDateButtonTitle() {
        self.dateButton.setTitle("\(date.startOf(component: .weekOfYear).string(format: DateFormat.custom(Constants.DateFormat.ShortForCalendar))) - \((date.startOf(component: .weekOfYear) + 6.days).string(format: DateFormat.custom(Constants.DateFormat.ShortForCalendar)))", for: UIControl.State.normal)
    }
    
    func formatDate(date: String) -> Date {
        let newDate = date.date(format: DateFormat.custom(Constants.DateFormat.ShortForService))
        
        //return newDate!.string(format: DateFormat.custom(Constants.DateFormat.DayAndDate))
        return (newDate?.absoluteDate)!
    }
    
    // MARK: - Internet Connection
    
    override func performConnectionUnavailableActions() {
        showIternetConnectionWarning {
            NotificationCenter.default.post(name: .GoToHome, object: nil)
        }
    }
    
}
