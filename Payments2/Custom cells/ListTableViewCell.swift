//
//  ListTableViewCell.swift
//  Payments2
//
//  Created by Evgeny Turchaninov on 09.01.2020.
//  Copyright © 2020 Evgeny Turchaninov. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    var checkButtonFunction: (() -> Void)?

    @IBOutlet weak var checkView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    
    @IBAction func checkBtnAction(_ sender: Any) {
        if let checkTap = checkButtonFunction {
            checkTap()
        }

    }
}
