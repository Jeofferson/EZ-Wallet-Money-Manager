//
//  VcAbout.swift
//  EZ Wallet
//
//  Created by Jeofferson Dela Peña on 4/10/20.
//  Copyright © 2020 Jeofferson Dela Peña. All rights reserved.
//

import UIKit

class VcAbout: UIViewController {
    
    
    @IBOutlet weak var imgDeveloperFrame: UIImageView!
    
    @IBOutlet weak var imgDeveloper: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        circleImage(uiImageView: imgDeveloperFrame)
        circleImage(uiImageView: imgDeveloper)
        
    }
    
    
    func circleImage(uiImageView: UIImageView) {
            
//        uiImageView.layer.borderWidth = 1
//        uiImageView.layer.masksToBounds = false
//        uiImageView.layer.borderColor = UIColor.black.cgColor
        
        uiImageView.layer.cornerRadius = uiImageView.frame.height / 2
        uiImageView.clipsToBounds = true
            
    }

    
}
