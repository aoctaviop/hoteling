//
//  UIViewController+Utils.swift
//  Hoteling
//
//  Created by Andrés Padilla on 2/11/19.
//  Copyright © 2019 Growth Acceleration Partners. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func isLoggedIn() -> Bool {
        var isLoggedIn = false
        if UserDefaults.standard.object(forKey: Constants.Key.TokenID) != nil {
            let tokenID = UserDefaults.standard.string(forKey: Constants.Key.TokenID)!
            
            if tokenID.count > 0 {
                isLoggedIn = true
            }
        }
        
        return isLoggedIn
    }
    
    func clearUserData() {
        UserDefaults.standard.removeObject(forKey: Constants.Key.UserID)
        UserDefaults.standard.removeObject(forKey: Constants.Key.TokenID)
        UserDefaults.standard.removeObject(forKey: Constants.Key.FullName)
        UserDefaults.standard.removeObject(forKey: Constants.Key.Email)
        UserDefaults.standard.removeObject(forKey: Constants.Key.Avatar)
        UserDefaults.standard.removeObject(forKey: Constants.Key.IsAdmin)
        
        UserDefaults.standard.removeObject(forKey: Constants.Key.PreferedSite)
        UserDefaults.standard.removeObject(forKey: Constants.Key.PreferedRoom)
    }
    
    func showIternetConnectionWarning() {
        UIAlertController.showAlert(
            in: self,
            withTitle: "",
            message: NSLocalizedString("Network connection failed. Please try again.", comment: ""),
            cancelButtonTitle: NSLocalizedString("OK", comment: ""),
            destructiveButtonTitle: nil,
            otherButtonTitles: nil,
            tap: nil
        )
    }
    
    func showIternetConnectionWarning(actionBlock: @escaping () -> Void) {
        UIAlertController.showAlert(
            in: self,
            withTitle: "",
            message: NSLocalizedString("Network connection failed. Please try again.", comment: ""),
            cancelButtonTitle: NSLocalizedString("OK", comment: ""),
            destructiveButtonTitle: nil,
            otherButtonTitles: nil,
            tap: {(controller, action, buttonIndex) in
                actionBlock()
        }
        )
    }
    
    func showOKAlertController(text: String) {
        UIAlertController.showAlert(
            in: self,
            withTitle: "",
            message: text,
            cancelButtonTitle: NSLocalizedString("OK", comment: ""),
            destructiveButtonTitle: nil,
            otherButtonTitles: nil,
            tap: nil
        )
    }
    
    func showOKAlertController(text: String, actionBlock: @escaping () -> Void) {
        UIAlertController.showAlert(
            in: self,
            withTitle: "",
            message: text,
            cancelButtonTitle: NSLocalizedString("OK", comment: ""),
            destructiveButtonTitle: nil,
            otherButtonTitles: nil,
            tap: {(controller, action, buttonIndex) in
                actionBlock()
        }
        )
    }
    
    func showYesNoAlertController(text: String, actionBlock: @escaping () -> Void) {
        UIAlertController.showAlert(
            in: self,
            withTitle: "",
            message: text,
            cancelButtonTitle: NSLocalizedString("No", comment: ""),
            destructiveButtonTitle: nil,
            otherButtonTitles: [NSLocalizedString("Yes", comment: "")],
            tap: {(controller, action, buttonIndex) in
                if buttonIndex == controller.firstOtherButtonIndex {
                    actionBlock()
                }
        }
        )
    }
    
    func showYesNoAlertController(text: String, actionBlock: @escaping () -> Void, cancelBlock: @escaping () -> Void) {
        UIAlertController.showAlert(
            in: self,
            withTitle: "",
            message: text,
            cancelButtonTitle: NSLocalizedString("No", comment: ""),
            destructiveButtonTitle: nil,
            otherButtonTitles: [NSLocalizedString("Yes", comment: "")],
            tap: {(controller, action, buttonIndex) in
                if buttonIndex == controller.cancelButtonIndex {
                    cancelBlock()
                } else if buttonIndex == controller.firstOtherButtonIndex {
                    actionBlock()
                }
        }
        )
    }
    
}

