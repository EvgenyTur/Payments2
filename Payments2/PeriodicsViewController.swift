//
//  PeriodicsViewController.swift
//  Payments2
//
//  Created by Evgeny Turchaninov on 12.01.2020.
//  Copyright © 2020 Evgeny Turchaninov. All rights reserved.
//

import UIKit
protocol SetPeriodicDateDelegate {
    func setPeriodicDate(period: Int, day: Int)
}

class PeriodicsViewController: UIViewController {
    
    var delegate: SetPeriodicDateDelegate?
    
    @IBOutlet weak var periodSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var monthsLabel: UILabel!
    
    @IBOutlet var monthButtons: [UIButton]!
    
    
    
    
    @IBOutlet weak var daysLabel: UILabel!
    
    @IBOutlet var dates: [UIButton]!
    
    
    
    let buttonColor = UIColor(named: "mainColor")

    var periodicDay = 0
    var datePeriod = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("choose_periodic_type", comment: "")
        
        periodSegmentedControl.setTitle(NSLocalizedString("monthly", comment: ""), forSegmentAt: 0)
        periodSegmentedControl.setTitle(NSLocalizedString("quartely", comment: ""), forSegmentAt: 1)
        periodSegmentedControl.setTitle(NSLocalizedString("annually", comment: ""), forSegmentAt: 2)

        for button in monthButtons {
            button.backgroundColor = buttonColor
            button.tintColor = .white
        }
        datePeriod = 30
        
        
    }
    
    @IBAction func periodSegmentChanged(_ sender: UISegmentedControl) {

        switch sender.selectedSegmentIndex {
        case 0:
            for button in monthButtons {
                button.backgroundColor = buttonColor
                button.tintColor = .white
            }
            datePeriod = 30
        case 1:
            resetMonthButtons()
            datePeriod = 90
        case 2:
            resetMonthButtons()
            datePeriod = 360
        default:
            print("wrong coice")
        }
        
    }
    
    @IBAction func monthBtnAction(_ sender: UIButton) {
        if periodSegmentedControl.selectedSegmentIndex > 0 {
            resetMonthButtons()
            sender.backgroundColor = buttonColor
            sender.setTitleColor(.white, for: .normal)
            if periodSegmentedControl.selectedSegmentIndex == 1 {
                datePeriod = 90 + sender.tag
                // 1 - 4 7 10 -> 91
                // 2 - 5 8 11 -> 92
                // 3 - 6 9 12 -> 93
                // 4 - 7 10 1
                for button in monthButtons {
                    var tag = (sender.tag - button.tag)
                    if tag < 0 {
                        tag = -1 * tag
                    }
                    print("tag: \(tag)")
                    if tag == 0 || tag == 3 || tag == 6 || tag == 9 {
                        button.backgroundColor = buttonColor
                        button.setTitleColor(.white, for: .normal)
                    }
                }
            }
        }
        
        if periodicDay > 0 {
            delegate?.setPeriodicDate(period: datePeriod, day: periodicDay)
        }
    }

    // MARK: - Dates processor
    @IBAction func dateBtnAction(_ sender: UIButton) {
        if #available(iOS 13.0, *) {
            for button in dates {
                button.backgroundColor = .systemBackground
                button.setTitleColor(UIColor(named: "dateFontColor"), for: .normal)
            }
        } else {
            for button in dates {
                button.backgroundColor = .white
                button.setTitleColor(UIColor(named: "dateFontColor"), for: .normal)
            }
        }

        sender.backgroundColor = buttonColor
        sender.setTitleColor(.white, for: .normal)
        
        periodicDay = sender.tag - 30
        delegate?.setPeriodicDate(period: datePeriod, day: periodicDay)
    }

    
    private func resetMonthButtons() {
        if #available(iOS 13.0, *) {
            for button in monthButtons {
                button.backgroundColor = .systemBackground
                button.setTitleColor(UIColor(named: "dateFontColor"), for: .normal)
            }
        } else {
            for button in monthButtons {
                button.backgroundColor = .white
                button.setTitleColor(UIColor(named: "dateFontColor"), for: .normal)
            }
        }

//        for button in monthButtons {
//            button.backgroundColor = UIColor(named: "brightColor")
//            button.tintColor = .black
//        }

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
