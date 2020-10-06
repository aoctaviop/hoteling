//
//  AdminEditBaseViewController.swift
//  Hoteling
//
//  Created by Andres Padilla on 2/12/19.
//  Copyright © 2019 Growth Acceleration Partners. All rights reserved.
//

import UIKit
import PKHUD

class AdminEditBaseViewController: UIViewController, UITextFieldDelegate {

    var currentPickerMode: PickerMode = .Site
    var currentSite: Site?
    var currentRoom: Room?
    var currentDesk: Desk?
    var sites: [Site] = []
    var rooms: [String: [Room]] = [:]
    var desks: [Desk] = []
    var types: [String] = ["Screen",
                           "Keyboard",
                           "Headset",
                           "Mouse"]
    
    var refreshProtocol: RefreshDataProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Save", comment: ""), style: .plain, target: self, action: #selector(addButtonTapped))
    }
    
    //MARK: - Button actions
    
    @objc func addButtonTapped() {
        self.view.endEditing(true)
    }
    
    //MARK: - Data retrieving
    
    func downloadSites(actionBlock: @escaping () -> Void) {
        HUD.show(.progress)
        NetworkingManager.sharedInstance.getSites(success: { (response) in
            for current: Any in response {
                self.sites.append(Site(params: current as! [String: Any]))
            }
            self.currentSite = self.sites[0]
            
            HUD.hide()
            
            actionBlock()
        }) { (error) in
            HUD.hide()
            self.showOKAlertController(text: error.localizedDescription)
        }
    }
    
    func downloadRoomsForSite(actionBlock: @escaping () -> Void) {
        HUD.show(.progress)
        NetworkingManager.sharedInstance.getRoomsForSite(siteID: currentSite!.siteID, success: { (response) in
            HUD.hide()
            var newRooms: [Room] = []
            for current: Any in response {
                newRooms.append(Room(params: current as! [String: Any], fullObject: false))
            }
            self.rooms[self.currentSite!.name] = newRooms
            
            self.currentRoom = newRooms[0]
            
            actionBlock()
        }) { (error) in
            HUD.hide()
            self.showOKAlertController(text: error.localizedDescription)
        }
    }
    
    func downloadDesks(actionBlock: @escaping () -> Void) {
        HUD.show(.progress)
        NetworkingManager.sharedInstance.getAllDesks(success: { (response) in
            for current: Any in response {
                self.desks.append(Desk(params: current as! [String : Any]))
            }
            self.currentDesk = self.desks[0]
            
            HUD.hide()
            
            actionBlock()
        }) { (error) in
            HUD.hide()
            self.showOKAlertController(text: error.localizedDescription)
        }
    }
    
    //MARK: - Picker view
    
    func showActionSheet(collection: [String], originView: UIView, actionBlock: @escaping (_ index: Int) -> Void) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet);
        
        for index in 0..<collection.count {
            let currentAction = UIAlertAction(title: collection[index], style: .default, handler: { (action) in
                HUD.hide()
                actionBlock(index)
            })
            actionSheet.addAction(currentAction)
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        actionSheet.addAction(cancelAction)
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = originView
            popoverController.sourceRect = CGRect(x: originView.bounds.midX, y: originView.bounds.midY, width: 0, height: 0)
        }
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    //MARK: - Data collections
    
    func roomStrings() -> [String] {
        var strings: [String] = []
        
        for current in rooms[(currentSite?.name)!]! {
            strings.append(current.name)
        }
        
        return strings
    }
    
    func siteStrings() -> [String] {
        var strings: [String] = []
        
        for current in sites {
            strings.append(current.name)
        }
        
        return strings
    }
    
    func deskStrings() -> [String] {
        var strings: [String] = []
        
        for current in desks {
            strings.append(current.deskName)
        }
        
        return strings
    }

    //MARK: - UITextFieldDelegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func dismissViewController() {
        self.refreshProtocol?.refreshData()
        self.navigationController?.popViewController(animated: true)
    }
    
}
