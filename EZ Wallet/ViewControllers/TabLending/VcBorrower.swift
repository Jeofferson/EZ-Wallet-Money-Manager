//
//  VcBorrower.swift
//  EZ Wallet
//
//  Created by Jeofferson Dela Peña on 3/23/20.
//  Copyright © 2020 Jeofferson Dela Peña. All rights reserved.
//

import UIKit
import SQLite


class VcBorrower: UIViewController {
    
    
    var currentYear = Int()
    var currentMonth = Int()
    var currentDay = Int()
    var currentHour = Int()
    var currentMinute = Int()
    var currentSecond = Int()
    
    var id = Int()
    
    var isPaid = Bool()
    var borrowerFirstName = String()
    var borrowerLastName = String()
    var borrowerFirstNameLastInitial = String()
    var borrowerGender = String()
    var amountPrincipal = Double()
    var amountRemaining = Double()
    var interestRateString = String()
    var amortizationSchedule = String()
    var gainedFromInterestString = String()
    
    var db: Connection!
    
    @IBOutlet weak var lblId: UILabel!
    
    @IBOutlet weak var imgBorrowerIcon: UIImageView!
    @IBOutlet weak var lblAmountPrincipal: UILabel!
    @IBOutlet weak var lblAmountRemaining: UILabel!
    @IBOutlet weak var lblInterestRate: UILabel!
    @IBOutlet weak var lblAmortizationSchedule: UILabel!
    @IBOutlet weak var lblGainedFromInterest: UILabel!
    
    @IBOutlet weak var btnEditBorrowEventOutlet: UIButton!
    
    @IBOutlet weak var tblViewTransactions: UITableView!
    
    @IBOutlet weak var btnYouGotOutlet: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let date = Date()
        let calendar = Calendar.current
        
        currentYear = calendar.component(.year, from: date)
        currentMonth = calendar.component(.month, from: date)
        currentDay = calendar.component(.day, from: date)
        currentHour = calendar.component(.hour, from: date)
        currentMinute = calendar.component(.minute, from: date)
        currentSecond = calendar.component(.second, from: date)
        
        id = SuperGlobals.selectedBorrowEventId
        
        isPaid = SuperGlobals.selectedIsPaid
        borrowerFirstName = SuperGlobals.selectedBorrowerFirstName
        borrowerLastName = SuperGlobals.selectedBorrowerLastName
        borrowerFirstNameLastInitial = "\(borrowerFirstName) \(Array(borrowerLastName)[0])."
        
        borrowerGender = SuperGlobals.selectedBorrowerGender
        amountPrincipal = SuperGlobals.selectedAmountPrincipal
        amountRemaining = SuperGlobals.selectedAmountRemaining
        
        let isWithInterest = SuperGlobals.selectedInterestRate != 0
        
        interestRateString = !isWithInterest ? "N/A" : "\(String(format: "%.2f", SuperGlobals.selectedInterestRate))%"
        amortizationSchedule = !isWithInterest ? "N/A" : SuperGlobals.selectedAmortizationSchedule
        gainedFromInterestString = !isWithInterest ? "N/A" : MoneyFormatter.convertToMoneyFormat(amount: SuperGlobals.selectedGainedFromInterest)
        
        prepareDb()
        queryTableTransaction()
        
        updateViews()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        id = SuperGlobals.selectedBorrowEventId
        
        borrowerFirstName = SuperGlobals.selectedBorrowerFirstName
        borrowerLastName = SuperGlobals.selectedBorrowerLastName
        borrowerFirstNameLastInitial = "\(borrowerFirstName) \(Array(borrowerLastName)[0])."
        
        borrowerGender = SuperGlobals.selectedBorrowerGender
        amountPrincipal = SuperGlobals.selectedAmountPrincipal
        amountRemaining = SuperGlobals.selectedAmountRemaining
        
        let isWithInterest = SuperGlobals.selectedInterestRate != 0
        
        interestRateString = !isWithInterest ? "N/A" : "\(String(format: "%.2f", SuperGlobals.selectedInterestRate))%"
        amortizationSchedule = !isWithInterest ? "N/A" : SuperGlobals.selectedAmortizationSchedule
        gainedFromInterestString = !isWithInterest ? "N/A" : MoneyFormatter.convertToMoneyFormat(amount: SuperGlobals.selectedGainedFromInterest)
        
        queryTableTransaction()
        
        updateViews()
        
    }
    
    
    @IBAction func btnDeleteBorrowEvent(_ sender: UIButton) {
        
        deleteBorrowEvent()
        
    }
    
    
    func deleteBorrowEvent() {
            
        let alertController = AlertControllerManager.generateAlertController(title: "Delete the whole transaction?", message: "You cannot undo this action.")
        
        let deleteButton = UIAlertAction(title: "Delete", style: .destructive) { (UIAlertAction) in
            
            do {
                
                let filteredOrderedTransactions = ConstantsSqlite.TABLE_TRANSACTION
                    .filter(ConstantsSqlite.TRANSACTION_BORROW_EVENT_ID == self.id)
                    
                try self.db.run(filteredOrderedTransactions.delete())
                
                let filteredOrderedBorrowEvents = ConstantsSqlite.TABLE_BORROW_EVENT
                    .filter(ConstantsSqlite.BORROW_EVENT_ID == self.id)
                
                try self.db.run(filteredOrderedBorrowEvents.delete())

                self.navigationController?.popViewController(animated: true)
                
            } catch {
                
                print(error)
                
            }
            
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(deleteButton)
        alertController.addAction(cancelButton)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    @IBAction func btnYouGot(_ sender: UIButton) {
        
        youGot()
        
    }
    
    
    func youGot() {
        
        let alertController = AlertControllerManager.generateAlertControllerWithTextField(title: "Payment", message: "", placeholder: "Amount...", text: "")
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
            
            do {
                
                let txtAmount = alertController.textFields![0] as UITextField
                
                let amountString = txtAmount.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "0.00" : txtAmount.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard let amount = Double(amountString) else {
                    
                    AlertControllerManager.showAlertControllerWithDefaultButton(vc: self, title: "Error", message: "Please enter numeric characters.")
                    return
                    
                }
                
                if amount <= 0 {
                    
                    AlertControllerManager.showAlertControllerWithDefaultButton(vc: self, title: "Error", message: "Please enter a valid amount.")
                    return
                    
                }

                let insertTransaction = ConstantsSqlite.TABLE_TRANSACTION.insert(
                    ConstantsSqlite.TRANSACTION_FROM <- "Payment",
                    ConstantsSqlite.TRANSACTION_AMOUNT <- amount,
                    ConstantsSqlite.TRANSACTION_YEAR <- self.currentYear,
                    ConstantsSqlite.TRANSACTION_MONTH <- self.currentMonth,
                    ConstantsSqlite.TRANSACTION_DAY <- self.currentDay,
                    ConstantsSqlite.TRANSACTION_HOUR <- self.currentHour,
                    ConstantsSqlite.TRANSACTION_MINUTE <- self.currentMinute,
                    ConstantsSqlite.TRANSACTION_SECOND <- self.currentSecond,
                    ConstantsSqlite.TRANSACTION_BORROW_EVENT_ID <- self.id
                )
                
                try self.db.run(insertTransaction)
                
                if amount >= self.amountRemaining {
                    
                    let filteredOrderedBorrowedEvents = ConstantsSqlite.TABLE_BORROW_EVENT
                        .filter(ConstantsSqlite.BORROW_EVENT_ID == self.id)
                        
                    try self.db.run(filteredOrderedBorrowedEvents.update(
                        ConstantsSqlite.BORROW_EVENT_IS_PAID <- true
                    ))
                    
                    SuperGlobals.selectedIsPaid = true
                    SuperGlobals.selectedAmountRemaining = 0.0
                    
                    self.isPaid = true
                    self.amountRemaining = 0.0
                    
                }

                self.queryTableTransaction()
                self.updateViews()
                
            } catch {
                
                print(error)
                
            }
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action : UIAlertAction!) -> Void in })

        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
        
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
    
    
    func queryTableTransaction() {
        
        do {
                    
            SuperGlobals.transactionList.removeAll()
            
            let filteredOrderedTransactions = ConstantsSqlite.TABLE_TRANSACTION
                .filter(ConstantsSqlite.TRANSACTION_BORROW_EVENT_ID == id)
                .order(ConstantsSqlite.TRANSACTION_YEAR.desc, ConstantsSqlite.TRANSACTION_MONTH.desc, ConstantsSqlite.TRANSACTION_DAY.desc, ConstantsSqlite.TRANSACTION_HOUR.desc, ConstantsSqlite.TRANSACTION_MINUTE.desc, ConstantsSqlite.TRANSACTION_SECOND.desc, ConstantsSqlite.TRANSACTION_ID.desc)
            
            let result = try db.prepare(filteredOrderedTransactions)

            for row in result {

                let id = row[ConstantsSqlite.TRANSACTION_ID]
                
                let from = row[ConstantsSqlite.TRANSACTION_FROM]
                let amount = row[ConstantsSqlite.TRANSACTION_AMOUNT]
                let year = row[ConstantsSqlite.TRANSACTION_YEAR]
                let month = row[ConstantsSqlite.TRANSACTION_MONTH]
                let day = row[ConstantsSqlite.TRANSACTION_DAY]
                let hour = row[ConstantsSqlite.TRANSACTION_HOUR]
                let minute = row[ConstantsSqlite.TRANSACTION_MINUTE]
                let second = row[ConstantsSqlite.TRANSACTION_SECOND]
                let borrowEventId = row[ConstantsSqlite.TRANSACTION_BORROW_EVENT_ID]

                let transaction = Transaction(id: id, from: from, amount: amount, year: year, month: month, day: day, hour: hour, minute: minute, second: second, borrowEventId: borrowEventId)
                SuperGlobals.transactionList.append(transaction)

            }
            
        } catch {
            
            print(error)
            
        }
        
    }
    
    
    func updateViews() {
        
        self.title = borrowerFirstNameLastInitial
        
        lblId.text = String(id)
        
        imgBorrowerIcon.image = borrowerGender == "Male" ? UIImage(named: Constants.MALE_DEFAULT_ICON_FILENAME) : UIImage(named: Constants.FEMALE_DEFAULT_ICON_FILENAME)
        
        lblAmountPrincipal.text = MoneyFormatter.convertToMoneyFormat(amount: amountPrincipal)
        lblAmountRemaining.text = MoneyFormatter.convertToMoneyFormat(amount: amountRemaining)
        lblInterestRate.text = interestRateString
        lblAmortizationSchedule.text = amortizationSchedule
        lblGainedFromInterest.text = gainedFromInterestString
        
        if !isPaid {
            
            btnEditBorrowEventOutlet.isEnabled = true
            
            btnYouGotOutlet.setTitle("Payment", for: .normal)
            btnYouGotOutlet.isEnabled = true
            
        } else {
            
            btnEditBorrowEventOutlet.isEnabled = false
            
            btnYouGotOutlet.setTitle("PAID", for: .normal)
            btnYouGotOutlet.isEnabled = false
            
        }
        
        prepareTableView()
        
        compute()
        
    }
    
    
    func prepareTableView() {
        
        tblViewTransactions.showsVerticalScrollIndicator = false
        tblViewTransactions.showsHorizontalScrollIndicator = false
        tblViewTransactions.separatorColor = .clear
        tblViewTransactions.tableFooterView = UIView.init(frame: .zero)
        
        let insets = UIEdgeInsets(top: 2.5, left: 0, bottom: 2.5, right: 0)
        self.tblViewTransactions.contentInset = insets
        
        tblViewTransactions.reloadData()
        
    }
    
    
    func compute() {
        
        var amountRemaining = amountPrincipal
        
        for i in 0 ..< SuperGlobals.transactionList.count {
            
            let transaction = SuperGlobals.transactionList[i]
            
            if transaction.from == "Payment" {
                
                if !isPaid {
                    
                    amountRemaining -= transaction.amount
                    
                } else {
                    
                    amountRemaining = 0.0
                    
                }
                
            } else if transaction.from == "Interest" {
                
                if !isPaid {
                    
                    amountRemaining += transaction.amount
                    
                } else {
                    
                    amountRemaining = 0.0
                    
                }
                
            }
            
        }
        
        lblAmountRemaining.text = MoneyFormatter.convertToMoneyFormat(amount: amountRemaining)
        
    }
    
    
}


extension VcBorrower: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        SuperGlobals.transactionList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblViewTransactions.dequeueReusableCell(withIdentifier: "cellTransaction") as! TableViewCellTransaction
        
        cell.selectionStyle = .none
        
        let transaction = SuperGlobals.transactionList[indexPath.row]
        
        let date = "\(Constants.MONTHS_OF_THE_YEAR[transaction.month]![0]) \(String(format: "%02d", transaction.day)), \(transaction.year)"
        let time = "\(String(format: "%02d", transaction.hour)):\(String(format: "%02d", transaction.minute))"
        
        cell.lblId.text = String(transaction.id)
        
        cell.lblFrom.text = transaction.from
        cell.lblAmountFromPayment.text = MoneyFormatter.convertToMoneyFormat(amount: transaction.amount)
        cell.lblAmountFromInterest.text = MoneyFormatter.convertToMoneyFormat(amount: transaction.amount)
        cell.lblDate.text = date
        cell.lblTime.text = time
        cell.lblBorrowEventId.text = String(transaction.borrowEventId)
        
        if transaction.from == "Payment" {
            
            cell.lblAmountFromPayment.isHidden = false
            cell.lblAmountFromInterest.isHidden = true
            
        } else if transaction.from == "Interest" {
            
            cell.lblAmountFromPayment.isHidden = true
            cell.lblAmountFromInterest.isHidden = false
            
        }
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if !isPaid {
            
            let edit = editAction(at: indexPath)
            let delete = deleteAction(at: indexPath)

            let transaction = SuperGlobals.transactionList[indexPath.row]
            
            if transaction.from == "Payment" {
                
                return UISwipeActionsConfiguration(actions: [delete, edit])
                
            } else if transaction.from == "Interest" {
                
                return UISwipeActionsConfiguration(actions: [])
                
            } else {
                
                return UISwipeActionsConfiguration(actions: [])
                
            }
            
        } else {
            
            return UISwipeActionsConfiguration(actions: [])
            
        }
        
    }
    
    
    func editAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .normal, title: "Edit", handler: { (action, view, completion) in
            
            self.editTransaction(at: indexPath)
            
            completion(true)
        })
        
        action.image =  UIImage(named: "edit")
        
        return action
        
    }
    
    
    func editTransaction(at indexPath: IndexPath) {
        
        let transaction = SuperGlobals.transactionList[indexPath.row]
        let originalAmount = transaction.amount
        
        let alertController = AlertControllerManager.generateAlertControllerWithTextField(title: "Edit Payment", message: "", placeholder: "Amount...", text: String(transaction.amount))
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
            
            do {
                
                let txtAmount = alertController.textFields![0] as UITextField
                
                let amountString = txtAmount.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "0.00" : txtAmount.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard let amount = Double(amountString) else {
                    
                    AlertControllerManager.showAlertControllerWithDefaultButton(vc: self, title: "Error", message: "Please enter numeric characters.")
                    return
                    
                }
                
                if amount <= 0 {
                    
                    AlertControllerManager.showAlertControllerWithDefaultButton(vc: self, title: "Error", message: "Please enter a valid amount.")
                    return
                    
                }
                
                let filteredOrderedTransactions = ConstantsSqlite.TABLE_TRANSACTION
                    .filter(ConstantsSqlite.TRANSACTION_ID == transaction.id)

                try self.db.run(filteredOrderedTransactions.update(
                    ConstantsSqlite.TRANSACTION_AMOUNT <- amount
                ))
                
                // Since you are updating the amount, the initial amount's contribution to the amount remaining should be cleared first. That's why we are subtracting it from the amount remaining. This should only be done when you are "updating".
                if amount >= (self.amountRemaining - originalAmount) {
                    
                    let filteredOrderedBorrowedEvents = ConstantsSqlite.TABLE_BORROW_EVENT
                        .filter(ConstantsSqlite.BORROW_EVENT_ID == self.id)
                        
                    try self.db.run(filteredOrderedBorrowedEvents.update(
                        ConstantsSqlite.BORROW_EVENT_IS_PAID <- true
                    ))
                    
                    SuperGlobals.selectedIsPaid = true
                    SuperGlobals.selectedAmountRemaining = 0.0
                    
                    self.isPaid = true
                    self.amountRemaining = 0.0
                    
                }

                self.queryTableTransaction()
                self.updateViews()
                
            } catch {
                
                print(error)
                
            }
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action : UIAlertAction!) -> Void in })

        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, completion) in
            
            self.deleteTransaction(at: indexPath)
            
            completion(true)
        })
        
        action.image = UIImage(named: "delete")
        
        return action
        
    }
    
    
    func deleteTransaction(at indexPath: IndexPath) {
        
        do {
            
            let transaction = SuperGlobals.transactionList[indexPath.row]
            
            let filteredOrderedTransactions = ConstantsSqlite.TABLE_TRANSACTION
                .filter(ConstantsSqlite.TRANSACTION_ID == transaction.id)
            
            try db.run(filteredOrderedTransactions.delete())
            
            queryTableTransaction()
            updateViews()
            
        } catch {
            
            print(error)
            
        }
        
    }
    
    
}
