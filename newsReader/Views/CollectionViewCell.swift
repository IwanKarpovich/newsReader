//
//  CollectionViewCell.swift
//  newsReader
//
//  Created by Ivan Karpovich on 27.01.22.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var textLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textLabel.layer.masksToBounds = true
        textLabel.layer.cornerRadius = 14
        textLabel.layer.borderColor = UIColor.lightGray.cgColor
        textLabel.layer.borderWidth = 1.0
        
        //textLabel.backgroundColor = .systemGray
        // Initialization code
    }

}
