//
//  ViewController.swift
//  Hoteling
//
//  Created by Andres Padilla on 3/20/18.
//  Copyright © 2018 Growth Acceleration Partners. All rights reserved.
//

import UIKit
import PKHUD
import SwiftDate
import UIAlertController_Blocks
import Crashlytics
import NotificationBannerSwift

class HomeViewController: BadgeViewController, UITableViewDelegate, UITableViewDataSource, DeskTableViewCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var cancelAllButton: UIButton!
    @IBOutlet weak var cancelAllButtonHeightConstraint: NSLayoutConstraint!
    
    private let cellHeight:CGFloat = 158.0
    private let refreshControl = UIRefreshControl()
    let banner = StatusBarNotificationBanner(title: NSLocalizedString("No internet connection.", comment: ""), style: .warning)
    
    var reservations: [Reservation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("My Reservations", comment: "")
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.emptyLabel.isHidden = false
        
        addPullToRefresh()
        
        if internetIsReachable() {
            HUD.show(.progress)
            self.loadReservations()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshReservations), name: .ReservationsChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .ReservationsChanged, object: nil)
        banner.dismiss()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.AddReservation {
            (segue.destination as! ReservationViewController).comesFromHome = true
        }
    }
    
    func addPullToRefresh() {
        self.refreshControl.addTarget(self, action: #selector(self.refreshReservations), for: UIControl.Event.valueChanged)
        self.refreshControl.tintColor = Constants.Color.Jade
        self.tableView.addSubview(self.refreshControl)
    }
    
    @objc func refreshReservations() {
        loadReservations()
    }
    
    func loadReservations() {
        if internetIsReachable() {
            self.downloadMyReservations()
        } else {
            self.refreshControl.endRefreshing()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.showIternetConnectionWarning()
            }
        }
    }
    
    func downloadMyReservations() {
        NetworkingManager.sharedInstance.getReservations(success: { response in
            HUD.hide()
            self.reservations.removeAll()
            
            for current: Any in response {
                self.reservations.append(Reservation(params: current as! [String: Any]))
            }
            
            self.emptyLabel.isHidden = self.reservations.count != 0
            
            self.tableView.reloadData()
            
            self.refreshControl.endRefreshing()
            
            //Shows/hides the 'Cancel all reservations' button
            
            if self.reservations.count > 1 {
                self.cancelAllButton.isHidden = false
                self.cancelAllButtonHeightConstraint.constant = 30.0
            } else {
                self.cancelAllButton.isHidden = true
                self.cancelAllButtonHeightConstraint.constant = 0.0
            }
            
            //Saves the remaining reservations counter and send the notification to update the badge
            
            UserDefaults.standard.set(String(5 - self.reservations.count), forKey: Constants.Key.RemainingReservations)
            NotificationCenter.default.post(name: .BadgeHasChanged, object: nil)
            
            //Saves dates to validate reservations before making new ones.
            
            var dates: [String] = []
            
            for current in self.reservations {
                let mySubstring = current.reservationDate!.prefix(10)
                dates.append(String(mySubstring))
            }
            
            UserDefaults.standard.set(dates, forKey: Constants.Key.ReservedDates)
        }) { error in
            HUD.hide()
            CLSNSLogv("%@, Error: %@", getVaList([#function, error.localizedDescription]))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reservations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DeskTableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier.Desk) as! DeskTableViewCell
        
        cell.deskStatus = .Booked
        cell.updateCellIcon()
        cell.setupCellForReservation(reservation: reservations[indexPath.row])
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    //MARK: - Actions
    
    @IBAction func menuButtonPressed(_ sender: UIBarButtonItem) {
            }
    
    @IBAction func addReservationButtonPressed(_ sender: UIBarButtonItem) {
        if internetIsReachable() {
            self.performSegue(withIdentifier: Constants.Segue.AddReservation, sender: self)
        } else {
            self.showIternetConnectionWarning()
        }
    }
    
    @IBAction func cancelReservationsButtonPressed(_ sender: UIButton) {
        if internetIsReachable() {
            showYesNoAlertController(text: NSLocalizedString("Do you want to cancel all your reservations?", comment: "")) {
                self.cancelAllReservations()
            }
        } else {
            self.showIternetConnectionWarning()
        }
    }
    
    //MARK: - DeskTableViewCellDelegate
    
    func locationButtonPressed(cell: DeskTableViewCell) {
        if internetIsReachable() {
            let indexPath: NSIndexPath = self.tableView.indexPath(for: cell)! as NSIndexPath
            
            let reservation: Reservation = self.reservations[indexPath.row]
            
            let locationVC: LocationViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.ViewIdentifier.Location) as! LocationViewController
            locationVC.imagePath = reservation.roomMap
            
            self.navigationController?.pushViewController(locationVC, animated: true)
        } else {
            self.showIternetConnectionWarning()
        }
    }
    
    func actionButtonPressed(cell: DeskTableViewCell) {
        if internetIsReachable() {
            let indexPath: NSIndexPath = self.tableView.indexPath(for: cell)! as NSIndexPath
            
            let reservation: Reservation = self.reservations[indexPath.row]
            
            let message = NSLocalizedString("Do you want to cancel the reservation for ", comment: "") + reservation.deskName + NSLocalizedString(", located at room ", comment: "") + reservation.roomName + NSLocalizedString(" in ", comment: "") + reservation.siteName + "?";
            showYesNoAlertController(text: message) {
                self.cancelReservation(reservation: reservation)
            }
        } else {
            self.showIternetConnectionWarning()
        }
    }
    
    func cancelReservation(reservation: Reservation) {
        HUD.show(.progress)
        NetworkingManager.sharedInstance.deleteReservation(reservation: reservation, success: { (message) in
            HUD.hide()
            self.showOKAlertController(text: message, actionBlock: {
                HUD.show(.progress)
                self.loadReservations()
                NotificationCenter.default.post(name: .ReservationsCanceled, object: nil)
            })
        }) { (error) in
            HUD.hide()
            self.showOKAlertController(text: error.localizedDescription)
        }
    }
    
    func cancelAllReservations() {
        HUD.show(.progress)
        NetworkingManager.sharedInstance.deleteAllReservations(reservations: reservations, success: { (message) in
            HUD.hide()
            self.showYesNoAlertController(text: message, actionBlock: {
                HUD.show(.progress)
                self.loadReservations()
                NotificationCenter.default.post(name: .ReservationsCanceled, object: nil)
            })
        }) { (error) in
            HUD.hide()
            self.showOKAlertController(text: error.localizedDescription)
        }
    }
        
    // MARK: -
    func reservationsHadChanged() {
        HUD.show(.progress)
        loadReservations()
    }
    
    override func handleLogout() {
        self.banner.dismiss()
    }
    
    // MARK: - Internet Connection
    
    override func performConnectionUnavailableActions() {
        if isLoggedIn() {
            DispatchQueue.main.async {
                self.banner.show(queuePosition: .front, bannerPosition: .top)
                self.banner.autoDismiss = false
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    override func performConnectionAvailableActions() {
        DispatchQueue.main.async {
            self.banner.dismiss()
            self.reservationsHadChanged()
        }
    }
}

