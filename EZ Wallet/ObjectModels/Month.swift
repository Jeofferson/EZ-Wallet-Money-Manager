//
//  Month.swift
//  EZ Wallet
//
//  Created by Jeofferson Dela Peña on 3/16/20.
//  Copyright © 2020 Jeofferson Dela Peña. All rights reserved.
//

import Foundation


class Month {
    
    
    var id: Int
    
    var monthName: String
    var yearName: String
    var startingBalance: Double
    var totalExpenses: Double
    var totalSavings: Double
    
    
    init(id: Int, monthName: String, yearName: String, startingBalance: Double, totalExpenses: Double, totalSavings: Double) {
        
        self.id = id
        self.monthName = monthName
        self.yearName = yearName
        self.startingBalance = startingBalance
        self.totalExpenses = totalExpenses
        self.totalSavings = totalSavings
        
    }
    
    
}
