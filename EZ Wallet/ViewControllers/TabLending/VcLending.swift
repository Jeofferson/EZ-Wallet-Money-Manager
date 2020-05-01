//
//  VcLending.swift
//  EZ Wallet
//
//  Created by Jeofferson Dela Peña on 3/18/20.
//  Copyright © 2020 Jeofferson Dela Peña. All rights reserved.
//

import UIKit
import SQLite
import Charts


class VcLending: UIViewController {
    
    
    var db: Connection!
    
    @IBOutlet weak var lblTotalAmountLent: UILabel!
    @IBOutlet weak var lblTotalGainedFromInterest: UILabel!
    
    @IBOutlet weak var tblViewBorrowEvents: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareDb()
        queryTableBorrowEvent()
        
        updateViews()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
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
    
    
    func queryTableBorrowEvent() {
        
        do {
            
            SuperGlobals.borrowEventList.removeAll()
            
            let filteredOrderedBorrowEvent = ConstantsSqlite.TABLE_BORROW_EVENT
                .order(ConstantsSqlite.BORROW_EVENT_BORROWER_FIRST_NAME, ConstantsSqlite.BORROW_EVENT_BORROWER_LAST_NAME)
            
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
                        
                        if !isPaid {
                            
                            amountRemaining += row[ConstantsSqlite.TRANSACTION_AMOUNT]
                            
                        } else {
                            
                            amountRemaining = 0.0
                            
                        }
                        
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
        
        prepareTableView()
        
        compute()
        
    }
    
    
    func prepareTableView() {
        
        tblViewBorrowEvents.showsVerticalScrollIndicator = false
        tblViewBorrowEvents.showsHorizontalScrollIndicator = false
        tblViewBorrowEvents.separatorColor = .clear
        tblViewBorrowEvents.tableFooterView = UIView.init(frame: .zero)
        
        let insets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        self.tblViewBorrowEvents.contentInset = insets
        
        tblViewBorrowEvents.reloadData()
        
    }
    
    
    func compute() {
        
        var totalAmountLent = Double()
        var totalGainedFromInterest = Double()
        
        for i in 0 ..< SuperGlobals.borrowEventList.count {
            
            let borrowEvent = SuperGlobals.borrowEventList[i]
            
            totalAmountLent += borrowEvent.amountPrincipal
            totalGainedFromInterest += borrowEvent.gainedFromInterest
            
        }
        
        lblTotalAmountLent.text = MoneyFormatter.convertToMoneyFormat(amount: totalAmountLent)
        lblTotalGainedFromInterest.text = MoneyFormatter.convertToMoneyFormat(amount: totalGainedFromInterest)
        
    }
    

}


extension VcLending: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SuperGlobals.borrowEventList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblViewBorrowEvents.dequeueReusableCell(withIdentifier: "cellBorrowEvent") as! TableViewCellBorrowEvent
        
        cell.selectionStyle = .none
        
        let borrowEvent = SuperGlobals.borrowEventList[indexPath.row]
        let fullName = "\(borrowEvent.borrowerFirstName) \(borrowEvent.borrowerLastName)"
        
        let isWithInterest = borrowEvent.interestRate != 0
        
        let interestRateString = !isWithInterest ? "N/A" : "\(String(format: "%.2f", borrowEvent.interestRate))%"
        let amortizationSchedule = !isWithInterest ? "N/A" : borrowEvent.amortizationSchedule
        let gainedFromInterestString = !isWithInterest ? "N/A" : MoneyFormatter.convertToMoneyFormat(amount: borrowEvent.gainedFromInterest)
        
        cell.lblId.text = String(borrowEvent.id)
        
        cell.imgBorrowerIcon.image = borrowEvent.borrowerGender == "Male" ? UIImage(named: Constants.MALE_DEFAULT_ICON_FILENAME) : UIImage(named: Constants.FEMALE_DEFAULT_ICON_FILENAME)
        cell.lblIsPaid.text = String(borrowEvent.isPaid)
        cell.lblFullName.text = fullName
        cell.lblAmountPrincipal.text = MoneyFormatter.convertToMoneyFormat(amount: borrowEvent.amountPrincipal)
        cell.lblAmountRemaining.text = MoneyFormatter.convertToMoneyFormat(amount: borrowEvent.amountRemaining)
        cell.lblInterestRate.text = interestRateString
        cell.lblAmortizationSchedule.text = amortizationSchedule
        cell.lblGainedFromInterest.text = gainedFromInterestString
        
        if borrowEvent.amountRemaining != 0 {
            
            cell.lblAmountRemainingLabel.isHidden = false
            cell.lblAmountRemaining.isHidden = false
            
            cell.imgLblPaidBg.isHidden = true
            cell.lblPaid.isHidden = true
            
        } else {
            
            cell.lblAmountRemainingLabel.isHidden = true
            cell.lblAmountRemaining.isHidden = true
            
            cell.imgLblPaidBg.isHidden = false
            cell.lblPaid.isHidden = false
            
        }
        
        updatePieChartLending(isWithInterest: isWithInterest, pieChartLending: cell.pieChartLending, amountPrincipal: borrowEvent.amountPrincipal, gainedFromInterest: borrowEvent.gainedFromInterest)
        
        return cell
        
    }
    
    
    func updatePieChartLending(isWithInterest: Bool, pieChartLending: PieChartView, amountPrincipal: Double, gainedFromInterest: Double) {
        
        pieChartLending.rotationAngle = 0
        pieChartLending.holeRadiusPercent = 0.35
        pieChartLending.holeColor = .clear
        
        if !isWithInterest {

            pieChartLending.drawHoleEnabled = true
            pieChartLending.transparentCircleColor = .label
            pieChartLending.transparentCircleRadiusPercent = 0.4

            pieChartLending.isUserInteractionEnabled = false
            
        } else {

            pieChartLending.drawHoleEnabled = false
            pieChartLending.transparentCircleRadiusPercent = 0

            pieChartLending.isUserInteractionEnabled = true
            
        }
        
        pieChartLending.usePercentValuesEnabled = false
        pieChartLending.legend.enabled = false
        pieChartLending.legend.textColor = .label
        
        pieChartLending.chartDescription?.enabled = false
        
        pieChartLending.rotationEnabled = true
        
        let dataEntryAmountPrincipal = PieChartDataEntry(value: !isWithInterest ? 0 : amountPrincipal)
        let dataEntryGainedFromInterest = PieChartDataEntry(value: gainedFromInterest)
        
        let spendingDataEntries = [dataEntryAmountPrincipal, dataEntryGainedFromInterest]
        
        let chartDataSet = PieChartDataSet(entries: spendingDataEntries, label: nil)
        chartDataSet.drawValuesEnabled = false
        
        let chartData = PieChartData(dataSet: chartDataSet)
        
        let colors = [UIColor(named: "orange"), UIColor(named: "green")]
        chartDataSet.colors = colors as! [NSUIColor]
        
        pieChartLending.data = chartData
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let borrowEvent = SuperGlobals.borrowEventList[indexPath.row]
        
        SuperGlobals.selectedBorrowEventId = borrowEvent.id
        
        SuperGlobals.selectedIsPaid = borrowEvent.isPaid
        SuperGlobals.selectedBorrowerFirstName = borrowEvent.borrowerFirstName
        SuperGlobals.selectedBorrowerLastName = borrowEvent.borrowerLastName
        SuperGlobals.selectedBorrowerGender = borrowEvent.borrowerGender
        SuperGlobals.selectedAmountPrincipal = borrowEvent.amountPrincipal
        SuperGlobals.selectedAmountRemaining = borrowEvent.amountRemaining
        SuperGlobals.selectedInterestRate = borrowEvent.interestRate
        SuperGlobals.selectedAmortizationSchedule = borrowEvent.amortizationSchedule
        SuperGlobals.selectedGainedFromInterest = borrowEvent.gainedFromInterest
        
        performSegue(withIdentifier: "vcLendingToVcBorrower", sender: self)
        
    }
    
    
}
