//
//  AdminDeskTableViewCell.swift
//  Hoteling
//
//  Created by Andres Padilla on 2/7/19.
//  Copyright © 2019 Growth Acceleration Partners. All rights reserved.
//

import UIKit

class AdminDeskTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var siteLabel: UILabel!
    
    var delegate: AdminCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setup(desk: Desk) {
        nameLabel.text = desk.deskName
        roomLabel.text = desk.roomName
        siteLabel.text = desk.siteName
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func editButtonPressed(_ sender: UIButton) {
        delegate?.editButtonPressed(cell: self)
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        delegate?.deleteButtonPressed(cell: self)
    }
    
}
