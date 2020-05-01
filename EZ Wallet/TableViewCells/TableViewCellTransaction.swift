//
//  TableViewCellTransaction.swift
//  EZ Wallet
//
//  Created by Jeofferson Dela Peña on 3/18/20.
//  Copyright © 2020 Jeofferson Dela Peña. All rights reserved.
//

import UIKit

class TableViewCellTransaction: UITableViewCell {
    
    
    @IBOutlet weak var lblId: UILabel!
    
    @IBOutlet weak var lblFrom: UILabel!
    @IBOutlet weak var lblAmountFromPayment: UILabel!
    @IBOutlet weak var lblAmountFromInterest: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblBorrowEventId: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
