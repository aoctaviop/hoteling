//
//  ManageDesksViewController.swift
//  Hoteling
//
//  Created by Andres Padilla on 2/7/19.
//  Copyright © 2019 Growth Acceleration Partners. All rights reserved.
//

import UIKit
import PKHUD

class ManageDesksViewController: AdminBaseTableViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let cellHeight: CGFloat = 90.0
    var desks: [Desk] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        downloadDesks()
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return desks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AdminDeskTableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier.AdminDesk, for: indexPath) as! AdminDeskTableViewCell
        cell.delegate = self
        cell.setup(desk: desks[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeight
    }
    
    //MARK: - Button actions
    
    @objc func addButtonPressed() {
        let edit = Utils.sharedInstance.getView(id: Constants.ViewIdentifier.EditDesk)
        makePush(view: edit)
    }
    
    //MARK: - Data retrieving
    
    @objc override func downloadData() {
        NetworkingManager.sharedInstance.getAllDesks(success: { (response) in
            HUD.hide()
            self.refreshControl.endRefreshing()
            self.desks = []
            for current: Any in response {
                self.desks.append(Desk(params: current as! [String: Any]))
            }
            self.tableView.reloadData()
        }) { (error) in
            HUD.hide()
            self.showOKAlertController(text: error.localizedDescription)
        }
    }
    
    func downloadDesks() {
        HUD.show(.progress)
        downloadData()
    }
    
    //MARK: - AdminCellProtocol
    
    override func editButtonPressed(cell: UITableViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        let desk = desks[(indexPath?.row)!]
        
        let edit = Utils.sharedInstance.getView(id: Constants.ViewIdentifier.EditDesk)
        (edit as! EditDeskViewController).desk = desk
        
        makePush(view: edit)
    }
    
    override func deleteButtonPressed(cell: UITableViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        let desk = desks[(indexPath?.row)!]
        
        showYesNoAlertController(text: String(format: NSLocalizedString("Do you want to delete %@?", comment: ""), desk.deskName)) {
            HUD.show(.progress)
            
            NetworkingManager.sharedInstance.deleteDesk(deskID: desk.deskID, success: { (response) in
                HUD.hide()
                self.showOKAlertController(text: response, actionBlock: {
                    self.downloadDesks()
                })
            }, failure: { (error) in
                HUD.hide()
            })
        }
    }

}
