//
//  VcEditBorrowEvent.swift
//  EZ Wallet
//
//  Created by Jeofferson Dela Peña on 3/23/20.
//  Copyright © 2020 Jeofferson Dela Peña. All rights reserved.
//

import UIKit
import SQLite


class VcEditBorrowEvent: UIViewController {
    
    
    var id = Int()
    
    var borrowerFirstName = String()
    var borrowerLastName = String()
    var borrowerGender = String()
    var isMale = Bool()
    var amountPrincipal = Double()
    var interestRate = Double()
    var isWithInterest = Bool()
    
    var db: Connection!
    
    @IBOutlet weak var imgBorrowerIcon: UIImageView!
    @IBOutlet weak var txtBorrowerFirstName: UITextField!
    @IBOutlet weak var txtBorrowerLastName: UITextField!
    @IBOutlet weak var btnMaleOutlet: UIButton!
    @IBOutlet weak var btnFemaleOutlet: UIButton!
    @IBOutlet weak var txtAmountPrincipal: UITextField!
    @IBOutlet weak var txtInterestRate: UITextField!
    @IBOutlet weak var lblErrorMessage: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        id = SuperGlobals.selectedBorrowEventId
        
        borrowerFirstName = SuperGlobals.selectedBorrowerFirstName
        borrowerLastName = SuperGlobals.selectedBorrowerLastName
        borrowerGender = SuperGlobals.selectedBorrowerGender
        isMale = borrowerGender == "Male"
        amountPrincipal = SuperGlobals.selectedAmountPrincipal
        interestRate = SuperGlobals.selectedInterestRate
        isWithInterest = interestRate != 0
        
        prepareDb()
        
        updateViews()
        
    }
    
    
    @IBAction func btnMale(_ sender: UIButton) {
        
        turnBorrowerGender(state: 1)
        
    }
    
    
    @IBAction func btnFemale(_ sender: UIButton) {
        
        turnBorrowerGender(state: 0)
        
    }
    
    
    func turnBorrowerGender(state: Int) {
        
        switch state {
            
        case 0:
            borrowerGender = "Female"
            
            imgBorrowerIcon.image = UIImage(named: Constants.FEMALE_DEFAULT_ICON_FILENAME)
            
            btnMaleOutlet.isSelected = false
            btnFemaleOutlet.isSelected = true
            
        case 1:
            borrowerGender = "Male"
            
            imgBorrowerIcon.image = UIImage(named: Constants.MALE_DEFAULT_ICON_FILENAME)
            
            btnMaleOutlet.isSelected = true
            btnFemaleOutlet.isSelected = false
            
        default:
            break
            
        }
        
    }
    
    
    @IBAction func btnEditBorrowEvent(_ sender: UIBarButtonItem) {
        
        editBorrowEvent()
        
    }
    
    
    func editBorrowEvent() {
        
        do {
            
            borrowerFirstName = txtBorrowerFirstName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            borrowerLastName = txtBorrowerLastName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let amountPrincipalString = txtAmountPrincipal.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "0.00" : txtAmountPrincipal.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            var interestRateString = String()
            
            if isWithInterest {
                
                interestRateString = txtInterestRate.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "0.00" : txtInterestRate.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                
            }
            
            if borrowerFirstName.isEmpty || borrowerLastName.isEmpty {
                
                showErrorMessage(message: "Please fill out the fields.")
                return
                
            }
            
            guard let amountPrincipal = Double(amountPrincipalString) else {
                
                showErrorMessage(message: "Please enter numeric characters.")
                return
                
            }
            
            if amountPrincipal <= 0 {
                
                showErrorMessage(message: "Please enter a valid amount.")
                return
                
            }
            
            if isWithInterest {
                
                guard let interestRateTemp = Double(interestRateString) else {
                    
                    showErrorMessage(message: "Please enter numeric characters.")
                    return
                    
                }
                
                interestRate = interestRateTemp
                
                if interestRate <= 0 || interestRate > 100 {
                    
                    showErrorMessage(message: "Please enter a valid interest rate.")
                    return
                    
                }
                
            }
            
            hideErrorMessage()
            
            let filteredOrderedBorrowEvents = ConstantsSqlite.TABLE_BORROW_EVENT
                .filter(ConstantsSqlite.BORROW_EVENT_ID == id)
            
            if !isWithInterest {
                
                try db.run(filteredOrderedBorrowEvents.update(
                    ConstantsSqlite.BORROW_EVENT_BORROWER_FIRST_NAME <- borrowerFirstName,
                    ConstantsSqlite.BORROW_EVENT_BORROWER_LAST_NAME <- borrowerLastName,
                    ConstantsSqlite.BORROW_EVENT_BORROWER_GENDER <- borrowerGender,
                    ConstantsSqlite.BORROW_EVENT_AMOUNT_PRINCIPAL <- amountPrincipal
                ))
                
            } else {
                
                try db.run(filteredOrderedBorrowEvents.update(
                    ConstantsSqlite.BORROW_EVENT_BORROWER_FIRST_NAME <- borrowerFirstName,
                    ConstantsSqlite.BORROW_EVENT_BORROWER_LAST_NAME <- borrowerLastName,
                    ConstantsSqlite.BORROW_EVENT_BORROWER_GENDER <- borrowerGender,
                    ConstantsSqlite.BORROW_EVENT_AMOUNT_PRINCIPAL <- amountPrincipal,
                    ConstantsSqlite.BORROW_EVENT_INTEREST_RATE <- interestRate
                ))
                
                let newGainedFromInterest = amountPrincipal * (interestRate * 0.01)
                
                let filteredOrderedTransactions = ConstantsSqlite.TABLE_TRANSACTION
                    .filter(ConstantsSqlite.TRANSACTION_BORROW_EVENT_ID == id)
                    .filter(ConstantsSqlite.TRANSACTION_FROM == "Interest")
                    
                try db.run(filteredOrderedTransactions.update(
                    ConstantsSqlite.TRANSACTION_AMOUNT <- newGainedFromInterest
                ))
                
                SuperGlobals.selectedGainedFromInterest = newGainedFromInterest
                
            }
            
            SuperGlobals.selectedBorrowerFirstName = borrowerFirstName
            SuperGlobals.selectedBorrowerLastName = borrowerLastName
            SuperGlobals.selectedBorrowerGender = borrowerGender
            SuperGlobals.selectedAmountPrincipal = amountPrincipal
            
            if isWithInterest {
                
                SuperGlobals.selectedInterestRate = interestRate
                
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
        
        imgBorrowerIcon.image = isMale ? UIImage(named: Constants.MALE_DEFAULT_ICON_FILENAME) : UIImage(named: Constants.FEMALE_DEFAULT_ICON_FILENAME)
        txtBorrowerFirstName.text = borrowerFirstName
        txtBorrowerLastName.text = borrowerLastName
        
        if isMale {
            
            btnMaleOutlet.isSelected = true
            btnFemaleOutlet.isSelected = false
            
        } else {
            
            btnMaleOutlet.isSelected = false
            btnFemaleOutlet.isSelected = true
            
        }
        
        txtAmountPrincipal.text = String(amountPrincipal)
        
        if !isWithInterest {
            
            txtInterestRate.isEnabled = false
            txtInterestRate.placeholder = "N/A"
            
        } else {
            
            txtInterestRate.isEnabled = true
            txtInterestRate.text = String(interestRate)
            
        }
        
    }
    
    
    func showErrorMessage(message: String) {
        
        lblErrorMessage.text = message
        lblErrorMessage.isHidden = false
        
    }
    
    
    func hideErrorMessage() {
        
        lblErrorMessage.isHidden = true
        
    }
    

}
