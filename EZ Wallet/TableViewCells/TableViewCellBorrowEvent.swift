//
//  TableViewCellBorrowEvent.swift
//  EZ Wallet
//
//  Created by Jeofferson Dela Peña on 3/18/20.
//  Copyright © 2020 Jeofferson Dela Peña. All rights reserved.
//

import UIKit
import Charts


class TableViewCellBorrowEvent: UITableViewCell {
    
    
    @IBOutlet weak var lblId: UILabel!
    
    @IBOutlet weak var imgBorrowerIcon: UIImageView!
    @IBOutlet weak var lblIsPaid: UILabel!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblAmountPrincipal: UILabel!
    @IBOutlet weak var lblAmountRemaining: UILabel!
    @IBOutlet weak var lblInterestRate: UILabel!
    @IBOutlet weak var lblAmortizationSchedule: UILabel!
    @IBOutlet weak var lblGainedFromInterest: UILabel!
    
    @IBOutlet weak var lblAmountRemainingLabel: UILabel!
    
    @IBOutlet weak var imgLblPaidBg: UIImageView!
    @IBOutlet weak var lblPaid: UILabel!
    
    @IBOutlet weak var pieChartLending: PieChartView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
}
