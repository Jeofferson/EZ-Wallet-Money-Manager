//
//  MoneyFormatter.swift
//  EZ Wallet
//
//  Created by Jeofferson Dela Peña on 4/10/20.
//  Copyright © 2020 Jeofferson Dela Peña. All rights reserved.
//

import Foundation


class MoneyFormatter {
    
    
    static func convertToMoneyFormat(amount: Double) -> String {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.maximumFractionDigits = 2
        // String(format: "%.2f", totalExpenses)
        
        return numberFormatter.string(from: NSNumber(value: amount))!
        
    }
    
    
}
