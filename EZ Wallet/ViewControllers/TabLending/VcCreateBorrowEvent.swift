//
//  VcCreateBorrowEvent.swift
//  EZ Wallet
//
//  Created by Jeofferson Dela Peña on 3/19/20.
//  Copyright © 2020 Jeofferson Dela Peña. All rights reserved.
//

import UIKit
import SQLite


class VcCreateBorrowEvent: UIViewController {
    
    
    var currentYear = Int()
    var currentMonth = Int()
    var currentDay = Int()
    var currentHour = Int()
    var currentMinute = Int()
    var currentSecond = Int()
    
    var borrowerGender = String()
    var interestRate = Double()
    
    var db: Connection!
    
    @IBOutlet weak var imgBorrowerIcon: UIImageView!
    @IBOutlet weak var txtBorrowerFirstName: UITextField!
    @IBOutlet weak var txtBorrowerLastName: UITextField!
    @IBOutlet weak var btnMaleOutlet: UIButton!
    @IBOutlet weak var btnFemaleOutlet: UIButton!
    @IBOutlet weak var txtAmountPrincipal: UITextField!
    
    @IBOutlet weak var switchWithInterestOutlet: UISwitch!
    @IBOutlet weak var txtInterestRate: UITextField!
    @IBOutlet weak var btnAmortizationScheduleOutlet: UIButton!
    @IBOutlet var btnAmortizationScheduleOptionOutletCollection: [UIButton]!
    @IBOutlet weak var lblErrorMessage: UILabel!
    
    
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
    
    
    @IBAction func switchWithInterest(_ sender: UISwitch) {
        
        toggleWithInterest(sender: sender)
        
    }
    
    
    func toggleWithInterest(sender: UISwitch) {
            
        txtInterestRate.isEnabled = sender.isOn
        btnAmortizationScheduleOutlet.isEnabled = sender.isOn
            
        if !sender.isOn {
            
            turnAmortizationScheduleOptions(state: 1)
            
        }
        
    }
    
    
    @IBAction func btnAmortizationSchedule(_ sender: UIButton) {
        
        turnAmortizationScheduleOptions(state: 2)
        
    }
    
    
    func turnAmortizationScheduleOptions(state: Int) {
        
        hideErrorMessage()
        
        for i in 0 ..< self.btnAmortizationScheduleOptionOutletCollection.count {
            
            UIView.animate(withDuration: 0.3, animations: {
                
                switch state {
                    
                case 0:
                    if self.btnAmortizationScheduleOptionOutletCollection[i].isHidden == true {
                        
                        self.btnAmortizationScheduleOptionOutletCollection[i].isHidden = false
                        
                    }
                    
                case 1:
                    if self.btnAmortizationScheduleOptionOutletCollection[i].isHidden == false {
                        
                        self.btnAmortizationScheduleOptionOutletCollection[i].isHidden = true
                        
                    }
                    
                case 2:
                    self.btnAmortizationScheduleOptionOutletCollection[i].isHidden = !self.btnAmortizationScheduleOptionOutletCollection[i].isHidden
                    
                default:
                    break
                    
                }
                
                self.view.layoutIfNeeded()
                
            })
            
        }
        
    }
    
    
    @IBAction func btnAmortizationScheduleOption(_ sender: UIButton) {
        
        selectAmortizationScheduleOption(sender)
        
    }
    
    
    func selectAmortizationScheduleOption(_ sender: UIButton) {
        
        btnAmortizationScheduleOutlet.setTitle(sender.titleLabel?.text!, for: .normal)
        
        turnAmortizationScheduleOptions(state: 1)
        
    }
    
    
    @IBAction func btnCreateBorrowEvent(_ sender: UIBarButtonItem) {
        
        createBorrowEvent()
        
    }
    
    
    func createBorrowEvent() {
        
        do {
            
            turnAmortizationScheduleOptions(state: 1)
            
            let borrowerFirstName = txtBorrowerFirstName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let borrowerLastName = txtBorrowerLastName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let amountPrincipalString = txtAmountPrincipal.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "0.00" : txtAmountPrincipal.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            var interestRateString = String()
            var amortizationSchedule = String()
            
            if !switchWithInterestOutlet.isOn {
                
                interestRateString = "0.0"
                amortizationSchedule = "N/A"
                
            } else {
                
                interestRateString = txtInterestRate.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "0.00" : txtInterestRate.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                amortizationSchedule = btnAmortizationScheduleOutlet.currentTitle!.trimmingCharacters(in: .whitespacesAndNewlines)
                
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
            
            if !switchWithInterestOutlet.isOn {
                
                interestRate = Double(interestRateString)!
                
            } else {
                
                guard let interestRateTemp = Double(interestRateString) else {
                    
                    showErrorMessage(message: "Please enter numeric characters.")
                    return
                    
                }
                
                interestRate = interestRateTemp
                
                if interestRate <= 0 || interestRate > 100 {
                    
                    showErrorMessage(message: "Please enter a valid interest rate.")
                    return
                    
                }
                
                if amortizationSchedule == "Select" {
                    
                    showErrorMessage(message: "Please choose the amortization schedule.")
                    return
                    
                }
                
            }
            
            hideErrorMessage()
            
            let insertBorrowEvent = ConstantsSqlite.TABLE_BORROW_EVENT.insert(
                ConstantsSqlite.BORROW_EVENT_IS_PAID <- false,
                ConstantsSqlite.BORROW_EVENT_BORROWER_FIRST_NAME <- borrowerFirstName,
                ConstantsSqlite.BORROW_EVENT_BORROWER_LAST_NAME <- borrowerLastName,
                ConstantsSqlite.BORROW_EVENT_BORROWER_GENDER <- borrowerGender,
                ConstantsSqlite.BORROW_EVENT_AMOUNT_PRINCIPAL <- amountPrincipal,
                ConstantsSqlite.BORROW_EVENT_INTEREST_RATE <- interestRate,
                ConstantsSqlite.BORROW_EVENT_AMORTIZATION_SCHEDULE <- amortizationSchedule,
                ConstantsSqlite.BORROW_EVENT_START_YEAR <- currentYear,
                ConstantsSqlite.BORROW_EVENT_START_MONTH <- currentMonth,
                ConstantsSqlite.BORROW_EVENT_START_DAY <- currentDay,
                ConstantsSqlite.BORROW_EVENT_START_HOUR <- currentHour,
                ConstantsSqlite.BORROW_EVENT_START_MINUTE <- currentMonth,
                ConstantsSqlite.BORROW_EVENT_START_SECOND <- currentSecond
            )
            
            try db.run(insertBorrowEvent)
            
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
        
        borrowerGender = "Male"
        
        imgBorrowerIcon.image = UIImage(named: Constants.MALE_DEFAULT_ICON_FILENAME)
        btnMaleOutlet.isSelected = true
        btnFemaleOutlet.isSelected = false
        
    }
    
    
    func showErrorMessage(message: String) {
        
        lblErrorMessage.text = message
        lblErrorMessage.isHidden = false
        
    }
    
    
    func hideErrorMessage() {
        
        lblErrorMessage.isHidden = true
        
    }
    
    
}
