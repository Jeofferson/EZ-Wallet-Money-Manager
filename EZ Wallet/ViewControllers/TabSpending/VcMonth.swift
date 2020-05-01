//
//  VcMonth.swift
//  EZ Wallet
//
//  Created by Jeofferson Dela Peña on 3/17/20.
//  Copyright © 2020 Jeofferson Dela Peña. All rights reserved.
//

import UIKit
import SQLite


class VcMonth: UIViewController {

    
    var selectedMonthId = Int()
    var selectedMonthName = String()
    var selectedStartingBalance = Double()
    
    var db: Connection!
    
    @IBOutlet weak var lblStartingBalance: UILabel!
    
    @IBOutlet weak var tblViewExpense: UITableView!
    
    @IBOutlet weak var lblPlannedExpenses: UILabel!
    @IBOutlet weak var lblPlannedSavings: UILabel!
    
    @IBOutlet weak var lblTotalExpenses: UILabel!
    @IBOutlet weak var lblTotalSavings: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedMonthId = SuperGlobals.selectedMonthId
        selectedMonthName = SuperGlobals.selectedMonthName
        selectedStartingBalance = SuperGlobals.selectedStartingBalance
        
        prepareDb()
        queryTableExpense()
        
        updateViews()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        queryTableExpense()
        
        updateViews()
        
    }
    
    
    @IBAction func btnEditStartingBalance(_ sender: Any) {
        
        editStartingBalance()
        
    }
    
    
    func editStartingBalance() {
                
        let text = selectedStartingBalance == 0 ? "" : String(selectedStartingBalance)
        
        let alertController = AlertControllerManager.generateAlertControllerWithTextField(title: "Edit Starting Balance", message: "", placeholder: "Enter new balance...", text: String(text))
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
            
            do {
                
                let txtStartingBalance = alertController.textFields![0] as UITextField
                
                let startingBalanceString = txtStartingBalance.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "0.00" : txtStartingBalance.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard let startingBalance = Double(startingBalanceString) else {
                    
                    AlertControllerManager.showAlertControllerWithDefaultButton(vc: self, title: "Error", message: "Please enter numeric characters.")
                    return
                    
                }
                
                if startingBalance <= 0 {
                    
                    AlertControllerManager.showAlertControllerWithDefaultButton(vc: self, title: "Error", message: "Please enter a valid amount.")
                    return
                    
                }
                
                let filteredOrderedMonths = ConstantsSqlite.TABLE_MONTH
                    .filter(ConstantsSqlite.MONTH_ID == self.selectedMonthId)
                    
                try self.db.run(filteredOrderedMonths.update(
                    ConstantsSqlite.MONTH_STARTING_BALANCE <- startingBalance
                ))

                SuperGlobals.selectedStartingBalance = startingBalance
                self.selectedStartingBalance = startingBalance
                
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
    
    
    func queryTableExpense() {
        
        do {
            
            SuperGlobals.expenseList.removeAll()

            let filteredOrderedExpenses = ConstantsSqlite.TABLE_EXPENSE
                .join(.inner, ConstantsSqlite.TABLE_CATEGORY, on: ConstantsSqlite.TABLE_EXPENSE[ConstantsSqlite.EXPENSE_CATEGORY_ID] == ConstantsSqlite.TABLE_CATEGORY[ConstantsSqlite.CATEGORY_ID])
                .filter(ConstantsSqlite.EXPENSE_MONTH_ID == selectedMonthId)
                .order(ConstantsSqlite.EXPENSE_ID.desc)
            
            let result = try db.prepare(filteredOrderedExpenses)
            
            for row in result {

                let id = row[ConstantsSqlite.TABLE_EXPENSE[ConstantsSqlite.EXPENSE_ID]]
                
                let categoryName = row[ConstantsSqlite.CATEGORY_CATEGORY_NAME]
                let amountActualExpense = row[ConstantsSqlite.EXPENSE_AMOUNT_ACTUAL_EXPENSE]
                let amountPlannedBudget = row[ConstantsSqlite.EXPENSE_AMOUNT_PLANNED_BUDGET]
                let monthId = row[ConstantsSqlite.EXPENSE_MONTH_ID]

                let expense = Expense(id: id, categoryName: categoryName, amountPlannedBudget: amountPlannedBudget, amountActualExpense: amountActualExpense, monthId: monthId)
                
                SuperGlobals.expenseList.append(expense)
                
            }
            
        } catch {
            
            print(error)
            
        }
        
    }
    
    
    func updateViews() {
        
        self.title = selectedMonthName
        
        prepareTableView()
        
        compute()
        
    }
    
    
    func prepareTableView() {
        
        tblViewExpense.showsVerticalScrollIndicator = false
        tblViewExpense.showsHorizontalScrollIndicator = false
        tblViewExpense.separatorColor = .clear
        tblViewExpense.tableFooterView = UIView.init(frame: .zero)
        
        let insets = UIEdgeInsets(top: 5, left: 0, bottom: 35, right: 0)
        self.tblViewExpense.contentInset = insets
        
        tblViewExpense.reloadData()
        
    }
    
    
    func compute() {
        
        lblStartingBalance.text = MoneyFormatter.convertToMoneyFormat(amount: SuperGlobals.selectedStartingBalance)
        
        var plannedExpenses = 0.0
        var totalExpenses = 0.0
        
        for i in 0 ..< SuperGlobals.expenseList.count {
            
            let expense  = SuperGlobals.expenseList[i]
            
            plannedExpenses += expense.amountPlannedBudget
            totalExpenses += expense.amountActualExpense
            
        }
        
        let plannedSavings = selectedStartingBalance - plannedExpenses
        let totalSavings = selectedStartingBalance - totalExpenses
        
        lblPlannedExpenses.text = MoneyFormatter.convertToMoneyFormat(amount: plannedExpenses)
        lblPlannedSavings.text = MoneyFormatter.convertToMoneyFormat(amount: plannedSavings)
        
        lblTotalExpenses.text = MoneyFormatter.convertToMoneyFormat(amount: totalExpenses)
        lblTotalSavings.text = MoneyFormatter.convertToMoneyFormat(amount: totalSavings)
        
    }
    

}


extension VcMonth: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SuperGlobals.expenseList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblViewExpense.dequeueReusableCell(withIdentifier: "cellExpense") as! TableViewCellExpense
        
        cell.selectionStyle = .none
        
        let expense = SuperGlobals.expenseList[indexPath.row]
        
        cell.lblId.text = String(expense.id)
        
        cell.lblCategoryName.text = expense.categoryName
        cell.lblAmountActualExpense.text = MoneyFormatter.convertToMoneyFormat(amount: expense.amountActualExpense)
        cell.lblAmountPlannedBudget.text = MoneyFormatter.convertToMoneyFormat(amount: expense.amountPlannedBudget)
        cell.lblMonthId.text = String(expense.monthId)
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            
        let edit = editAction(at: indexPath)
        let delete = deleteAction(at: indexPath)
        
        return UISwipeActionsConfiguration(actions: [delete, edit])
        
    }
    
    
    func editAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .normal, title: "Edit", handler: { (action, view, completion) in
            
            self.editExpense(at: indexPath)
            
            completion(true)
        })
        
        action.image = UIImage(named: "edit")
        
        return action
        
    }
    
    
    func editExpense(at indexPath: IndexPath) {
        
        let expense = SuperGlobals.expenseList[indexPath.row]
        
        SuperGlobals.selectedExpenseId = expense.id

        SuperGlobals.selectedExpenseCategoryName = expense.categoryName
        SuperGlobals.selectedAmountPlannedBudget = expense.amountPlannedBudget
        SuperGlobals.selectedAmountActualExpense = expense.amountActualExpense

        performSegue(withIdentifier: "vcMonthToVcEditExpense", sender: self)
        
    }
    
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, completion) in
            
            self.deleteExpense(at: indexPath)
            
            completion(true)
        })
        
        action.image = UIImage(named: "delete")
        
        return action
        
    }
    
    
    func deleteExpense(at indexPath: IndexPath) {
        
        do {
            
            let expense = SuperGlobals.expenseList[indexPath.row]
            
            let filteredOrderedExpenses = ConstantsSqlite.TABLE_EXPENSE
                .filter(ConstantsSqlite.EXPENSE_ID == expense.id)

            try self.db.run(filteredOrderedExpenses.delete())

            self.queryTableExpense()
            self.updateViews()
            
        } catch {
            
            print(error)
            
        }
        
    }
    
    
}
