//
//  VcHelp.swift
//  EZ Wallet
//
//  Created by Jeofferson Dela Peña on 3/27/20.
//  Copyright © 2020 Jeofferson Dela Peña. All rights reserved.
//

import UIKit

class VcHelp: UIViewController {

    
    var currentIndex = 0
    
    @IBOutlet weak var imgHelp: UIImageView!
    @IBOutlet weak var lblHelpDescription: UILabel!
    
    @IBOutlet weak var btnPrevOutlet: UIButton!
    @IBOutlet weak var btnNextOutlet: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViews()
        
    }
    
    
    @IBAction func btnPrevious(_ sender: UIButton) {
        
        currentIndex = currentIndex <= 0 ? currentIndex : currentIndex - 1
        
        updateViews()
        
    }
    
    
    @IBAction func btnNext(_ sender: UIButton) {
        
        currentIndex = currentIndex >= Constants.IMAGE_HELP_FILE_NAME_LIST.count - 1 ? currentIndex : currentIndex + 1
        
        updateViews()
        
    }
    
    
    func updateViews() {
        
        if currentIndex <= 0 {
            
            btnPrevOutlet.setImage(UIImage(named: Constants.PREV_DISABLED_LIGHT), for: .normal)
            
        } else {
            
            btnPrevOutlet.setImage(UIImage(named: Constants.PREV_LIGHT), for: .normal)
            
        }
        
        if currentIndex >= Constants.IMAGE_HELP_FILE_NAME_LIST.count - 1 {
            
            btnNextOutlet.setImage(UIImage(named: Constants.NEXT_DISABLED_LIGHT), for: .normal)
            
        } else {
            
            btnNextOutlet.setImage(UIImage(named: Constants.NEXT_LIGHT), for: .normal)
            
        }
        
        imgHelp.image = UIImage(named: Constants.IMAGE_HELP_FILE_NAME_LIST[currentIndex])
        lblHelpDescription.text = Constants.HELP_DESCRIPTION_LIST[currentIndex]
        
    }
    

}
