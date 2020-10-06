//
//  AdminBaseTableViewController.swift
//  Hoteling
//
//  Created by Andrés Padilla on 2/11/19.
//  Copyright © 2019 Growth Acceleration Partners. All rights reserved.
//

import UIKit
import PKHUD

class AdminBaseTableViewController: BaseViewController, AdminCellProtocol, RefreshDataProtocol {

    @IBOutlet weak var tableView: UITableView!
    let refreshControl = UIRefreshControl()
    
    var navigationDelegate: AdminNavControllerProtocol? = nil
    var shouldRefreshData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addPullToRefresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if shouldRefreshData {
            HUD.show(.progress)
            shouldRefreshData = false
            downloadData()
        }
    }
    
    func addPullToRefresh() {
        self.refreshControl.addTarget(self, action: #selector(self.downloadData), for: UIControl.Event.valueChanged)
        self.refreshControl.tintColor = Constants.Color.Jade
        self.tableView.addSubview(self.refreshControl)
    }
    
    @objc func downloadData() {
        
    }
    
    func makePush(view: UIViewController) {
        (view as! AdminEditBaseViewController).refreshProtocol = self
        self.navigationDelegate!.push(v: view)
    }
    
    //MARK: - AdminCellProtocol
    
    func editButtonPressed(cell: UITableViewCell) {
        
    }
    
    func deleteButtonPressed(cell: UITableViewCell) {
        
    }
    
    //MARK: - DownloadDataProtocol

    func refreshData() {
        shouldRefreshData = true
    }
    
}
