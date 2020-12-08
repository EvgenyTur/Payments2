//
//  SetTimeViewController.swift
//  Payments2
//
//  Created by Evgeny Turchaninov on 09.01.2020.
//  Copyright © 2020 Evgeny Turchaninov. All rights reserved.
//

import UIKit

protocol TimeSetup {
    func setupTime()
}
class SetTimeViewController: UIViewController {

    var delegate: TimeSetup?
    
    @IBOutlet weak var timePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("reminder_time", comment: "")
//        timePicker.datePickerMode = .time
        timePicker.date = UserDefaults.standard.object(forKey: "RemindTime") as? Date ?? Date()
    }

    @IBAction func timePickerChanged(_ sender: Any) {
        UserDefaults.standard.set(timePicker.date, forKey: "RemindTime")
        delegate?.setupTime()
    }
}
