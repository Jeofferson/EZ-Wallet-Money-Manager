//
//  TableViewCellMonth.swift
//  EZ Wallet
//
//  Created by Jeofferson Dela Peña on 3/16/20.
//  Copyright © 2020 Jeofferson Dela Peña. All rights reserved.
//

import UIKit
import Charts


class TableViewCellMonth: UITableViewCell {

    
    var index: Int!
    var month: Month!
    
    @IBOutlet weak var lblId: UILabel!
    
    @IBOutlet weak var lblMonthName: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var lblStartingBalance: UILabel!
    @IBOutlet weak var lblExpenses: UILabel!
    @IBOutlet weak var lblSavings: UILabel!
    
    @IBOutlet weak var pieChartSpending: PieChartView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func setMonth(index: Int, month: Month) {
        
        self.index = index
        self.month = month
        
    }
    

}
