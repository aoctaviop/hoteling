//
//  ManageRoomsViewController.swift
//  Hoteling
//
//  Created by Andres Padilla on 2/7/19.
//  Copyright © 2019 Growth Acceleration Partners. All rights reserved.
//

import UIKit
import PKHUD

class ManageRoomsViewController: AdminBaseTableViewController, UITableViewDelegate, UITableViewDataSource {

    private let cellHeight: CGFloat = 70.0
    var rooms: [Room] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        downloadRooms()
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AdminRoomTableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier.AdminRoom, for: indexPath) as! AdminRoomTableViewCell
        cell.delegate = self
        cell.setup(room: rooms[indexPath.row])
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
        let edit = Utils.sharedInstance.getView(id: Constants.ViewIdentifier.EditRoom)
        makePush(view: edit)
    }
    
    //MARK: - Data retrieving
    
    @objc override func downloadData() {
        NetworkingManager.sharedInstance.getAllRooms(success: { (response) in
            HUD.hide()
            self.refreshControl.endRefreshing()
            self.rooms = []
            for current: Any in response {
                self.rooms.append(Room(params: current as! [String: Any], fullObject: true))
            }
            self.tableView.reloadData()
        }) { (error) in
            HUD.hide()
            self.showOKAlertController(text: error.localizedDescription)
        }
    }
    
    func downloadRooms() {
        HUD.show(.progress)
        downloadData()
    }
    
    //MARK: - AdminCellProtocol
    
    override func editButtonPressed(cell: UITableViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        let room = rooms[(indexPath?.row)!]
        
        let edit = Utils.sharedInstance.getView(id: Constants.ViewIdentifier.EditRoom)
        (edit as! EditRoomViewController).room = room
        
        makePush(view: edit)
    }
    
    override func deleteButtonPressed(cell: UITableViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        let room = rooms[(indexPath?.row)!]
        
        showYesNoAlertController(text: String(format: NSLocalizedString("Do you want to delete %@?", comment: ""), room.name)) {
            HUD.show(.progress)
            
            NetworkingManager.sharedInstance.deleteRoom(roomID: room.roomID, success: { (response) in
                HUD.hide()
                self.showOKAlertController(text: response, actionBlock: {
                    self.downloadRooms()
                })
            }, failure: { (error) in
                HUD.hide()
            })
        }
    }

}
