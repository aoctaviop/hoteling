//
//  EditDeskViewController.swift
//  Hoteling
//
//  Created by Andrés Padilla on 2/11/19.
//  Copyright © 2019 Growth Acceleration Partners. All rights reserved.
//

import UIKit
import PKHUD

class EditDeskViewController: AdminEditBaseViewController {

    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var siteButton: UIButton!
    @IBOutlet weak var roomButton: UIButton!
    
    var desk: Desk?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        downloadSites(actionBlock: {
            self.downloadRoomsForSite(actionBlock: {
                self.loadDataToUI()
            })
        })
    }
    
    //MARK: - Button actions
    
    @objc override func addButtonTapped() {
        super.addButtonTapped()
        
        HUD.show(.progress)
        
        if (desk?.deskID.count)! > 0 {
            NetworkingManager.sharedInstance.updateDesk(desk: desk!, success: { (response) in
                HUD.hide()
                self.showOKAlertController(text: response, actionBlock: {
                    self.dismissViewController()
                })
            }) { (error) in
                HUD.hide()
                self.showOKAlertController(text: error.localizedDescription)
            }
        } else {
            NetworkingManager.sharedInstance.addDesk(desk: desk!, success: { (response) in
                HUD.hide()
                self.showOKAlertController(text: response, actionBlock: {
                    self.dismissViewController()
                })
            }) { (error) in
                HUD.hide()
                self.showOKAlertController(text: error.localizedDescription)
            }
        }
    }
    
    @IBAction func selectSiteButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        showActionSheet(collection: siteStrings(), originView: sender) { (index) in
            self.currentSite = Site(location: "", name: self.sites[index].name, siteID: self.sites[index].siteID)
            self.desk?.siteID = self.sites[index].siteID
            self.desk?.siteName = self.sites[index].name
            self.downloadRoomsForSite(actionBlock: {
                self.desk?.roomID = self.rooms[(self.currentSite?.name)!]![0].roomID
                self.desk?.roomName = self.rooms[(self.currentSite?.name)!]![0].name
                self.loadDataToUI()
            })
        }
    }
    
    @IBAction func selectRoomButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        showActionSheet(collection: roomStrings(), originView: sender) { (index) in
            self.desk?.roomID = self.rooms[(self.currentSite?.name)!]![index].roomID
            self.desk?.roomName = self.rooms[(self.currentSite?.name)!]![index].name
            
            self.loadDataToUI()
        }
    }
    
    //MARK: - Utils
    
    func loadDataToUI() {
        if (desk != nil) {
            nameLabel.text = desk?.deskName
        } else {
            desk = Desk()
            
            desk?.siteID = (currentSite?.siteID)!
            desk?.siteName = (currentSite?.name)!
            
            desk?.roomID = (currentRoom?.roomID)!
            desk?.roomName = (currentRoom?.name)!
        }
        
        siteButton.setTitle(desk?.siteName, for: .normal)
        roomButton.setTitle(desk?.roomName, for: .normal)
    }
    
    //MARK: - UITextFieldDelegate
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        self.desk?.deskName = textField.text!
    }
    
}
