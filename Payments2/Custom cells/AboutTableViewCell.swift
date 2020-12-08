//
//  AboutTableViewCell.swift
//  Payments2
//
//  Created by Evgeny Turchaninov on 10.01.2020.
//  Copyright © 2020 Evgeny Turchaninov. All rights reserved.
//

import UIKit

class AboutTableViewCell: UITableViewCell {
    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
