//
//  LocationViewController.swift
//  Hoteling
//
//  Created by Andrés Padilla on 4/2/18.
//  Copyright © 2018 Growth Acceleration Partners. All rights reserved.
//

import UIKit
import ZoomImageView
import Alamofire
import AlamofireImage
import PKHUD
import SideMenuController

class LocationViewController: UIViewController {

    @IBOutlet weak var imageView: ZoomImageView!
    
    var imagePath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.maximumZoomScale = 10.0

        HUD.show(.progress)
        
        Alamofire.request(API.URL.Base + API.URL.Maps + imagePath!).responseImage { response in
            self.imageView.image = response.value
            HUD.hide()
        }
        
        SideMenuController.preferences.drawing.menuButtonImage = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        SideMenuController.preferences.drawing.menuButtonImage = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
