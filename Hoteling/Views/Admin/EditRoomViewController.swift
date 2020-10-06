//
//  EditRoomViewController.swift
//  Hoteling
//
//  Created by Andrés Padilla on 2/11/19.
//  Copyright © 2019 Growth Acceleration Partners. All rights reserved.
//

import UIKit
import PKHUD

class EditRoomViewController: AdminEditBaseViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var siteButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    
    var room: Room?

    override func viewDidLoad() {
        super.viewDidLoad()

        downloadSites {
            self.loadDataToUI()
        }
    }
    
    //MARK: - Button actions
    
    @IBAction func selectSiteButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        showActionSheet(collection: siteStrings(), originView: sender) { (index) in
            self.currentSite = Site(location: "", name: self.sites[index].name, siteID: self.sites[index].siteID)
            self.room?.site = self.currentSite!
            self.loadDataToUI()
        }
    }
    
    @IBAction func selectMapButtonPressed(_ sender: UIButton) {
        
    }
    
    @objc override func addButtonTapped() {
        super.addButtonTapped()
        
        HUD.show(.progress)
        
        if (room?.roomID.count)! > 0 {
            NetworkingManager.sharedInstance.updateRoom(room: room!, success: { (response) in
                HUD.hide()
                self.showOKAlertController(text: response, actionBlock: {
                    self.dismissViewController()
                })
            }) { (error) in
                HUD.hide()
                self.showOKAlertController(text: error.localizedDescription)
            }
        } else {
            NetworkingManager.sharedInstance.addRoom(room: room!, success: { (response) in
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
    
    //MARK: - Utils
    
    func loadDataToUI() {
        if (room != nil) {
            nameTextField.text = room?.name
        } else {
            room = Room()
            room?.site = currentSite!
        }
        
        siteButton.setTitle(room?.site.name, for: .normal)
    }
    
    //MARK: - UITextFieldDelegate
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        self.room?.name = textField.text!
    }
    
}
