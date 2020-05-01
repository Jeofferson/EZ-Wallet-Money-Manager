//
//  ViewController.swift
//  EZ Wallet
//
//  Created by Jeofferson Dela Peña on 3/16/20.
//  Copyright © 2020 Jeofferson Dela Peña. All rights reserved.
//

import UIKit
import SQLite
import Charts


class ViewController: UIViewController {
    
    
    let calendar = Calendar.current
    
    var currentYear = Int()
    var currentMonth = Int()
    var currentDay = Int()
    var currentHour = Int()
    var currentMinute = Int()
    var currentSecond = Int()
    
    var currentDateString = String()
    
    let defaults = UserDefaults.standard
    
    var db: Connection!
    
    @IBOutlet weak var lblTotalExpenses: UILabel!
    @IBOutlet weak var lblTotalSavings: UILabel!
    
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var btnPreviousYearOutlet: UIButton!
    @IBOutlet weak var btnNextYearOutlet: UIButton!
    
    @IBOutlet weak var tblViewMonths: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let date = Date()
        
        currentYear = calendar.component(.year, from: date)
        currentMonth = calendar.component(.month, from: date)
        currentDay = calendar.component(.day, from: date)
        currentHour = calendar.component(.hour, from: date)
        currentMinute = calendar.component(.minute, from: date)
        currentSecond = calendar.component(.second, from: date)
        
        currentDateString = "\(currentMonth) \(currentDay), \(currentYear)"
        
        prepareDb()
        prepareTables()
        
        updateViews()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        queryTableYear()
        queryTableMonth()
        queryTableBorrowEvent()
        
        updateViews()
        
    }
    
    
    @IBAction func btnNextYear(_ sender: UIButton) {
        
        stepOneYear(isForward: true)
        
    }
    
    
    @IBAction func btnPreviousYear(_ sender: UIButton) {
        
        stepOneYear(isForward: false)
        
    }
    
    
    func prepareDb() {
        
        do {
            
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("db").appendingPathExtension("sqlite3")
            let db = try Connection(fileUrl.path)
            self.db = db
            
        } catch {
            
            print(error)
            
        }
        
    }
    
    
    func prepareTables() {
        
        prepareTableYear()
        queryTableYear()
        
        prepareTableExpense()
        
        prepareTableMonth()
        queryTableMonth()
        
        prepareTableCategory()
        
        prepareTableTransaction()
        
        prepareTableBorrowEvent()
        queryTableBorrowEvent()
        
    }
    
    
    func prepareTableYear() {
        
        do {
            
            let createTable = ConstantsSqlite.TABLE_YEAR.create(ifNotExists: true) { (table) in
                
                table.column(ConstantsSqlite.YEAR_ID, primaryKey: true)
                table.column(ConstantsSqlite.YEAR_YEAR_NAME)
                
            }
            
            try db.run(createTable)
            
            checkIfEmptyTableYear()
            
        } catch {
            
            print(error)
            
        }
        
    }
    
    
    func checkIfEmptyTableYear() {
        
        do {
            
            let count = try db.scalar(ConstantsSqlite.TABLE_YEAR.count)
            
            if count <= 0 {

                for i in 0 ..< Constants.YEAR_LIST.count {

                    let year = Constants.YEAR_LIST[i]

                    let insertYear = ConstantsSqlite.TABLE_YEAR.insert(
                        ConstantsSqlite.YEAR_YEAR_NAME <- year.yearName
                    )

                    try db.run(insertYear)

                }
                
            }
            
        } catch {
            
            print(error)
            
        }
        
    }
    
    
    func queryTableYear() {
        
        do {
                
            SuperGlobals.yearList.removeAll()
        
            let result = try db.prepare(ConstantsSqlite.TABLE_YEAR)

            for row in result {

                let id = row[ConstantsSqlite.YEAR_ID]
                let yearName = row[ConstantsSqlite.YEAR_YEAR_NAME]

                let year = Year(id: id, yearName: yearName)
                SuperGlobals.yearList.append(year)

            }
            
            SuperGlobals.selectedYearIndex = SuperGlobals.yearList.count - 1
            SuperGlobals.selectedYearId = SuperGlobals.yearList[SuperGlobals.selectedYearIndex].id
            SuperGlobals.selectedYearName = SuperGlobals.yearList[SuperGlobals.selectedYearIndex].yearName
            
        } catch {
            
            print(error)
            
        }
        
    }
    
    
    func prepareTableMonth() {
        
        do {
            
            let createTable = ConstantsSqlite.TABLE_MONTH.create(ifNotExists: true) { (table) in
                
                table.column(ConstantsSqlite.MONTH_ID, primaryKey: true)
                table.column(ConstantsSqlite.MONTH_MONTH_NAME)
                table.column(ConstantsSqlite.MONTH_YEAR_ID)
                table.column(ConstantsSqlite.MONTH_STARTING_BALANCE)
                
            }
            
            try db.run(createTable)
            
            checkIfEmptyTableMonth()
            
        } catch {
            
            print(error)
            
        }
        
    }
    
    
    func checkIfEmptyTableMonth() {
        
        do {
            
            let count = try db.scalar(ConstantsSqlite.TABLE_MONTH.count)
            
            if count <= 0 {

                for i in 0 ..< Constants.MONTH_LIST.count {

                    let month = Constants.MONTH_LIST[i]

                    let insertMonth = ConstantsSqlite.TABLE_MONTH.insert(
                        ConstantsSqlite.MONTH_MONTH_NAME <- month.monthName,
                        ConstantsSqlite.MONTH_YEAR_ID <- SuperGlobals.selectedYearId,
                        ConstantsSqlite.MONTH_STARTING_BALANCE <- month.startingBalance
                    )

                    try db.run(insertMonth)

                }
                
            }
            
        } catch {
            
            print(error)
            
        }

    }
    
    
    func queryTableMonth() {
        
        do {
                    
            SuperGlobals.monthList.removeAll()
                            
            let filteredOrderedMonths = ConstantsSqlite.TABLE_MONTH
                .join(.inner, ConstantsSqlite.TABLE_YEAR, on: ConstantsSqlite.TABLE_MONTH[ConstantsSqlite.MONTH_YEAR_ID] == ConstantsSqlite.TABLE_YEAR[ConstantsSqlite.YEAR_ID])
                .filter(ConstantsSqlite.MONTH_YEAR_ID == SuperGlobals.selectedYearId)
                .order(ConstantsSqlite.MONTH_ID)
            
            let result = try db.prepare(filteredOrderedMonths)

            for row in result {

                let id = row[ConstantsSqlite.TABLE_MONTH[ConstantsSqlite.MONTH_ID]]
                let monthName = row[ConstantsSqlite.MONTH_MONTH_NAME]
                let yearName = row[ConstantsSqlite.YEAR_YEAR_NAME]
                let startingBalance = row[ConstantsSqlite.MONTH_STARTING_BALANCE]
                
                var totalExpenses = 0.0
                
                let filteredOrderedExpenses = ConstantsSqlite.TABLE_EXPENSE
                    .filter(ConstantsSqlite.EXPENSE_MONTH_ID == id)
                
                let result = try db.prepare(filteredOrderedExpenses)
                
                for row in result {
                    
                    totalExpenses += row[ConstantsSqlite.EXPENSE_AMOUNT_ACTUAL_EXPENSE]
                    
                }
                
                let totalSavings = startingBalance - totalExpenses

                let month = Month(id: id, monthName: monthName, yearName: yearName, startingBalance: startingBalance, totalExpenses: totalExpenses, totalSavings: totalSavings)
                SuperGlobals.monthList.append(month)

            }
            
        } catch {
            
            print(error)
            
        }
        
    }
    
    
    func prepareTableExpense() {
        
        do {
            
            let createTable = ConstantsSqlite.TABLE_EXPENSE.create(ifNotExists: true) { (table) in
                
                table.column(ConstantsSqlite.EXPENSE_ID, primaryKey: true)
                table.column(ConstantsSqlite.EXPENSE_CATEGORY_ID)
                table.column(ConstantsSqlite.EXPENSE_AMOUNT_ACTUAL_EXPENSE)
                table.column(ConstantsSqlite.EXPENSE_AMOUNT_PLANNED_BUDGET)
                table.column(ConstantsSqlite.EXPENSE_MONTH_ID)
                
            }
            
            try db.run(createTable)
            
        } catch {
            
            print(error)
            
        }
        
    }
    
    
    func prepareTableCategory() {
        
        do {
            
            let createTable = ConstantsSqlite.TABLE_CATEGORY.create(ifNotExists: true) { (table) in
                
                table.column(ConstantsSqlite.CATEGORY_ID, primaryKey: true)
                table.column(ConstantsSqlite.CATEGORY_CATEGORY_NAME)
                
            }
            
            try db.run(createTable)
            
            checkIfEmptyTableCategory()
            
        } catch {
            
            print(error)
            
        }
        
    }
    
    
    func checkIfEmptyTableCategory() {
        
        do {
            
            let count = try db.scalar(ConstantsSqlite.TABLE_CATEGORY.count)
            
            if count <= 0 {

                for i in 0 ..< Constants.CATEGORY_LIST.count {

                    let category = Constants.CATEGORY_LIST[i]

                    let insertCategory = ConstantsSqlite.TABLE_CATEGORY.insert(
                        ConstantsSqlite.CATEGORY_CATEGORY_NAME <- category.categoryName
                    )

                    try db.run(insertCategory)

                }
                
            }
            
        } catch {
            
            print(error)
            
        }
        
    }
    
    
    func prepareTableBorrowEvent() {
        
        do {
            
            let createTable = ConstantsSqlite.TABLE_BORROW_EVENT.create(ifNotExists: true) { (table) in
                
                table.column(ConstantsSqlite.BORROW_EVENT_ID, primaryKey: true)
                table.column(ConstantsSqlite.BORROW_EVENT_IS_PAID)
                table.column(ConstantsSqlite.BORROW_EVENT_BORROWER_FIRST_NAME)
                table.column(ConstantsSqlite.BORROW_EVENT_BORROWER_LAST_NAME)
                table.column(ConstantsSqlite.BORROW_EVENT_BORROWER_GENDER)
                table.column(ConstantsSqlite.BORROW_EVENT_AMOUNT_PRINCIPAL)
                table.column(ConstantsSqlite.BORROW_EVENT_INTEREST_RATE)
                table.column(ConstantsSqlite.BORROW_EVENT_AMORTIZATION_SCHEDULE)
                table.column(ConstantsSqlite.BORROW_EVENT_START_YEAR)
                table.column(ConstantsSqlite.BORROW_EVENT_START_MONTH)
                table.column(ConstantsSqlite.BORROW_EVENT_START_DAY)
                table.column(ConstantsSqlite.BORROW_EVENT_START_HOUR)
                table.column(ConstantsSqlite.BORROW_EVENT_START_MINUTE)
                table.column(ConstantsSqlite.BORROW_EVENT_START_SECOND)
                
            }
            
            try db.run(createTable)
            
        } catch {
            
            print(error)
            
        }
        
    }
    
    
    func queryTableBorrowEvent() {
        
        do {
            
            SuperGlobals.borrowEventList.removeAll()
            
            let filteredOrderedBorrowEvent = ConstantsSqlite.TABLE_BORROW_EVENT
                .filter(ConstantsSqlite.BORROW_EVENT_IS_PAID == false)
                .filter(ConstantsSqlite.BORROW_EVENT_INTEREST_RATE > 0)
            
            let result = try db.prepare(filteredOrderedBorrowEvent)
            
            for row in result {
                
                let id = row[ConstantsSqlite.BORROW_EVENT_ID]
                let isPaid = row[ConstantsSqlite.BORROW_EVENT_IS_PAID]
                let borrowerFirstName = row[ConstantsSqlite.BORROW_EVENT_BORROWER_FIRST_NAME]
                let borrowerLastName = row[ConstantsSqlite.BORROW_EVENT_BORROWER_LAST_NAME]
                let borrowerGender = row[ConstantsSqlite.BORROW_EVENT_BORROWER_GENDER]
                let amountPrincipal = row[ConstantsSqlite.BORROW_EVENT_AMOUNT_PRINCIPAL]
                let interestRate = row[ConstantsSqlite.BORROW_EVENT_INTEREST_RATE]
                let amortizationSchedule = row[ConstantsSqlite.BORROW_EVENT_AMORTIZATION_SCHEDULE]
                let startYear = row[ConstantsSqlite.BORROW_EVENT_START_YEAR]
                let startMonth = row[ConstantsSqlite.BORROW_EVENT_START_MONTH]
                let startDay = row[ConstantsSqlite.BORROW_EVENT_START_DAY]
                let startHour = row[ConstantsSqlite.BORROW_EVENT_START_HOUR]
                let startMinute = row[ConstantsSqlite.BORROW_EVENT_START_MINUTE]
                let startSecond = row[ConstantsSqlite.BORROW_EVENT_START_SECOND]
                
                var amountRemaining = amountPrincipal
                var gainedFromInterest = 0.0
                
                let filteredOrderedTransactions = ConstantsSqlite.TABLE_TRANSACTION
                    .filter(ConstantsSqlite.TRANSACTION_BORROW_EVENT_ID == id)
                
                let result = try db.prepare(filteredOrderedTransactions)
                
                for row in result {
                    
                    if row[ConstantsSqlite.TRANSACTION_FROM] == "Payment" {
                        
                        if !isPaid {
                            
                            amountRemaining -= row[ConstantsSqlite.TRANSACTION_AMOUNT]
                            
                        } else {
                            
                            amountRemaining = 0.0
                            
                        }
                        
                    } else if row[ConstantsSqlite.TRANSACTION_FROM] == "Interest" {
                        
                        gainedFromInterest += row[ConstantsSqlite.TRANSACTION_AMOUNT]
                        
                    }
                    
                }
                
                let borrowEvent = BorrowEvent(id: id, isPaid: isPaid, borrowerFirstName: borrowerFirstName, borrowerLastName: borrowerLastName, borrowerGender: borrowerGender, amountPrincipal: amountPrincipal, amountRemaining: amountRemaining, interestRate: interestRate, amortizationSchedule: amortizationSchedule, gainedFromInterest: gainedFromInterest, startYear: startYear, startMonth: startMonth, startDay: startDay, startHour: startHour, startMinute: startMinute, startSecond: startSecond)
                SuperGlobals.borrowEventList.append(borrowEvent)
                
            }
            
            if defaults.object(forKey: ConstantsUserDefaults.CURRENT_DATE) == nil {
                
                defaults.set(currentDateString, forKey: ConstantsUserDefaults.CURRENT_DATE)
                
                deletePreviousInterests()
                
            } else {
                
                if defaults.string(forKey: ConstantsUserDefaults.CURRENT_DATE) != currentDateString {
                    
                    defaults.set(currentDateString, forKey: ConstantsUserDefaults.CURRENT_DATE)
                    
                    deletePreviousInterests()
                    
                }
                
            }

        } catch {

            print(error)

        }
        
    }
    
    
    func deletePreviousInterests() {
        
        do {
            
            print(SuperGlobals.borrowEventList.count) // delete this after...
            
            for i in 0 ..< SuperGlobals.borrowEventList.count {
                
                let borrowEvent = SuperGlobals.borrowEventList[i]

                let filteredOrderedTransactions = ConstantsSqlite.TABLE_TRANSACTION
                    .filter(ConstantsSqlite.TRANSACTION_BORROW_EVENT_ID == borrowEvent.id)
                    .filter(ConstantsSqlite.TRANSACTION_FROM == "Interest")

                try db.run(filteredOrderedTransactions.delete())
                
            }
            
            setNewInterests()
            
        } catch {
            
            print(error)
            
        }
        
    }
    
    
    func setNewInterests() {
        
        do {
            
            for i in 0 ..< SuperGlobals.borrowEventList.count {
                
                let borrowEvent = SuperGlobals.borrowEventList[i]
                
                let interest = borrowEvent.amountPrincipal * (borrowEvent.interestRate * 0.01)
                
                let startDate = DateComponents(calendar: calendar, year: borrowEvent.startYear, month: borrowEvent.startMonth, day: borrowEvent.startDay)
                let currentDate = DateComponents(calendar: calendar, year: currentYear, month: currentMonth, day: currentDay)
                print(startDate) // delete this after...
                print(currentDate) // delete this after...
                
                var intervalDate = Int()
                
                switch borrowEvent.amortizationSchedule {
                    
                case "Daily":
                    intervalDate = calendar.dateComponents([.day], from: startDate, to: currentDate).day == nil ? 0 : calendar.dateComponents([.day], from: startDate, to: currentDate).day!
                    
                case "Weekly":
                    intervalDate = calendar.dateComponents([.day], from: startDate, to: currentDate).day == nil ? 0 : calendar.dateComponents([.day], from: startDate, to: currentDate).day! / 7
                    
                case "Monthly":
                    intervalDate = calendar.dateComponents([.month], from: startDate, to: currentDate).month == nil ? 0 : calendar.dateComponents([.month], from: startDate, to: currentDate).month!
                    
                case "Quarterly":
                    intervalDate = calendar.dateComponents([.month], from: startDate, to: currentDate).month == nil ? 0 : calendar.dateComponents([.month], from: startDate, to: currentDate).month! / 3
                    
                case "Semiannually":
                    intervalDate = calendar.dateComponents([.month], from: startDate, to: currentDate).month == nil ? 0 : calendar.dateComponents([.month], from: startDate, to: currentDate).month! / 6
                    
                case "Annually":
                    intervalDate = calendar.dateComponents([.year], from: startDate, to: currentDate).year == nil ? 0 : calendar.dateComponents([.year], from: startDate, to: currentDate).year!
                    
                default:
                    break
                    
                }
                
                print(intervalDate) // delete this after...
                
                for i in 0 ..< intervalDate {
                    
                    var fromStartDateDate = Date()
                    
                    switch borrowEvent.amortizationSchedule {
                            
                    case "Daily":
                        fromStartDateDate = calendar.date(byAdding: .day, value: i + 1, to: startDate.date!)!
                        
                    case "Weekly":
                        fromStartDateDate = calendar.date(byAdding: .day, value: (i + 1) * 7, to: startDate.date!)!
                        
                    case "Monthly":
                        fromStartDateDate = calendar.date(byAdding: .month, value: i + 1, to: startDate.date!)!
                        
                    case "Quarterly":
                        fromStartDateDate = calendar.date(byAdding: .month, value: (i + 1) * 3, to: startDate.date!)!
                        
                    case "Semiannually":
                        fromStartDateDate = calendar.date(byAdding: .month, value: (i + 1) * 6, to: startDate.date!)!
                        
                    case "Annually":
                        fromStartDateDate = calendar.date(byAdding: .year, value: i + 1, to: startDate.date!)!
                        
                    default:
                        break
                        
                    }
                    
                    let transactionYear = calendar.component(.year, from: fromStartDateDate)
                    let transactionMonth = calendar.component(.month, from: fromStartDateDate)
                    let transactionDay = calendar.component(.day, from: fromStartDateDate)
                    let transactionHour = 0
                    let transactionMinute = 0
                    let transactionSecond = 0
                    print("\(transactionMonth) \(transactionDay), \(transactionYear)") // delete this after...

                    let insertTransaction = ConstantsSqlite.TABLE_TRANSACTION.insert(
                        ConstantsSqlite.TRANSACTION_FROM <- "Interest",
                        ConstantsSqlite.TRANSACTION_AMOUNT <- interest,
                        ConstantsSqlite.TRANSACTION_YEAR <- transactionYear,
                        ConstantsSqlite.TRANSACTION_MONTH <- transactionMonth,
                        ConstantsSqlite.TRANSACTION_DAY <- transactionDay,
                        ConstantsSqlite.TRANSACTION_HOUR <- transactionHour,
                        ConstantsSqlite.TRANSACTION_MINUTE <- transactionMinute,
                        ConstantsSqlite.TRANSACTION_SECOND <- transactionSecond,
                        ConstantsSqlite.TRANSACTION_BORROW_EVENT_ID <- borrowEvent.id
                    )
                    
                    try self.db.run(insertTransaction)
                    
                }
                
            }
            
        } catch {
            
            print(error)
            
        }
        
    }
    
    
    func prepareTableTransaction() {
        
        do {
            
            let createTable = ConstantsSqlite.TABLE_TRANSACTION.create(ifNotExists: true) { (table) in
                
                table.column(ConstantsSqlite.TRANSACTION_ID, primaryKey: true)
                table.column(ConstantsSqlite.TRANSACTION_FROM)
                table.column(ConstantsSqlite.TRANSACTION_AMOUNT)
                table.column(ConstantsSqlite.TRANSACTION_YEAR)
                table.column(ConstantsSqlite.TRANSACTION_MONTH)
                table.column(ConstantsSqlite.TRANSACTION_DAY)
                table.column(ConstantsSqlite.TRANSACTION_HOUR)
                table.column(ConstantsSqlite.TRANSACTION_MINUTE)
                table.column(ConstantsSqlite.TRANSACTION_SECOND)
                table.column(ConstantsSqlite.TRANSACTION_BORROW_EVENT_ID)
                
            }
            
            try db.run(createTable)
            
        } catch {
            
            print(error)
            
        }
        
    }
    
    
    func updateViews() {
        
        lblYear.text = SuperGlobals.selectedYearName
        
        if SuperGlobals.selectedYearIndex <= 0 {
            
            btnPreviousYearOutlet.isEnabled = false
            
        }
        
        if SuperGlobals.selectedYearIndex >= (SuperGlobals.yearList.count - 1) {
            
            btnNextYearOutlet.isEnabled = false
            
        }
        
        prepareTableView()
        
        compute()
        
    }
    
    
    func prepareTableView() {
        
        tblViewMonths.showsVerticalScrollIndicator = false
        tblViewMonths.showsHorizontalScrollIndicator = false
        tblViewMonths.separatorColor = .clear
        tblViewMonths.tableFooterView = UIView.init(frame: .zero)
        
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        self.tblViewMonths.contentInset = insets
        
        tblViewMonths.reloadData()
        
    }
    
    
    func compute() {
        
        var totalExpenses = 0.0
        var totalSavings = 0.0
        
        for i in 0 ..< SuperGlobals.monthList.count {
            
            let month = SuperGlobals.monthList[i]
            
            totalExpenses += month.totalExpenses
            totalSavings += month.totalSavings
            
        }
        
        lblTotalExpenses.text = MoneyFormatter.convertToMoneyFormat(amount: totalExpenses)
        lblTotalSavings.text = MoneyFormatter.convertToMoneyFormat(amount: totalSavings)
        
    }

    
    func stepOneYear(isForward: Bool) {
        
        if !isForward {
            
            
            
        } else {
            
            
            
        }
        
    }
    
    
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SuperGlobals.monthList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblViewMonths.dequeueReusableCell(withIdentifier: "cellMonth") as! TableViewCellMonth
        
        cell.selectionStyle = .none
        
        let month = SuperGlobals.monthList[indexPath.row]
        
        cell.setMonth(index: indexPath.row, month: month)
        
        cell.lblId.text = String(month.id)
        
        cell.lblMonthName.text = month.monthName
        cell.lblYear.text = String(month.yearName)
        cell.lblStartingBalance.text = MoneyFormatter.convertToMoneyFormat(amount: month.startingBalance)
        cell.lblExpenses.text = MoneyFormatter.convertToMoneyFormat(amount: month.totalExpenses)
        cell.lblSavings.text = MoneyFormatter.convertToMoneyFormat(amount: month.totalSavings)
        
        updatePieChartSpending(pieChartSpending: cell.pieChartSpending, totalExpenses: month.totalExpenses, totalSavings: month.totalSavings)
        
        return cell
        
    }
    
    
    func updatePieChartSpending(pieChartSpending: PieChartView, totalExpenses: Double, totalSavings: Double) {
        
        pieChartSpending.rotationAngle = 0
        pieChartSpending.holeRadiusPercent = 0.35
        pieChartSpending.holeColor = .clear
        
        if totalExpenses <= 0 && totalSavings <= 0 {

            pieChartSpending.drawHoleEnabled = true
            pieChartSpending.transparentCircleColor = .label
            pieChartSpending.transparentCircleRadiusPercent = 0.4

            pieChartSpending.isUserInteractionEnabled = false
            
        } else {

            pieChartSpending.drawHoleEnabled = false
            pieChartSpending.transparentCircleRadiusPercent = 0

            pieChartSpending.isUserInteractionEnabled = true
            
        }
        
        pieChartSpending.usePercentValuesEnabled = false
        pieChartSpending.legend.enabled = false
        pieChartSpending.legend.textColor = .label
        
        pieChartSpending.chartDescription?.enabled = false
        
        pieChartSpending.rotationEnabled = true
        
        let dataEntryTotalExpenses = PieChartDataEntry(value: totalExpenses)
        let dataEntryTotalSavings = PieChartDataEntry(value: totalSavings)
        
        let spendingDataEntries = [dataEntryTotalExpenses, dataEntryTotalSavings]
        
        let chartDataSet = PieChartDataSet(entries: spendingDataEntries, label: nil)
        chartDataSet.drawValuesEnabled = false
        
        let chartData = PieChartData(dataSet: chartDataSet)
        
        let colors = [UIColor(named: "red"), UIColor(named: "blue")]
        chartDataSet.colors = colors as! [NSUIColor]
        
        pieChartSpending.data = chartData
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        SuperGlobals.selectedMonthId = SuperGlobals.monthList[indexPath.row].id
        SuperGlobals.selectedMonthName = SuperGlobals.monthList[indexPath.row].monthName
        SuperGlobals.selectedStartingBalance = SuperGlobals.monthList[indexPath.row].startingBalance
        
        performSegue(withIdentifier: "vcToVcMonth", sender: self)
        
    }
    
    
}

