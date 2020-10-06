//
//  DeskTableViewCell.swift
//  Hoteling
//
//  Created by Andrés Padilla on 3/21/18.
//  Copyright © 2018 Growth Acceleration Partners. All rights reserved.
//

import UIKit
import SwiftDate

enum DeskStatus {
    case Available
    case Booked
}

protocol DeskTableViewCellDelegate: class {
    func locationButtonPressed(cell: DeskTableViewCell)
    func actionButtonPressed(cell: DeskTableViewCell)
}

class DeskTableViewCell: UITableViewCell {
    
    var deskStatus: DeskStatus = .Available
    weak var delegate: DeskTableViewCellDelegate?
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var siteLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var actionButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCellIcon() {
        switch self.deskStatus {
        case .Available:
            self.iconImageView.image = UIImage.init(named: Constants.Images.DeskIconFree)
        case .Booked:
            self.iconImageView.image = UIImage.init(named: Constants.Images.DeskIconBooked)
            
        }
    }
    
    func setupCellForReservation(reservation: Reservation) {
        nameLabel.text = reservation.deskName
        siteLabel.text = reservation.siteName
        roomLabel.text = reservation.roomName
        dateLabel.text = formatDate(date: reservation.reservationDate!)
    }
    
    func setupCellForCalendar(reservation: Desk) {
        nameLabel.text = reservation.deskName
        siteLabel.text = reservation.siteName
        roomLabel.text = reservation.roomName
        dateLabel.text = reservation.reservationUser
    }
    
    func setupCellForBookedDesk(desk: Desk) {
        nameLabel.text = desk.deskName
        siteLabel.text = desk.siteName
        roomLabel.text = desk.roomName
        dateLabel.text = desk.reservationUser
    }
    
    func setupCellForDesk(desk: Desk) {
        nameLabel.text = desk.deskName
        siteLabel.text = desk.siteName
        roomLabel.text = desk.roomName
    }
    
    // MARK: - Button Actions
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        if delegate != nil {
            delegate?.locationButtonPressed(cell: self)
        }
    }
    
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        if delegate != nil {
            delegate?.actionButtonPressed(cell: self)
        }
    }
    
    func formatDate(date: String) -> String {
        let newDate = date.date(format: DateFormat.custom(Constants.DateFormat.LongFormat))
        
        return newDate!.string(format: DateFormat.custom(Constants.DateFormat.ShortForService))
    }
    
}
