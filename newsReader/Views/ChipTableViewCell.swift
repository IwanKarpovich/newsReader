//
//  ChipTableViewCell.swift
//  newsReader
//
//  Created by Ivan Karpovich on 27.01.22.
//

import UIKit

class ChipTableViewCell: UITableViewCell {

    @IBOutlet weak var messageBackgroundView: UIView!
    @IBOutlet weak var chipLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        chipLabel.layer.masksToBounds = true
        chipLabel.layer.cornerRadius = 8

        chipLabel.backgroundColor = .systemGray
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
