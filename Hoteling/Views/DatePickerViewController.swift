//
//  DatePickerViewController.swift
//  Hoteling
//
//  Created by Andres Padilla on 3/22/18.
//  Copyright © 2018 Growth Acceleration Partners. All rights reserved.
//

import UIKit
import JBDatePicker

protocol DatePickingDelegate: class {
    func dateChanged(_ date: Date)
}

class DatePickerViewController: UIViewController, JBDatePickerViewDelegate {
    
    @IBOutlet weak var datePickerView: JBDatePickerView!
    weak var delegate: DatePickingDelegate?
    
    var dateToSelect: Date!
    var allowPreviousDates: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        datePickerView.delegate = self
        
        //get presented month
        self.navigationItem.title = datePickerView.presentedMonthView?.monthDescription
        
        //remove hairline under navigationbar
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: Constants.Images.GreenPixel), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage(named: Constants.Images.TransparentPixel)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - JBDatePickerViewDelegate
    
    func didSelectDay(_ dayView: JBDatePickerDayView) {
        if self.delegate != nil {
            self.delegate?.dateChanged(dayView.date!)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func didPresentOtherMonth(_ monthView: JBDatePickerMonthView) {
        self.navigationItem.title = datePickerView.presentedMonthView.monthDescription
        
    }
    
    func shouldAllowSelectionOfDay(_ date: Date?) -> Bool {
        
        if allowPreviousDates {
            return true
        }
        
        guard let date = date else {return true}
        let comparison = NSCalendar.current.compare(date, to: Date(), toGranularity: .day)
        
        if comparison == .orderedAscending {
            return false
        }
        return true
        
    }
    
    var colorForUnavaibleDay: UIColor {
        return .blue
    }
    
    var dateToShow: Date {
        
        if let date = dateToSelect {
            return date
        }
        else{
            return Date()
        }
    }
    
    var weekDaysViewHeightRatio: CGFloat {
        return 0.1
    }
    
    
    @IBAction func loadNextMonth(_ sender: UIBarButtonItem) {
        datePickerView.loadNextView()
    }
    
    @IBAction func loadPreviousMonth(_ sender: UIBarButtonItem) {
        datePickerView.loadPreviousView()
    }
    
    
    @IBAction func dismissDatePicker(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
