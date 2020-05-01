//
//  Transaction.swift
//  EZ Wallet
//
//  Created by Jeofferson Dela Peña on 3/18/20.
//  Copyright © 2020 Jeofferson Dela Peña. All rights reserved.
//

import Foundation


class Transaction {
    
    
    var id: Int
    
    var from: String
    var amount: Double
    var year: Int
    var month: Int
    var day: Int
    var hour: Int
    var minute: Int
    var second: Int
    var borrowEventId: Int
    
    
    init(id: Int, from: String, amount: Double, year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, borrowEventId: Int) {
        
        self.id = id
        self.from = from
        self.amount = amount
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.second = second
        self.borrowEventId = borrowEventId
        
    }
    
    
}
