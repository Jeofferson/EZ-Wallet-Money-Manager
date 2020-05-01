//
//  ConstantsSqlite.swift
//  EZ Wallet
//
//  Created by Jeofferson Dela Peña on 3/16/20.
//  Copyright © 2020 Jeofferson Dela Peña. All rights reserved.
//

import Foundation
import SQLite


class ConstantsSqlite {
    
    
    static let TABLE_YEAR = Table("year")
    static let YEAR_ID = Expression<Int>("id")
    static let YEAR_YEAR_NAME = Expression<String>("year_name")
        
    static let TABLE_MONTH = Table("month")
    static let MONTH_ID = Expression<Int>("id")
    static let MONTH_MONTH_NAME = Expression<String>("month_name")
    static let MONTH_YEAR_ID = Expression<Int>("year_id")
    static let MONTH_STARTING_BALANCE = Expression<Double>("starting_balance")
        
    static let TABLE_EXPENSE = Table("expense")
    static let EXPENSE_ID = Expression<Int>("id")
    static let EXPENSE_CATEGORY_ID = Expression<Int>("category_id")
    static let EXPENSE_AMOUNT_PLANNED_BUDGET = Expression<Double>("amount_planned_budget")
    static let EXPENSE_AMOUNT_ACTUAL_EXPENSE = Expression<Double>("amount_actual_expense")
    static let EXPENSE_MONTH_ID = Expression<Int>("month_id")
        
    static let TABLE_CATEGORY = Table("category")
    static let CATEGORY_ID = Expression<Int>("id")
    static let CATEGORY_CATEGORY_NAME = Expression<String>("category_name")
        
    static let TABLE_BORROW_EVENT = Table("borrow_event")
    static let BORROW_EVENT_ID = Expression<Int>("id")
    static let BORROW_EVENT_IS_PAID = Expression<Bool>("is_paid")
    static let BORROW_EVENT_BORROWER_FIRST_NAME = Expression<String>("borrower_first_name")
    static let BORROW_EVENT_BORROWER_LAST_NAME = Expression<String>("borrower_last_name")
    static let BORROW_EVENT_BORROWER_GENDER = Expression<String>("borrower_gender")
    static let BORROW_EVENT_AMOUNT_PRINCIPAL = Expression<Double>("amount_principal")
    static let BORROW_EVENT_INTEREST_RATE = Expression<Double>("interest_rate")
    static let BORROW_EVENT_AMORTIZATION_SCHEDULE = Expression<String>("amortization_schedule")
    static let BORROW_EVENT_START_YEAR = Expression<Int>("start_year")
    static let BORROW_EVENT_START_MONTH = Expression<Int>("start_month")
    static let BORROW_EVENT_START_DAY = Expression<Int>("start_day")
    static let BORROW_EVENT_START_HOUR = Expression<Int>("start_hour")
    static let BORROW_EVENT_START_MINUTE = Expression<Int>("start_minute")
    static let BORROW_EVENT_START_SECOND = Expression<Int>("start_second")
    
    static let TABLE_TRANSACTION = Table("transaction")
    static let TRANSACTION_ID = Expression<Int>("id")
    static let TRANSACTION_FROM = Expression<String>("from")
    static let TRANSACTION_AMOUNT = Expression<Double>("amount")
    static let TRANSACTION_YEAR = Expression<Int>("year")
    static let TRANSACTION_MONTH = Expression<Int>("month")
    static let TRANSACTION_DAY = Expression<Int>("day")
    static let TRANSACTION_HOUR = Expression<Int>("hour")
    static let TRANSACTION_MINUTE = Expression<Int>("minute")
    static let TRANSACTION_SECOND = Expression<Int>("second")
    static let TRANSACTION_BORROW_EVENT_ID = Expression<Int>("borrow_event_id")
    
    
}
