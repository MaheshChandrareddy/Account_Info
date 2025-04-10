//
//  AccountCell.swift
//  IdentityVault
//
//  Created by Mahesh Chandrareddy on 09/04/25.
//

import UIKit

class AccountCell: UITableViewCell {

    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var accountIdLabel: UILabel!
    @IBOutlet weak var alternateAccountNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
