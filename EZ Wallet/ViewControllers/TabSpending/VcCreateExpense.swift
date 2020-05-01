//
//  VcCreateExpense.swift
//  EZ Wallet
//
//  Created by Jeofferson Dela Peña on 3/17/20.
//  Copyright © 2020 Jeofferson Dela Peña. All rights reserved.
//

import UIKit
import SQLite


class VcCreateExpense: UIViewController {
    
    
    var selectedMonthId = Int()
    
    var selectedCategoryId = Int()
    var selectedCategoryName = String()
    
    var db: Connection!
    
    @IBOutlet weak var btnSelectCategoryOutlet: UIButton!
    
    @IBOutlet weak var txtAmountPlannedBudget: UITextField!
    @IBOutlet weak var lblAmountPlannedBudgetErrorMessage: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedMonthId = SuperGlobals.selectedMonthId
        
        selectedCategoryId = SuperGlobals.selectedCategoryId
        selectedCategoryName = SuperGlobals.selectedCategoryName
        
        prepareDb()
        
        updateViews()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        selectedCategoryId = SuperGlobals.selectedCategoryId
        selectedCategoryName = SuperGlobals.selectedCategoryName
        
        updateViews()
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        lblAmountPlannedBudgetErrorMessage.isHidden = true
        
    }
    
    
    @IBAction func txtAmountPlannedBudgetAction(_ sender: UITextField) {
        
        amountPlannedBudgetChanged()
        
    }
    
    
    func amountPlannedBudgetChanged() {
        
        let amountPlannedBudgetString = txtAmountPlannedBudget.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if amountPlannedBudgetString.isEmpty {
            
            hideErrorMessage()
            return
            
        }
        
        guard Double(amountPlannedBudgetString) != nil else {
            
            showErrorMessage(message: "Please enter numeric characters.")
            return
            
        }
        
        hideErrorMessage()
        
    }
    
    
    @IBAction func btnCreateExpense(_ sender: UIBarButtonItem) {
        
        createExpense()
        
    }
    
    
    func createExpense() {
        
        do {
            
            let amountPlannedBudgetString = txtAmountPlannedBudget.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "0.00" : txtAmountPlannedBudget.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if selectedCategoryName.isEmpty {
                
                showErrorMessage(message: "Please choose a category.")
                return
                
            }
            
            guard var amountPlannedBudget = Double(amountPlannedBudgetString) else {
                
                showErrorMessage(message: "Please enter numeric characters.")
                return
                
            }
            
            if amountPlannedBudget <= 0 {
                
                showErrorMessage(message: "Please enter a valid amount.")
                return
                
            }
            
            hideErrorMessage()
            
            let filteredOrderedExpenses = ConstantsSqlite.TABLE_EXPENSE
                .filter(ConstantsSqlite.EXPENSE_CATEGORY_ID == selectedCategoryId && ConstantsSqlite.EXPENSE_MONTH_ID == selectedMonthId)
            
            let count = try db.scalar(filteredOrderedExpenses.count)
            
            if count > 0 {
                
                let result = try db.prepare(filteredOrderedExpenses)
                
                for row in result {
                    
                    amountPlannedBudget += row[ConstantsSqlite.EXPENSE_AMOUNT_PLANNED_BUDGET]
                    
                }
                
                try db.run(filteredOrderedExpenses.update(
                    ConstantsSqlite.EXPENSE_AMOUNT_PLANNED_BUDGET <- amountPlannedBudget
                ))
                
            } else {

                let insertExpense = ConstantsSqlite.TABLE_EXPENSE.insert(
                    ConstantsSqlite.EXPENSE_CATEGORY_ID <- selectedCategoryId,
                    ConstantsSqlite.EXPENSE_AMOUNT_ACTUAL_EXPENSE <- 0.0,
                    ConstantsSqlite.EXPENSE_AMOUNT_PLANNED_BUDGET <- amountPlannedBudget,
                    ConstantsSqlite.EXPENSE_MONTH_ID <- selectedMonthId
                )

                try db.run(insertExpense)
                
            }

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
        
        btnSelectCategoryOutlet.setTitle(selectedCategoryName.isEmpty ? "Select Category" : selectedCategoryName, for: .normal)
        
    }
    
    
    func showErrorMessage(message: String) {
        
        lblAmountPlannedBudgetErrorMessage.text = message
        lblAmountPlannedBudgetErrorMessage.isHidden = false
        
    }
    
    
    func hideErrorMessage() {
        
        lblAmountPlannedBudgetErrorMessage.isHidden = true
        
    }

    
}
