//
//  BadTableViewCell.swift
//  newsReader
//
//  Created by Ivan Karpovich on 28.01.22.
//

import UIKit

class BadTableViewCell: UITableViewCell {

    @IBOutlet weak var textBadeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
