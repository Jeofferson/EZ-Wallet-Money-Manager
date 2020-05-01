//
//  Expense.swift
//  EZ Wallet
//
//  Created by Jeofferson Dela Peña on 3/17/20.
//  Copyright © 2020 Jeofferson Dela Peña. All rights reserved.
//

import Foundation


class Expense {
    
    
    var id: Int
    
    var categoryName: String
    var amountPlannedBudget: Double
    var amountActualExpense: Double
    var monthId: Int
    
    
    init(id: Int, categoryName: String, amountPlannedBudget: Double, amountActualExpense: Double, monthId: Int) {
        
        self.id = id
        self.categoryName = categoryName
        self.amountPlannedBudget = amountPlannedBudget
        self.amountActualExpense = amountActualExpense
        self.monthId = monthId
        
    }
    
    
}
