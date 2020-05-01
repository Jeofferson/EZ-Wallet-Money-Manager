//
//  VcCategories.swift
//  EZ Wallet
//
//  Created by Jeofferson Dela Peña on 3/17/20.
//  Copyright © 2020 Jeofferson Dela Peña. All rights reserved.
//

import UIKit
import SQLite


class VcCategories: UIViewController {
    
    
    var db: Connection!
    
    @IBOutlet weak var tblViewCategories: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareDb()
        queryTableCategory()
        
        updateViews()
        
    }
    
    
    @IBAction func btnCreateCategory(_ sender: UIBarButtonItem) {
        
        createCategory()
        
    }
    
    
    func createCategory() {
        
        let alertController = AlertControllerManager.generateAlertControllerWithTextField(title: "New Category", message: "", placeholder: "Enter new category...", text: "")
        
        let addButton = UIAlertAction(title: "Add", style: .default, handler: { (UIAlertAction) in
            
            do {
                
                let txtCategoryName = alertController.textFields![0] as UITextField
                let categoryName = txtCategoryName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if categoryName.isEmpty {
                    
                    AlertControllerManager.showAlertControllerWithDefaultButton(vc: self, title: "Error", message: "Category cannot be empty.")
                    return
                    
                }
                
                let filteredOrderedCategories = ConstantsSqlite.TABLE_CATEGORY
                    .filter(ConstantsSqlite.CATEGORY_CATEGORY_NAME.lowercaseString == categoryName.lowercased())
                
                let count = try self.db.scalar(filteredOrderedCategories.count)
                
                if count > 0 {
                    
                    AlertControllerManager.showAlertControllerWithDefaultButton(vc: self, title: "Already Exists", message: "You entered an already existing category.")
                    
                } else {

                    let insertCategory = ConstantsSqlite.TABLE_CATEGORY.insert(
                        ConstantsSqlite.CATEGORY_CATEGORY_NAME <- categoryName
                    )

                    try self.db.run(insertCategory)
                    
                    self.queryTableCategory()
                    self.updateViews()
                    
                }
                
            } catch {
                
                print(error)
                
            }
            
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(addButton)
        alertController.addAction(cancelButton)

        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    @IBAction func btnRestoreDefaultCategories(_ sender: UIButton) {
        
        restoreDefaultCategories()
        
    }
    
    
    func restoreDefaultCategories() {
        
        let alertController = AlertControllerManager.generateAlertController(title: "Restore Defaults?", message: "This will bring back the original categories. Categories that you've created will not be lost.")
        
        let okButton = UIAlertAction(title: "Restore", style: .default) { (UIAlertAction) in
            
            do {
                
                SuperGlobals.categoryList = Constants.CATEGORY_LIST

                for i in 0 ..< Constants.CATEGORY_LIST.count {

                    let category = Constants.CATEGORY_LIST[i]
                    
                    let filteredOrderedCategories = ConstantsSqlite.TABLE_CATEGORY
                        .filter(ConstantsSqlite.CATEGORY_CATEGORY_NAME.lowercaseString == category.categoryName.lowercased())
                    
                    let count = try self.db.scalar(filteredOrderedCategories.count)
                    
                    if count <= 0 {

                        let insertCategory = ConstantsSqlite.TABLE_CATEGORY.insert(
                            ConstantsSqlite.CATEGORY_CATEGORY_NAME <- category.categoryName
                        )

                        try self.db.run(insertCategory)
                        
                    }

                }
                
                self.clearSelectedCategory()
                self.queryTableCategory()
                self.updateViews()
                
            } catch {
                
                print(error)
                
            }
            
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(okButton)
        alertController.addAction(cancelButton)
        
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
    
    
    func queryTableCategory() {
        
        do {
                    
            SuperGlobals.categoryList.removeAll()
            
            let filteredOrderedCategories = ConstantsSqlite.TABLE_CATEGORY
                .order(ConstantsSqlite.CATEGORY_CATEGORY_NAME.lowercaseString)
            
            let result = try db.prepare(filteredOrderedCategories)

            for row in result {

                let id = row[ConstantsSqlite.CATEGORY_ID]
                let categoryName = row[ConstantsSqlite.CATEGORY_CATEGORY_NAME]

                let category = Category(id: id, categoryName: categoryName)
                SuperGlobals.categoryList.append(category)

            }
            
        } catch {
            
            print(error)
            
        }
        
    }
    
    
    func updateViews() {
        
        prepareTableView()
        
    }
    
    
    func prepareTableView() {
        
        tblViewCategories.showsVerticalScrollIndicator = false
        tblViewCategories.showsHorizontalScrollIndicator = false
        tblViewCategories.separatorColor = .clear
        tblViewCategories.tableFooterView = UIView.init(frame: .zero)
        
        let insets = UIEdgeInsets(top: 2.5, left: 0, bottom: 2.5, right: 0)
        self.tblViewCategories.contentInset = insets
        
        tblViewCategories.reloadData()
        
    }
    
    
    func clearSelectedCategory() {
        
        SuperGlobals.selectedCategoryId = 0
        SuperGlobals.selectedCategoryName = ""
        
    }
    

}


extension VcCategories: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SuperGlobals.categoryList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblViewCategories.dequeueReusableCell(withIdentifier: "cellCategory") as! TableViewCellCategory
        
        let category = SuperGlobals.categoryList[indexPath.row]
        
        cell.lblId.text = String(category.id)
        
        cell.lblCategoryName.text = category.categoryName
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            
        let edit = editAction(at: indexPath)
        let delete = deleteAction(at: indexPath)
        
        return UISwipeActionsConfiguration(actions: [delete, edit])
        
    }
    
    
    func editAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .normal, title: "Edit", handler: { (action, view, completion) in
            
            self.editCategory(at: indexPath)
            
            completion(true)
        })
        
        action.image = UIImage(named: "edit")
        
        return action
        
    }
    
    
    func editCategory(at indexPath: IndexPath) {
        
        let category = SuperGlobals.categoryList[indexPath.row]

        let alertController = AlertControllerManager.generateAlertControllerWithTextField(title: "Edit Category", message: "", placeholder: "Enter new category...", text: category.categoryName)

        let editButton = UIAlertAction(title: "Edit", style: .default, handler: { (UIAlertAction) in

            do {

                let txtCategoryName = alertController.textFields![0] as UITextField
                let categoryName = txtCategoryName.text!.trimmingCharacters(in: .whitespacesAndNewlines)

                if categoryName.isEmpty {

                    AlertControllerManager.showAlertControllerWithDefaultButton(vc: self, title: "Error", message: "Category cannot be empty.")
                    return

                }

                let filteredCategories = ConstantsSqlite.TABLE_CATEGORY
                    .filter(ConstantsSqlite.CATEGORY_CATEGORY_NAME.lowercaseString == categoryName.lowercased())

                let count = try self.db.scalar(filteredCategories.count)

                if count > 0 {

                    AlertControllerManager.showAlertControllerWithDefaultButton(vc: self, title: "Already Exists", message: "You entered an already existing category.")

                } else {

                    let filteredOrderedCategories = ConstantsSqlite.TABLE_CATEGORY
                        .filter(ConstantsSqlite.CATEGORY_ID == category.id)

                    try self.db.run(filteredOrderedCategories.update(
                        ConstantsSqlite.CATEGORY_CATEGORY_NAME <- categoryName
                    ))

                    self.clearSelectedCategory()
                    self.queryTableCategory()
                    self.updateViews()

                }

            } catch {

                print(error)

            }

        })

        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(editButton)
        alertController.addAction(cancelButton)

        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, completion) in
            
            self.deleteCategory(at: indexPath)
            
            completion(true)
        })
        
        action.image = UIImage(named: "delete")
        
        return action
        
    }
    
    
    func deleteCategory(at indexPath: IndexPath) {
        
        do {
            
            let category = SuperGlobals.categoryList[indexPath.row]

            let filteredOrderedExpenses = ConstantsSqlite.TABLE_EXPENSE
                .filter(ConstantsSqlite.EXPENSE_CATEGORY_ID == category.id)

            let count = try db.scalar(filteredOrderedExpenses.count)

            if count > 0 {

                AlertControllerManager.showAlertControllerWithDefaultButton(vc: self, title: "Error", message: "This category is being used by one of the expenses. Please delete the expense first.")

            } else {

                let filteredOrderedCategories = ConstantsSqlite.TABLE_CATEGORY
                    .filter(ConstantsSqlite.CATEGORY_ID == category.id)

                try db.run(filteredOrderedCategories.delete())

                clearSelectedCategory()
                queryTableCategory()
                updateViews()

            }
            
        } catch {
            
            print(error)
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let category = SuperGlobals.categoryList[indexPath.row]
        
        SuperGlobals.selectedCategoryId = category.id
        SuperGlobals.selectedCategoryName = category.categoryName
        
        navigationController?.popViewController(animated: true)
        
    }
    
    
}
