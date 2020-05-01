//
//  VcEditExpense.swift
//  EZ Wallet
//
//  Created by Jeofferson Dela Peña on 3/18/20.
//  Copyright © 2020 Jeofferson Dela Peña. All rights reserved.
//

import UIKit
import SQLite


class VcEditExpense: UIViewController {
    
    
    var selectedExpenseId = Int()
    
    var selectedExpenseCategoryName = String()
    var selectedAmountPlannedBudget = Double()
    var selectedAmountActualExpense = Double()
    
    var db: Connection!
    
    @IBOutlet weak var lblCategoryName: UILabel!
    
    @IBOutlet weak var txtAmountPlannedBudget: UITextField!
    @IBOutlet weak var txtAmountActualExpense: UITextField!
    @IBOutlet weak var lblErrorMessage: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedExpenseId = SuperGlobals.selectedExpenseId
        selectedExpenseCategoryName = SuperGlobals.selectedExpenseCategoryName
        selectedAmountPlannedBudget = SuperGlobals.selectedAmountPlannedBudget
        selectedAmountActualExpense = SuperGlobals.selectedAmountActualExpense
        
        prepareDb()
        
        updateViews()
        
    }
    
    
    @IBAction func amountPlannedBudgetAction(_ sender: UITextField) {
        
        amountChanged()
        
    }
    
    
    @IBAction func amountActualExpenseAction(_ sender: UITextField) {
        
        amountChanged()
        
    }
    
    
    func amountChanged() {
        
        let amountPlannedBudgetString = txtAmountPlannedBudget.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "0.00" : txtAmountPlannedBudget.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let amountActualExpenseString = txtAmountActualExpense.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "0.00" : txtAmountActualExpense.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if amountPlannedBudgetString.isEmpty {
            
            if !checkIsConvertibleToDouble(amount: amountActualExpenseString) { return }
            
            hideErrorMessage()
            return
            
        }
        
        if amountActualExpenseString.isEmpty {
            
            if !checkIsConvertibleToDouble(amount: amountPlannedBudgetString) { return }
            
            hideErrorMessage()
            return
            
        }
        
        if !checkIsConvertibleToDouble(amount: amountPlannedBudgetString) { return }
        
        if !checkIsConvertibleToDouble(amount: amountActualExpenseString) { return }
        
        hideErrorMessage()
        
    }
    
    
    func checkIsConvertibleToDouble(amount: String) -> Bool {
        
        guard Double(amount) != nil else {
            
            showErrorMessage(message: "Please enter numeric characters.")
            return false
            
        }
        
        return true
        
    }
    
    
    @IBAction func btnEditExpense(_ sender: UIBarButtonItem) {
        
        editExpense()
        
    }
    
    
    func editExpense() {
        
        do {
            
            let amountPlannedBudgetString = txtAmountPlannedBudget.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "0.00" : txtAmountPlannedBudget.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let amountActualExpenseString = txtAmountActualExpense.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "0.00" : txtAmountActualExpense.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard let amountPlannedBudget = Double(amountPlannedBudgetString) else {
                
                showErrorMessage(message: "Please enter numeric characters.")
                return
                
            }
            
            guard let amountActualExpense = Double(amountActualExpenseString) else {
                
                showErrorMessage(message: "Please enter numeric characters.")
                return
                
            }
            
            if amountPlannedBudget <= 0 {
                
                showErrorMessage(message: "Planned budget cannot be empty or zero.")
                return
                
            }
            
            if amountActualExpense < 0 {
                
                showErrorMessage(message: "Please enter a valid amount.")
                return
                
            }
            
            hideErrorMessage()
            
            let filteredOrderedExpenses = ConstantsSqlite.TABLE_EXPENSE
                .filter(ConstantsSqlite.EXPENSE_ID == selectedExpenseId)
            
            try db.run(filteredOrderedExpenses.update(
                ConstantsSqlite.EXPENSE_AMOUNT_PLANNED_BUDGET <- amountPlannedBudget,
                ConstantsSqlite.EXPENSE_AMOUNT_ACTUAL_EXPENSE <- amountActualExpense
            ))

            navigationController?.popViewController(animated: true)
            
        } catch {
            
            print(error)
            
        }
        
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
    
    
    func updateViews() {
        
        lblCategoryName.text = selectedExpenseCategoryName
        txtAmountPlannedBudget.text = selectedAmountPlannedBudget == 0 ? "" : String(selectedAmountPlannedBudget)
        txtAmountActualExpense.text = selectedAmountActualExpense == 0 ? "" : String(selectedAmountActualExpense)
        
    }
    
    
    func showErrorMessage(message: String) {
        
        lblErrorMessage.text = message
        lblErrorMessage.isHidden = false
        
    }
    
    
    func hideErrorMessage() {
        
        lblErrorMessage.isHidden = true
        
    }
    
    
}
