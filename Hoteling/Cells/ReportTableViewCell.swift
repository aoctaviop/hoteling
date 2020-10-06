//
//  ReportTableViewCell.swift
//  Hoteling
//
//  Created by Andres Padilla on 2/14/19.
//  Copyright © 2019 Growth Acceleration Partners. All rights reserved.
//

import UIKit
import SwiftDate

class ReportTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var siteLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var iconWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconMarginConstraint: NSLayoutConstraint!
    
    private var isChecked = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCellForReservation(reservation: Desk) {
        nameLabel.text = reservation.deskName
        siteLabel.text = reservation.siteName
        roomLabel.text = reservation.roomName
        userLabel.text = reservation.reservationUser
        dateLabel.text = reservation.reservationDate
    }
    
    func formatDate(date: String) -> String {
        let newDate = date.date(format: DateFormat.custom(Constants.DateFormat.ShortForService))
        
        return newDate!.string(format: DateFormat.custom(Constants.DateFormat.ShortForCalendar))
    }
    
    func markAsChecked(checked: Bool) {
        isChecked = checked
        
        if isChecked {
            iconWidthConstraint.constant = 18.8
            iconMarginConstraint.constant = 8.0
        } else {
            iconWidthConstraint.constant = 0.0
            iconMarginConstraint.constant = 0.0
        }
    }

}
