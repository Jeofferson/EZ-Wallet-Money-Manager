//
//  VcStatistics.swift
//  EZ Wallet
//
//  Created by Jeofferson Dela Peña on 3/18/20.
//  Copyright © 2020 Jeofferson Dela Peña. All rights reserved.
//

import UIKit
import SQLite
import Charts


class VcStatistics: UIViewController {
    
    
    var totalExpenses = Double()
    var totalSavings = Double()
    
    var totalAmountLent = Double()
    var gainedFromInterest = Double()
    
    var db: Connection!
    
    @IBOutlet weak var pieChartSpending: PieChartView!
    @IBOutlet weak var pieChartLending: PieChartView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareDb()
        queryTableYear()
        queryTableMonth()
        
        updateViews()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        queryTableYear()
        queryTableMonth()
        
        queryTableBorrowEvent()
        
        updateViews()
        
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
    
    
    func queryTableMonth() {
        
        do {
                    
            SuperGlobals.monthList.removeAll()
                            
            let filteredOrderedMonths = ConstantsSqlite.TABLE_MONTH
                .join(.inner, ConstantsSqlite.TABLE_YEAR, on: ConstantsSqlite.TABLE_MONTH[ConstantsSqlite.MONTH_YEAR_ID] == ConstantsSqlite.TABLE_YEAR[ConstantsSqlite.YEAR_ID])
                .filter(ConstantsSqlite.MONTH_YEAR_ID == SuperGlobals.selectedYearId)
                .order(ConstantsSqlite.MONTH_ID.desc)
            
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
    
    
    func queryTableBorrowEvent() {
        
        do {
            
            SuperGlobals.borrowEventList.removeAll()
            
            let filteredOrderedBorrowEvent = ConstantsSqlite.TABLE_BORROW_EVENT
                .order(ConstantsSqlite.BORROW_EVENT_ID.desc)
            
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

        } catch {

            print(error)

        }
        
    }
    
    
    func updateViews() {
        
        compute()
        
    }
    
    
    func compute() {
        
        totalExpenses = 0.0
        totalSavings = 0.0
        
        for i in 0 ..< SuperGlobals.monthList.count {
            
            let month = SuperGlobals.monthList[i]
            
            totalExpenses += month.totalExpenses
            totalSavings += month.totalSavings
            
        }
        
        totalAmountLent = 0.0
        gainedFromInterest = 0.0
        
        for i in 0 ..< SuperGlobals.borrowEventList.count {
            
            let borrowEvent = SuperGlobals.borrowEventList[i]
            
            totalAmountLent += borrowEvent.amountPrincipal
            gainedFromInterest += borrowEvent.gainedFromInterest
            
        }
        
        updatePieChart(pieChart: pieChartSpending, title: "Spending", value1: totalExpenses, value2: totalSavings, value1Title: "Expenses", value2Title: "Savings", value1Color: UIColor(named: "red")!, value2Color: UIColor(named: "blue")!)
        updatePieChart(pieChart: pieChartLending, title: "Lending", value1: totalAmountLent, value2: gainedFromInterest, value1Title: "Amount Lent", value2Title: "From Interest", value1Color: UIColor(named: "orange")!, value2Color: UIColor(named: "green")!)
        
    }
    
    
    func updatePieChart(pieChart: PieChartView, title: String, value1: Double, value2: Double, value1Title: String, value2Title: String, value1Color: UIColor, value2Color: UIColor) {
        
        pieChart.rotationAngle = 0
        pieChart.drawHoleEnabled = true
        pieChart.holeRadiusPercent = 0.35
        pieChart.holeColor = .clear
        
        if value1 <= 0 && value2 <= 0 {
            
            pieChart.transparentCircleColor = .label
            pieChart.transparentCircleRadiusPercent = 0.4
            
        } else {
            
            pieChart.transparentCircleRadiusPercent = 0
            
        }
        
        let attribute = [
            NSAttributedString.Key.foregroundColor: UIColor.label
        ]
        let attributeString = NSAttributedString(string: title, attributes: attribute as [NSAttributedString.Key : Any])
        pieChart.centerAttributedText = attributeString
        
        pieChart.usePercentValuesEnabled = true
        pieChart.legend.enabled = true
        pieChart.legend.textColor = .label
        
        pieChart.chartDescription?.enabled = false
        
        pieChart.rotationEnabled = true
        pieChart.isUserInteractionEnabled = true
        
        let dataEntryTotalExpenses = PieChartDataEntry(value: value1, label: value1Title)
        let dataEntryTotalSavings = PieChartDataEntry(value: value2, label: value2Title)
        
        let spendingDataEntries = [dataEntryTotalExpenses, dataEntryTotalSavings]
        
        let chartDataSet = PieChartDataSet(entries: spendingDataEntries, label: nil)
        chartDataSet.xValuePosition = .outsideSlice
        chartDataSet.yValuePosition = .outsideSlice
        chartDataSet.valueLinePart1Length = 0.5
        chartDataSet.valueLinePart2Length = 0.5
        chartDataSet.valueTextColor = .label
        chartDataSet.valueLineColor = .gray
        chartDataSet.sliceSpace = 8
        
        let chartData = PieChartData(dataSet: chartDataSet)
        
        let formatter:NumberFormatter = {
            
            let a = NumberFormatter()
            a.numberStyle = .percent
            a.maximumFractionDigits = 0
            a.multiplier = 1
            a.percentSymbol = " %"
            return a
            
        }()
        let myFormatter = DefaultValueFormatter(formatter: formatter)
        chartData.setValueFormatter(myFormatter)
        
        let colors = [value1Color, value2Color]
        chartDataSet.colors = colors
        
        pieChart.data = chartData
        
    }
    

}
