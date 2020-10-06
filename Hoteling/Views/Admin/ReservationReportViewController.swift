//
//  ReservationReportViewController.swift
//  Hoteling
//
//  Created by Andres Padilla on 2/14/19.
//  Copyright © 2019 Growth Acceleration Partners. All rights reserved.
//

import UIKit
import SwiftDate
import PKHUD

class ReservationReportViewController: UIViewController, DatePickingDelegate, DeskTableViewCellDelegate, UITableViewDataSource, UITableViewDelegate {
    
    let kAllObjectsValue: String = "-1"
    
    @IBOutlet weak var fromButton: UIButton!
    @IBOutlet weak var toButton: UIButton!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelAllButton: UIButton!
    
    private let refreshControl = UIRefreshControl()
    
    private var fromDate = Date()
    private var toDate = Date()
    
    private var pressedButton: UIButton?
    
    var reservations: [Desk] = []
    var selectedReservations: [Desk] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateButtonsTitle()
        
         addPullToRefresh()
        
        HUD.show(.progress)
        downloadReservations()
        
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        pressedButton = (sender as! UIButton)
        let view = (segue.destination as! UINavigationController).viewControllers[0]
        (view as! DatePickerViewController).delegate = self
        (view as! DatePickerViewController).dateToSelect = (pressedButton!.isEqual(fromButton)) ? fromDate : toDate
        (view as! DatePickerViewController).allowPreviousDates = true
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reservations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell
        
        let currentDesk = reservations[indexPath.row]
        
        let cellx: ReportTableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier.BookedDesk, for: indexPath) as! ReportTableViewCell
        cellx.setupCellForReservation(reservation: currentDesk)
        cellx.markAsChecked(checked: false)
        cell = cellx
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125.0
    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        let reservation = reservations[indexPath.row]
        
        if selectedReservations.contains(reservation) {
            selectedReservations.remove(at: selectedReservations.firstIndex(of: reservation)!)
            (cell as! ReportTableViewCell).markAsChecked(checked: false)
        } else {
            selectedReservations.append(reservations[indexPath.row])
            (cell as! ReportTableViewCell).markAsChecked(checked: true)
        }
        
        updateCancelButtonVisibility()
    }
    
    //MARK: - Button actions
    
    @IBAction func cancelAllButtonPressed(_ sender: Any) {
        showYesNoAlertController(text: NSLocalizedString("Do you want to delete all selected reservations?", comment: "")) {
            HUD.show(.progress)
            NetworkingManager.sharedInstance.deleteAllReservations(reservations: self.selectedReservations, success: { (response) in
                HUD.hide()
                self.showOKAlertController(text: response, actionBlock: {
                    HUD.show(.progress)
                    self.downloadReservations()
                    NotificationCenter.default.post(name: .ReservationsChanged, object: nil)
                })
            }) { (error) in
                HUD.hide()
                self.showOKAlertController(text: error.localizedDescription)
            }
        }
    }
    
    //MARK: - DatePickingDelegate
    
    func dateChanged(_ date: Date) {
        
        if (pressedButton?.isEqual(fromButton))! {
            fromDate = date;
        } else {
            toDate = date;
        }
        
        updateButtonsTitle()
        
        HUD.show(.progress)
        downloadReservations()
    }
    
    func updateButtonsTitle() {
        fromButton.setTitle(fromDate.string(format: DateFormat.custom(Constants.DateFormat.ShortForCalendar)), for: UIControl.State.normal)
        toButton.setTitle(toDate.string(format: DateFormat.custom(Constants.DateFormat.ShortForCalendar)), for: UIControl.State.normal)
    }
    
    //MARK: - DeskTableViewCellDelegate
    
    func locationButtonPressed(cell: DeskTableViewCell) {
        
    }
    
    func actionButtonPressed(cell: DeskTableViewCell) {
        
    }
    
    //MARK: - Data retrieving
    
    @objc func downloadReservations() {
        NetworkingManager.sharedInstance.getReservations(fromDate: fromDate.string(format: DateFormat.custom(Constants.DateFormat.ShortForService)), toDate: toDate.string(format: DateFormat.custom(Constants.DateFormat.ShortForService)), siteID: kAllObjectsValue, roomID: kAllObjectsValue, success: { (desks) in
            self.selectedReservations = []
            self.reservations =  []
            for current in desks {
                self.reservations.append(Desk(params: current))
            }
            
            self.sortReservations()
            
            self.refreshControl.endRefreshing()
            
            self.tableView.reloadData()
            
            if self.reservations.count > 0 {
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
    
    //MARK: - Utils
    
    func sortReservations() {
        reservations = reservations.sorted(by: { (a, b) -> Bool in
            return a.deskName < b.deskName
        })
    }
    
    func addPullToRefresh() {
        self.refreshControl.addTarget(self, action: #selector(self.downloadReservations), for: UIControl.Event.valueChanged)
        self.refreshControl.tintColor = Constants.Color.Jade
        self.tableView.addSubview(self.refreshControl)
    }
    
    func updateCancelButtonVisibility() {
        if (selectedReservations.count) > 0 {
            cancelAllButton.setTitle(NSLocalizedString("Cancell selected reservations", comment: ""), for: .normal)
            cancelAllButton.isUserInteractionEnabled = true
        } else {
            cancelAllButton.setTitle(NSLocalizedString("Select reservations to cancel", comment: ""), for: .normal)
            cancelAllButton.isUserInteractionEnabled = false
        }
    }
    
}
