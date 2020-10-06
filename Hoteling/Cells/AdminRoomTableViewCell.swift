//
//  AdminRoomTableViewCell.swift
//  Hoteling
//
//  Created by Andres Padilla on 2/7/19.
//  Copyright © 2019 Growth Acceleration Partners. All rights reserved.
//

import UIKit

class AdminRoomTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var siteLabel: UILabel!
    
    var delegate: AdminCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(room: Room) {
        nameLabel.text = room.name
        siteLabel.text = room.site.name
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        delegate?.editButtonPressed(cell: self)
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        delegate?.deleteButtonPressed(cell: self)
    }
    
}
