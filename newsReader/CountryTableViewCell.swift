//
//  CountryTableViewCell.swift
//  newsReader
//
//  Created by Ivan Karpovich on 13.01.22.
//

import UIKit

class CountryTableViewCell: UITableViewCell {

    @IBOutlet weak var textCountry: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        super.prepareForReuse()

        textCountry?.text = nil
    }
    
}
