//
//  ManageAssetsViewController.swift
//  Hoteling
//
//  Created by Andres Padilla on 2/7/19.
//  Copyright © 2019 Growth Acceleration Partners. All rights reserved.
//

import UIKit
import PKHUD

class ManageAssetsViewController: AdminBaseTableViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let cellHeight: CGFloat = 160.0
    var assets: [Asset] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        downloadAssets()
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AdminAssetTableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier.AdminAsset, for: indexPath) as! AdminAssetTableViewCell
        cell.delegate = self
        cell.setup(asset: assets[indexPath.row])
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
        let edit = Utils.sharedInstance.getView(id: Constants.ViewIdentifier.EditAsset)
        makePush(view: edit)
    }
    
    override func deleteButtonPressed(cell: UITableViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        let asset = assets[(indexPath?.row)!]
        
        showYesNoAlertController(text: String(format: NSLocalizedString("Do you want to delete %@?", comment: ""), asset.GAPID!)) {
            HUD.show(.progress)
            
            NetworkingManager.sharedInstance.deleteAsset(assetID: asset.assetID!, success: { (response) in
                HUD.hide()
                self.showOKAlertController(text: response, actionBlock: {
                    self.downloadAssets()
                })
            }, failure: { (error) in
                HUD.hide()
            })
        }
    }

    //MARK: - Data retrieving
    
    @objc override func downloadData() {
        NetworkingManager.sharedInstance.getAssets(success: { (response) in
            HUD.hide()
            self.refreshControl.endRefreshing()
            self.assets = []
            for current: Any in response {
                self.assets.append(Asset(params: current as! [String: Any]))
            }
            self.tableView.reloadData()
        }) { (error) in
            HUD.hide()
            self.showOKAlertController(text: error.localizedDescription)
        }
    }
    
    func downloadAssets() {
        HUD.show(.progress)
        downloadData()
    }
    
    //MARK: - AdminCellProtocol
    
    override func editButtonPressed(cell: UITableViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        let asset = assets[(indexPath?.row)!]
        
        let edit = Utils.sharedInstance.getView(id: Constants.ViewIdentifier.EditAsset)
        (edit as! EditAssetViewController).asset = asset
        
        makePush(view: edit)
    }
    
}
