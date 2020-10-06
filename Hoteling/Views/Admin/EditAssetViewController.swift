//
//  EditAssetViewController.swift
//  Hoteling
//
//  Created by Andrés Padilla on 2/11/19.
//  Copyright © 2019 Growth Acceleration Partners. All rights reserved.
//

import UIKit
import PKHUD

class EditAssetViewController: AdminEditBaseViewController {

    @IBOutlet weak var siteButton: UIButton!
    @IBOutlet weak var roomButton: UIButton!
    @IBOutlet weak var deskButton: UIButton!
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var gapIDLabel: UITextField!
    @IBOutlet weak var brandLabel: UITextField!
    @IBOutlet weak var serialLabel: UITextField!
    @IBOutlet weak var accesoriesLabel: UITextField!
    
    var asset: Asset?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        downloadSites(actionBlock: {
            self.downloadRoomsForSite(actionBlock: {
                self.downloadDesks(actionBlock: {
                    self.loadDataToUI()
                })
            })
        })
    }
    
    //MARK: - Utils
    
    func loadDataToUI() {
        if (asset == nil) {
            asset = Asset()
            
            asset?.siteID = (currentSite?.siteID)!
            asset?.siteName = (currentSite?.name)!
            
            asset?.roomID = (currentRoom?.roomID)!
            asset?.roomName = (currentRoom?.name)!
            
            self.asset?.deskID = currentDesk!.deskID
            self.asset?.deskName = currentDesk!.deskName
        }
        
        gapIDLabel.text = asset?.GAPID
        brandLabel.text = asset?.brand
        serialLabel.text = asset?.serial
        accesoriesLabel.text = asset?.accesories
        
        self.siteButton.setTitle(asset?.siteName, for: .normal)
        self.roomButton.setTitle(asset?.roomName, for: .normal)
        self.deskButton.setTitle(asset?.deskName, for: .normal)
        
        if (asset?.type?.count)! > 0 {
            self.typeButton.setTitle(asset?.type, for: .normal)
        }
    }
    
    //MARK: - Button actions
    
    @IBAction func selectSiteButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        showActionSheet(collection: siteStrings(), originView: sender) { (index) in
            self.currentSite = Site(location: "", name: self.sites[index].name, siteID: self.sites[index].siteID)
            self.asset?.siteID = self.sites[index].siteID
            self.asset?.siteName = self.sites[index].name
            self.downloadRoomsForSite(actionBlock: {
                self.asset?.roomID = self.rooms[(self.currentSite?.name)!]![0].roomID
                self.asset?.roomName = self.rooms[(self.currentSite?.name)!]![0].name
                self.loadDataToUI()
            })
        }
    }
    
    @IBAction func selectRoomButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        showActionSheet(collection: roomStrings(), originView: sender) { (index) in
            self.asset?.roomID = self.rooms[(self.currentSite?.name)!]![index].roomID
            self.asset?.roomName = self.rooms[(self.currentSite?.name)!]![index].name
            
            self.loadDataToUI()
        }
    }
    
    @IBAction func selectDeskButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        showActionSheet(collection: deskStrings(), originView: sender) { (index) in
            self.asset?.deskID = self.desks[index].deskID
            self.asset?.deskName = self.desks[index].deskName
            
            self.loadDataToUI()
        }
    }
    
    @IBAction func typeButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        showActionSheet(collection: types, originView: sender) { (index) in
            self.asset?.type = self.types[index]
            
            self.loadDataToUI()
        }
    }
    
    override func addButtonTapped() {
        super.addButtonTapped()
        
        if asset?.type?.count == 0 {
            self.showOKAlertController(text: NSLocalizedString("Type is required.", comment: ""), actionBlock: {
                
            })
            return
        }
        
        if (asset?.assetID?.count)! > 0 {
            NetworkingManager.sharedInstance.updateAsset(asset: asset!, success: { (response) in
                HUD.hide()
                self.showOKAlertController(text: response, actionBlock: {
                    self.dismissViewController()
                })
            }) { (error) in
                HUD.hide()
                self.showOKAlertController(text: error.localizedDescription)
            }
        } else {
            NetworkingManager.sharedInstance.addAsset(asset: asset!, success: { (response) in
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
    
    //MARK: - UITextFieldDelegate
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.isEqual(gapIDLabel) {
            asset?.GAPID = textField.text
        } else if textField.isEqual(brandLabel) {
            asset?.brand = textField.text
        } else if textField.isEqual(serialLabel) {
            asset?.serial = textField.text
        } else if textField.isEqual(accesoriesLabel) {
            asset?.accesories = textField.text
        }
    }
    
}
