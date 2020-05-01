//
//  TableViewCellCategory.swift
//  EZ Wallet
//
//  Created by Jeofferson Dela Peña on 3/17/20.
//  Copyright © 2020 Jeofferson Dela Peña. All rights reserved.
//

import UIKit


class TableViewCellCategory: UITableViewCell {

    
    var index: Int!
    var category: Category!
    
    @IBOutlet weak var lblId: UILabel!
    @IBOutlet weak var lblCategoryName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}
