//
//  SignInViewController.swift
//  Hoteling
//
//  Created by Andrés Padilla on 3/26/18.
//  Copyright © 2018 Growth Acceleration Partners. All rights reserved.
//

import UIKit
import GoogleSignIn
import Crashlytics

class SignInViewController: BaseViewController, GIDSignInUIDelegate, GIDSignInDelegate {

    @IBOutlet weak var miscButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        if isLoggedIn() {
            self.performSegue(withIdentifier: Constants.Segue.ShowHomeView, sender: self)
        }
        
        miscButton.isHidden = ReachabilityManager.sharedInstance.isConnectedToNetwork && ReachabilityManager.sharedInstance.isConnectedToInternet
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - GIDSignInDelegate
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            CLSNSLogv("%@, Error: %@", getVaList([#function, error.localizedDescription]))
        } else {
            NetworkingManager.sharedInstance.validateToken(token: user.authentication.idToken, success: { (response) in
                if let wasSuccessful = response["isAdmin"] {
                    UserDefaults.standard.set(user.userID, forKey: Constants.Key.UserID)
                    UserDefaults.standard.set(response["token"], forKey: Constants.Key.TokenID)
                    UserDefaults.standard.set(user.profile.name, forKey: Constants.Key.FullName)
                    UserDefaults.standard.set(user.profile.email, forKey: Constants.Key.Email)
                    UserDefaults.standard.set(user.profile.imageURL(withDimension: Constants.Dimention.MenuWidth), forKey: Constants.Key.Avatar)
                    UserDefaults.standard.set(wasSuccessful as! Bool, forKey: Constants.Key.IsAdmin)
                    
                    CLSNSLogv("%@, Auth Token: %@", getVaList([#function, user.authentication.accessToken]))
                    
                    self.performSegue(withIdentifier: Constants.Segue.ShowHomeView, sender: self)
                } else {
                    self.showOKAlertController(text: response["message"] as! String)
                    GIDSignIn.sharedInstance().disconnect()
                }
            }) { (error) in
                print(user.authentication.idToken)
                self.showOKAlertController(text: error.localizedDescription)
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            CLSNSLogv("%@, Error: %@", getVaList([#function, error.localizedDescription]))
        } else {
            clearUserData()
            
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    // MARK: - Internet Connection
    
    override func performConnectionUnavailableActions() {
        DispatchQueue.main.async {
            self.miscButton.isHidden = false
        }
    }
    
    override func performConnectionAvailableActions() {
        DispatchQueue.main.async {
            self.miscButton.isHidden = true
        }
    }
    
    // MARK: - Button Actions
    
    @IBAction func miscButtonPressed(_ sender: UIButton) {
        if self.internetIsReachable() {
            sender.isHidden = true
        } else {
            self.showIternetConnectionWarning()
            self.network.checkInternetConnection()
        }
    }
}
