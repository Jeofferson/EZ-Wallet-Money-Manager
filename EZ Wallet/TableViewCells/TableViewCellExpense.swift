//
//  TableViewCellExpense.swift
//  EZ Wallet
//
//  Created by Jeofferson Dela Peña on 3/17/20.
//  Copyright © 2020 Jeofferson Dela Peña. All rights reserved.
//

import UIKit


class TableViewCellExpense: UITableViewCell {
    

    var index: Int!
    var expense: Expense!
    
    @IBOutlet weak var lblId: UILabel!
    
    @IBOutlet weak var lblCategoryName: UILabel!
    @IBOutlet weak var lblAmountActualExpense: UILabel!
    @IBOutlet weak var lblAmountPlannedBudget: UILabel!
    @IBOutlet weak var lblMonthId: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}
