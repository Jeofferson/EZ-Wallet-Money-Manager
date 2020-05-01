//
//  SuperGlobals.swift
//  EZ Wallet
//
//  Created by Jeofferson Dela Peña on 3/16/20.
//  Copyright © 2020 Jeofferson Dela Peña. All rights reserved.
//

import Foundation


class SuperGlobals {
    
    
    static var selectedYearId = Int()
    static var selectedYearName = String()
    static var selectedYearIndex = Int()
    
    static var selectedMonthId = Int()
    static var selectedMonthName = String()
    static var selectedStartingBalance = Double()
    
    static var selectedExpenseId = Int()
    static var selectedExpenseCategoryName = String()
    static var selectedAmountPlannedBudget = Double()
    static var selectedAmountActualExpense = Double()
    
    static var selectedCategoryId = Int()
    static var selectedCategoryName = String()
    
    static var selectedBorrowEventId = Int()
    static var selectedIsPaid = Bool()
    static var selectedBorrowerFirstName = String()
    static var selectedBorrowerLastName = String()
    static var selectedBorrowerGender = String()
    static var selectedAmountPrincipal = Double()
    static var selectedAmountRemaining = Double()
    static var selectedInterestRate = Double()
    static var selectedAmortizationSchedule = String()
    static var selectedGainedFromInterest = Double()
    
    static var yearList = [Year]()
    static var monthList = [Month]()
    static var expenseList = [Expense]()
    static var categoryList = [Category]()
    
    static var borrowEventList = [BorrowEvent]()
    static var transactionList = [Transaction]()
    
    
}
