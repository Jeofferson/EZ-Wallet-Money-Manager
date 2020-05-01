//
//  BorrowEvent.swift
//  EZ Wallet
//
//  Created by Jeofferson Dela Peña on 3/18/20.
//  Copyright © 2020 Jeofferson Dela Peña. All rights reserved.
//

import Foundation


class BorrowEvent {
    
    
    var id: Int
    
    var isPaid: Bool
    var borrowerFirstName: String
    var borrowerLastName: String
    var borrowerGender: String
    var amountPrincipal: Double
    var amountRemaining: Double
    var interestRate: Double
    var amortizationSchedule: String
    var gainedFromInterest: Double
    var startYear: Int
    var startMonth: Int
    var startDay: Int
    var startHour: Int
    var startMinute: Int
    var startSecond: Int
    
    
    init(id: Int, isPaid: Bool, borrowerFirstName: String, borrowerLastName: String, borrowerGender: String, amountPrincipal: Double, amountRemaining: Double, interestRate: Double, amortizationSchedule: String, gainedFromInterest: Double, startYear: Int, startMonth: Int, startDay: Int, startHour: Int, startMinute: Int, startSecond: Int) {
        
        self.id = id
        self.isPaid = isPaid
        self.borrowerFirstName = borrowerFirstName
        self.borrowerLastName = borrowerLastName
        self.borrowerGender = borrowerGender
        self.amountPrincipal = amountPrincipal
        self.amountRemaining = amountRemaining
        self.interestRate = interestRate
        self.amortizationSchedule = amortizationSchedule
        self.gainedFromInterest = gainedFromInterest
        self.startYear = startYear
        self.startMonth = startMonth
        self.startDay = startDay
        self.startHour = startHour
        self.startMinute = startMinute
        self.startSecond = startSecond
        
    }
    
    
}
