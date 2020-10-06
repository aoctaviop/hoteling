//
//  Protocols.swift
//  Hoteling
//
//  Created by Andrés Padilla on 2/11/19.
//  Copyright © 2019 Growth Acceleration Partners. All rights reserved.
//

import UIKit

protocol AdminNavControllerProtocol {
    func push(v: UIViewController)
    func pop()
}

protocol AdminCellProtocol {
    func editButtonPressed(cell: UITableViewCell)
    func deleteButtonPressed(cell: UITableViewCell)
}

protocol RefreshDataProtocol {
    func refreshData()
}
