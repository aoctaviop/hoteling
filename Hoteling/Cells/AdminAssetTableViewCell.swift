//
//  AdminAssetTableViewCell.swift
//  Hoteling
//
//  Created by Andres Padilla on 2/7/19.
//  Copyright © 2019 Growth Acceleration Partners. All rights reserved.
//

import UIKit

class AdminAssetTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var gapIDLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var serialLabel: UILabel!
    @IBOutlet weak var accesoriesLabel: UILabel!
    
    var delegate: AdminCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(asset: Asset) {
        nameLabel.text = asset.deskName
        typeLabel.text = asset.type
        gapIDLabel.text = asset.GAPID
        brandLabel.text = asset.brand
        serialLabel.text = asset.serial
        accesoriesLabel.text = asset.accesories
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        delegate?.editButtonPressed(cell: self)
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        delegate?.deleteButtonPressed(cell: self)
    }

}
