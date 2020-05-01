//
//  AlertControllerManager.swift
//  EZ Wallet
//
//  Created by Jeofferson Dela Peña on 3/17/20.
//  Copyright © 2020 Jeofferson Dela Peña. All rights reserved.
//

import UIKit


class AlertControllerManager {
    
    
    static func showAlertControllerWithDefaultButton(vc: UIViewController, title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.view.tintColor = UIColor(named: "color_accent")
        
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alertController.addAction(alertAction)
        
        vc.present(alertController, animated: true, completion: nil)
        
    }
    
    
    static func generateAlertController(title: String, message: String) -> UIAlertController {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.view.tintColor = UIColor(named: "color_accent")
        
        return alertController
        
    }
    
    
    static func generateAlertControllerWithTextField(title: String, message: String, placeholder:String, text: String) -> UIAlertController {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.view.tintColor = UIColor(named: "color_accent")
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            
            textField.textAlignment = NSTextAlignment.center
            
            textField.placeholder = placeholder
            textField.text = text
            
        }
        
        return alertController
        
    }
    
    
}
