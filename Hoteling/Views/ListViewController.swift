//
//  ListViewController.swift
//  Hoteling
//
//  Created by Andres Padilla on 4/19/18.
//  Copyright © 2018 Growth Acceleration Partners. All rights reserved.
//

import UIKit
import PKHUD

enum SortType: Int {
    case Free
    case Booked
    case Number
}

class ListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, DeskTableViewCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    private let refreshControl = UIRefreshControl()
    
    weak var delegate: AvailableDesksDelegate?
    
    private let availableCellHeight:CGFloat = 130.0
    private let bookedCellHeight:CGFloat = 160.0
    
    var desks:[Desk] = []
    var filteredDesks:[Desk] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        HUD.show(.progress)
        self.downloadDesks()
        
        NotificationCenter.default.addObserver(self, selector: #selector(downloadDesks), name: .ReservationsCanceled, object: nil)
        
        addPullToRefresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addPullToRefresh() {
        self.refreshControl.addTarget(self, action: #selector(self.downloadDesks), for: UIControl.Event.valueChanged)
        self.refreshControl.tintColor = Constants.Color.Jade
        self.tableView.addSubview(self.refreshControl)
    }

    //MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (delegate?.isFiltering())! ? self.filteredDesks.count : self.desks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell
        
        let currentDesk = (delegate?.isFiltering())! ? filteredDesks[indexPath.row] : self.desks[indexPath.row]
        
        if currentDesk.isBooked {
            let cellx:DeskTableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier.BookedDesk, for: indexPath) as! DeskTableViewCell
            cellx.setupCellForBookedDesk(desk: currentDesk)
            cellx.delegate = self;
            cell = cellx
        } else {
            let cellx:DeskTableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier.AvailableDesk, for: indexPath) as! DeskTableViewCell
            cellx.setupCellForDesk(desk: currentDesk)
            cellx.delegate = self;
            cell = cellx
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentDesk = (delegate?.isFiltering())! ? filteredDesks[indexPath.row] : self.desks[indexPath.row]
        return currentDesk.isBooked ? self.bookedCellHeight : self.availableCellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentDesk = (delegate?.isFiltering())! ? filteredDesks[indexPath.row] : self.desks[indexPath.row]
        return currentDesk.isBooked ? self.bookedCellHeight : self.availableCellHeight
    }
    
    //MARK: - DeskTableViewCellDelegate
    
    func locationButtonPressed(cell: DeskTableViewCell) {
        let indexPath: NSIndexPath = self.tableView.indexPath(for: cell)! as NSIndexPath
        
        let desk: Desk = (delegate?.isFiltering())! ? filteredDesks[indexPath.row] : self.desks[indexPath.row]
        
        delegate?.showDeskLocation(desk: desk)
    }
    
    func actionButtonPressed(cell: DeskTableViewCell) {
        let indexPath: NSIndexPath = self.tableView.indexPath(for: cell)! as NSIndexPath
        
        let desk: Desk = (delegate?.isFiltering())! ? filteredDesks[indexPath.row] : self.desks[indexPath.row]
        
        delegate?.bookDesk(desk: desk)
    }
    
    // MARK: Functions
    
    func loadReservations() {
        if internetIsReachable() {
            self.downloadDesks()
            HUD.hide()
        } else {
            self.refreshControl.endRefreshing()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.showIternetConnectionWarning()
            }
        }
    }
    
    @objc func downloadDesks() {
        NetworkingManager.sharedInstance.getDesks(siteID: (delegate?.site())!, roomID: (delegate?.room())!, date: (delegate?.selectedDate())!, success: { (response) in
            
            self.desks.removeAll()
            for current: Any in response {
                self.desks.append(Desk(params: current as! [String: Any]))
            }
            
            self.refreshControl.endRefreshing()
            
            self.sortDesks()
            self.tableView.reloadData()
            
            self.emptyLabel.isHidden = self.desks.count > 0
            self.tableView.isHidden = !self.emptyLabel.isHidden
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                HUD.hide()
            }
            
            self.delegate?.updateFilteringIfNeeded()
        }) { (error) in
            HUD.hide()
            self.showOKAlertController(text: error.localizedDescription)
        }
    }
    
    func filterDesksUsingText(searchText: String) {
        filteredDesks = desks.filter({( desk : Desk) -> Bool in
            return desk.deskName.lowercased().contains(searchText.lowercased())
        })
        self.sortDesks()
        tableView.reloadData()
    }
    
    func sortDesks() {
        switch delegate?.sortType() {
        case .Free?:
            desks = desks.sorted(by: { (a, b) -> Bool in
                if !a.isBooked && b.isBooked {
                    return true //this will return true: b is booked, a is not
                }
                if a.isBooked && !b.isBooked {
                    return false //this will return false: a is booked, b is not
                }
                if a.isBooked == b.isBooked {
                    return a.deskName < b.deskName //if both are booked, then return depending on the desk name
                }
                return false
            })
            filteredDesks = filteredDesks.sorted(by: { (a, b) -> Bool in
                if !a.isBooked && b.isBooked {
                    return true //this will return true: b is booked, a is not
                }
                if a.isBooked && !b.isBooked {
                    return false //this will return false: a is booked, b is not
                }
                if a.isBooked == b.isBooked {
                    return a.deskName < b.deskName //if both are booked, then return depending on the desk name
                }
                return false
            })
            break
        case .Booked?:
            desks = desks.sorted(by: { (a, b) -> Bool in
                if a.isBooked && !b.isBooked {
                    return true //this will return true: a is booked, b is not
                }
                if !a.isBooked && b.isBooked {
                    return false //this will return false: b is booked, a is not
                }
                if a.isBooked == b.isBooked {
                    return a.deskName < b.deskName //if both are booked, then return depending on the desk name
                }
                return false
            })
            filteredDesks = filteredDesks.sorted(by: { (a, b) -> Bool in
                if a.isBooked && !b.isBooked {
                    return true //this will return true: a is booked, b is not
                }
                if !a.isBooked && b.isBooked {
                    return false //this will return false: b is booked, a is not
                }
                if a.isBooked == b.isBooked {
                    return a.deskName < b.deskName //if both are booked, then return depending on the desk name
                }
                return false
            })
            break
        case .Number?:
            desks = desks.sorted(by: { (a, b) -> Bool in
                return a.deskName < b.deskName
            })
            filteredDesks = filteredDesks.sorted(by: { (a, b) -> Bool in
                return a.deskName < b.deskName
            })
            break
        
        case .none:
            break
        }
        
        tableView.reloadData()
        
        if (delegate?.isFiltering())! {
            if filteredDesks.count > 0 {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        } else {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
}
